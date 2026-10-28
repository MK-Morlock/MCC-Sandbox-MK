uiNamespace setVariable ["MCC_console3D", profileNamespace getVariable ["MCC_consoleButtons", false]];
private _gd = _this param [0, displayNull];
[_gd] call MCC_fnc_consoleApply3D;
if (!isNull _gd) then {
	private _on = uiNamespace getVariable ["MCC_console3D", false];
	(_gd displayCtrl 9174) ctrlSetTextColor ([[0.56, 0.75, 0.42, 1], [0.88, 0.89, 0.90, 1]] select _on);
	(_gd displayCtrl 9175) ctrlSetTextColor ([[0.88, 0.89, 0.90, 1], [0.56, 0.75, 0.42, 1]] select _on);
};
private _mccdialog = controlNull;
private _comboBox = controlNull;
private _displayname = "";
private "_pic";
private "_index";
private _html = "";
// By: Shay_gman
// Version: 1.1 (April 2012)
#define groupGen_IDD 2994
#define MCC_MINIMAP 9000
#define MCC_FACTION 8008

#define MCCMISSIONMAKERNAME 1020
#define MCCCLIENTFPS 1021
#define MCCSERVERFPS 1022
#define MCC_GroupGenInfo_IDC 530

#define MCCSTOPCAPTURE 1014

#define MCC_UM_LIST 3069
#define MCC_UM_PIC 3070
#define MCC_UM_KICK 3076
#define MCC_UM_BAN 3077

disableSerialization;
MCC_mcc_screen = 2;	//Group gen for poping up the same menu again

//Clear old data
missionNamespace setVariable ["MCC_selectedUnits",[]];
missionNamespace setVariable ["MCC_GroupGenGroupSelected",[]];

uiNamespace setVariable ["MCC_groupGen_Dialog", _this select 0]; {((_this select 0) displayCtrl _x) ctrlAddEventHandler ["MouseButtonDown", {MCC_mapClickTime = diag_tickTime}]} forEach [9000, 9010];

//Add delete button
(findDisplay groupGen_IDD) displayAddEventHandler ["KeyUp",format ["if (_this select 1 == 211) then {MCC_UMUnitSaved = MCC_UMUnit; MCC_UMUnit = 3; null = [12] execVM '%1mcc\general_scripts\unitManage\um.sqf'};",MCC_path]];

//Assign as Curator on init
// MCC's Zeus only for players who don't already own a Zeus (see MCC_fnc_assignCurator)
if (player != getAssignedCuratorUnit MCC_curator && {isNull (getAssignedCuratorLogic player)}) then {player remoteExec ["MCC_fnc_assignCurator", 2, false]};

//Track units if enabled
if (MCC_trackMarker) then {
	MCC_trackMarkerHandler = ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrladdeventhandler ["draw","_this call MCC_fnc_trackUnits;"];
};

//Hide GroupWP
ctrlShow [510,false];
ctrlShow [MCC_GroupGenInfo_IDC,false];

//Show zones
{str _x setMarkerAlphaLocal 0.4;(format["LABEL_%1",_x]) setMarkerAlphaLocal 0.3;} foreach (missionNamespace getVariable ["MCC_zones_numbers",[]]);

//Hide admin buttons for no-admins
if !(serverCommandAvailable "#kick") then {
	ctrlShow [MCC_UM_KICK,false];
	ctrlShow [MCC_UM_BAN,false];
};

