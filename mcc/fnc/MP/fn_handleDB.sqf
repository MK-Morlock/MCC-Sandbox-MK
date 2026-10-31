/*============================================================MCC_fnc_handleDB=============================================================================================
	read/write a single value to/from persistent storage.
	Backend is extDB3 (MySQL/MariaDB) when available (MCC_iniDBenabled == true, set by MCC_fnc_initExtDB3),
	otherwise falls back to profileNamespace - same as before, only the DB-enabled branch changed.

	This keeps the ORIGINAL calling contract so every other script that calls MCC_fnc_handleDB is untouched.

<IN>
	0:	STRING DB name (kept for compatibility; with extDB3 all values live in one table, so this
		becomes part of the row key rather than selecting a separate database/file)
	1:	STRING section name
	2:	STRING variable name
	3:	STRING "read"/"write"
	4:	ANY default return value (read) or new value (write)
	5:	ignored with extDB3 - kept for backward-compatible call signatures, was the "create new DB" flag
============================================================================================================================================================*/

params [
	["_dbName", "", [""]],
	["_section", "", [""]],
	["_var", "", [""]],
	["_read", "read", [""]],
	["_value", "", ["", true, [], 0]],
	["_newDB", false, ["", true]]
];

_read = toLower _read;

// ---- No extDB3 available: fall back to profileNamespace, exactly as the original did ----
if !(missionNamespace getVariable ["MCC_iniDBenabled", false]) exitWith {
	if (_read == "read") then {
		_value = profileNamespace getVariable [format ["%1_%2_%3", _dbName, _section, _var], _value];
	} else {
		profileNamespace setVariable [format ["%1_%2_%3", _dbName, _section, _var], _value];
		//MCC_fnc_saveServer writes many values per save and saves the profile once at the end
		if !(missionNamespace getVariable ["MCC_dbDeferSave", false]) then {saveProfileNamespace};
	};
	_value
};

// ---- extDB3 branch ----
private _session = missionNamespace getVariable ["MCC_extDB3Session", "mcc_campaign"];

// Basic SQL string escaping - doubles single quotes. Fine here because the only thing ever
// interpolated into these queries is MCC's own key names and a serialised SQF value, never
// raw player-typed text, but escape it anyway rather than trust that assumption forever.
private _fnc_sqlEscape = {
	private _str = _this;
	private _out = "";
	for "_i" from 0 to ((count _str) - 1) do {
		private _ch = _str select [_i, 1];
		_out = _out + (if (_ch == "'") then {"''"} else {_ch});
	};
	_out
};

if (_read == "read") then {
	private _query = format [
		"SELECT value_data FROM mcc_persistent WHERE db_name='%1' AND section='%2' AND var_name='%3';",
		[_dbName] call _fnc_sqlEscape,
		[_section] call _fnc_sqlEscape,
		[_var] call _fnc_sqlEscape
	];

	private _raw = "extDB3" callExtension format ["0:%1:%2", _session, _query];

	if (MCC_debug) then {diag_log text format ["MCC_fnc_handleDB read raw: %1", _raw];};

	// extDB3's SQL protocol returns a stringified array on success. The exact nesting can differ
	// a little between extDB3 builds - if this ever comes back empty when you expect a value,
	// enable MCC_debug and check the RPT log line above against what your build actually sent,
	// then adjust the parsing below to match.
	private _parsed = parseSimpleArray _raw;

	private _storedString = "";
	if (_parsed isEqualType [] && {count _parsed > 0}) then {
		private _rows = _parsed param [1, []];
		if (_rows isEqualType [] && {count _rows > 0}) then {
			private _firstRow = _rows select 0;
			if (_firstRow isEqualType [] && {count _firstRow > 0}) then {
				_storedString = _firstRow select 0;
			};
		};
	};

	if (_storedString == "") exitWith {_value};

	// Values are stored as their SQF representation (str _value) so arrays/numbers/bools round-trip.
	// This is only ever fed by data MCC itself wrote, never external input.
	// try/catch is native SQF since Arma 3 v1.94 - catches an explicit `throw` reliably; whether it
	// also traps a malformed `compile` call depends on your game version, so this is a safety net,
	// not a guarantee. If you see "Error Generic error in expression" in the RPT instead of the
	// diag_log line below, the corrupt-data case slipped past the catch - worth a follow-up pass.
	private _decoded = _value;
	try {
		_decoded = call compile _storedString;
	} catch {
		if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC_fnc_handleDB: failed to decode stored value for %1/%2/%3 - returning default", _dbName, _section, _var]};
		_decoded = _value;
	};

	_decoded

} else {

	private _serialised = str _value;
	private _query = format [
		"INSERT INTO mcc_persistent (db_name, section, var_name, value_data) VALUES ('%1','%2','%3','%4') ON DUPLICATE KEY UPDATE value_data = VALUES(value_data);",
		[_dbName] call _fnc_sqlEscape,
		[_section] call _fnc_sqlEscape,
		[_var] call _fnc_sqlEscape,
		[_serialised] call _fnc_sqlEscape
	];

	// Mode "1" = fire and forget, no return value needed for a write
	"extDB3" callExtension format ["1:%1:%2", _session, _query];

	_value
};
