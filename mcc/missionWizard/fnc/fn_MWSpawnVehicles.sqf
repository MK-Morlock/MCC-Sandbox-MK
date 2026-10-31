//======================================================MCC_fnc_MWSpawnVehicles==================================================================================================
// Spawn infantry groups in the zone.
// Example:[_totalEnemyUnits,_zoneNumber,_arrayGroup,_arrayUnits,_priceGroup,_priceUnit] call MCC_fnc_MWSpawnVehicles;
// Return - handler
//=====================================================================================================================================================================
private _unitPlaced = 0;
private _spawnbehavior = "";
private _group = [];
private _price = 0;
params [
	["_totalEnemyUnits", 0, [0]],
	["_zoneNumber", 0, [0, ""]],
	["_arrayGroup", [], [[]]],
	["_arrayUnits", [], [[]]],
	["_priceGroup", 0, [0]],
	["_priceUnit", 0, [0]],
	["_simType", "", [""]],
	["_side", sideUnknown, [sideUnknown]]
];

if ((missionNamespace getVariable ["MCC_MWVehicleSpawnMode", 1]) == 0) exitWith {
_unitPlaced = 0;
if (count _arrayUnits > 0) then
{
	while {_unitPlaced < (_totalEnemyUnits)} do
	{
		//Behavior
		_spawnbehavior	= ["MOVE","NOFOLLOW"] call BIS_fnc_selectRandom;

		//Group or units
		if (random 1 < 0.5 && ((count _arrayGroup)>0)) then
			{
				//Group
				_group = _arrayGroup call BIS_fnc_selectRandom;
				_price = (_priceUnit * (_group select 1));

				//Spawn a group only if it isn't too much
				if !(_price > _totalEnemyUnits) then
				{
					_unitPlaced = (_unitPlaced + (_group select 1))*_priceGroup;

					//Spawn them
					[_zoneNumber,"GROUP",_simType,true,_group select 0,_group select 2,_spawnbehavior,_group select 0,_side] call MCC_fnc_MWSpawnInZone;
				};
			}
			else
			{
				if (count _arrayUnits > 0) then
				{
					//Units
					_group = _arrayUnits call BIS_fnc_selectRandom;
					_unitPlaced = _unitPlaced + _priceUnit;

					//Spawn them
					[_zoneNumber,"VEHICLE",_simType,true,_group select 1,str (_group select 2),_spawnbehavior,(_group select 3) select 0,_side] call MCC_fnc_MWSpawnInZone;
				}
				else
				{
					if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC: Mission Wizard Error: No vehicles available in the selected enemy faction"};
				};
			};
	};
}
else
{
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC: Mission Wizard Error: No vehicles available in the selected enemy faction"};
};
_unitPlaced;
};

private _allowedVeh = [];
{
	{
		if (_x isEqualType [] && {count _x > 1} && {(_x select 1) isEqualType ""}) then {_allowedVeh pushBackUnique toLower (_x select 1)};
	} forEach (missionNamespace getVariable [_x, []]);
} forEach ["MCC_MWunitsArrayCar", "MCC_MWunitsArrayArmored", "MCC_MWunitsArraySupport", "MCC_MWunitsArrayAutonomous", "MCC_MWunitsArrayShip"];

private _eligible = [];
{
	private _cfg = call compile (_x select 2);
	private _vehs = (("true" configClasses _cfg) apply {getText (_x >> "vehicle")}) select {((_x isKindOf "LandVehicle") || {_x isKindOf "Ship"}) && {!(_x isKindOf "CAManBase")}};
	if (((count _vehs) in [1, 2]) && {(_vehs findIf {!((toLower _x) in _allowedVeh)}) < 0}) then {_eligible pushBack [_x, count _vehs]};
} forEach (_arrayGroup select {_x isEqualType [] && {count _x > 2} && {(_x select 2) isEqualType ""}});

private _groupChance = [0.25, 0.33] select (_arrayGroup isEqualTo (missionNamespace getVariable ["MCC_MWGroupArrayArmored", []]));
private _poolUnits = +_arrayUnits;
private _usedGroups = [];
_totalEnemyUnits = _totalEnemyUnits * (0.85 + random 0.3);

_unitPlaced = 0;
if (count _arrayUnits > 0 && {_priceUnit > 0}) then {
	while {_unitPlaced < _totalEnemyUnits} do {
		_spawnbehavior = selectRandom ["MOVE", "NOFOLLOW"];
		private _left = _totalEnemyUnits - _unitPlaced;
		private _fit = _eligible select {((_x select 1) - 1) * _priceUnit < _left};
		if (count _fit > 0 && {random 1 < _groupChance}) then {
			private _fresh = _fit select {!((_x select 0) in _usedGroups)};
			private _pick = selectRandom ([_fit, _fresh] select (count _fresh > 0));
			_group = _pick select 0;
			_usedGroups pushBack _group;
			_unitPlaced = _unitPlaced + ((_pick select 1) * _priceUnit);
			[_zoneNumber,"GROUP",_simType,true,_group select 0,_group select 2,_spawnbehavior,_group select 0,_side] call MCC_fnc_MWSpawnInZone;
		} else {
			if (_poolUnits isEqualTo []) then {_poolUnits = +_arrayUnits};
			_group = selectRandom _poolUnits;
			_poolUnits deleteAt (_poolUnits find _group);
			_unitPlaced = _unitPlaced + _priceUnit;
			[_zoneNumber,"VEHICLE",_simType,true,_group select 1,str (_group select 2),_spawnbehavior,(_group select 3) select 0,_side] call MCC_fnc_MWSpawnInZone;
		};
	};
} else {
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC: Mission Wizard Error: No vehicles available in the selected enemy faction"};
};
_unitPlaced
