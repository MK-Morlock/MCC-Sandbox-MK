[findDisplay 2993] call MCC_fnc_consoleApply3D;
["start"] spawn {sleep 0.1; ["start"] call MCC_fnc_consoleCampaignTiles};	//no campaign territory overlay on the Commander Console map (once its display exists)
[] spawn {sleep 0.15; ["init", "cc"] call MCC_fnc_consoleMapLayers};
private _mccdialog = controlNull;
private _comboBox = controlNull;
private _displayname = "";
private _pic = "";
private "_index";
private _planeName = "";
private _counter = 0;
private "_type";
private "_group";
private _groupControl = configNull;
private "_cost";
private _insetionArray = [];
private "_control";
private "_markerType";
private "_markerColor";
private "_leader";
private "_icon";
private _wpArray = [];
private _haveGPS = nil;
private "_behaviour";
private "_unitsSizeMarker";
private _arrayName = "";
private "_evacVehicles";
// By: Shay_gman
// Version: 1.1 (May 2012)
#define mcc_playerConsole_IDD 2993

#define MCC_ConsoleCASAvailableTextBox_IDD 9100
#define MCC_ConsoleEvacFlyHightComboBox_IDD 9101
#define MCC_ConsoleEvacApproachComboBox_IDD 9102
#define MCC_ConsoleAirdropAvailableTextBox_IDD 9104
#define MCC_ConsoleEvacTypeText_IDD 9103
#define MCC_CONSOLEINFOTEXT 9150
#define MCC_CONSOLEINFOLIVEFEED 9151
#define MCC_MAPBACKGROUND 9152
#define MCC_CONSOLEINFOLIVEFEEDNV 9153
#define MCC_CONSOLEINFOLIVEFEEDTM 9154
#define MCC_CONSOLEINFOLIVEFEEDCLOSE 9155
#define MCC_CONSOLEINFOLIVEFEEDNORMAL 9156
#define MCC_CONSOLEINFOUAVCONTROL 9162

#define MCC_CONSOLEWPBCKGR 9157
#define MCC_CONSOLEWPCOMBO 9158
#define MCC_CONSOLEWPFORMATIONCOMBO 9166
#define MCC_CONSOLEWPSPEEDCOMBO 9167
#define MCC_CONSOLEWPBEHAVIORCOMBO 9168

#define MCC_CONSOLEWPADD 	9159
#define MCC_CONSOLEWPREPLACE 9160
#define MCC_CONSOLEWPCLEAR 9161
#define MCC_CONSOLEWPCANCEL 9169
#define MCC_ConsoleMapRulerButton 9163
#define MCC_ConsoleMapRulerDir 9164
#define MCC_ConsoleMapRulerDis 9165

#define BON_ARTY_DIRECTION 999907
#define BON_ARTY_DISTANCE 999908

#define MCC_ResourcesControlsGroup 80

disableSerialization;
MCC_Console1Open = true;
MCC_Console2Open = false;
MCC_Console3Open = false;
MCC_Console4Open = false;

ctrlShow [MCC_CONSOLEINFOTEXT,false];
ctrlShow [MCC_CONSOLEINFOLIVEFEED,false];
ctrlShow [MCC_CONSOLEINFOLIVEFEEDNV,false];
ctrlShow [MCC_CONSOLEINFOLIVEFEEDTM,false];
ctrlShow [MCC_CONSOLEINFOLIVEFEEDCLOSE,false];
ctrlShow [MCC_CONSOLEINFOLIVEFEEDNORMAL,false];
ctrlShow [MCC_CONSOLEWPBCKGR,false];
ctrlShow [MCC_CONSOLEWPCOMBO,false];
ctrlShow [MCC_CONSOLEWPFORMATIONCOMBO,false];
ctrlShow [MCC_CONSOLEWPSPEEDCOMBO,false];
ctrlShow [MCC_CONSOLEWPBEHAVIORCOMBO,false];
ctrlShow [MCC_CONSOLEWPADD,false];
ctrlShow [MCC_CONSOLEWPREPLACE,false];
ctrlShow [MCC_CONSOLEWPCLEAR,false];
ctrlShow [MCC_CONSOLEWPCANCEL,false];
ctrlShow [9219,false];
ctrlShow [MCC_CONSOLEINFOUAVCONTROL,false];
ctrlShow [MCC_ResourcesControlsGroup,false];

