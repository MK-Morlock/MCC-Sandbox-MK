//==================================================================MCC_fnc_setValue======================================================================================
// Sets variable with custom value on a specific player
// Input:
//	_varName1: 	String - variable Name
//	_value:		Anything - Value
//	_id  			String - player ID where to set  the value
//
//Outout: <NOTHING>
//
// Example: [_varName1, _value1,_id], "MCC_fnc_setValue", true, false] spawn BIS_fnc_MP;
//==============================================================================================================================================================================

params ["_varName", "_value", "_id"];

if (getPlayerUID player == _id) then {
	if (typeName _value == "STRING") then {
		call compile format ["%1 = '%2';",_varName,_value];
	} else {
		call compile format ["%1=%2;",_varName,_value];
	};
};

