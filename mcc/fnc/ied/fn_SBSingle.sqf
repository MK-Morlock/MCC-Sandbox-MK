//==================================================================MCC_fnc_SBSingle===============================================================================================
// Place suicide bomber
// Example: [_pos, _trapkind, _trapvolume, _IEDExplosionType, _iedside] spawn MCC_fnc_SBSingle;
// <in>: 	_pos 			= position, center of the explosion.
// 		_trapkind 		= string, unit's vehicle class
//		_trapvolume 		= String "small", "medium", "large"
//		_IEDExplosionType	= Integer, 1- deadly 	2- Disabling	3- Fake
//		_iedside 			= side, which side trigger the armed civilian
// <out>	unit, object
//=================================================================================================================================================================================

//Made by Shay_Gman (c) 09.10
private _group = grpNull;
private _sb = objNull;

 if (!isServer) exitWith {};

params ["_pos", "_trapkind", "_trapvolume", "_IEDExplosionType", "_iedside"];

_group = creategroup civilian;
_sb	= _group createunit [_trapkind, _pos, [], 0, "NONE"];

_init = FORMAT [";[_this,%1,'%2',%3] spawn MCC_fnc_manageSB;"
				, str ((if (_iedside isEqualType []) then {_iedside} else {[_iedside]}) apply {if (_x isEqualType "") then {_x} else {str _x}})
				, _trapvolume
				, _IEDExplosionType
				];

["MCC_fnc_setVehicleInit", [[netid _sb,_sb], _init], 2, false] call MCC_fnc_secRemote;

{_x addCuratorEditableObjects [[_sb],false]} forEach allCurators;

_sb;