//set ruler data
ctrlSetText [MCC_ConsoleMapRulerDir,format ["Dir: %1",MCC_ConsoleRulerData select 0]];
ctrlSetText [MCC_ConsoleMapRulerDis,format ["Dis: %1m",MCC_ConsoleRulerData select 1]];
ctrlSetText [BON_ARTY_DIRECTION,format["%1",MCC_ConsoleRulerData select 0]]; //degrees
ctrlSetText [BON_ARTY_DISTANCE,format["%1",MCC_ConsoleRulerData select 1]]; //distance

_mccdialog = findDisplay mcc_playerConsole_IDD;
MCC_Console1Open = true;
_evacVehicles = missionNamespace getvariable [format ["MCC_evacVehicles_%1",playerSide],[]];

//(MK) the side panels' tabs and grey arrow bars: open (out and down) / close, one at a time (MCCMK_fnc_consoleFolder)
{
	(_mccdialog displayCtrl _x) ctrlAddEventHandler ["MouseButtonClick", {["close", (ctrlIDC (_this select 0)) + 1000] call MCCMK_fnc_consoleFolder; playSound "click"}];
} forEach [1010,1020,1030];
{
	(_mccdialog displayCtrl _x) ctrlAddEventHandler ["MouseButtonClick", {["open", (ctrlIDC (_this select 0)) + 999] call MCCMK_fnc_consoleFolder; playSound "click"}];
} forEach [1011,1021,1031];

//Add default drops & CAS
private _cfg = configNull;
private _varName = "";
private _airDrops = [];
private "_airDropsAvaliable";
if (([["hq",2], playerSide] call MCC_fnc_CheckBuildings || (missionNamespace getVariable ["MCC_defaultSupplyDropsEnabled",false])) &&
    !(missionNamespace getVariable ["MCC_RTSAddDefaultSupplyDrops",false])) then {

	_cfg = if (isClass (missionconfigFile >> "CfgMCCRtsAirdrops" >> str playerSide)) then {
		missionconfigFile >>  "CfgMCCRtsAirdrops" >> str playerSide;
	} else {
		configFile >>  "CfgMCCRtsAirdrops" >> str playerSide;
	};

	//AIrdrop
	_airDrops = [];
	for "_i" from 0 to (count (_cfg >> "airdrops") -1) step 1 do
	{
		if (isClass ((_cfg >> "airdrops") select _i)) then {
			_airDrops pushBack [getText(((_cfg >> "airdrops") select _i) >> "className"),
								getArray(((_cfg >> "airdrops") select _i) >> "resources")];
		};
	};

	_varName = format ["MCC_ConsoleAirdropArray%1",playerSide];
	_airDropsAvaliable = missionNamespace getVariable [_varName,[]];

	{
		_airDropsAvaliable pushBack [[[_x select 0]],[""],2];
		missionNamespace setVariable [str ([[[_x select 0]],[""],2]), _x select 1];
		publicVariable str ([[[_x select 0]],[""],2]);
	} forEach _airDrops;

	publicVariable _varName;

	missionNamespace setVariable ["MCC_RTSAddDefaultSupplyDrops",true];
	publicVariable "MCC_RTSAddDefaultSupplyDrops";
};

if (([["hq",3], playerSide] call MCC_fnc_CheckBuildings || (missionNamespace getVariable ["MCC_defaultCASEnabled",false])) &&
    !(missionNamespace getVariable ["MCC_RTSAddDefaultCAS",false])) then {

	_cfg = if (isClass (missionconfigFile >> "CfgMCCRtsAirdrops" >> str playerSide)) then {
		missionconfigFile >>  "CfgMCCRtsAirdrops" >> str playerSide;
	} else {
		configFile >>  "CfgMCCRtsAirdrops" >> str playerSide;
	};

	//CAS
	_airDrops = [];
	for "_i" from 0 to (count (_cfg >> "cas") -1) step 1 do
	{
		if (isClass ((_cfg >> "cas") select _i)) then {
			_airDrops pushBack [getText(((_cfg >> "cas") select _i) >> "casType"),
								getText(((_cfg >> "cas") select _i) >> "className"),
								getArray(((_cfg >> "cas") select _i) >> "resources")];
		};
	};

	_varName = format ["MCC_CASConsoleArray%1",playerSide];
	_airDropsAvaliable = missionNamespace getVariable [_varName,[]];

	{
		_airDropsAvaliable pushBack [[_x select 0],[_x select 1]];
		missionNamespace setVariable [str ([[_x select 0],[_x select 1]]), _x select 2];
		publicVariable str ([[_x select 0],[_x select 1]]);
	} forEach _airDrops;

	publicVariable _varName;

	missionNamespace setVariable ["MCC_RTSAddDefaultCAS",true];
	publicVariable "MCC_RTSAddDefaultCAS";
};