for "_i" from 500 to 518 step 1 do {
	((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl _i) ctrlShow false;
};
((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 521) ctrlShow false;

if (missionNamespace getVariable ["CP_activated",false]) then {
	ctrlsettext [520,"Disable Roles"];
} else {
	ctrlsettext [520,"Enable Roles"];
};

//Capture
if !(missionNamespace getVariable ["MCC_capture_state",false]) then { ctrlEnable [MCCSTOPCAPTURE,false];};

//Respawn
[] call MCC_fnc_respawnButton;	//Disable Respawn / Enable Respawn (was greyed out for good once respawn was off)

//Mission Maker
ctrlSetText [MCCMISSIONMAKERNAME, format["%1",mcc_missionmaker]];

_mccdialog = findDisplay groupGen_IDD;

_comboBox = _mccdialog displayCtrl MCC_FACTION; //fill combobox CFG factions
lbClear _comboBox;
{
	_displayname = format ["%1(%2)",_x select 0,_x select 1];
	_comboBox lbAdd _displayname;
} foreach U_FACTIONS;
_comboBox lbSetCurSel MCC_faction_index;

//-------------------------------------------- GAIA --------------------------------------------------------------------------------------------------
_comboBox =((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 1);
lbClear _comboBox;
{
	_displayname = format ["%1",_x select 0];
	_index = _comboBox lbAdd _displayname;
} foreach MCC_GAIA_spawn_behaviors;
_comboBox lbSetCurSel 0;

//------------------------------------------- ZONES --------------------------------------------------------------------------------------------------
["fill"] call MCC_fnc_zoneList;

//------------------------------------------- Tooltip --------------------------------------------------------------------------------------------------
_comboBox = ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 303); //fill combobox zone's numbers

_html = "<t color='#E1E3E5' size='0.85' shadow='1' align='left' underline='true'>HELP:</t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Scroll down this menu to get help. </t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Open 3D Editor: ALT + LMB on map. </t><br/><br/>";
_html = _html + "<t color='#E1E3E5' size='0.85' shadow='1' align='left' underline='true'>GROUPS: </t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Assign Waypoint: Select a group and double Click on map. </t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Assign Quick Waypoint: Select groups hold Ctrl + double Click on map. </t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Groups' multi-select: Hold and drag on map. </t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Group Info:  Right-click on the group's icon. </t><br/><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Delete Selected Groups: Press the Delete button </t><br/><br/>";
_html = _html + "<t color='#E1E3E5' size='0.85' shadow='1' align='left' underline='true'>ZONES: </t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Select Zone: Left Click on Zone's icon.</t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Move Zone: Click on Zone's icon and drag.</t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Resize Zone: Shift + click on Zone's icon and drag.</t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Rotate Zone: Ctrl + click on Zone's icon and rotate. </t><br/><br/>";
_html = _html + "<t color='#E1E3E5' size='0.85' shadow='1' align='left' underline='true'>IED: </t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Manual Detonate: Ctrl + Left mouse button on an IED icon.</t><br/>";
_html = _html + "<t color='#E1E3E5' size='0.8' shadow='1' align='left' underline='false'>* Sync IEDs: Drag a line between two IEDs while holding Shift + Left mouse button.</t><br/>";

_comboBox ctrlSetStructuredText parseText _html;

//Is it first time we around? Let's respawn the zone markers if they are available
if (isnil "MCCFirstOpenUI") then
{
	MCCFirstOpenUI = false;

	sleep 1;
	//Loose mission maker when DC move to after login
	[] call MCC_fnc_createMCCZones;
};

//----------------------------------------------------------- GROUPs ----------------------------------------------------------------------------

[] spawn MCC_fnc_groupGenRefresh;

//-------------------------------------------------FPS Loop  -----------------------------
//Units / Groups switch of the unit list shows the choice in use (it showed Units while the list held groups)
if !((missionNamespace getVariable ["MCC_UMUnit", 0]) in [0, 1]) then {MCC_UMUnit = 0};
((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9134) lbSetCurSel MCC_UMUnit;

//Unit video feed: opens in the view mode last chosen, and its switch shows it
if (isNil "MCC_UMPIPView") then {MCC_UMPIPView = profileNamespace getVariable ["MCC_feedVision_unit", 0]};
((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9133) lbSetCurSel MCC_UMPIPView;

//Unit video feed: right-drag to swing the camera, wheel to zoom (MCC_fnc_pipOrbit)
["attach", [uiNamespace getVariable "MCC_groupGen_Dialog"]] call MCC_fnc_pipOrbit;
["refresh"] call MCC_fnc_umFeedToggle;	//On / Off button shows the choice kept for this session
[9134, MCC_UMUnit] call MCC_fnc_umToolboxHighlight;	//rounded boxes under the chosen Units / Groups and view
[9133, MCC_UMPIPView] call MCC_fnc_umToolboxHighlight;

//Transparency slider (left see-through, middle normal, right black), at the saved position
private _alphaSlider = (uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9120;
_alphaSlider sliderSetRange [0, 1];
_alphaSlider sliderSetSpeed [0.05, 0.1];
_alphaSlider sliderSetPosition (profileNamespace getVariable ["MCC_consoleAlpha", 0.5]);
private _mapSlider = (uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9121;
_mapSlider sliderSetRange [0, 1];
_mapSlider sliderSetSpeed [0.01, 0.05];	//arrows: 1 % steps, clicking the bar: 5 %
_mapSlider sliderSetPosition (profileNamespace getVariable ["MCC_consoleMapAlpha", 1]);
[] call MCC_fnc_consoleTheme;	//console colour (also applies the transparency)

//No campaign territory overlay on the console map (only while the console is open, only on this computer)
["start"] call MCC_fnc_consoleCampaignTiles;
["init"] call MCC_fnc_consoleMapLayers;
["init"] call MCC_fnc_consoleFilter;
[] call MCC_fnc_consoleAmbientLook;
((uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) displayCtrl 9170) ctrlShow false;

while {(str (finddisplay groupGen_IDD) != "no display")} do {
	MCC_clientFPS  = round(diag_fps);
	ctrlSetText [MCCCLIENTFPS, format["%1",MCC_clientFPS]];

	if (isnil "mcc_fps_running") then {mcc_fps_running = false};
	if !(mcc_fps_running) then {
		[1] remoteExec ["MCC_fnc_FPS", 0, false];
		sleep 0.5;
	};

	if !( MCC_isHC ) then {
		ctrlSetText [MCCSERVERFPS, format["%1",MCC_serverFPS]];
	} else {
		ctrlSetText [MCCSERVERFPS, format[" %1 - HC FPS: %2", MCC_serverFPS, MCC_hcFPS]];
	};
	sleep 1;
};

//Hide zones
{str _x setMarkerAlphaLocal 0;(format["LABEL_%1",_x]) setMarkerAlphaLocal 0;} foreach (missionNamespace getVariable ["MCC_zones_numbers",[]]);

//------------------------------------------------------------------------------------------

//Console closed: the selected unit's red marker belongs to the console map only (it showed on every map)
deleteMarkerLocal "currentUnitSelected";
