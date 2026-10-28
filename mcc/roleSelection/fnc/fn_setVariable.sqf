//==================================================================MCC_fnc_setVariable======================================================================================
// Global execute a command on server only  - SERVER ONLY
// Example: [varName,playerID,VarValue] remoteExec ["MCC_fnc_setVariable", false, false];
//==============================================================================================================================================================================

private "_id";
private _varType = "";
private "_name";
params ["_varName", "_player", "_value"];
_varType	= toUpper (_this select 3);

if(!isServer) exitWith {};
if (isnil "_player") exitWith {};

if (typeName _player == typeName []) then {
	_id = _player select 0;
	_name = _player select 1;
} else {
	_id = getPlayerUID _player;
	_name = name _player;
};


[_name, _id, _varName, "write",_value,true] call MCC_fnc_handleDB;