//(MK) Air Patrol: one entry per aircraft of the commander's faction (MCCMK_fnc_airPatrolList), each with its cost (ammo
// per call, fuel for its time on station) and details for the CAS panel (MCCMK_fnc_apConsoleInfo); once per faction.
// The old two generic entries (from older saves) go.
if (([["hq",3], playerSide] call MCC_fnc_CheckBuildings || (missionNamespace getVariable ["MCC_defaultCASEnabled",false]))
	&& {!(missionNamespace getVariable [format ["MCCMK_apAdded_%1_%2", playerSide, faction player], false])}) then {
	private _vn = format ["MCC_CASConsoleArray%1", playerSide];
	private _arr = (missionNamespace getVariable [_vn, []]) select {!((toLower ((_x select 0) select 0)) in ["air patrol - jet (air-to-air)", "air patrol - helicopter (air-to-ground)"])};
	{
		_x params ["_cls", "_nm", "_type", "_aa", "_ag", "_am", "_fu", "_mi"];
		private _e = [[format ["Air Patrol - %1", _nm]], [_cls]];
		if !(_e in _arr) then {_arr pushBack _e};
		missionNamespace setVariable [str _e, [["ammo", _am], ["fuel", _fu]], true];
		missionNamespace setVariable [format ["MCCMK_ap_%1", _cls], [_type, _aa, _ag, _mi, _am, _fu], true];
	} forEach ([faction player] call MCCMK_fnc_airPatrolList);
	missionNamespace setVariable [_vn, _arr, true];
	missionNamespace setVariable [format ["MCCMK_apAdded_%1_%2", playerSide, faction player], true, true];
};

[] spawn {
	disableSerialization;
	while {!isNull (findDisplay 2993)} do {
		private _d = findDisplay 2993;
		{(_d displayCtrl (_x select 1)) ctrlSetTooltip (([_x select 0] call MCC_fnc_consoleFKeyState) select 2)} forEach [[2, 9196], [3, 9197]];
		sleep 1;
	};
};
//--------------------------------------------------Evac-------------------------------------------------------------------------------
if (count _evacVehicles > 0) then {
	_comboBox = _mccdialog displayCtrl MCC_ConsoleEvacTypeText_IDD;		//fill combobox type
	lbClear _comboBox;
	{
		if (alive _x) then	{
			_vehicleDisplayName 	= getText(configFile >> "CfgVehicles" >> typeof _x >> "displayname");
			_displayname 			= [_x] call MCCMK_fnc_evacLabel;	//(MK)
			_index 					= _comboBox lbAdd _displayname;
		} else {
			_displayname 			= "N/A";
			_index 					= _comboBox lbAdd _displayname;
			};
	} foreach _evacVehicles;
	_comboBox lbSetCurSel (missionNameSpace getvariable ["MCC_evacVehicles_index",0]);

	_type = _evacVehicles select (lbCurSel MCC_ConsoleEvacTypeText_IDD);
	ctrlShow [MCC_ConsoleEvacFlyHightComboBox_IDD,false];
	_insetionArray = ["Move (engine on)","Move (engine off)","RTB"];

	if (_type iskindof "helicopter") then {									//Case we choose aircrft
		ctrlShow [MCC_ConsoleEvacFlyHightComboBox_IDD,true];
		_insetionArray = ["Free Landing (engine on)","Free Landing (engine off)","Hover","Helocasting(Water)","Smoke Signal","Fast-Rope","Precise Landing","Paradrop","Water landing (engine on)","Water landing (engine off)","RTB"];
		_comboBox = _mccdialog displayCtrl MCC_ConsoleEvacFlyHightComboBox_IDD;		//fill combobox Fly in Hight
		lbClear _comboBox;
		{
			_displayname = format ["%1",_x  select 0];
			_index = _comboBox lbAdd _displayname;
		} foreach MCC_evacFlyInHight_array;
		[_comboBox, "MCC_ccEvacHeight"] call MCC_fnc_consoleListMemory;
	};

		_comboBox = _mccdialog displayCtrl MCC_ConsoleEvacApproachComboBox_IDD;		//fill combobox Approach
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach _insetionArray;
	[_comboBox, "MCC_ccEvacInsertion"] call MCC_fnc_consoleListMemory;
};
if (count _evacVehicles > 0 && {(lbCurSel MCC_ConsoleEvacTypeText_IDD) >= 0}) then {missionNamespace setVariable ["MCC_evacConsoleObj", _evacVehicles select (lbCurSel MCC_ConsoleEvacTypeText_IDD)]};
[] spawn {
	disableSerialization;
	private _last = (missionNamespace getVariable [format ["MCC_evacVehicles_%1", playerSide], []]) apply {[_x, alive _x, alive (driver _x)]};
	while {!isNull (findDisplay 2993)} do {
		sleep 1;
		private _sig = (missionNamespace getVariable [format ["MCC_evacVehicles_%1", playerSide], []]) apply {[_x, alive _x, alive (driver _x)]};
		if !(_sig isEqualTo _last) then {_last = _sig; call MCC_fnc_evacConsoleRefresh};
	};
};

