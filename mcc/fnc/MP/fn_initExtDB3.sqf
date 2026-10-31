/*========================================================MCC_fnc_initExtDB3=============================================================
	Detect and initialise the extDB3 connection used for persistent campaign data.
	Replaces the old OO_INIDBI / inidbi2 bootstrap block. Run ONCE, server only, from init.sqf,
	before anything calls MCC_fnc_handleDB.

	extDB3: https://github.com/SteezCram/extDB3
	Requires:
		@extdb3 on the server's root folder (next to arma3server.exe / the Linux binary)
		userconfig\extdb3\extdb3-conf.ini      (see extdb3-conf.ini sample shipped alongside this file)
		userconfig\extdb3\sql_custom.ini       (not used here - we talk raw SQL over the SQL protocol)
		A MySQL/MariaDB server + the schema in mcc_persistent_schema.sql applied to it

	<OUT>
		BOOLEAN - true if extDB3 loaded and the database connection + protocol are ready
//==========================================================================================================================================*/

if (!isServer) exitWith {false};

// Config: must match the section name in extdb3-conf.ini and is also used as extDB3's protocol/session name.
private _dbConfigSection = "mcc_campaign";
private _sessionName = "mcc_campaign";

// MCC_iniDBenabled is kept as the flag name for backward compatibility - every other script in MCC only
// checks "is a DB backend available", it never cared which backend. This just changes what backs it.
MCC_iniDBenabled = false;
MCC_extDB3Session = _sessionName;

// Detect the extension. If @extdb3 isn't loaded, callExtension returns "" or a BattlEye-block style string
// instead of a version number, so we sanity check the result rather than trust that the call didn't error.
private _versionRaw = "extDB3" callExtension "9:VERSION";
private _extDB3Present = (_versionRaw isEqualType "") && {_versionRaw != ""} && {(_versionRaw select [0,1]) in ["0","1","2","3","4","5","6","7","8","9"]};

if (!_extDB3Present) exitWith {
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC_fnc_initExtDB3: extDB3 not detected (got: %1) - falling back to profileNamespace persistence.", _versionRaw]};
	MCC_iniDBenabled = false;
	publicVariable "MCC_iniDBenabled";
	false
};

if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC_fnc_initExtDB3: extDB3 version %1 detected.", _versionRaw]};

// Connect to the database section defined in extdb3-conf.ini
private _connectResult = "extDB3" callExtension format ["9:ADD_DATABASE:%1", _dbConfigSection];
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC_fnc_initExtDB3: ADD_DATABASE result: %1", _connectResult]};

// Register the SQL protocol under our session name (empty escape char = use extDB3's default escaping)
private _protocolResult = "extDB3" callExtension format ["9:ADD_DATABASE_PROTOCOL:%1:SQL:%2:", _dbConfigSection, _sessionName];
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC_fnc_initExtDB3: ADD_DATABASE_PROTOCOL result: %1", _protocolResult]};

// Make sure the table exists - safe to run every mission start, it's IF NOT EXISTS
private _createTableSQL = "CREATE TABLE IF NOT EXISTS mcc_persistent (db_name VARCHAR(191) NOT NULL, section VARCHAR(191) NOT NULL, var_name VARCHAR(191) NOT NULL, value_data MEDIUMTEXT, PRIMARY KEY (db_name, section, var_name)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
private _createResult = "extDB3" callExtension format ["1:%1:%2", _sessionName, _createTableSQL];
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC_fnc_initExtDB3: CREATE TABLE result: %1", _createResult]};

MCC_iniDBenabled = true;
publicVariable "MCC_iniDBenabled";

true
