#define MCC3D_IDD 8000
#define MCC_FACTION 8008
#define MCC_UNIT_TYPE 8001
#define MCC_UNIT_CLASS 8002
#define MCC_NAMEBOX 8003
#define MCC_INITBOX 8004
#define MCC_PRESETS 8005
#define MCC_SETTING_EMPTY 8006
#define MCC_ZONE_LOC 8007

#define MCC_3DDOCIDC 8017
#define MCC_3DCargoGen 8018
#define MCC_3dTasksControlsIDC 8020

ctrlShow [MCC_3DDOCIDC,false];
ctrlShow [MCC_3DCargoGen,false];
ctrlShow [MCC_3dTasksControlsIDC,false];

disableSerialization;
private _mccdialog = controlNull;
private _comboBox = controlNull;
private _displayname = "";
private "_x";

MCC3DInitDone = false;
missionNamespace setVariable ["MCC_mcc_screen",1];

_mccdialog = findDisplay MCC3D_IDD;
uiNamespace setVariable ["MCC3D_Dialog", _this select 0];

//track Units
MCC_trackMarkerHandler3DDialog = ((uiNamespace getVariable "MCC3D_Dialog") displayCtrl 0) ctrladdeventhandler ["draw","_this call MCC_fnc_trackUnits;"];

((uiNamespace getVariable "MCC3D_Dialog") displayCtrl 0) ctrlMapAnimAdd [0, uiNamespace getVariable ["MCC3D_DialogMapScale", 0.15], getpos MCC_3D_CAM];
ctrlMapAnimCommit ((uiNamespace getVariable "MCC3D_Dialog") displayCtrl 0);

//fill combobox CFG factions (narrowed by the search box, which starts empty)
uiNamespace setVariable ["MCCMK_factionText_8000", ""];
["apply", "", 8000] call MCCMK_fnc_factionFilter;

_comboBox = _mccdialog displayCtrl MCC_UNIT_TYPE;		//fill combobox CFG unit
lbClear _comboBox;
{
	_displayname =  _x;
	_index = _comboBox lbAdd _displayname;
	_comboBox lbSetValue [_index, _forEachIndex];
	if (_forEachIndex == 0) then {
		private _g = _comboBox lbAdd "Infantry Groups";
		_comboBox lbSetValue [_g, 999];
	};
} foreach ["Infantry", "Vehicles", "Tracked/Static", "Motorcycle", "Helicopter", "Fixed-wing", "Boat", "D.O.C", "Ammo", "Objects (Fortifications)", "Objects (Dead Bodies)", "Objects (Furniture)",
			"Objects (Market)", "Objects (Construction)", "Objects (Signs)", "Objects (Flags)", "Objects (Military)","Objects (Small)", "Objects (Wrecks)", "Objects (Submerged)", "Objects (Tents)","Objects (Garbage)","Objects (Lamps)",
			"Objects (Container)","Objects (Helpers)","Objects (Training)","Mines","Animals","Structures (Airport)","Structures (Military)","Structures (Cultural)","Structures (Walls)","Structures (Infrastructure)","Structures (commercial)",
			"Structures (Industrial)","Structures (Town)","Structures (Village)","Structures (Fences)","Structures (General)","Backpacks","Intel","Items","Items (Headgear)","Items (Uniforms)","Items (Vests)","Weapons (Accessories)","Weapons (Handguns)",
			"Weapons (Primary)","Weapons (Secondary)","Respawn Items"];
_comboBox lbSetCurSel MCC_class_index;
private _behBox = _mccdialog displayCtrl 8034;
lbClear _behBox;
{
	private _bi = _behBox lbAdd (_x select 0);
	_behBox lbSetData [_bi, _x select 1];
} forEach [["Hold position", "hold"], ["None (Arma default)", "bis"], ["BIS Defence", "bisd"], ["BIS Patrol", "bisp"]];
private _behSel = ["hold", "bis", "bisd", "bisp"] find (missionNamespace getVariable ["MCC_3D_beh", "hold"]);
_behBox lbSetCurSel (_behSel max 0);
private _cmdBox = _mccdialog displayCtrl 8035;
lbClear _cmdBox;
{_cmdBox lbAdd _x} forEach ["No", "Yes"];
_cmdBox lbSetCurSel ([0, 1] select (missionNamespace getVariable ["MCC_3D_cmd", false]));
private _searchBox = _mccdialog displayCtrl 8031;
private _searchText = uiNamespace getVariable ["MCC3D_factionSearchText", ""];
_searchBox ctrlSetText _searchText;
if (_searchText != "") then {ctrlSetFocus _searchBox};

