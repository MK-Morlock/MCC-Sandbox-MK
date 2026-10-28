//Cruise missile feed: the mouse does not steer or fire (MCC_consoleCruise)
if (missionNamespace getVariable ["MCC_consoleCruise", false]) exitWith {};
#define MCC_CONSOLE_UAV_MISSILE_COUNT 9110
//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
private "_posX";
private "_posY";
private "_shift";
private "_ctrlKey";
private "_alt";
private "_rocket";
private _objects = [];
disableSerialization;

params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;
_posX = _params select 2;
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;

if (isNil "MCC_ConolseUAV" || isNil "MCC_fakeUAV") exitWith {};
if (isNull MCC_ConolseUAV || !alive MCC_ConolseUAV) exitWith {};

//Control camera
if (_pressed==1) then  {
	MCC_uavPos = [0.5,0.44];
	if (MCC_ConsoleUAVMouseButtonDown) then {MCC_ConsoleUAVMouseButtonDown = false} else {
		MCC_ConsoleUAVMouseButtonDown = true};
};

 //Fire Missile
if (_pressed==0) then {
	MCC_ConsoleUAVmissiles = [MCC_ConolseUAV] call MCC_fnc_uavPickWeapon;
	private _aimOk = [MCC_ConolseUAV, MCC_ConsoleUAVmissiles, getPos MCC_fakeUAVCenter] call MCC_fnc_uavCanAim;
	if !((MCC_ConsoleUAVmissiles select 0) != "" && {(MCC_ConsoleUAVmissiles select 1) > 0} && {_aimOk select 0}) then {
		["DEBUG", "console", "UAV view: no shot from %1 - %2", [typeOf MCC_ConolseUAV, if ((MCC_ConsoleUAVmissiles select 0) == "") then {"no missile or bomb found"} else {if ((MCC_ConsoleUAVmissiles select 1) <= 0) then {"out of ammunition"} else {_aimOk select 1}}]] call MCC_fnc_log;
	};
	if ((MCC_ConsoleUAVmissiles select 0) != "" && (MCC_ConsoleUAVmissiles select 1) > 0 && {_aimOk select 0}) then {
		playSound "missileLunch";
		if (local MCC_ConolseUAV) then {[MCC_ConolseUAV, getPosATL MCC_fakeUAVCenter, 0, 4] call MCC_fnc_casGuideArm} else {[MCC_ConolseUAV, getPosATL MCC_fakeUAVCenter, 0, 4] remoteExec ["MCC_fnc_casGuideArm", MCC_ConolseUAV]};
		[1,""] execVM MCC_path+"mcc\general_scripts\console\uavControl.sqf";
		["DEBUG", "console", "UAV view: %1 fires its own %2, guided onto %3", [typeOf MCC_ConolseUAV, MCC_ConsoleUAVmissiles select 2, (getPosATL MCC_fakeUAVCenter) apply {round _x}]] call MCC_fnc_log;
		ctrlSetText [MCC_CONSOLE_UAV_MISSILE_COUNT, format ["%1 #: %2",MCC_ConsoleUAVmissiles select 0,(MCC_ConsoleUAVmissiles select 1)-1]];
	};
};
