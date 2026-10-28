//==================================================================MCC_fnc_radioSupport=========================================================================================
// Broadcast radio support to all elements not including the broadcaster group
// Example:[_caller, _messege] call MCC_fnc_radioSupport;
//===============================================================================================================================================================================
params ["_caller", "_messege"];

//No dedi no HC
if (isDedicated || !hasInterface) exitWith {};

//Do not use radio on the group calling it
if (_caller in (units player)) exitWith {};

_caller globalRadio _messege;
