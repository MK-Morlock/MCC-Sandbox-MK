//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
private "_posX";
private "_posY";
private "_shift";
private "_ctrlKey";
private "_alt";
disableSerialization;
#define MCC_sqlpdaMenu0 (uiNamespace getVariable "MCC_sqlpdaMenu0")
#define MCC_sqlpdaMenu1 (uiNamespace getVariable "MCC_sqlpdaMenu1")
#define MCC_sqlpdaMenu2 (uiNamespace getVariable "MCC_sqlpdaMenu2")
#define MCC_CONSOLEINFOLIVEFEED (uiNamespace getVariable "MCC_CONSOLEINFOLIVEFEED")
#define MCC_CONSOLEINFOTEXT (uiNamespace getVariable "MCC_CONSOLEINFOTEXT")

params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;
_posX = _params select 2;
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;

//Mouse state
MCC_ConsoleMouseButtonDown = true;
MCC_ConsoleMouseButtonUp = false;
if (isnil "MCC_doubleClicked") then {MCC_doubleClicked =false};

if ((_pressed == 0 || _pressed == 1) && !MCC_doubleClicked) then 								//Close Group info control
{
	{
		_x ctrlshow false;
	} foreach [MCC_sqlpdaMenu0,MCC_sqlpdaMenu1,MCC_sqlpdaMenu2,MCC_CONSOLEINFOLIVEFEED,MCC_CONSOLEINFOTEXT];
	if (!isNil "MCC_fnc_SQLPDAMenuBg") then {[] call MCC_fnc_SQLPDAMenuBg};
};
