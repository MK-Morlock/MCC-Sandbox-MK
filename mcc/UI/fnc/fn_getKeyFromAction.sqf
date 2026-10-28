//==================================================================MCC_fnc_getKeyFromAction=================================================================================
//Get the keys name from an action defined in CfgActions
// In: action - string
// Out: keys names - string
//==============================================================================================================================================================================
private _name = "";
params ["_action"];

_name = "";
{
	_name = _name + keyName _x + " ";
} forEach (actionKeys _action);

_name

