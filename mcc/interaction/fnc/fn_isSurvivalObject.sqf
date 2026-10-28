//=====================================================MCC_fnc_isSurvivalObject=====================================================================================
// is an object is a survival object
// Example:[]  call MCC_fnc_isSurvivalObject;
// <IN>
//	none
//
// <OUT>
//		Boolean
//==============================================================================================================================================================
private ["_positionStart","_positionEnd","_pointIntersect","_selected","_resault","_objArray"];
if !(missionNamespace getVariable ["MCC_surviveModAllowSearch",false]) exitWith {false};

// <optional IN> 0: OBJECT - the object to check (ACE interaction menu passes its target); default: what the player looks at
params [["_selected", objNull, [objNull]]];
_resault = false;

if (isNull _selected) then {
	_positionStart 	= eyePos player;
	_positionEnd 	= ATLtoASL screenToWorld [0.5,0.5];
	_pointIntersect = lineIntersectsWith [_positionStart, _positionEnd, player, objNull, true];
	if (count _pointIntersect > 0) then {_selected = _pointIntersect select ((count _pointIntersect)-1)};
};

if (!isNull _selected && {player distance _selected < 5} && {isNull attachedTo _selected} && {([_selected] call MCC_fnc_survivalObjectType) != ""}) then {
	_resault = true;
};

_resault