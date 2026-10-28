params [["_units", []]];
_units = _units select {!isNull _x && {alive _x} && {!isPlayer _x}};
if (count _units < 2) exitWith {};
if (count _units > 16) then {_units resize 16};
{_x setVariable ["MCC_haloInFormation", true]} forEach _units;

private _lead = _units select 0;
waitUntil {sleep 0.05; !alive _lead || {vehicle _lead == _lead}};
if (!alive _lead) exitWith {};
{_x setVariable ["MCC_haloFormationChute", true]} forEach _units;
["INFO", "haloFormation", "ROS formation on %1 with %2 units at %3 m", [name _lead, count _units, round ((getPosATL _lead) select 2)]] call MCC_fnc_log;

//---- ROS_HaloFormation positions (copied unchanged) ----
private _outerRpos = [[6.12012,9.38477,-0.838795],[-0.5,12.0508,-0.838795],[-8,9.30078,-0.838795],[-12.5,1.05078,-0.838795],[-10.5,-5.69922,-0.838795],[-3.75,-10.4492,-0.838795],[3.5,-10.1992,-0.838795],[9.5,-4.94922,-0.838795],[11,3.05078,-0.838795]];
private _innerRpos = [[0.774414,2.84375,-0.838795],[-1,2.55078,-0.838795],[-2.25,1.55078,-0.838795],[-2.75,-0.199219,-0.838795],[-2,-1.94922,-0.838795],[0,-2.44922,-0.838795],[1.75,-1.94922,-0.838795],[2.5,-0.449219,-0.838795],[2.25,1.30078,-0.838795]];

private _n = count _units;
if (_n != 9) then {
	private _rIn = 1.5 max (_n * 1.88 / 6.2832);
	private _rOut = _rIn * (11.56 / 2.69);
	_outerRpos = []; _innerRpos = [];
	for "_k" from 0 to (_n - 1) do {
		private _a = 15 - (360 / _n) * _k;
		_outerRpos pushBack [_rOut * sin _a, _rOut * cos _a, -0.838795];
		_innerRpos pushBack [_rIn * sin _a, _rIn * cos _a, -0.838795];
	};
};
private _breakAlt = 170 + 85 + ((_n - 1) max 0) * 0.2 * 68;
private _p0 = _innerRpos select 0;
private _cDist = vectorMagnitude [_p0 select 0, _p0 select 1, 0];
private _ringYaw = 180 - ((_p0 select 0) atan2 (_p0 select 1));
//ring place (relative to the centre, ROS's numbers) -> position relative to the leader
private _fnc_toLead = {
	params ["_r", "_cDist", "_ringYaw", "_p0z"];
	private _m = vectorMagnitude [_r select 0, _r select 1, 0];
	private _b = ((_r select 0) atan2 (_r select 1)) + _ringYaw;
	[_m * sin _b, _cDist + _m * cos _b, (_r select 2) - _p0z]
};
//facing towards the centre for a position relative to the leader
private _fnc_faceC = {
	params ["_pos", "_cDist"];
	((0 - (_pos select 0)) atan2 (_cDist - (_pos select 1)))
};

