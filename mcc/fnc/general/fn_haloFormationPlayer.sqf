/*================================================================== MCC_fnc_haloFormationPlayer ==================================================================
	CREDITS: ROS_HaloFormation.sqf by RickOShay (ROS Group HALO) - its formation free fall, adapted for a player and his AI.
*/
params [["_units", []]];
private _player = (_units select {!isNull _x && {isPlayer _x}}) param [0, objNull];
if (isNull _player) exitWith {};
private _ai = _units select {!isNull _x && {alive _x} && {!isPlayer _x}};
if (count _ai > 15) then {_ai resize 15};
{_x setVariable ["MCC_haloInFormation", true]; _x setVariable ["MCC_haloFormationChute", true]} forEach _ai;

private _outerRpos = [[6.12012,9.38477,-0.838795],[-0.5,12.0508,-0.838795],[-8,9.30078,-0.838795],[-12.5,1.05078,-0.838795],[-10.5,-5.69922,-0.838795],[-3.75,-10.4492,-0.838795],[3.5,-10.1992,-0.838795],[9.5,-4.94922,-0.838795],[11,3.05078,-0.838795]];
private _innerRpos = [[0.774414,2.84375,-0.838795],[-1,2.55078,-0.838795],[-2.25,1.55078,-0.838795],[-2.75,-0.199219,-0.838795],[-2,-1.94922,-0.838795],[0,-2.44922,-0.838795],[1.75,-1.94922,-0.838795],[2.5,-0.449219,-0.838795],[2.25,1.30078,-0.838795]];
private _n = (count _ai) + 1;
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
private _p0 = _innerRpos select 0;
private _cDist = vectorMagnitude [_p0 select 0, _p0 select 1, 0];
private _ringYaw = 180 - ((_p0 select 0) atan2 (_p0 select 1));
private _fnc_rel = {
	params ["_r"];
	private _m = vectorMagnitude [_r select 0, _r select 1, 0];
	private _b = ((_r select 0) atan2 (_r select 1)) + _ringYaw;
	[_m * sin _b, _cDist + _m * cos _b, (_r select 2) - (_p0 select 2)]
};
private _fnc_faceC = {params ["_pos"]; ((0 - (_pos select 0)) atan2 (_cDist - (_pos select 1)))};

{_x setVariable ["MCC_haloOnOuter", false]; _x setVariable ["MCC_haloRingDone", false]; _x setVariable ["MCC_haloChuteAlt", nil]} forEach _ai;

waitUntil {sleep 0.05; !alive _player || {vehicle _player == _player}};
if (!alive _player) exitWith {};
["INFO", "haloFormation", "ROS player formation on %1 with %2 AI at %3 m", [name _player, count _ai, round ((getPosATL _player) select 2)]] call MCC_fnc_log;
private _v0 = velocity _player;
if ((vectorMagnitude [_v0 select 0, _v0 select 1, 0]) > 5) then {
	[[((_v0 select 0) atan2 (_v0 select 1) + 360) mod 360, _v0], {params ["_d", "_v"]; player setDir _d; player setVelocity _v}] remoteExec ["call", _player];
};

if (((_player getVariable ["MCC_paraOpen", [0, 0]]) select 0) != 1) then {[_player] spawn {
	params ["_p"];
	waitUntil {sleep 0.1; !alive _p || {vehicle _p != _p} || {((getPosATL _p) select 2) < 240}};
	if (alive _p && {vehicle _p == _p}) then {[_p, ["OpenParachute", _p]] remoteExec ["action", _p]};
}};

private _outer = []; private _inner = [];
{
	private _o = [_outerRpos select (_forEachIndex + 1)] call _fnc_rel;
	private _i = [_innerRpos select (_forEachIndex + 1)] call _fnc_rel;
	_outer pushBack _o; _inner pushBack _i;
	[_x, _player, _o, _cDist] spawn {
		params ["_u", "_p", "_o", "_cDist"];
		private _t0 = time;
		waitUntil {sleep 0.05; !alive _u || {!alive _p} || {vehicle _u == _u} || {time - _t0 > 30}};
		if (!alive _u || {!alive _p} || {vehicle _u != _u} || {vehicle _p != _p}) exitWith {};
		private _tf = time + 4;
		waitUntil {sleep 0.05; !alive _u || {!alive _p} || {vehicle _p != _p} || {vehicle _u != _u} || {time > _tf}};
		if (!alive _u || {!alive _p} || {vehicle _u != _u} || {vehicle _p != _p}) exitWith {};
		private _rel = _p worldToModelVisual (ASLToAGL (getPosASLVisual _u));
		_u attachTo [_p, _rel];
		private _n = round ((((vectorMagnitude (_o vectorDiff _rel)) / 20) max 3 min 15) / 0.015);
		for "_s" from 1 to _n do {
			if (!alive _u || {(attachedTo _u) != _p}) exitWith {};
			private _f = _s / _n;
			private _pos = _rel vectorAdd ((_o vectorDiff _rel) vectorMultiply (_f * _f * (3 - 2 * _f)));
			_u attachTo [_p, _pos];
			_u setDir ((0 - (_pos select 0)) atan2 (_cDist - (_pos select 1)));
			sleep 0.015;
		};
		if (!alive _u || {(attachedTo _u) != _p}) exitWith {};
		_u setVariable ["MCC_haloOnOuter", true];
		[_u, "B_Parachute"] remoteExec ["addBackpackGlobal", _u];
	};
} forEach _ai;

[_ai, _player] spawn {
	params ["_ai", "_p"];
	private _t = time + 25;
	waitUntil {sleep 0.1; time > _t || {({alive _x && {!(_x getVariable ["MCC_haloOnOuter", false])}} count _ai) == 0}};
	["INFO", "haloFormation", "outer ring complete at %1 m (%2 of %3 AI on it)", [round ((getPosATL _p) select 2), {_x getVariable ["MCC_haloOnOuter", false]} count _ai, count _ai]] call MCC_fnc_log;
};

