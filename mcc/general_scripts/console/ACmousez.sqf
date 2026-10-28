#define MCC_CONSOLE_AC_ZOOM_TEXT 5015
//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
disableSerialization;

params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;

if (isNil "MCC_fakeAC") exitWith {};
if (isNull MCC_fakeAC) exitWith {};

private _levels = [25 / 120, 10.5 / 120, 2.5 / 120];
private _idx = 0;
{if (abs (MCC_fakeACFOV - _x) < abs (MCC_fakeACFOV - (_levels select _idx))) then {_idx = _forEachIndex}} forEach _levels;
_idx = (_idx + ([1, -1] select (_pressed < 0))) max 0 min 2;
MCC_fakeACFOV = _levels select _idx;
MCC_fakeAC camsetFOV MCC_fakeACFOV;
MCC_fakeAC camCommit 0;
ctrlSetText [MCC_CONSOLE_AC_ZOOM_TEXT, ["WFOV", "MFOV", "NFOV"] select _idx];
[findDisplay 5010, _idx] call MCC_fnc_acReticle;
