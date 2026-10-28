//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
private "_posX";
private "_posY";
private "_shift";
private "_ctrlKey";
private "_alt";
disableSerialization;
 
params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;
_posX = _params select 2; 
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;

MCC_ConsoleMouseButtonDown = false;	//Mouse state
MCC_ConsoleMouseButtonUp = true;