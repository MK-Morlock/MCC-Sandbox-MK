params [["_v", objNull, [objNull]]];
private _p = [_v] call MCCMK_Taru_fnc_ASL_Nacelle;
if (isNull _p) exitWith {};
_v setVariable ["MCCMK_Info_Taru", "Arrimage", true];
private _all = [];
{if (_x isEqualType []) then {_all append _x} else {_all pushBack _x}} forEach (_v getVariable ["ASL_Ropes", []]);
_all = _all select {!isNull _x};
private _sp = 0;
private _t = time + 60;
waitUntil {
	_sp = (_sp + 0.3) min 5;
	{if (!isNull _x) then {ropeUnwind [_x, _sp, 1]}} forEach _all;
	sleep 0.3;
	!alive _v || {!alive _p} || {time > _t} || {({!isNull _x} count _all) == 0} || {((_all select {!isNull _x}) findIf {ropeLength _x > 1.3}) < 0}
};
if (!alive _v || {!alive _p} || {!(_p in (ropeAttachedObjects _v))}) exitWith {_v setVariable ["MCCMK_Info_Taru", "", true]};
{if (!isNull _x) then {ropeDestroy _x}} forEach _all;
_v setVariable ["ASL_Ropes", nil, true];
_v enableRopeAttach true;
_p enableRopeAttach true;
private _ok = _v setSlingLoad _p;
_v setVariable ["MCCMK_Info_Taru", "", true];
if (_ok) then {
	[_v] call MCCMK_Taru_fnc_Action_Arrimage;
} else {
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC MK Taru Pod Mod: %1 would not take the pod (%2) from the ASL ropes on its sling", typeOf _v, typeOf _p]};
};
