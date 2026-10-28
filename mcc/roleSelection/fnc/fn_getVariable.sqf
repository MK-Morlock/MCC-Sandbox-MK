//==================================================================MCC_fnc_getVariable======================================================================================
// Global execute a command on server only  - SERVER ONLY
// Example: [varName,playerID,VarDefaultValue] remoteExec ["MCC_fnc_getVariable", false, false];
//==============================================================================================================================================================================

private "_id";
private _value = [];
private "_varType";
private _valueExist = false;
params ["_varName", "_player", "_varDefault"];
_varType	= switch (toUpper (_this select 3)) do {
					case "STRING" :	{""};
					case "ARRAY" : 	{[]};
					case "SCALAR" : {0};
				};

if(!isServer) exitWith {};
if (isnil "_player") exitWith {};

_id = getPlayerUID _player;
_value = [name _player, _id, _varName, "read",_varType,true] call MCC_fnc_handleDB;
_valueExist = str _value != str _varType;

if (!_valueExist) then {
	_null = [name _player, _id, _varName, "write",_varDefault,true] call MCC_fnc_handleDB;
	_value = _varDefault;
};

//returns value
[_varName,_value,_id] remoteExec ["MCC_fnc_setValue", _player, false];