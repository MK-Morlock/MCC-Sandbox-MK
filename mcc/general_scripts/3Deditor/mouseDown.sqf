
//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
private "_posX";
private "_posY";
private "_shift";
private "_ctrlKey";
private "_alt";
private "_click";
private "_mapPos";
disableSerialization;

_click = _this select 1;  //0 - click 1- doubleClick
params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;
_posX = _params select 2; 
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;


MCC_mouseButtonDown = true;	//Mouse state
MCC_mouseButtonUp = false; 

if (_click == 1) exitWith 
{
	if (isnil "MCC_3D_CAM") exitWith {}; 
	_mapPos = _ctrl ctrlMapScreenToWorld [_posX,_posY];
	if (!isNil "MCC_3D_moveTo") then {[_mapPos] call MCC_3D_moveTo} else {MCC_3D_CAM setposATL [_mapPos select 0, _mapPos select 1, 15]};
	_ctrl ctrlMapAnimAdd [0, 0.15, getpos MCC_3D_CAM];
};
