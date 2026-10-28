//==================================================================MCC_fnc_getKeyFromCBA=================================================================================
//Get a pretty name from CBA key binds
// In: 	_modName - string
//		_ActionName - string
// Out: keys names - string
//==============================================================================================================================================================================
private "_keySetup";
private "_specKeys";
private _name = "";
params ["_modName", "_ActionName"];

_name = "";
_keySetup = (([_modName,_ActionName] call CBA_fnc_getKeybind) select 5) ;
if (isNil "_keySetup") exitWith {};
if (count _keySetup == 0) exitWith {};

_specKeys = _keySetup select 1;

{
	if (_specKeys select _foreachindex) then {_name = _name + _x + " + "};
} forEach ["Shift","Ctrl","Alt"];

_name = _name + (keyName (_keySetup select 0));

_name

