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





