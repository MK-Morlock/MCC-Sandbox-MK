params [["_p", objNull, [objNull]], ["_t", [0, 0, 0], [[], objNull]]];
if (isNull _p) exitWith {};
private _tp0 = if (_t isEqualType objNull) then {if (isNull _t) then {[]} else {getPosASL _t}} else {_t};
if (count _tp0 < 3) exitWith {};
_p setVariable ["MCC_guideEnd", time + 40];
_p setVariable ["MCC_guideTo", _t];
_p setVariable ["MCC_guideDir", (getPosASL _p) vectorFromTo _tp0];
_p setVariable ["MCC_guideEH", addMissionEventHandler ["EachFrame", {
	private _p = _thisArgs select 0;
	if (isNull _p || {time > (_p getVariable ["MCC_guideEnd", 0])}) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
		["DEBUG", "guide", "%1 ended: last %2 m from its point after %3 updates", [_thisArgs select 1, round (_thisArgs select 2), _thisArgs select 3]] call MCC_fnc_log;
	};
	private _t = _p getVariable ["MCC_guideTo", []];
	private _tp = if (_t isEqualType objNull) then {if (isNull _t) then {[]} else {getPosASL _t}} else {_t};
	if (count _tp < 3) exitWith {removeMissionEventHandler ["EachFrame", _thisEventHandler]};
	private _line = _p getVariable ["MCC_guideDir", [0, 0, -1]];
	private _d = (getPosASL _p) vectorFromTo (_tp vectorAdd (_line vectorMultiply 10));
	private _s = (vectorMagnitude (velocity _p)) max 120;
	_p setVectorDir _d;
	_p setVelocity (_d vectorMultiply _s);
	_thisArgs set [2, (getPosASL _p) distance _tp];
	_thisArgs set [3, (_thisArgs select 3) + 1];
}, [_p, typeOf _p, -1, 0]]];
