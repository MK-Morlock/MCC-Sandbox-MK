params [["_veh", objNull, [objNull]], ["_secs", 360, [0]], ["_label", "Support", [""]], ["_side", west, [west]], ["_icon", "", [""]], ["_empty", {false}, [{}]], ["_onEnd", {}, [{}]]];
if (isNull _veh) exitWith {};
private _t0 = time;
private _warned = false;
private _emptySince = -1;
waitUntil {
	sleep 1;
	if (!alive _veh || {_veh getVariable ["MCC_supportDone", false]}) exitWith {true};
	private _left = _secs - (time - _t0);
	if (!_warned && {_left <= 60}) then {
		_warned = true;
		[_veh, "warn", _label, "Leaving in 60 seconds", _icon, _side] call MCC_fnc_supportNotice;
	};
	if (_veh call _empty) then {if (_emptySince < 0) then {_emptySince = time}} else {_emptySince = -1};
	_left <= 0 || {_emptySince >= 0 && {time - _emptySince >= 30}}
};
if (!alive _veh || {_veh getVariable ["MCC_supportDone", false]}) exitWith {};
_veh setVariable ["MCC_supportDone", true, true];
["DEBUG", "support", "%1 (%2) leaves: %3", [_label, typeOf _veh, ["time is up", "out of ammunition"] select (_emptySince >= 0 && {time - _emptySince >= 30})]] call MCC_fnc_log;
private _uc = UAVControl _veh;
for "_i" from 0 to (count _uc - 1) step 2 do {
	private _c = _uc select _i;
	if (!isNull _c && {isPlayer _c}) then {
		[2, {player action ["BackFromUAV", player]; player connectTerminalToUAV objNull; player switchCamera "INTERNAL"}] remoteExec ["MCC_fnc_globalExecute", _c];
	};
};
_veh call _onEnd;
sleep 1;
if (alive _veh) then {[group driver _veh, driver _veh, _veh, [_veh, 3000, random 360] call BIS_fnc_relPos] call MCC_fnc_deletePlane};
[_veh, "leave", _label, "Left the scene", _icon, _side] call MCC_fnc_supportNotice;