//----------------------------------------------CAS--------------------------------------------------------------------------------------
_arrayName	= format ["MCC_CASConsoleArray%1",(player getVariable ["CP_side",  playerside])];

_comboBox = _mccdialog displayCtrl MCC_ConsoleCASAvailableTextBox_IDD;		//fill list box for CAS Types
lbClear _comboBox;
{
	_planeName = getText (configFile >> "CfgVehicles" >> (_x  select 1) select 0>> "displayname");
	_pic = getText (configFile >> "CfgVehicles" >> (_x  select 1) select 0>> "picture");
	_displayname = format ["%1",(_x  select 0) select 0];
	_index = _comboBox lbAdd _displayname;
	_comboBox lbSetPictureRight [_index, _pic];

	//if we have a cost show the cost otherwise shoe the plane
	_cost = missionNamespace getVariable [str _x,[]];
	if (count _cost > 0) then {

		//Show resources
		ctrlShow [MCC_ResourcesControlsGroup,true];

		private _str = "";

		{
			_str = _str + (toUpper ((_x select 0) select [0, 1])) + ((_x select 0) select [1]) + " x " + str (_x select 1) + " ";
		} forEach _cost;

		_comboBox lbSetTooltip [_index, _str];

		private _available = false;
		{
			_available = [playerSide, _x] call MCC_fnc_checkRes;
			if (!_available) exitWith {_comboBox lbSetColor [_index, [0.311,0.311, 0.311, 0.8]]};
		} foreach _cost;
	} else {
		_comboBox lbSetTooltip [_index, _planeName];
	};

} foreach (missionNameSpace getVariable [_arrayName,[]]);
[_comboBox, "MCC_ccCAS"] call MCC_fnc_consoleListMemory;

//----------------------------------------------Airdrop--------------------------------------------------------------------------------------
_arrayName	= format ["MCC_ConsoleAirdropArray%1",(player getVariable ["CP_side",  playerside])];

//(MK) the Smoke tick box, as this player left it (shared with the side, so every airdrop follows it)
private _smk = _mccdialog displayCtrl 9230;
if (!isNull _smk) then {
	private _on = profileNamespace getVariable ["MCCMK_dropSmoke", true];
	_smk cbSetChecked _on;
	MCCMK_dropSmoke = _on;
	publicVariable "MCCMK_dropSmoke";
};
_comboBox = _mccdialog displayCtrl MCC_ConsoleAirdropAvailableTextBox_IDD;		//fill list box for Airdrop Types
lbClear _comboBox;
_counter = 0;
{
	_counter = _counter + 1;
	_displayname = ((((_x select 0) select 0) apply {getText (configFile >> "CfgVehicles" >> _x >> "displayname")}) joinString ", ");
	_displayname = _displayname;
	_pic = if (!(_x select 2 isEqualTo 1) || (_x isEqualTo true)) then {"\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa"} else {"\A3\ui_f\data\map\markers\handdrawn\pickup_CA.paa"};
	_index = _comboBox lbAdd _displayname;
	_comboBox lbSetPictureRight [_index, _pic];

	//if we have a cost show the cost
	_cost = missionNamespace getVariable [str _x,[]];
	if (count _cost > 0) then {
		private _str = "";

		//Show resources
		ctrlShow [MCC_ResourcesControlsGroup,true];

		{
			_str = _str + (toUpper ((_x select 0) select [0, 1])) + ((_x select 0) select [1]) + " x " + str (_x select 1) + " ";
		} forEach _cost;

		_comboBox lbSetTooltip [_index, _str];

		private _available = false;
		{
			_available = [playerSide, _x] call MCC_fnc_checkRes;
			if (!_available) exitWith {_comboBox lbSetColor [_index, [0.311,0.311, 0.311, 0.8]]};
		} foreach _cost;
	};

} foreach (missionNameSpace getVariable [_arrayName,[]]);
// Taru supply pods (MK): always on offer, paid from the side's resources
{
	_x params ["_kind", "_label"];
	private _c = [_forEachIndex] call MCCMK_fnc_podCost;
	private _free = call MCCMK_fnc_resFree;
	private _parts = [];
	{if ((_c select _forEachIndex) > 0) then {_parts pushBack format ["%1 %2", _c select _forEachIndex, _x]}} forEach ["Ammo", "Supply", "Fuel", "Meds"];
	_index = _comboBox lbAdd format ["Taru pod: %1", _label];
	_comboBox lbSetPictureRight [_index, "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa"];
	_comboBox lbSetTooltip [_index, if (_free) then {toString [8734]} else {_parts joinString ", "}];
	if (!_free) then {
		private _r = missionNamespace getVariable [format ["MCC_res%1", playerSide], [0, 0, 0, 0, 0]];
		if ((_r select 0) < (_c select 0) || {(_r select 1) < (_c select 1)} || {(_r select 2) < (_c select 2)} || {(_r select 4) < (_c select 3)}) then {_comboBox lbSetColor [_index, [0.311, 0.311, 0.311, 0.8]]};
	};
} forEach (call MCCMK_fnc_podInfo);
[_comboBox, "MCC_ccAirdrop"] call MCC_fnc_consoleListMemory;