_comboBox = _mccdialog displayCtrl MCC_SETTING_EMPTY;		//fill combobox Empty on/off
lbClear _comboBox;
{
	_displayname = format ["%1",_x select 0];
	_comboBox lbAdd _displayname;
} foreach MCC_spawn_empty;
_comboBox lbSetCurSel MCC_empty_index;

//(MK) Start (aircraft): Landed (as the 3D Editor always placed them) / Flying
_comboBox = _mccdialog displayCtrl 8036;
lbClear _comboBox;
{_comboBox lbAdd _x} forEach ["Landed", "Flying", "On water"];
_comboBox lbSetCurSel ([1, 0, 2] find (missionNamespace getVariable ["MCC_3D_start", [0, 1] select (missionNamespace getVariable ["MCC_3D_landed", true])]));
["3d"] spawn MCCMK_fnc_spawnStartRefresh;

_comboBox = _mccdialog displayCtrl MCC_ZONE_LOC;		//fill zone locations
lbClear _comboBox;
{
	_displayname = _x select 0;
	_comboBox lbAdd _displayname;
} foreach MCC_ZoneLocation;
_comboBox lbSetCurSel mcc_hc;	//MCC_ZoneLocation_index;

//(MK) with this menu open the camera still moves: W/S forward/back, A/D left/right, Q/Z up/down (Shift: faster) - they used
// to change the drop-downs instead. The mouse still works the menu.
private _d3 = _this select 0;
MCC_3D_dlgKeys = [];
MCC_3D_dlgT = diag_tickTime;
_d3 displayAddEventHandler ["KeyDown", {
	params ["", "_k", "_sh"];
	if (_k in [17, 30, 31, 32, 16, 44]) exitWith {MCC_3D_dlgKeys pushBackUnique _k; MCC_3D_dlgShift = _sh; true};
	false
}];
_d3 displayAddEventHandler ["KeyUp", {
	params ["", "_k", "_sh"];
	if (_k in [17, 30, 31, 32, 16, 44]) exitWith {MCC_3D_dlgKeys = MCC_3D_dlgKeys - [_k]; MCC_3D_dlgShift = _sh; true};
	false
}];
private _mv = addMissionEventHandler ["EachFrame", {
	private _now = diag_tickTime;
	private _dt = ((_now - (missionNamespace getVariable ["MCC_3D_dlgT", _now])) max 0) min 0.1;
	MCC_3D_dlgT = _now;
	if (isNil "MCC_3D_CAM" || {MCC_3D_dlgKeys isEqualTo []}) exitWith {};
	private _sp = [12, 48] select (missionNamespace getVariable ["MCC_3D_dlgShift", false]);
	private _dir = getDir MCC_3D_CAM;
	private _f = ([0, 1] select (17 in MCC_3D_dlgKeys)) - ([0, 1] select (31 in MCC_3D_dlgKeys));
	private _r = ([0, 1] select (32 in MCC_3D_dlgKeys)) - ([0, 1] select (30 in MCC_3D_dlgKeys));
	private _u = ([0, 1] select (16 in MCC_3D_dlgKeys)) - ([0, 1] select (44 in MCC_3D_dlgKeys));
	private _p = getPosASL MCC_3D_CAM;
	private _dx = ((sin _dir) * _f + (sin (_dir + 90)) * _r) * _sp * _dt;
	private _dy = ((cos _dir) * _f + (cos (_dir + 90)) * _r) * _sp * _dt;
	MCC_3D_CAM setPosASL [(_p select 0) + _dx, (_p select 1) + _dy, ((_p select 2) + (_u * _sp * 0.5 * _dt)) max ((getTerrainHeightASL _p) + 1)];
}];
_d3 displayAddEventHandler ["Unload", compile format ["removeMissionEventHandler ['EachFrame', %1]; MCC_3D_dlgKeys = []", _mv]];

sleep 1;
MCC3DInitDone = true;