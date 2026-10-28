//==================================================================MCC_fnc_groupchat======================================================================================
// Send chat across MP
// Example: [[netid _unit,_unit],_text,_local] remoteExec ["MCC_fnc_groupchat", true, false];
// Params: 
//	_unit: object, brocadcasting unit
//	_text: string, text to broadcast
//	_local: bolean, false - all clients and server, true - only where the unit is local
//==============================================================================================================================================================================
private _unit = if (((_this select 0) select 0) == "") then {(_this select 0) select 1} else {objectFromNetID ((_this select 0) select 0)};
private _text = _this select 1;
private _local = _this select 2;
if (_local && !(local _unit) || (isDedicated)) exitWith {};
_unit globalchat _text;
