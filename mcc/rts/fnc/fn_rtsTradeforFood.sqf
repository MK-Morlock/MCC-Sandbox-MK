//=================================================================MCC_fnc_rtsTradeforFood==============================================================================
//	Trade resources for food
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
private _cfgName = missionNamespace getVariable [format ["MCC_ctrlData_%1", ctrlIDC _ctrl], ""];
private _gain = getArray ((if (isClass (missionconfigFile >> "cfgRtsActions" >> _cfgName)) then {missionconfigFile} else {configFile}) >> "cfgRtsActions" >> _cfgName >> "gain");
private _food = if (count _gain > 0) then {(_gain select 0) select 1} else {50};
[9989,format ["%1 Food Added", _food],5,true] call MCC_fnc_setIDCText;
_resArray set [3,(_resArray select 3)+_food];
missionNamespace setvariable [_resVar,_resArray,true];