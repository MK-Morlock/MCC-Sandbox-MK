params [["_ship", objNull, [objNull]], ["_kind", "recon", [""]], ["_es", east, [east]], ["_faction", "", [""]], ["_fromDir", 0, [0]], ["_count", 1, [0]], ["_lk", [], [[]]]];
if (!isServer || {isNull _ship}) exitWith {};
private _pool = [_faction, ["air", "anyair"] select (_kind == "recon")] call MCCMK_fnc_factionAssets;
if (_pool isEqualTo []) then {_pool = [_faction, "anyair"] call MCCMK_fnc_factionAssets};
if (_pool isEqualTo []) exitWith {["INFO", "naval", "%1: enemy faction has no aircraft", [_kind]] call MCC_fnc_log};
private _target = if (count _lk > 1) then {+_lk} else {getPosWorld _ship};
if (_kind == "recon") then {_target = _target getPos [random 500, random 360]};
private _edge = [_target, _fromDir] call MCCMK_fnc_edgePos;
private _grps = [];
for "_i" from 1 to _count do {
	private _p = _edge getPos [(_i - 1) * 300, _fromDir + 90];
	_p set [2, 450];
	private _v = createVehicle [selectRandom _pool, _p, [], 0, "FLY"];
	_v setPosASL [_p select 0, _p select 1, 450];
	_v setDir (_p getDir _target);
	_v setVelocityModelSpace [0, 80, 0];
	private _g = createVehicleCrew _v;
	[_v, "naval air"] call MCCMK_fnc_airTrack;	//(MK) debug
	[_v, _faction] call MCCMK_fnc_factionCrew;
	if ((side _g) != _es) then {private _ng = createGroup [_es, true]; (units _g) joinSilent _ng; _g = _ng};
	_g setBehaviour (["COMBAT", "AWARE"] select (_kind == "recon"));
	_g setCombatMode (["RED", "GREEN"] select (_kind == "recon"));
	_v flyInHeight ([250, 400] select (_kind == "recon"));
	private _wp = _g addWaypoint [_target, 0];
	_wp setWaypointType (["SAD", "LOITER"] select (_kind == "recon"));
	if (_kind == "recon") then {_wp setWaypointLoiterRadius 900; _wp setWaypointLoiterType "CIRCLE_L"};
	_grps pushBack [_g, _v];
};
["INFO", "naval", "%1 x%2 from the map edge towards %3 (last known grid %4)", [_kind, count _grps, _ship getVariable ["MCC_LHDDisplayName", "ship"], mapGridPosition _target]] call MCC_fnc_log;
private _start = serverTime;
private _warned = false;
private _leaving = false;
while {(_grps findIf {alive (_x select 1)}) >= 0 && {(serverTime - _start) < 1200}} do {
	sleep 5;
	private _alive = _grps select {alive (_x select 1)};
	if (_alive isEqualTo []) exitWith {};
	private _lead = (_alive select 0) select 1;
	if (!_warned) then {
		{
			private _s = _x;
			if (!isNull _s && {(_s getVariable ["MCC_side", sideUnknown]) isNotEqualTo _es} && {_s getVariable ["MCCMK_radarOn", false]} && {(_lead distance2D _s) < ([_s] call MCCMK_fnc_radarRange)}) then {
				if (_kind == "recon") then {[_s, "Aircraft overhead - possibly reconnaissance.", true] call MCCMK_fnc_navalContact} else {
					[_s, format ["Air contacts inbound, bearing %1, %2 km.", round (_s getDir _lead), (round ((_s distance2D _lead) / 100)) / 10], true] call MCCMK_fnc_navalContact;
				};
				_warned = true;
			};
		} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
	};
	private _done = if (_kind == "recon") then {(serverTime - _start) > 360} else {
		((serverTime - _start) > 780) || {(_grps findIf {alive (_x select 1) && {((magazinesAllTurrets (_x select 1)) findIf {(_x select 2) > 0}) >= 0}}) < 0}
	};
	if (_done && {!_leaving}) then {
		_leaving = true;
		{
			_x params ["_g", "_v"];
			for "_w" from (count waypoints _g) - 1 to 0 step -1 do {deleteWaypoint [_g, _w]};
			_g setCombatMode "BLUE";
			_g setBehaviour "CARELESS";
			private _wp = _g addWaypoint [_edge, 0];
			_wp setWaypointType "MOVE";
		} forEach _grps;
	};
	if (_leaving) then {
		{
			_x params ["_g", "_v"];
			if (alive _v && {(_v distance2D _edge) < 900}) then {{deleteVehicle _x} forEach crew _v; deleteVehicle _v};
		} forEach _grps;
	};
};
{
	_x params ["_g", "_v"];
	if (alive _v) then {{deleteVehicle _x} forEach crew _v; deleteVehicle _v};
	{deleteVehicle _x} forEach (units _g);
	deleteGroup _g;
} forEach _grps;