private _order = [];
for "_k" from 0 to ((count _ai) - 1) do {_order pushBack _k};
_order = _order call BIS_fnc_arrayShuffle;
{
	private _u = _ai select _x;
	private _o = _outer select _x;
	private _i = _inner select _x;
	private _tw = time + 30;
	waitUntil {sleep 0.05; !alive _u || {_u getVariable ["MCC_haloOnOuter", false]} || {time > _tw}};
	sleep (2 + random 0.5);
	if (alive _u && {alive _player} && {vehicle _player == _player} && {(attachedTo _u) == _player} && {((getPosATL _player) select 2) > 450}) then {
		for "_s" from 1 to 80 do {
			private _pos = _o vectorAdd ((_i vectorDiff _o) vectorMultiply (_s / 80));
			_u attachTo [_player, _pos];
			_u setDir ([_pos] call _fnc_faceC);
			sleep 0.015;
		};
	};
} forEach _order;
{_x setVariable ["MCC_haloRingDone", true]} forEach _ai;
["INFO", "haloFormation", "player ring formed at %1 m (%2 of %3 AI held round %4)", [round ((getPosATL _player) select 2), {alive _x && {(attachedTo _x) == _player}} count _ai, count _ai, name _player]] call MCC_fnc_log;

private _breakAlt = 156 + 68 * (2.3 + 0.1 * (count _ai));
waitUntil {sleep 0.1; !alive _player || {vehicle _player != _player} || {((getPosATLVisual _player) select 2) < _breakAlt}};
["INFO", "haloFormation", "player ring break off at %1 m", [round ((getPosATL _player) select 2)]] call MCC_fnc_log;
private _held = _ai select {alive _x && {(attachedTo _x) == _player}};
private _po = _player getVariable ["MCC_paraOpen", [0, 0]];
private _hts = if ((_po select 0) == 1) then {_held apply {(_po select 1) + random 30}} else {_held apply {145 + random 8}};
_hts sort false;
private _byHeight = [_held, [], {(getPosASL _x) select 2}, "DESCEND"] call BIS_fnc_sortBy;
{_x setVariable ["MCC_haloChuteAlt", _hts select _forEachIndex]} forEach _byHeight;
private _centre = AGLToASL (_player modelToWorldVisual [0, _cDist, 0]);
private _lv = velocity _player;
private _pDir = getDir _player;
{
	_x setVariable ["MCC_haloChuteDir", _pDir, true];
	[_x, false] remoteExec ["allowDamage", _x];
	_x setVariable ["ace_medical_allowDamage", false, true];
	[_x] spawn {
		params ["_u"];
		private _t = time + 90;
		waitUntil {sleep 0.2; !alive _u || {vehicle _u != _u} || {time > _t}};
		sleep 2;
		[_u, true] remoteExec ["allowDamage", _u];
		_u setVariable ["ace_medical_allowDamage", true, true];
	};
} forEach _ai;
MCC_haloBreak = [];
_held = _held call BIS_fnc_arrayShuffle;
private _ehB = addMissionEventHandler ["EachFrame", {
	{
		_x params ["_u", "_p", "_in", "_out", "_t0", "_cDist"];
		if (alive _u && {(attachedTo _u) == _p}) then {
			private _t = time - _t0;
			private _f = (_t / 1) min 1;
			private _d = 1 * _f * _f * (3 - 2 * _f);
			private _g = 0;
			if (_t > 1) then {
				private _ts = _t - 1;
				_d = _d + (if (_ts < 0.4) then {15 * _ts * _ts} else {2.4 + 12 * (_ts - 0.4)});
				_g = (_ts / 0.5) min 1;
			};
			private _pos = _in vectorAdd (_out vectorMultiply _d);
			_u attachTo [_p, _pos];
			private _faceC = (0 - (_pos select 0)) atan2 (_cDist - (_pos select 1));
			_u setDir (_faceC + 180 * _g * _g * (3 - 2 * _g));
		};
	} forEach (missionNamespace getVariable ["MCC_haloBreak", []]);
}];
{
	private _k = _ai find _x;
	if (alive _x && {_k >= 0}) then {
		if (backpack _x == "B_Parachute") then {[_x] remoteExec ["removeBackpackGlobal", _x]};
		private _in = _inner select _k;
		private _out = vectorNormalized [_in select 0, (_in select 1) - _cDist, 0];
		if ((vectorMagnitude _out) < 0.1) then {_out = [sin (random 360), cos (random 360), 0]};
		MCC_haloBreak pushBack [_x, _player, _in, _out, time, _cDist];
	};
	sleep 0.1;
} forEach _held;
private _tf = time + 12;
waitUntil {sleep 0.02; !alive _player || {vehicle _player != _player} || {time > _tf} || {((getPosATLVisual _player) select 2) < 262}};
removeMissionEventHandler ["EachFrame", _ehB];
private _pv = velocity _player;
{
	_x params ["_u", "_p", "_in", "_out"];
	if (alive _u && {(attachedTo _u) == _player}) then {
		private _w = _player vectorModelToWorldVisual _out;
		detach _u;
		_u setVelocity (_pv vectorAdd ((vectorNormalized [_w select 0, _w select 1, 0]) vectorMultiply 12));
	};
} forEach MCC_haloBreak;
["INFO", "haloFormation", "player ring let go at %1 m (%2 AI)", [round ((getPosATL _player) select 2), count MCC_haloBreak]] call MCC_fnc_log;
MCC_haloBreak = [];
{if ((attachedTo _x) == _player) then {detach _x}} forEach _ai;
