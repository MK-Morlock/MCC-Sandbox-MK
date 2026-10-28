private "_ctrl";
private "_posX";
private "_posY";
disableSerialization;

params ["_params"];

_ctrl = _params select 0;
_posX = _params select 1;
_posY = _params select 2;

if (missionNamespace getVariable ["MCC_ConsoleACMouseButtonDown",false]) then {
	#define MCC_ACPos [0.5,0.44]
	private _fov = missionNamespace getVariable ["MCC_fakeACFOV",0.8];
	private _realAc = missionNamespace getVariable ["MCC_ACConsoleUp",objNull];
	if (!alive _realAc) exitWith {};
	private _k = 120 * _fov;
	(["angles", missionNamespace getVariable ["MCC_acGround", []]] call MCC_fnc_acAim) params ["_az0", "_el0"];
	private _az = _az0 - ((_posX - (MCC_ACPos select 0)) * _k);
	private _el = _el0 - ((_posY - (MCC_ACPos select 1)) * _k);
	(["clamp", _az, _el] call MCC_fnc_acAim) params ["_caz", "_cel"];
	MCC_acGround = ["ground", _caz, _cel] call MCC_fnc_acAim;
	if (player getVariable ["MCC_lastSoundTime",time] <= time) then {playsound ["MCC_zoom",true];player setVariable ["MCC_lastSoundTime",time+0.12]};
	setMousePosition [0.5,0.44];
};
