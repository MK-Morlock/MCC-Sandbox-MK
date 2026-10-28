//=================================================================MCC_fnc_addVirtualWeaponCargo===============================================================================
//  Parameter(s):
//     0: OBJECT - objct to which items will be added
//     1: STRING or ARRAY of STRINGs - item class(es) to be added
//==============================================================================================================================================================================
private "_object";
private _classes = [];
_object     = _this param [0, missionnamespace, [missionnamespace,objnull]];
_classes    = _this param [1, [], ["",true,[]]];
disableSerialization;
[_object,_classes,1,1] call MCC_fnc_addVirtualItemCargo;