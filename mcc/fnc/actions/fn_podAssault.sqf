params [["_h", objNull, [objNull]], ["_tgt", [], [[]]]];
private _p = _h getVariable ["MCC_attachedPod", objNull];
if (isNull _p) then {_p = getSlingLoad _h};
if (isNull _p || {(attachedTo _p) != _h}) exitWith {["WARN", "podAssault", "%1: no pod docked", [typeOf _h]] call MCC_fnc_log; false};
_h setCustomWeightRTD 0;
_h setMass ((getMass _h) - (_h getVariable ["MCC_attachedPodMass", 0]));
_h setVariable ["MCC_attachedPod", objNull, true];
_h setVariable ["MCC_attachedPodMass", 0, true];
_h enableRopeAttach true;
_p enableRopeAttach true;
detach _p;
private _sling = _h setSlingLoad _p;
if (!_sling || {count (ropes _h) == 0}) then {
	(boundingBoxReal _p) params ["_b1", "_b2"];
	private _z = _b2 select 2;
	{ropeCreate [_h, [0, 0, -1], _p, [_x select 0, _x select 1, _z], ((_h modelToWorld [0, 0, -1]) distance (_p modelToWorld [_x select 0, _x select 1, _z])) + 0.5]} forEach [[(_b1 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b1 select 0) * 0.6, (_b2 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b2 select 1) * 0.6]];
};
["INFO", "podAssault", "%1: pod on %2 ropes (%3)", [typeOf _h, count (ropes _h), ["ropes made by script", "Arma sling load"] select _sling]] call MCC_fnc_log;
["INFO", "podAssault", "%1 lowering the pod on its ropes from %2 m", [typeOf _h, round ((getPosATL _h) select 2)]] call MCC_fnc_log;

private _v = 4;
private _t = time + 90;
waitUntil {
	private _pw = getPosWorld _p;
	private _ins = lineIntersectsSurfaces [_pw, _pw vectorAdd [0, 0, -1000], _h, _p];
	private _rel = if (count _ins > 0) then {(_pw select 2) - (((_ins select 0) select 0) select 2)} else {(getPosATL _p) select 2};
	if (count (ropes _h) > 0 && {ropeLength ((ropes _h) select 0) <= 5}) then {_h disableCollisionWith _p} else {_h enableCollisionWith _p};
	_v = if (_rel < 1.5) then {15} else {if (_rel < 7) then {2} else {(_v + 0.3) min 12}};
	{ropeUnwind [_x, _v, 100]} forEach (ropes _h);
	sleep 0.3;
	!alive _h || {!alive _p} || {time > _t} || {count (ropes _h) == 0} ||
	{isTouchingGround _p && {_rel < 10}} || {ropeLength ((ropes _h) select 0) >= 99.5}
};
{ropeUnwind [_x, 0, ropeLength _x]} forEach (ropes _h);
if (alive _h && {alive _p} && {isTouchingGround _p}) then {{ropeUnwind [_x, 3, ((ropeLength _x) + 0.1) min 100]} forEach (ropes _h); sleep 1};
if (!alive _h || {!alive _p} || {count (ropes _h) == 0}) exitWith {["WARN", "podAssault", "%1: the pod was lost while lowering", [typeOf _h]] call MCC_fnc_log; false};

private _n = count (crew _p);
{
	[_x, {params ["_u"]; if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by pods (podAssault) | %1 from %2 at %3 m", [name _u, typeOf (vehicle _u), round ((getPosATL _u) select 2)]] call MCC_fnc_log}; unassignVehicle _u; moveOut _u}] remoteExec ["call", _x];
	sleep 0.15;
} forEach (crew _p);
private _tl = time + 20;
waitUntil {sleep 0.2; count (crew _p) == 0 || {!alive _p} || {time > _tl}};
["INFO", "podAssault", "drop pod lowered at %1 - %2 passengers out%3", [mapGridPosition _p, _n, if (count _tgt > 1) then {format [" - %1 m from its place on the line", round (_p distance2D _tgt)]} else {""}]] call MCC_fnc_log;
sleep 1;

if (_sling) exitWith {
	[_h] spawn {
		params ["_hh"];
		private _ok = [_hh, 5, false, false] call MCC_fnc_podDock;
		["INFO", "podAssault", "%1: pod %2", [typeOf _hh, ["NOT docked again", "winched up and docked again"] select _ok]] call MCC_fnc_log;
	};
	true
};
_h call MCC_fnc_attachPod;
!isNull (_h getVariable ["MCC_attachedPod", objNull])
