//======================================================MCC_fnc_MWSpawnInfantry==================================================================================================
// Spawn infantry groups in the zone.
// Example:[_totalEnemyUnits,_zoneNumber] call MCC_fnc_MWSpawnInfantry;
// Return - handler
//===============================================================================================================================================================================
private _menArraySpecial = [];
private _unitPlaced = 0;
private _group = grpNull;
private _unitsArray = [];
params [
	["_totalEnemyUnits", 0, [0]],
	["_zoneNumber", 0, [0, ""]],
	["_spawnbehavior", "", ["", []]],
	["_side", sideUnknown, [sideUnknown]]
];

_menArraySpecial = [];
if ((count MCC_MWGroupArrayMenRecon)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenRecon};
if ((count MCC_MWGroupArrayMenSniper)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenSniper};
if ((count MCC_MWGroupArrayMenSupport)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenSupport};

_unitPlaced = 0;
if (isnil "MCC_customGroupsSaveMW") then {MCC_customGroupsSaveMW = []};

_unitsArray = MCC_MWGroupArrayMen + MCC_customGroupsSaveMW;

if (count _unitsArray > 0) then
{
	//Infantry
	while {_unitPlaced < _totalEnemyUnits} do
	{
		//Regular or SF
		if (random 1 < 0.2 && ((count _menArraySpecial)>0)) then
		{
			_group = _menArraySpecial call BIS_fnc_selectRandom;
		}
		else
		{
			_group = _unitsArray call BIS_fnc_selectRandom;
		};

		//count units
		_unitPlaced = _unitPlaced + (_group select 1);

		//Spawn them
		[_zoneNumber,"GROUP","LAND",true,_group select 0,_group select 2,_spawnbehavior,_group select 0,_side] call MCC_fnc_MWSpawnInZone;
	};
}
else
{
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC: Mission Wizard Error: No group available in the selected enemy faction"};
};

_unitPlaced;





