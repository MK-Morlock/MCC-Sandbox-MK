//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
disableSerialization;
 
params ["_params"];

_ctrl = _params select 0;
MCCDispPosXY = _ctrl ctrlmapscreentoworld [_params select 1,_params select 2];