private _ai = _units - [_lead];
{
	private _i = _forEachIndex + 1;
	[_x, _lead, [_innerRpos select _i, _cDist, _ringYaw, _p0 select 2] call _fnc_toLead, _cDist, _fnc_faceC] spawn {
		params ["_u", "_lead", "_inner", "_cDist", "_fnc_faceC"];
		private _t0 = time;
		waitUntil {sleep 0.05; !alive _u || {!alive _lead} || {vehicle _u == _u} || {time - _t0 > 30}};
		if (!alive _u || {!alive _lead} || {vehicle _u != _u}) exitWith {};
		private _tOut = time;
		_u disableAI "anim";
		_u switchMove "HaloFreeFall_non";
		private _v = velocity _u;
		_u setDir (((getDir _lead) + ([_inner, _cDist] call _fnc_faceC)) mod 360);
		_u setVelocity _v;
		//straight in to his inner place - no turning while moving
		private _end = time + 20;	//(safety)
		private _done = false;
		while {!_done && {alive _u} && {alive _lead} && {time < _end} && {((getPosATL _lead) select 2) > 380}} do {
			private _d = (AGLToASL (_lead modelToWorldVisual _inner)) vectorDiff (getPosASLVisual _u);
			private _dist = vectorMagnitude _d;
			if (_dist < 1) then {
				_done = true;
			} else {
				_u setVelocity ((velocity _lead) vectorAdd ((vectorNormalized _d) vectorMultiply ((_dist * 1.5) min 50)));
				sleep 0.2;
			};
		};
		private _left = (AGLToASL (_lead modelToWorldVisual _inner)) vectorDiff (getPosASLVisual _u);
		["DEBUG", "haloFormation", "%1 in his place: %2 s after leaving the aircraft, %3 m from it when held (%4)", [name _u, round ((time - _tOut) * 10) / 10, round ((vectorMagnitude _left) * 10) / 10, if (_done) then {"reached"} else {"time limit / break-off / died"}]] call MCC_fnc_log;
		if (alive _u && {alive _lead}) then {
			_u attachTo [_lead, _inner];
			_u setDir ([_inner, _cDist] call _fnc_faceC);
		};
	};
} forEach _ai;

private _tr = time + 20;
waitUntil {sleep 0.25; time > _tr || {({alive _x && {(attachedTo _x) != _lead}} count _ai) == 0}};
{_x setVariable ["MCC_haloRingDone", true]} forEach _units;
["INFO", "haloFormation", "ring formed at %1 m (%2 of %3 held in place%4) - damage back on now", [round ((getPosATL _lead) select 2), {alive _x && {(attachedTo _x) == _lead}} count _ai, count _ai, if (time > _tr) then {", 20 s limit reached"} else {""}]] call MCC_fnc_log;

waitUntil {sleep 0.25; !alive _lead || {((getPosATLVisual _lead) select 2) < _breakAlt}};
["INFO", "haloFormation", "break off at %1 m", [round ((getPosATL _lead) select 2)]] call MCC_fnc_log;
//Chute heights: one random height (120 - 170 m) per man, shared out so that whoever is HIGHEST now gets the HIGHEST
//opening height - a man above opens first and slows first, so nobody still falling fast drops through an open canopy
//below him (read by MCC_fnc_paradrop as MCC_haloChuteAlt)
private _all = _units select {alive _x};
private _po = (_all param [0, objNull]) getVariable ["MCC_paraOpen", [0, 0]];
private _hts = if ((_po select 0) == 1) then {_all apply {(_po select 1) + random 30}} else {_all apply {120 + random 50}};
_hts sort false;
private _byHeight = [_all, [], {(getPosASL _x) select 2}, "DESCEND"] call BIS_fnc_sortBy;
{_x setVariable ["MCC_haloChuteAlt", _hts select _forEachIndex]} forEach _byHeight;
//Starburst: each man pushed straight out from the CENTRE of the ring in his own direction (like the spokes of a wheel,
//away from the men either side of him) at 18 m/s plus 4 m/s up; the leader too (he used to carry on without a push,
//and the others were pushed away from him - a fan towards the far side of the ring). One by one, 0.2 s apart.
private _centre = AGLToASL (_lead modelToWorldVisual [0, _cDist, 0]);
private _fnc_out = {
	params ["_u", "_centre"];
	private _o = (getPosASL _u) vectorDiff _centre;
	if ((vectorMagnitude [_o select 0, _o select 1, 0]) > 0.1) then {vectorNormalized [_o select 0, _o select 1, 0]} else {[sin (random 360), cos (random 360), 0]}
};
private _lv = velocity _lead;
{
	if (alive _x) then {
		detach _x;
		_x setVelocity (_lv vectorAdd (([_x, _centre] call _fnc_out) vectorMultiply 18) vectorAdd [0, 0, 4]);
	};
	sleep 0.2;
} forEach _ai;
if (alive _lead) then {_lead setVelocity ((velocity _lead) vectorAdd (([_lead, _centre] call _fnc_out) vectorMultiply 18) vectorAdd [0, 0, 4])};