//------------------------------------------Group Control-------------------------------------------------------------------------------------
//---------------------Console Groups management

if (!isnil "HCEast" ||  !isnil "HCWest" || !isnil "HCGuer") exitWith {}; 			//If HC is working aboart process

private _groupIconHandle = addMissionEventHandler ["GroupIconClick", {
								params [
									"_is3D", "_group", "_waypointId",
									"_mouseButton", "_posX", "_posY",
									"_shift", "_control", "_alt"
								];

   								 if (!(MCC_Console1Open) && dialog) exitWith {};
								if !([side group player, side _group] call BIS_fnc_sideIsFriendly) exitWith {};	//(MK) Map Intel's enemy icons: not selectable

								[_group,_mouseButton,[_posX,_posY],_shift,_control,_alt] execVM format ["%1mcc\fnc\console\fn_consoleClickGroupIcon.sqf",MCC_path];
								//[_group,_button,[_posx,_posy],_shift,_ctrl,_alt] spawn MCC_fnc_consoleClickGroupIcon;
							}];

//Add - Ctrl + number group selections handlers
if (isnil "MCC_consoleGroupSelectionEH") then {
	MCC_consoleGroupSelectionEH = (findDisplay 46) displayAddEventHandler  ["KeyDown", format ["nul = _this execVM '%1mcc\general_scripts\console\groupNumbersSelectionEH.sqf';",MCC_path]];
};

