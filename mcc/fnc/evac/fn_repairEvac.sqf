//===================================================================MCC_fnc_repairEvac======================================================================================
// Repair evac helicopter
// Params:
// 	_vehicle: OBJECT
// 	_onlyAI: BOOLEAN - only repair AI vehicle
//==============================================================================================================================================================================
private _vehicle = _this param [0, objNull, [objNull]];
private _onlyAI = _this param [1, false, [false]];

if (isNull _vehicle) exitWith {};
if (_onlyAI && isPlayer driver _vehicle) exitWith {};

_vehicle setfuel 1;
_vehicle setDamage 0;
