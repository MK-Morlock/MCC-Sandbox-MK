/*======================================================MCC_fnc_parseSetting=================================================================================
	Safely turn an MCC CBA "EDITBOX" setting (text such as '["B_officer_F","O_officer_F"]') into a value.

	The old handlers did `call compile _value` directly. Any malformed text (hand-edited setting,
	corrupted profile, a value written by another mod) threw an engine "Error in expression"
	with no hint of which setting it was. This checks the text is a single well-formed array
	[...] or string "..." (brackets balanced outside quotes) before compiling it. If it is not,
	the setting's default is used and the setting name is written to the RPT.

	<IN>
		0	STRING	value from CBA
		1	STRING	default text (the setting's default)
		2	STRING	setting name (for the RPT)

	<OUT> the compiled value (ARRAY or STRING)
//==========================================================================================================================================*/

params [["_value", "", [""]], ["_default", "[]", [""]], ["_name", "?", [""]]];

private _fnc_wellFormed = {
	params ["_text"];
	private _chars = toArray _text;
	private _solid = _chars select {!(_x in [32, 9, 10, 13])};
	if (_solid isEqualTo []) exitWith {false};
	private _first = _solid select 0;
	private _last = _solid select (count _solid - 1);
	// must be one array [...] or one string "..." / '...'
	if !((_first == 91 && _last == 93) || (_first == 34 && _last == 34) || (_first == 39 && _last == 39)) exitWith {false};

	private _depth = 0;
	private _quote = -1;	// -1 = not inside a string, otherwise the quote char code
	private _ok = true;
	private _closedTop = false;
	{
		if (_quote >= 0) then {
			if (_x == _quote) then {_quote = -1};	// doubled quotes simply reopen on the next char
		} else {
			switch (true) do {
				case (_closedTop && {!(_x in [32, 9, 10, 13])}): {_ok = false};	// text after the outer ]
				case (_x == 34 || _x == 39): {_quote = _x};
				case (_x == 91 || _x == 40 || _x == 123): {_depth = _depth + 1};
				case (_x == 93 || _x == 41 || _x == 125): {
					_depth = _depth - 1;
					if (_depth < 0) then {_ok = false};
					if (_depth == 0 && {_first == 91}) then {_closedTop = true};
				};
			};
		};
		if (!_ok) exitWith {};
	} forEach _chars;
	_ok && {_quote < 0} && {_depth == 0}
};

if ([_value] call _fnc_wellFormed) exitWith {call compile _value};

["WARN", "fn_parseSetting", "CBA setting %1 has an invalid value %2 - using the default", [_name, str _value]] call MCC_fnc_log;
call compile _default
