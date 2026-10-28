params [["_hide", false, [false]]];
if (!hasInterface) exitWith {};
MCCMK_missionStatusHidden = _hide;
private _fnc_set = {
	params ["_show"];
	private _d = uiNamespace getVariable ["RscMissionStatus", displayNull];
	if (!isNull _d) then {{_x ctrlShow _show} forEach (allControls _d)};
};
if (!_hide) exitWith {[true] call _fnc_set};
if (!isNil "MCCMK_missionStatusLoop" && {!scriptDone MCCMK_missionStatusLoop}) exitWith {};
MCCMK_missionStatusLoop = [_fnc_set] spawn {
	params ["_fnc_set"];
	while {missionNamespace getVariable ["MCCMK_missionStatusHidden", false]} do {
		[false] call _fnc_set;
		sleep 0.5;
	};
};
