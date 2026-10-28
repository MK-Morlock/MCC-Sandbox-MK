#define mcc_playerConsole3_IDD 5010

#define MCC_CONSOLE_AC_TARGET 5016
#define MCC_CONSOLE_AC_MISSILE_COUNT 5012
#define MCC_CONSOLE_AC_MISSILE_COUNT2 5019
#define MCC_CONSOLE_AC_MISSILE_COUNT3 5020
private _control1 = controlNull;
private _control2 = controlNull;
private _control3 = controlNull;
private _mccdialog = controlNull;
disableSerialization;
_mccdialog = findDisplay mcc_playerConsole3_IDD;
_control1 = _mccdialog displayCtrl MCC_CONSOLE_AC_MISSILE_COUNT;
_control2 = _mccdialog displayCtrl MCC_CONSOLE_AC_MISSILE_COUNT2;
_control3 = _mccdialog displayCtrl MCC_CONSOLE_AC_MISSILE_COUNT3;

MCC_ConsoleACweaponSelected = _this select 1;
(["angles", missionNamespace getVariable ["MCC_acGround", []]] call MCC_fnc_acAim) params ["_az0", "_el0"];
(["clamp", _az0, _el0] call MCC_fnc_acAim) params ["_caz", "_cel"];
MCC_acGround = ["ground", _caz, _cel] call MCC_fnc_acAim;


switch (MCC_ConsoleACweaponSelected) do {
	// 20mm
	case 0: {
		_control1 ctrlSetBackgroundColor [1, 1, 0.8, 0.2];
		_control2 ctrlSetBackgroundColor [0, 0, 0, 0];
		_control3 ctrlSetBackgroundColor [0, 0, 0, 0];
	};
	
	// 40mm
	case 1: {
		_control1 ctrlSetBackgroundColor [0, 0, 0, 0];
		_control2 ctrlSetBackgroundColor [1, 1, 0.8, 0.2];
		_control3 ctrlSetBackgroundColor [0, 0, 0, 0];
	};
	
	// 105mm
	case 2: {
		_control1 ctrlSetBackgroundColor [0, 0, 0, 0];
		_control2 ctrlSetBackgroundColor [0, 0, 0, 0];
		_control3 ctrlSetBackgroundColor [1, 1, 0.8, 0.2];
	};
};

[] call MCC_fnc_acAmmoRefresh;
