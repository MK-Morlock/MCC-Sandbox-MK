/*
	MCCMK_fnc_airPatrolList - the aircraft a faction can send on an Air Patrol, from its pools (MCCMK_fnc_pool - its own,
	a sibling's, then the base game's with the vanilla fallback setting): combat jets, armed helicopters, armed drones -
	no more than three of each class, one per name. Each: [class, name, class kind, air-to-air, ground, ammo, fuel,
	minutes on station]. The cost: ammo per call and fuel per minute by its class (fighter 400 / 40, ground-attack jet
	350 / 30, attack helicopter 250 / 16, light helicopter 100 / 10, drone 120 / 8), ammo up to 10% more or less for
	more or fewer pylons than its class usually has; jets and drones 8 minutes, helicopters 6. [faction]
*/
params [["_faction", "", [""]]];
private _cands = [];
{_cands append ([_faction, _x] call MCCMK_fnc_pool)} forEach ["PlaneCAS", "Plane", "HeliArmed", "UAV"];
_cands = _cands arrayIntersect _cands;
private _table = createHashMapFromArray [["fighter", [400, 40, 10, 8]], ["ground", [350, 30, 10, 8]], ["attack", [250, 16, 6, 6]], ["light", [100, 10, 2, 6]], ["drone", [120, 8, 2, 8]]];
private _order = ["fighter", "ground", "attack", "light", "drone"];
private _out = [];
private _names = [];
private _per = createHashMap;
{
	private _cls = _x;
	private _cfg = configFile >> "CfgVehicles" >> _cls;
	if (isClass _cfg && {_cls isKindOf "Air"} && {!(_cls isKindOf "ParachuteBase")} && {getNumber (_cfg >> "transportSoldier") <= 4}) then {
		([_cls] call MCCMK_fnc_airPatrolCaps) params ["_aa", "_ag", "_type", "_np"];
		private _name = getText (_cfg >> "displayName");
		if ((_aa || _ag) && {!(_name in _names)} && {(_per getOrDefault [_type, 0]) < 3}) then {
			(_table get _type) params ["_ammo0", "_fuelMin", "_avgPyl", "_mins"];
			private _f = ((1 + (_np - _avgPyl) / (_avgPyl * 4)) max 0.9) min 1.1;
			private _ammo = (round (_ammo0 * _f / 10)) * 10;
			_out pushBack [_order find _type, _name, _cls, _type, _aa, _ag, _ammo, _fuelMin * _mins, _mins];
			_names pushBack _name;
			_per set [_type, (_per getOrDefault [_type, 0]) + 1];
		};
	};
} forEach _cands;
_out sort true;
_out apply {[_x select 2, _x select 1, _x select 3, _x select 4, _x select 5, _x select 6, _x select 7, _x select 8]}
