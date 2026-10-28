//Cruise missile feed: the mouse does not steer or fire (MCC_consoleCruise)
if (missionNamespace getVariable ["MCC_consoleCruise", false]) exitWith {};
#define MCC_CONSOLE_ZOOM_TEXT 9113
//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
disableSerialization;
 if (isNil "MCC_ConolseUAV" || isNil "MCC_fakeUAV" || isNil "MCC_fakeUAVFOV") exitWith {};

params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;

if (_pressed<0) then {
	MCC_fakeUAVFOV = MCC_fakeUAVFOV + 0.1;
	} else {
		MCC_fakeUAVFOV = MCC_fakeUAVFOV - 0.1;
		};
if (MCC_fakeUAVFOV <= 0.02) then {MCC_fakeUAVFOV = 0.02};
if (MCC_fakeUAVFOV >= 0.9) then {MCC_fakeUAVFOV = 0.9};
MCC_fakeUAV camsetFOV MCC_fakeUAVFOV;
MCC_fakeUAV camCommit 0.1;
ctrlSetText [MCC_CONSOLE_ZOOM_TEXT, format ["ZOOM X %1",floor (10-(10*MCC_fakeUAVFOV))]];