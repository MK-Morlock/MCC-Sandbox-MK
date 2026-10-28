//=================================================================MCC_fnc_rtsDestroyLogic==============================================================================
//	Destroy the selected object
//  Parameter(s):
//     	_ctrl: CONTROL
//		_res: resources Needed
//==============================================================================================================================================================================

disableSerialization;
params ["_ctrl"];

if (count MCC_ConsoleGroupSelected <=0) exitWith {};

_answer = ["<t size='0.8' align='center'>Are you sure you want to destroy it?</t>","Destroy",nil,true,true] call MCC_fnc_messageBox;
waituntil {!isnil "_answer"};
if (_answer) then {
	[MCC_ConsoleGroupSelected select 0, true] call MCC_fnc_rtsClearBuilding;
};
