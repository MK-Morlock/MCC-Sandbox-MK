//=================================================================MCC_fnc_rtsCreateMeds==============================================================================
//	Create Meds
//  Parameter(s):
//     	_ctrl: CONTROL
//		_res: resources Needed
//==============================================================================================================================================================================
private _res = [];
private "_side";
disableSerialization;
params ["_ctrl"];
_res = param [1, [], [[]]];
_side = playerSide;

//Start building time
private "_obj";
playsound "click";
if (count MCC_ConsoleGroupSelected <=0) exitWith {};
_obj = MCC_ConsoleGroupSelected select 0;

//Start building time
if !([_obj,_res] call MCC_fnc_rtsBuildingProgress) exitWith {};

private _resVar = format ["MCC_res%1", _side];
_resArray = missionNamespace getvariable [_resVar,[]];
[9989,"50 Meds Added",5,true] call MCC_fnc_setIDCText;
_resArray set [4,(_resArray select 4)+50];
 missionNamespace setvariable [_resVar,_resArray,true];