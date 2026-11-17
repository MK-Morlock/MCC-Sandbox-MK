/*
	MCCMK_fnc_garage3D - (client) the garage opened from the 3D Editor: [class]. The editor's menu is closed and kept closed
	while the garage is open, the garage uses its own camera, and afterwards the editor's camera is made the view again and
	its menu reopened - the editor carries on where it was. Its panel, compass and minimap are hidden while the
	garage is open.
*/
params [["_cls", ""]];
if (_cls == "" || {!isNil "MCCMK_garageBusy"}) exitWith {};
private _allow = missionNamespace getVariable ["MCC_3dEditorAllowDialog", true];
MCC_3dEditorAllowDialog = false;	// (the editor's own key reopens its menu - not while the garage is up)
while {dialog} do {closeDialog 0};
// the editor's own panel (controls list), compass and minimap hidden while the garage is up (its H key), back after
private _gui = missionNamespace getVariable ["MCC_3D_GUI", false];
if (_gui && {!isNil "MCC_3D_toggleGUI"}) then {[] call MCC_3D_toggleGUI};
[_cls, -1, "3d"] call MCCMK_fnc_garageOpen;
if (_gui && {!isNil "MCC_3D_toggleGUI"} && {!(missionNamespace getVariable ["MCC_3D_GUI", false])}) then {[] call MCC_3D_toggleGUI};
uiSleep 0.3;
MCC_3dEditorAllowDialog = _allow;
if (!isNil "MCC_3D_CAM" && {!isNull MCC_3D_CAM}) then {
	MCC_3D_CAM cameraEffect ["internal", "back"];
	cameraEffectEnableHUD true;
	showCinemaBorder false;
	if (!dialog) then {createDialog ("MCC3D_Dialog" call MCC_fnc_dialogName)};
	["INFO", "garage", "%1: back to the 3D Editor", [_cls]] call MCC_fnc_log;
};
