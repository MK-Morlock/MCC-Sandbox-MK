params [["_h", objNull, [objNull]], ["_vmax", 5, [0]], ["_instant", false, [false]], ["_keepSling", true, [true]]];
private _p = getSlingLoad _h;
if (isNull _p) exitWith {false};
if (_instant) then {
	_h disableCollisionWith _p;
	{ropeUnwind [_x, 15, 1]} forEach (ropes _h);
} else {
	private _v = 0;
	private _t = time + 60;
	waitUntil {
		if (count (ropes _h) > 0 && {ropeLength ((ropes _h) select 0) <= 5}) then {_h disableCollisionWith _p};
		_v = (_v + 0.3) min _vmax;
		{ropeUnwind [_x, _v, 1]} forEach (ropes _h);
		sleep 0.3;
		!alive _h || {!alive _p} || {isNull (getSlingLoad _h)} || {(_h distance _p) < 2.5} || {count (ropes _h) == 0} || {ropeLength ((ropes _h) select 0) <= 1.05} || {time > _t}
	};
};
if (!alive _h || {!alive _p} || {isNull (getSlingLoad _h)}) exitWith {false};
private _d = switch (true) do {
	case (_p isKindOf "Land_Pod_Heli_Transport_04_bench_F"): {[[0, 0.1, -1.3], 680]};
	case (_p isKindOf "Land_Pod_Heli_Transport_04_covered_F"): {[[0, -1.05, -0.995], 1413]};
	case (_p isKindOf "Land_Pod_Heli_Transport_04_fuel_F"): {[[0.05, -0.35, -1.44], 13311]};
	case (_p isKindOf "Land_Pod_Heli_Transport_04_medevac_F"): {[[-0.04, -1.05, -1.087], 1321]};
	case (_p isKindOf "Land_Pod_Heli_Transport_04_repair_F"): {[[0, -1.05, -1.276], 1270]};
	default {[[0, -1.05, -1.265], 1270]};
};
_h allowDamage false;
_p attachTo [_h, _d select 0];
private _pm = getMass _p;
_h setCustomWeightRTD (_d select 1);
_h setMass ((getMass _h) + _pm);
_h allowDamage true;
_h setVariable ["MCC_attachedPod", _p, true];
_h setVariable ["MCC_attachedPodMass", _pm, true];
_h setVariable ["MCC_podSling", _keepSling, true];
if (!_keepSling) then {_h setSlingLoad objNull};
[_h, _p, _keepSling] spawn {
	params ["_h", "_p", "_ks"];
	waitUntil {sleep 0.3; isNull _h || {!alive _h} || {!alive _p} || {_ks && {isNull (getSlingLoad _h)}} || {(attachedTo _p) != _h}};
	if (isNull _h) exitWith {if (alive _p && {(count crew _p) == 0}) then {deleteVehicle _p}};
	if (!alive _h && {alive _p}) exitWith {_p setDamage 1; detach _p};
	if (_ks && {isNull (getSlingLoad _h)} && {(attachedTo _p) == _h}) then {detach _p};
};
true
