params [["_key", 2, [0]]];
disableSerialization;
([_key] call MCC_fnc_consoleFKeyState) params ["_act", "_arg"];
switch (_act) do {
	case "connect": {
		if (_key == 2) then {MCC_ConolseUAV = _arg};
		[_key] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf", MCC_path];
	};
	case "select": {hint "Several UAVs available - right-click one on the map to select it"};
	case "none": {hint (([_key] call MCC_fnc_consoleFKeyState) select 2)};
	case "deploy": {
		if (isNull (findDisplay 2993)) then {
			[1] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf", MCC_path];
			private _t = time + 3;
			waitUntil {!isNull (findDisplay 2993) || {time > _t}};
			sleep 0.3;
		};
		private _d = findDisplay 2993;
		if (isNull _d) exitWith {};
		(_d displayCtrl 9100) lbSetCurSel _arg;
		sleep 0.1;
		MCCMK_callSource = format ["F%1 Deploy", _key];
		[1] execVM format ["%1mcc\general_scripts\console\console_request.sqf", MCC_path];
	};
};
