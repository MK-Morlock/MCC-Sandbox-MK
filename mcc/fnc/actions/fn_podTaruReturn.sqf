params [["_heli", objNull, [objNull]], ["_pod", objNull, [objNull]], ["_height", 400, [0]]];
if (isNull _heli || {!alive _heli}) exitWith {};
private _grp = group driver _heli;
private _carry = false;
private _fnc_leave = {
	params ["_why"];
	["INFO", "podTaru", "%1 leaves the map%2", [typeOf _heli, _why]] call MCC_fnc_log;
	[_heli, 150] call MCC_fnc_haloPlaneExit;
	if (_carry && {!isNull _pod}) then {deleteVehicle _pod};
};
private _fnc_wp = {
	params ["_pos", ["_speed", "NORMAL"], ["_radius", 300]];
	for "_i" from (count waypoints _grp - 1) to 0 step -1 do {deleteWaypoint [_grp, _i]};
	private _wp = _grp addWaypoint [_pos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointSpeed _speed;
	_wp setWaypointBehaviour "CARELESS";
	_wp setWaypointCombatMode "BLUE";
	_wp setWaypointCompletionRadius _radius;
	_grp setCurrentWaypoint _wp;
};
_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";
_heli allowCrewInImmobile true;
_grp setVariable ["MCC_canbecontrolled", false, true];

private _podPos = getPosATL _pod;
private _tBack = time + 300;
_heli flyInHeight 200;
[_heli getPos [2000, getDir _heli]] call _fnc_wp;
["INFO", "podTaru", "%1 waits away from the pod for 5 minutes", [typeOf _heli]] call MCC_fnc_log;
private _tLeg = time + 40;
waitUntil {sleep 1; !alive _heli || {time > _tLeg}};
private _fnc_zoneGap = {
	params ["_q"];
	private _gap = 1000000;
	{
		private _m = str _x;
		if !((getMarkerPos _m) isEqualTo [0,0,0]) then {
			private _r = ((getMarkerSize _m) select 0) max ((getMarkerSize _m) select 1);
			_gap = _gap min ((_q distance2D (getMarkerPos _m)) - _r);
		};
	} forEach (missionNamespace getVariable ["MCC_zones_numbers", []]);
	_gap
};
while {alive _heli && {time < _tBack}} do {
	private _p = [];
	private _best = -1000000;
	for "_k" from 1 to 30 do {
		private _q = _podPos getPos [2500 + random 1500, random 360];
		private _g = [_q] call _fnc_zoneGap;
		if (_g > _best) then {_best = _g; _p = _q};
		if (_g >= 800) exitWith {};
	};
	_p set [2, 0];
	[_p] call _fnc_wp;
	private _t = time + 90;
	waitUntil {sleep 1; !alive _heli || {time > _tBack} || {time > _t} || {(_heli distance2D _p) < 350}};
};
if (!alive _heli) exitWith {};

if (isNull _pod || {!alive _pod}) exitWith {[" (pod destroyed)"] call _fnc_leave};
if (count (crew _pod) > 0) exitWith {[" (someone is in the pod)"] call _fnc_leave};
["INFO", "podTaru", "%1 coming back for the pod at %2", [typeOf _heli, mapGridPosition _pod]] call MCC_fnc_log;
_podPos = getPosATL _pod;
_heli flyInHeight 40;
[_podPos, "FULL", 0] call _fnc_wp;
private _tGive = time + 120;
waitUntil {sleep 0.5; !alive _heli || {time > _tGive} || {(_heli distance2D _podPos) < 1000}};
_heli flyInHeight 13;
waitUntil {sleep 0.1; !alive _heli || {time > _tGive} || {(_heli distance2D _podPos) < 450}};
MCC_podTaruHold = true;
MCC_podTaruHoldH = 13;
[_heli, _pod] spawn {
	params ["_h", "_p"];
	while {alive _h && {alive _p} && {missionNamespace getVariable ["MCC_podTaruHold", false]}} do {
		private _tgt = (getPosASL _p) vectorAdd [0, 0, missionNamespace getVariable ["MCC_podTaruHoldH", 22]];
		private _d = _tgt vectorDiff (getPosASL _h);
		private _dh = vectorMagnitude [_d select 0, _d select 1, 0];
		private _vh = if (_dh > 0.5) then {(vectorNormalized [_d select 0, _d select 1, 0]) vectorMultiply ((_dh * 0.35) min 25)} else {[0, 0, 0]};
		_h setVelocity [_vh select 0, _vh select 1, ((_d select 2) * 0.5) max -10 min 4];
		sleep 0.1;
	};
};
private _tLog = 0;
waitUntil {
	sleep 0.25;
	if (time > _tLog) then {
		_tLog = time + 5;
		["INFO", "podTaru", "%1 over the pod: %2 m to the side, %3 m up", [typeOf _heli, round (_heli distance2D _pod), round ((getPosATL _heli) select 2)]] call MCC_fnc_log;
	};
	!alive _heli || {time > _tGive} || {((_heli distance2D _pod) < 4) && {(((getPosASL _heli) select 2) - ((getPosASL _pod) select 2)) > 9} && {(((getPosASL _heli) select 2) - ((getPosASL _pod) select 2)) < 18}}
};
if (time > _tGive || {!alive _heli}) then {MCC_podTaruHold = false};
if (!alive _heli) exitWith {};
if (time > _tGive || {!alive _pod} || {count (crew _pod) > 0}) exitWith {[" (could not get over the pod in 2 minutes, or the pod changed)"] call _fnc_leave};

_heli enableRopeAttach true;
_pod enableRopeAttach true;
private _hooked = _heli setSlingLoad _pod;
if (!_hooked || {count (ropes _heli) == 0}) then {
	(boundingBoxReal _pod) params ["_b1", "_b2"];
	private _z = _b2 select 2;
	{
		ropeCreate [_heli, [0, 0, -1], _pod, [(_x select 0), (_x select 1), _z], ((_heli modelToWorld [0, 0, -1]) distance (_pod modelToWorld [(_x select 0), (_x select 1), _z])) + 0.5];
	} forEach [[(_b1 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b1 select 0) * 0.6, (_b2 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b2 select 1) * 0.6]];
};
["INFO", "podTaru", "%1 hooked the pod (%2 ropes, %3) - %4 m above it", [typeOf _heli, count (ropes _heli), ["ropes made by script", "Arma sling load"] select _hooked, round (((getPosASL _heli) select 2) - ((getPosASL _pod) select 2))]] call MCC_fnc_log;

_carry = true;
private _dock = if (_hooked) then {[_heli, 5, false, false] spawn MCC_fnc_podDock} else {[_heli, 1] spawn MCC_fnc_attachPod};
sleep 1;
MCC_podTaruHold = false;
if (!alive _heli) exitWith {};
_heli flyInHeight 35;
[_heli] spawn {sleep 8; if (alive (_this select 0)) then {(_this select 0) flyInHeight 60}};
[_heli getPos [2000, getDir _heli], "FULL", 300] call _fnc_wp;
private _tD = time + 40;
waitUntil {sleep 0.5; scriptDone _dock || {!alive _heli} || {time > _tD}};
if (!alive _heli) exitWith {};
if (!scriptDone _dock) then {
	terminate _dock;
	{ropeDestroy _x} forEach (ropes _heli);
	if (alive _pod) then {_pod attachTo [_heli, [0, 0, -1.2]]; _heli setVariable ["MCC_attachedPod", _pod, true]};
	["INFO", "podTaru", "%1: winch did not finish in 40 s - pod docked directly", [typeOf _heli]] call MCC_fnc_log;
} else {
	["INFO", "podTaru", "%1: pod winched up and docked", [typeOf _heli]] call MCC_fnc_log;
};
[" with the pod"] call _fnc_leave;
