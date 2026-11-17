params [["_ship", objNull, [objNull]], ["_es", east, [east]], ["_faction", "", [""]], ["_fromDir", 0, [0]], ["_lvl", 1, [0]], ["_zones", [], [[]]]];
if (!isServer || {isNull _ship}) exitWith {};
private _log = {params ["_f", ["_a", []]]; ["INFO", "navalbase", _f, _a] call MCC_fnc_log};
private _ps = _ship getVariable ["MCC_side", west];
private _facs = [_faction] + ([_faction] call MCC_fnc_factionSiblings);
private _boatsPool = [];
private _helis = [];
private _cars = [];
private _men = [];
{
	_boatsPool append ([_x, "boat"] call MCCMK_fnc_factionAssets);
	_helis append ([_x, "transportheli"] call MCCMK_fnc_factionAssets);
	_cars append ([_x, "lightarmed"] call MCCMK_fnc_factionAssets);
	_men append ([_x, "men"] call MCCMK_fnc_factionAssets);
} forEach _facs;
if (_boatsPool isEqualTo [] || {_men isEqualTo []}) exitWith {["no armed boats or infantry for %1 - air threats only", [_faction]] call _log; _ship setVariable ["MCCMK_baseFailUntil", serverTime + 1e6]};
private _site = [_ship, _zones] call MCCMK_fnc_navalBaseSite;
if (_site isEqualTo []) exitWith {["no base site near %1", [_ship getVariable ["MCC_LHDDisplayName", "ship"]]] call _log; _ship setVariable ["MCCMK_baseFailUntil", serverTime + 900]};
_site params ["_lz", "_moor", "_score"];
private _route = [_moor] call MCCMK_fnc_navalRoute;
if (_route isEqualTo []) exitWith {["no water route to %1 - air threats only here", [mapGridPosition _moor]] call _log; _ship setVariable ["MCCMK_baseFailUntil", serverTime + 1800]};
private _h = createVehicle ["Land_HelipadEmpty_F", _lz, [], 0, "CAN_COLLIDE"];
_h setVariable ["MCCMK_baseShip", _ship];
_h setVariable ["MCCMK_baseMoor", _moor];
_h setVariable ["MCCMK_baseSide", _es];
private _zk = _zones apply {[(_x select 1) distance2D _lz, _x select 0]};
_zk sort true;
private _zoneKey = (_zk select 0) select 1;
MCCMK_navalBases pushBack _h;
private _id = format ["MCCMK_base_%1", floor random 1e6];
private _objs = [_h];
private _pads = [_h];
for "_k" from 1 to 2 do {
	private _pp = _lz getPos [45, random 360];
	private _e = _pp isFlatEmpty [9, -1, 0.4, 10, 0, false, objNull];
	if (_e isNotEqualTo [] && {!surfaceIsWater _pp}) then {private _o = createVehicle ["Land_HelipadEmpty_F", _pp, [], 0, "CAN_COLLIDE"]; _objs pushBack _o; _pads pushBack _o} else {_pads pushBack _h};
};
["base site %1 (score %2), mooring %3, route %4 points", [mapGridPosition _lz, _score, mapGridPosition _moor, count _route]] call _log;
private _range = [[4, 6], [4, 6], [6, 8], [10, 12]] param [_lvl, [4, 6]];
private _nG = (_range select 0) + floor random (((_range select 1) - (_range select 0)) + 1);
private _fb = [["O_Heli_Transport_04_F", "O_MRAP_02_hmg_F"], ["B_Heli_Transport_03_F", "B_LSV_01_armed_F"], ["I_Heli_Transport_02_F", "I_G_Offroad_01_armed_F"]] param [[east, west, independent] find _es, ["I_Heli_Transport_02_F", "I_G_Offroad_01_armed_F"]];
private _edge = [_lz, _fromDir] call MCCMK_fnc_edgePos;
private _spawnHeli = {
	params ["_cls", "_p"];
	_p set [2, 250];
	private _v = createVehicle [_cls, _p, [], 0, "FLY"];
	_v setPosASL [_p select 0, _p select 1, 250];
	_v setDir (_p getDir _lz);
	_v setVelocityModelSpace [0, 40, 0];
	private _g = createVehicleCrew _v;
	[_v, _faction] call MCCMK_fnc_factionCrew;
	if ((side _g) != _es) then {private _ng = createGroup [_es, true]; (units _g) joinSilent _ng; _g = _ng};
	_g setBehaviour "CARELESS";
	_g setCombatMode "BLUE";
	_v flyInHeight 80;
	[_v, _g]
};
private _h1cls = if (count _helis > 0) then {selectRandom _helis} else {_fb select 0};
([_h1cls, +_edge] call _spawnHeli) params ["_heli1", "_hg1"];
private _veh = objNull;
private _try = (_cars call BIS_fnc_arrayShuffle) select [0, 4];
if !((_fb select 1) in _try) then {_try pushBack (_fb select 1)};
{
	if (isNull _veh && {isClass (configFile >> "CfgVehicles" >> _x)}) then {
		private _c = createVehicle [_x, (getPosATL _heli1) vectorAdd [0, 0, -14], [], 0, "CAN_COLLIDE"];
		if ((_heli1 canSlingLoad _c) && {_heli1 setSlingLoad _c}) then {_veh = _c} else {deleteVehicle _c};
	};
} forEach _try;
if (!isNull _veh) then {_objs pushBack _veh};
private _gg = createGroup [_es, true];
private _seats1 = _heli1 emptyPositions "cargo";
private _n1 = _nG min _seats1;
for "_i" from 1 to _n1 do {private _u = _gg createUnit [selectRandom _men, [0, 0, 0], [], 0, "NONE"]; _u moveInCargo _heli1};
private _rest = _nG - _n1;
private _heli2 = objNull;
private _hg2 = grpNull;
if (_rest > 0) then {
	private _fit = _helis select {(getNumber (configFile >> "CfgVehicles" >> _x >> "transportSoldier")) >= _rest};
	private _c2 = if (count _fit > 0) then {selectRandom _fit} else {_fb select 0};
	([_c2, _edge getPos [600, _fromDir + 90]] call _spawnHeli) params ["_v2", "_g2"];
	_heli2 = _v2;
	_hg2 = _g2;
	for "_i" from 1 to (_rest min (_heli2 emptyPositions "cargo")) do {private _u = _gg createUnit [selectRandom _men, [0, 0, 0], [], 0, "NONE"]; _u moveInCargo _heli2};
};
["delivery: %1 with %2, %3 guards%4", [typeOf _heli1, ["no vehicle", typeOf _veh] select !isNull _veh, count units _gg, ["", format [" (second helicopter %1)", typeOf _heli2]] select !isNull _heli2]] call _log;
private _deliver = {
	params ["_v", "_hg", "_pad", "_cargoVeh", "_lz", "_edge", "_gg"];
	_v doMove (getPos _pad);
	private _t0 = serverTime;
	waitUntil {sleep 2; !alive _v || {(_v distance2D _pad) < 250} || {(serverTime - _t0) > 600}};
	if (!alive _v) exitWith {};
	if (!isNull _cargoVeh) then {
		_v flyInHeight 18;
		_v doMove _lz;
		private _t1 = serverTime;
		waitUntil {sleep 1; !alive _v || {((_v distance2D _lz) < 50) && {((getPosATL _cargoVeh) select 2) < 4}} || {(serverTime - _t1) > 90}};
		_v setSlingLoad objNull;
	};
	private _wp = _hg addWaypoint [getPos _pad, 0];
	_wp setWaypointType "TR UNLOAD";
	private _t2 = serverTime;
	waitUntil {sleep 2; !alive _v || {((crew _v) findIf {(group _x) == _gg}) < 0} || {(serverTime - _t2) > 150}};
	{if ((group _x) == _gg) then {unassignVehicle _x; moveOut _x}} forEach (crew _v);
	if (!alive _v) exitWith {};
	for "_w" from (count waypoints _hg) - 1 to 0 step -1 do {deleteWaypoint [_hg, _w]};
	_v flyInHeight 80;
	(_hg addWaypoint [_edge, 0]) setWaypointType "MOVE";
	private _t3 = serverTime;
	waitUntil {sleep 3; !alive _v || {(_v distance2D _edge) < 900} || {(serverTime - _t3) > 420}};
	{deleteVehicle _x} forEach (crew _v);
	deleteVehicle _v;
};
private _d1 = [_heli1, _hg1, _pads select 0, _veh, _lz, _edge, _gg] spawn _deliver;
private _d2 = if (!isNull _heli2) then {[_heli2, _hg2, _pads select 1, objNull, _lz, _edge, _gg] spawn _deliver} else {scriptNull};
waitUntil {sleep 3; scriptDone _d1 && {scriptDone _d2}};
private _guards = (units _gg) select {alive _x && {vehicle _x == _x}};
if (_guards isEqualTo []) exitWith {
	["delivery failed - base abandoned", []] call _log;
	{deleteVehicle _x} forEach ((units _gg) + _objs);
	MCCMK_navalBases = MCCMK_navalBases - [_h];
	_ship setVariable ["MCCMK_baseFailUntil", serverTime + 1200];
};
sleep 40;
private _hasBuild = (count (nearestObjects [_lz, ["House"], 35])) > 0;
private _put = {
	params ["_cls", "_d"];
	private _p = (_lz getPos [_d, random 360]) findEmptyPosition [0, 15, _cls];
	if (_p isEqualTo []) exitWith {};
	private _o = createVehicle [_cls, _p, [], 0, "CAN_COLLIDE"];
	_o setDir random 360;
	_objs pushBack _o;
};
if (!_hasBuild) then {
	[["CamoNet_OPFOR_open_F", "CamoNet_BLUFOR_open_F", "CamoNet_INDP_open_F"] param [[east, west, independent] find _es, "CamoNet_INDP_open_F"], 8] call _put;
	["Land_TentA_F", 12] call _put;
	["Land_TentA_F", 14] call _put;
};
["MetalBarrel_burning_F", 6] call _put;
["Land_PaperBox_closed_F", 9] call _put;
["Land_Pallets_stack_F", 10] call _put;
[_gg, _lz] call BIS_fnc_taskDefend;
if (!isNull _veh && {alive _veh} && {(_veh emptyPositions "gunner") > 0} && {count _guards > 1}) then {private _gu = _guards select 0; _gu assignAsGunner _veh; _gu moveInGunner _veh};
_h setVariable ["MCCMK_baseReady", true];
["base set up at %1 with %2 guards", [mapGridPosition _lz, count _guards]] call _log;
private _spawnBoats = {
	params ["_n"];
	private _bg = createGroup [_es, true];
	private _bs = [];
	for "_i" from 1 to _n do {
		private _p = (_route select 0) getPos [(_i - 1) * 60, 90];
		private _b = createVehicle [selectRandom _boatsPool, _p, [], 0, "NONE"];
		_b setPosASLW [_p select 0, _p select 1, 0];
		private _cg = createVehicleCrew _b;
		[_b, _faction] call MCCMK_fnc_crewFix;
		(units _cg) joinSilent _bg;
		_bs pushBack _b;
	};
	_bg setBehaviour "AWARE";
	_bg setCombatMode "YELLOW";
	{private _wp = _bg addWaypoint [_x, 0]; _wp setWaypointType "MOVE"; _wp setWaypointCompletionRadius 150} forEach (_route select [1, 999]);
	[_bg, _bs]
};
([[2, 2, 2, 3] param [_lvl, 2]] call _spawnBoats) params ["_bg", "_bs"];
private _repl = 1;
private _attackUntil = 0;
private _atBase = false;
private _warnedBoats = false;
private _spotted = false;
private _idleSince = serverTime;
private _end = "";
while {_end == ""} do {
	sleep 10;
	_guards = (units _gg) select {alive _x};
	private _boatsAlive = _bs select {alive _x && {canMove _x} && {count (crew _x) > 0}};
	if (_guards isEqualTo [] && {_boatsAlive isEqualTo []}) exitWith {_end = "destroyed"};
	if (_boatsAlive isEqualTo [] && {_repl > 0} && {_guards isNotEqualTo []}) then {
		_repl = _repl - 1;
		([[2, 2, 2, 3] param [_lvl, 2]] call _spawnBoats) params ["_nbg", "_nbs"];
		_bg = _nbg; _bs = _nbs; _atBase = false; _warnedBoats = false; _attackUntil = 0;
		["replacement boats sent", []] call _log;
	};
	if (!_warnedBoats && {!isNull leader _bg}) then {
		{
			if (!isNull _x && {(_x getVariable ["MCC_side", sideUnknown]) isEqualTo _ps} && {_x getVariable ["MCCMK_radarOn", false]} && {((leader _bg) distance2D _x) < ([_x] call MCCMK_fnc_radarRange)}) exitWith {
				[_x, format ["Surface contacts heading for the coast near grid %1.", mapGridPosition _moor], true] call MCCMK_fnc_navalContact;
				_warnedBoats = true;
			};
		} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
	};
	if (!_atBase && {_attackUntil == 0} && {!isNull leader _bg} && {((leader _bg) distance2D _moor) < 220}) then {_atBase = true; {doStop _x} forEach (units _bg)};
	private _ap = _h getVariable ["MCCMK_attackPos", []];
	if (_ap isNotEqualTo [] && {_atBase}) then {
		for "_w" from (count waypoints _bg) - 1 to 0 step -1 do {deleteWaypoint [_bg, _w]};
		(_bg addWaypoint [_ap, 100]) setWaypointType "SAD";
		_bg setCombatMode "RED";
		_attackUntil = serverTime + 600;
		_atBase = false;
		_h setVariable ["MCCMK_attackPos", []];
		["boats attacking near %1", [mapGridPosition _ap]] call _log;
	};
	if (_attackUntil > 0 && {serverTime > _attackUntil}) then {
		for "_w" from (count waypoints _bg) - 1 to 0 step -1 do {deleteWaypoint [_bg, _w]};
		(_bg addWaypoint [_moor, 0]) setWaypointType "MOVE";
		_bg setCombatMode "YELLOW";
		_attackUntil = 0;
	};
	if (!_spotted) then {
		private _all = _guards + _boatsAlive + ([_veh] select {!isNull _x});
		if ((allGroups findIf {(side _x) isEqualTo _ps && {!isNull leader _x} && {((leader _x) distance2D _lz) < 4000} && {private _g = _x; (_all findIf {(_g knowsAbout _x) > 1.5}) >= 0}}) >= 0) then {
			_spotted = true;
			[_id, _lz, "Enemy boat base"] remoteExec ["MCCMK_fnc_navalBaseMarker", _ps, _id];
			["base spotted by %1", [_ps]] call _log;
		};
	};
	if (((missionNamespace getVariable ["MCC_staticShips", []]) findIf {!isNull _x && {(_x distance2D _lz) < 10000} && {(_x getVariable ["MCCMK_aware", 0]) >= 20}}) >= 0) then {_idleSince = serverTime};
	private _held = (MCCMK_navalZones findIf {((_x select 0) isEqualTo _zoneKey) && {(_x select 3) isEqualTo _es}}) >= 0;
	if (!_held || {(serverTime - _idleSince) > 3600}) exitWith {_end = "packup"};
};
["base at %1: %2", [mapGridPosition _lz, _end]] call _log;
if (_end == "packup") then {
	for "_w" from (count waypoints _bg) - 1 to 0 step -1 do {deleteWaypoint [_bg, _w]};
	private _back = +_route;
	reverse _back;
	{(_bg addWaypoint [_x, 0]) setWaypointType "MOVE"} forEach _back;
	_guards = (units _gg) select {alive _x};
	if (_guards isNotEqualTo []) then {
		private _fit = _helis select {(getNumber (configFile >> "CfgVehicles" >> _x >> "transportSoldier")) >= count _guards};
		([[if (count _fit > 0) then {selectRandom _fit} else {_fb select 0}] select 0, +_edge] call _spawnHeli) params ["_pv", "_pg"];
		_pv doMove _lz;
		private _t0 = serverTime;
		waitUntil {sleep 2; !alive _pv || {(_pv distance2D _lz) < 200} || {(serverTime - _t0) > 600}};
		if (alive _pv) then {
			_pv land "GET IN";
			private _t1 = serverTime;
			waitUntil {sleep 2; !alive _pv || {isTouchingGround _pv} || {(serverTime - _t1) > 90}};
			{_x assignAsCargo _pv} forEach _guards;
			_guards orderGetIn true;
			private _t2 = serverTime;
			waitUntil {sleep 3; !alive _pv || {(_guards findIf {alive _x && {vehicle _x != _pv}}) < 0} || {(serverTime - _t2) > 120}};
			if (alive _pv && {!isNull _veh} && {alive _veh} && {(count crew _veh) == 0}) then {
				_pv flyInHeight 15;
				_pv doMove (getPos _veh);
				private _t3 = serverTime;
				waitUntil {sleep 1; !alive _pv || {(_pv distance2D _veh) < 25} || {(serverTime - _t3) > 60}};
				if (alive _pv && {_pv canSlingLoad _veh}) then {_pv setSlingLoad _veh};
			};
			_pv flyInHeight 80;
			_pv doMove _edge;
			private _t4 = serverTime;
			waitUntil {sleep 3; !alive _pv || {(_pv distance2D _edge) < 900} || {(serverTime - _t4) > 420}};
			if (!isNull (getSlingLoad _pv)) then {deleteVehicle (getSlingLoad _pv)};
			{deleteVehicle _x} forEach (crew _pv);
			deleteVehicle _pv;
		};
	};
	private _t5 = serverTime;
	waitUntil {sleep 5; (_bs findIf {alive _x && {(_x distance2D (_route select 0)) > 900}}) < 0 || {(serverTime - _t5) > 900}};
} else {
	sleep 300;
};
{if (!isNull _x) then {{deleteVehicle _x} forEach crew _x; deleteVehicle _x}} forEach _bs;
{deleteVehicle _x} forEach ((units _gg) select {vehicle _x == _x});
{deleteVehicle _x} forEach (_objs select {!isNull _x && {!(_x isKindOf "AllVehicles") || {count crew _x == 0}}});
[_id, [0, 0], ""] remoteExec ["MCCMK_fnc_navalBaseMarker", _ps, _id];
remoteExec ["", _id];
MCCMK_navalBases = MCCMK_navalBases - [_h];