MCC_fnc_mapDrawWPConsole =
{
	_map = _this select 0;
	[_map, missionNamespace getVariable ["MCC_ConsoleGroupSelected", []], (["MCC_ConsoleRuler", "MCC_CASrequestMarker", "MCC_evacParaWait", "MCCMK_makeHQPick"] findIf {(missionNamespace getVariable [_x, false]) isEqualTo true}) >= 0] call MCCMK_fnc_wpChainDraw;
	{
		_leader = (leader _x);
		_groupControl = if ((isplayer _leader) || (getText (configfile >> "CfgVehicles" >> typeOF vehicle _leader >> "vehicleClass")== "Autonomous")) then {true} else {_x getvariable ["MCC_canbecontrolled",false]};	//Can we control this group
		_haveGPS =  if ((vehicle _leader != _leader) || !isPlayer _leader) then {true} else {(((assignedItems _leader) findIf {(_x isKindOf ["ItemGPS", configFile >> "CfgWeapons"]) || {_x isKindOf ["UavTerminal_base", configFile >> "CfgWeapons"]}}) >= 0)};
		if (isnil "_haveGPS") then {_haveGPS = false};
		if ((side _leader == side player) && alive _leader && _groupControl && ((MCC_ConsoleOnlyShowUnitsWithGPS && _haveGPS) || !MCC_ConsoleOnlyShowUnitsWithGPS)) then
		{
			_wpArray = waypoints (group _leader);
			if (count _wpArray > 0)then
			{
				private "_wp";
				private "_wPos";
				private "_wType";
				private _lastPos = nil;
				_texture = gettext (configfile >> "CfgMarkers" >> "waypoint" >> "icon");
				for [{_i= currentWaypoint (group _leader)},{_i < count _wpArray},{_i=_i+1}] do 	//Draw the current WP
				{
					_wp = (_wpArray select _i);
					_wPos  = waypointPosition _wp;
					if ((_wPos  distance [0,0,0]) > 50) then
					{
						_wType = waypointType _wp;


						_map drawIcon [
							_texture,
							[0,0,1,1],
							_wPos,
							24,
							24,
							0,
							_wType,
							0,
							0.04,
							"PuristaBold",
							"center"
						];

						if (isNil "_lastPos") then {_lastPos = [(getpos _leader) select 0,(getpos _leader) select 1]};

						_map drawLine [
							_lastPos,
							_wPos,
							[0,0,1,1]
						];

						_lastPos = _wPos;
					};
				};
			};
			private _mkPlan = (group _leader) getVariable ["MCCMK_wpPlan", []];
			if (_mkPlan isNotEqualTo []) then
			{
				private _mkTex = gettext (configfile >> "CfgMarkers" >> "waypoint" >> "icon");
				private _mkLp = getPos _leader;
				for "_mkK" from (currentWaypoint (group _leader)) to ((count _wpArray) - 1) do {
					private _mkP = waypointPosition (_wpArray select _mkK);
					if ((_mkP distance [0,0,0]) > 50) then {_mkLp = _mkP};
				};
				{
					_x params ["_mkP", "_mkT"];
					_map drawIcon [_mkTex, [0,0,1,1], _mkP, 24, 24, 0, _mkT, 0, 0.04, "PuristaBold", "center"];
					_map drawLine [[_mkLp select 0, _mkLp select 1], _mkP, [0,0,1,1]];
					_mkLp = _mkP;
				} forEach _mkPlan;
			};
		};
	} foreach allgroups;

	//Draw icons for UAV
	{
		if (vehicle _x == _x || _x == driver vehicle _x) then {
			_texture = gettext (configfile >> "CfgVehicles" >> typeof vehicle _x >> "icon");
			_color = (getNumber (configfile >> "CfgVehicles" >> typeof vehicle _x >> "side")) call BIS_fnc_sideColor;
			_map drawIcon [
							_texture,
							_color,
							position _x,
							18,
							18,
							direction _x,
							"",
							0,
							0.03,
							"PuristaBold",
							"Right"
						];
		};
	} forEach (missionNamespace getVariable [(format ["MCC_uavSpotted_%1", playerSide]),[]]);
};

