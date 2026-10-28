//==================================================================MCC_fnc_doorUnlock==============================================================================
// Unlock door
// Example:[_object] spawn MCC_fnc_doorUnlock;
// <IN>
//	_object:					Object- object.
//
// <OUT>
//		<nothing>
//====================================================================================================================================================================
params ["_object"];

private "_door";
private "_animation";
private "_phase";
private "_closed";
private _tempArray = [];
_tempArray = [_object]  call MCC_fnc_isDoor;
_door = _tempArray select 0;
_animation = _tempArray select 1;
_phase = _tempArray select 2;
_closed = _tempArray select 3;

if (_door == "") exitWith {};

closedialog 0;
["Unlocking",10] call MCC_fnc_interactProgress;
_object setVariable [format ["bis_disabled_%1",_door],0,true];
