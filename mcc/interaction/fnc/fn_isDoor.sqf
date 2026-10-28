//==================================================================MCC_fnc_isDoor========================================================================================
// is the player facing a door
// Example:[_object]  call MCC_fnc_isDoor;
// <IN>
//	_target:					Object- object.
//
// <OUT>
//		[_door,_animation,_phase,_closed]
//=======================================================================================================================================================================

#define MCC_ARMA2MAPS ["takistan","zargabad","chernarus","utes","sara","saralite","sara_dbe1","chernarus_summer","lingor3","kunduz","panthera3","fallujah"]

private _doorTypes = [];
private _loadName = "";
private _optionalDoors = [];
private _door = "";
private "_typeOfSelected";
private "_animation";
private _phase = 0;
private _closed = false;
params ["_object"];

//No house found - exit
if !(_object isKindof "house" || _object isKindof "wall") exitWith {["","",0,false]};

_doorTypes	= ["door", "hatch"];
_loadName	= "GEOM";

_optionalDoors = [_object, _loadName] intersect [asltoatl (eyepos player),(player modelToworld [0, 3, 0])];

_door = "";
{
	_typeOfSelected = _x select 0;
	{
		if ([_x,_typeOfSelected] call BIS_fnc_inString) exitWith {_door = _typeOfSelected};
	} foreach _doorTypes;

} forEach _optionalDoors;

//No door found - exit
if (_door == "") exitWith {["","",0,false]};

_animation = _door + "_rot";

_phase = if ((_object animationPhase _animation) > 0) then {0} else {1};

_closed = _phase == 1;
[_door,_animation,_phase,_closed]