[] call {
	private _handler = controlNull;
	private _haveGPS = nil;
	private "_leader";
	private "_groupStatus";
	private _wpArray = [];
	private "_behaviour";
	private _groupControl = configNull;
	private _haveGPS = nil;
	private "_groupName";
	private _groupIconData = [];

	setGroupIconsVisible [true,false];
	setGroupIconsSelectable true;

	_handler = (_mccdialog displayCtrl 9120) ctrladdeventhandler ["draw","_this call MCC_fnc_mapDrawWPConsole;"];
	uiNamespace setVariable ["MCCMK_wpChain", nil];
	// (MK) groups under Arma's High Command (the commandable ones): its module keeps writing their icon colour and name. This
	// console's own are put back every frame, just before the map is drawn, so its rewrite never reaches the screen.
	// (MK) THE CONSOLE'S ICONS HELD AGAINST ARMA'S HIGH COMMAND. While the player is his side's commander, Arma's High Command
	// script goes round EVERY group about once a second and blanks its icon's colour and name (colour [0,0,0,0], name
	// '', on friendly and enemy groups alike, in his High Command or not, and its own "dummy" icons added). The
	// console's colour and name are put back at three points of every frame: at its start, when the scene is drawn
	// (after the scripts have run,
	// before the map is), and when the map is drawn.
	MCCMK_iconHold = {
		{
			private _w = _x getVariable "MCCMK_iconWant";
			private _id = _x getVariable "MCCgroupIconData";
			if (!isNil "_w" && {!(_x getVariable ["MCCMK_miFlashing", false])}) then {_x setGroupIconParams ([_x, _w] call MCCMK_fnc_iconWithWp)};
		} forEach allGroups;
	};
	// (MK) THE ICONS AND ARMA'S "MILITARY SYMBOLS". Arma's High Command starts Arma's Military Symbols module (MARTA - read in
	// A3\modules_f: hc.sqf creates it, marta_local.fsm runs it; MCC's UAV console starts it too). For every group of the
	// player's side and every enemy group his side knows of, it keeps two icons of its own on the group - a symbol (its id in
	// the group's BIS_MARTA_ICON_TYPE) and a size marker (BIS_MARTA_ICON_SIZE) - and on every pass (about twice a second) it
	// sets the symbol, the size marker and the icon's colour (the side's) and name (none). High Command's own scripts read
	// that symbol back by its id. So:
	//   - its icons are NEVER removed or cleared (High Command then fails: "Undefined variable _grpIconClass" / "_icon");
	//   - a group that has them is shown THROUGH its symbol: the console names the symbol it wants in the group's
	//     MARTA_customicon - the module's own setting for exactly this - so the module itself shows the console's symbol
	//     (the half-and-half "in combat" ones included) and, with a custom symbol, leaves its size marker alone (set empty
	//     here; the console's own size marker is used). The console adds no symbol of its own to such a group: one box;
	//   - a group without them gets the console's own symbol, as always;
	//   - the colour and name are held every frame (MCCMK_iconHold): the module writes its own on every pass;
	//   - a group the console does not show (its side filtered out, or its leader riding in another group's vehicle) is
	//     held invisible instead of having its icons cleared;
	//   - when the console closes, MARTA_customicon is taken off again and the module goes back to its own symbols.
	MCCMK_iconMartaHas = {
		params ["_g"];
		private _t = _g getVariable "BIS_MARTA_ICON_TYPE";
		!isNil "_t" && {((_g getGroupIcon _t) param [0, ""]) != ""}
	};
	MCCMK_iconMartaOff = {
		{
			if (_x getVariable ["MCCMK_iconMarta", false]) then {_x setVariable ["MARTA_customicon", nil]; _x setVariable ["MCCMK_iconMarta", nil]};
			_x setVariable ["MCCMK_iconWant", nil];
		} forEach allGroups;
	};
	{_x setVariable ["MCCMK_iconWant", nil]} forEach allGroups;	// (nothing left over from the other console)
	private _holdEHs = [addMissionEventHandler ["EachFrame", {call MCCMK_iconHold}], addMissionEventHandler ["Draw3D", {call MCCMK_iconHold}]];
	// (every group this console shows, not only those under High Command - see MCC_fnc_groupGenRefresh)
	(_mccdialog displayCtrl 9120) ctrlAddEventHandler ["Draw", {
		{
			private _w = _x getVariable "MCCMK_iconWant";
			// (only where this console's own icon is really on the group - Map Intel's icons on other groups are its own - and not
			// during Map Intel's gunfire flash)
			private _id = _x getVariable "MCCgroupIconData";
			if (!isNil "_w" && {!(_x getVariable ["MCCMK_miFlashing", false])}) then {_x setGroupIconParams ([_x, _w] call MCCMK_fnc_iconWithWp)};
		} forEach allGroups;
	}];
	while {MCC_Console1Open && (str (finddisplay mcc_playerConsole_IDD) != "no display")} do 		//Draw WP
	{
		{
			_leader = (leader _x);
			_groupStatus = _x getvariable "MCC_support";
			_wpArray = waypoints (group _leader);
			_behaviour = behaviour _leader;
			_groupControl = if ((isplayer _leader) || (getText (configfile >> "CfgVehicles" >> typeOF vehicle _leader >> "vehicleClass")== "Autonomous")) then {true} else {_x getvariable ["MCC_canbecontrolled",false]};	//Can we control this group
			_haveGPS =  if ((vehicle _leader != _leader) || !isPlayer _leader) then {true} else {(((assignedItems _leader) findIf {(_x isKindOf ["ItemGPS", configFile >> "CfgWeapons"]) || {_x isKindOf ["UavTerminal_base", configFile >> "CfgWeapons"]}}) >= 0)};
			if (isnil "_haveGPS") then {_haveGPS = false};

			_side = side _leader;

			if ((_side == side player) && alive _leader && _groupControl && ((MCC_ConsoleOnlyShowUnitsWithGPS && _haveGPS) || !MCC_ConsoleOnlyShowUnitsWithGPS)) then {

				_groupIconData = [_x] call MCC_fnc_getGroupIconData;
				_markerColor = _groupIconData select 0;
				_groupName = _groupIconData select 1;
				_markerType = _groupIconData select 2;
				_unitsSizeMarker = _groupIconData select 3;

				//Set markers (the colour and name: set once, below)

				//(MK) the icon updated in place, not deleted and re-created twice a second
				_icon = (_x getvariable "MCCgroupIconData");
				private _iconType = _markerType;
				if (_behaviour == "COMBAT" && {_side != civilian}) then {
					private _c = format [["MCC_%1_combat", "MCC_%1_combatP"] select (isPlayer _leader), _markerType];
					if (isClass (configFile >> "CfgGroupIcons" >> _c)) then {_iconType = _c};
				};
				// (MK) the symbol: through Arma's Military Symbols icon where the group has one (see MCCMK_iconMartaHas, above),
				// else the console's own
				if ([_x] call MCCMK_iconMartaHas) then {
					private _mT = _x getVariable "BIS_MARTA_ICON_TYPE";
					if !((_x getVariable ["MARTA_customicon", []]) isEqualTo [_iconType]) then {_x setVariable ["MARTA_customicon", [_iconType]]};
					if (((_x getGroupIcon _mT) param [0, ""]) != _iconType) then {_x setGroupIcon [_mT, _iconType]};	// (at once - the module sets the same on its next pass)
					private _mS = _x getVariable "BIS_MARTA_ICON_SIZE";
					if (!isNil "_mS" && {!((toLower ((_x getGroupIcon _mS) param [0, ""])) in ["", "dummy"])}) then {_x setGroupIcon [_mS, "dummy"]};
					if (!(_x getVariable ["MCCMK_iconMarta", false]) && {missionNamespace getVariable ["MCC_debug", false]}) then {["INFO", "console icons", "%1: shown through Arma's Military Symbols icon (id %2), set to %3 | icons on the group: %4", [groupId _x, _mT, _iconType, getGroupIcons _x]] call MCC_fnc_log};
					_x setVariable ["MCCMK_iconMarta", true];
					if (!isNil "_icon") then {_x removeGroupIcon _icon};
					_x setVariable ["MCCgroupIconData", nil];
				} else {
					if (!isNil "_icon" && {((_x getGroupIcon _icon) param [0, ""]) != ""}) then {_x setGroupIcon [_icon, _iconType]} else {_icon = _x addGroupIcon [_iconType,[0,0]]};
					_x setvariable ["MCCgroupIconData",_icon,false];
				};

				_icon = (_x getvariable ["MCCgroupIconSize", [nil]]) select 0;
				if (!isNil "_icon" && {((_x getGroupIcon _icon) param [0, ""]) != ""}) then {_x setGroupIcon [_icon, _unitsSizeMarker]} else {_icon = _x addGroupIcon [_unitsSizeMarker,[0,0]]};
				_x setvariable ["MCCgroupIconSize",[_icon,_unitsSizeMarker],false];

				//(MK) the colour and name worked out first and set ONCE a pass - set in steps (plain, the status, white
				//in combat), the map draws the steps in between: icons flash dark / light, names flicker
				private _iconCol = _markerColor;
				private _iconTxt = format ["%1",_groupName];
				if (!isnil "_groupStatus" && {(abs (time - (_groupStatus select 1))) < 180}) then {_iconTxt = format ["%1%2",_groupName,_groupStatus select 0]};
				if (_behaviour == "COMBAT") then {_iconCol = [1,1,1,1]; _iconTxt = _groupName};	//Show in combat
				_x setGroupIconParams ([_x, [_iconCol,_iconTxt,1,true]] call MCCMK_fnc_iconWithWp);
				_x setVariable ["MCCMK_iconWant", [_iconCol,_iconTxt,1,true]];
			};
		} foreach allgroups;

		//Load available resources
		_array = (missionNamespace getVariable format ["MCC_res%1",playerside]);
		{_mccdialog displayCtrl _x ctrlSetText str floor (_array select _forEachIndex)} foreach [81,82,83,84,85];

		sleep 0.5;
	};

	//Clear stuff after exiting
	{
		_x removeGroupIcon (_x getVariable ["MCCgroupIconData",-1]);
		_x removeGroupIcon ((_x getVariable ["MCCgroupIconSize",[-1]]) select 0);
		_x removeGroupIcon (_x getVariable ["MCCgroupIconDataSelected",-1]);
	} foreach allgroups;

	setGroupIconsVisible [false,false];
	setGroupIconsSelectable false;

	//Remove EH
	removeMissionEventHandler ["EachFrame", _holdEHs select 0];
	removeMissionEventHandler ["Draw3D", _holdEHs select 1];
	call MCCMK_iconMartaOff;
	(_mccdialog displayCtrl 9120) ctrlRemoveEventHandler ["draw",_handler];

	removeMissionEventHandler ["GroupIconClick",_groupIconHandle];
};