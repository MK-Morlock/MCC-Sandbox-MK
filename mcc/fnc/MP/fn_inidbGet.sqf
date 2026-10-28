//==================================================================MCC_fnc_LootGet======================================================================================
// Global execute a command on server only  - SERVER ONLY
// Example: [varName,playerID,VarDefaultValue] remoteExec ["MCC_fnc_getVariable", false, false];
//==============================================================================================================================================================================
private _varName1 = "";
private _varName2 = "";
private _varName3 = "";
private _read = false;
private "_id";
private _value = [];
private _player = objNull;
private _varType = "";
private "_var";
_varName1 	=  _this param [0, "", [""]];
_varName2 	=  _this param [1, "", [""]];
_varName3 	=  _this param [2, "", [""]];
_varType	=  _this param [3, "", [""]];
_player		= _this param [4, objNull, [objNull]];
_read		= _this param [5, true, [true]];
_value		= _this param [6, []];

_var = switch (toupper _varType) do {
			    case "ARRAY": {[]};
			    case "SCALAR": {0};
			    default {""};
			};

//systemChat format ["this: %1 %2 %3 %4", _varName1, _varName2, _varName3, _varType];
if(!isServer) exitWith {};
if (isNull _player || !(isPlayer _player)) exitWith {};

_id = getPlayerUID _player;

if (_read) exitWith {
	if (missionNamespace getVariable ["MCC_iniDBenabled",false]) then {
			_value = [_varName1, _varName2, _varName3, "read",_var,_varName1] call MCC_fnc_handleDB;
		} else {
			_value = missionNamespace getVariable [_varName1 + _varName2 + _varName3,_var];
		};

	//returns value
	[_value,_id] remoteExec ["MCC_fnc_inidbSet", _player, false];
};


//Update server
if (missionNamespace getVariable ["MCC_iniDBenabled",false]) then {
	[_varName1, _varName2, _varName3, "write",_value,_varName1] call MCC_fnc_handleDB;
} else {
	missionNamespace setVariable [_varName1 + _varName2 + _varName3,_value];
};

true;