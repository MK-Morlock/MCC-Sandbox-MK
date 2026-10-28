//Made by Shay_Gman (c) 02.14
#define groupGen_IDD 2994

#define UNIT_TYPE 3010
#define UNIT_CLASS 3011
#define MCC_GGUNIT_TYPE 3012
#define MCC_GGUNIT_BEHAVIOR 3030
#define MCC_GroupGenCurrentGroup_IDD 9003
#define MCC_GGListBoxIDC 3013
#define MCC_GGADDIDC 3014
#define MCC_GGCLEARIDC 3015
#define MCC_GGUNIT_EMPTY 3016
#define MCC_GGUNIT_EMPTYTITLE 3017
#define mcc_groupGen_CurrentgroupNameTittle_IDC 3018
#define mcc_groupGen_CurrentgroupNameText_IDC 3019
#define MCC_GGSAVE_GROUPIDC 3020

private _control = controlNull;
private _mccdialog = displayNull;
private _comboBox = controlNull;
private _displayname = "";
private _pic = nil;
disableSerialization;

params ["_action", ["_refresh", false]];
//Support menus need a faction that has support: not civilians
if (_action in [4, 5, 7, 16] && {!(call MCC_fnc_supportFactionOK)}) exitWith {};
_mccdialog = (uiNamespace getVariable "MCC_groupGen_Dialog");
["init"] call MCCMK_fnc_panelRemember;
["restore"] spawn MCCMK_fnc_panelRemember;
//Clicking a console button again closes its panel (action -> panel idc)
private _ownPanel = [501,502,503,504,500,505,506,507,508,509,511,512,513,514,515,516,517,518,521] param [_action, -1];
if (!_refresh && {_ownPanel > 0} && {ctrlShown (_mccdialog displayCtrl _ownPanel)}) exitWith {(_mccdialog displayCtrl _ownPanel) ctrlShow false};
MCC_GUI1initDone = false;
//------------------------------------------------------------------------------------ Close all open boxes -------------------------------------------------------------------------------
for "_i" from 500 to 518 step 1 do
{
	(_mccdialog displayCtrl _i) ctrlShow false;
};
(_mccdialog displayCtrl 521) ctrlShow false;

if (_action == 18) exitWith
{
	(_mccdialog displayCtrl 521) ctrlShow true;
	[] call MCCMK_fnc_paradropPanel;
};

//-------------------------------------------------------------------------------------Weather----------------------------------------------------------------------------------------------
if (_action == 0) exitWith
{
	_control = (_mccdialog displayCtrl 501);
	_control ctrlShow true;

	(_mccdialog displayCtrl 10) sliderSetRange [0, 1];
	(_mccdialog displayCtrl 11) sliderSetRange [0, 1];
	(_mccdialog displayCtrl 12) sliderSetRange [0, 1];
	(_mccdialog displayCtrl 13) sliderSetRange [0, 1];
	(_mccdialog displayCtrl 14) sliderSetRange [0, 1];

	(_mccdialog displayCtrl 10) sliderSetPosition fog;
	(_mccdialog displayCtrl 11) sliderSetPosition rain;
	(_mccdialog displayCtrl 12) sliderSetPosition overcast;
	(_mccdialog displayCtrl 13) sliderSetPosition waves;
	(_mccdialog displayCtrl 14) sliderSetPosition windStr;
};

//-------------------------------------------------------------------------------------Time----------------------------------------------------------------------------------------------
if (_action == 1) exitWith
{
	_control = (_mccdialog displayCtrl 502);
	_control ctrlShow true;

	//--------------------------------------Fill index--------------------------------------------------------------------------
	_comboBox = (_mccdialog displayCtrl 15);		// MONTH
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_comboBox lbAdd _displayname;
	} foreach MCC_months_array;
	_comboBox lbSetCurSel (date select 1)-1;

	_comboBox = (_mccdialog displayCtrl 16);		// Day
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x];
		_comboBox lbAdd _displayname;
	} foreach MCC_days_array;
	_comboBox lbSetCurSel (date select 2)-1;

	_comboBox = (_mccdialog displayCtrl 17);		//  Year
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x];
		_comboBox lbAdd _displayname;
	} foreach [1990,1991,1992,1993,1994,1995,1996,1997,1998,1999,2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025,2026,2027,2028,2029,2030];
	_comboBox lbSetCurSel ((date select 0)-1990);

	_comboBox = (_mccdialog displayCtrl 18);		// HOUR
	lbClear _comboBox;
	{
		_displayname = if (_x < 10) then {format ["0%1",_x]} else {format ["%1",_x]};
		_comboBox lbAdd _displayname;
	} foreach MCC_hours_array;
	_comboBox lbSetCurSel (date select 3);

	_comboBox = (_mccdialog displayCtrl 19);		// Minutes
	lbClear _comboBox;
	{
		_displayname = if (_x < 10) then {format ["0%1",_x]} else {format ["%1",_x]};
		_comboBox lbAdd _displayname;
	} foreach MCC_minutes_array;
	_comboBox lbSetCurSel (date select 4);
};

//-------------------------------------------------------------------------------------RESPWAN----------------------------------------------------------------------------------------------
if (_action == 2) exitWith
{
	_control = (_mccdialog displayCtrl 503);
	_control ctrlShow true;

	//--------------------------------------Fill index--------------------------------------------------------------------------
	_comboBox = (_mccdialog displayCtrl 21);		// FOB
	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach ["HQ","F.O.B"];
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = (_mccdialog displayCtrl 201212);		// Teleport

	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach ["None","Teleport","Paradrop","HALO"];
	[_comboBox, 1] call MCC_fnc_comboRemember;
};

//-------------------------------------------------------------------------------------DEBUG----------------------------------------------------------------------------------------------
if (_action == 3) exitWith
{
	_control = (_mccdialog displayCtrl 504);
	_control ctrlShow true;
};

//-------------------------------------------------------------------------------------CAS----------------------------------------------------------------------------------------------
if (_action == 4) exitWith
{
	_control = (_mccdialog displayCtrl 500);
	_control ctrlShow true;

	//--------------------------------------CAS--------------------------------------------------------------------------

	[] call MCCMK_fnc_casAirList;
};

//-------------------------------------------------------------------------------------Artillery----------------------------------------------------------------------------------------------
if (_action == 5) exitWith
{
	_control = (_mccdialog displayCtrl 505);
	_control ctrlShow true;

	//---------------------------------Artillery----------------------------------------------------------------------------
	_comboBox = (_mccdialog displayCtrl 30);		// Artillery Type
		lbClear _comboBox;
		{
			_displayname = format ["%1",_x select 0];
			_comboBox lbAdd _displayname;
		} foreach MCC_artilleryTypeArray;
		[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = (_mccdialog displayCtrl 31);		//Artillery Spread
		lbClear _comboBox;
		{
			_displayname = format ["%1",_x select 0];
			_comboBox lbAdd _displayname;
		} foreach MCC_artillerySpreadArray;
		[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = (_mccdialog displayCtrl 32);		//Artillery Number
	lbClear _comboBox;
	for "_i" from 1 to 50 do
	{
		_displayname = str _i;
		_comboBox lbAdd _displayname;
	};
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = (_mccdialog displayCtrl 33);		//Artillery Delay
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["0","20 sec","40 sec","1 min","80  sec","100  sec","2 min","140 sec","160 sec","3 min"];
	[_comboBox, 0] call MCC_fnc_comboRemember;
};

//-------------------------------------------------------------------------------------SPAWN----------------------------------------------------------------------------------------------
if (_action == 6) exitWith
{
	_control = (_mccdialog displayCtrl 506);
	_control ctrlShow true;

	MCC_groupGenCurrenGroupArray = []; 		//Reset the current group

	//Units / Groups first, then the type list that belongs to it: the type list was always filled with the single-unit
	//types, so with Groups remembered the group list offered single units
	_comboBox = _mccdialog displayCtrl MCC_GGUNIT_TYPE;
	MCC_spawnListsBusy = true;
	lbClear _comboBox;
	{
		_displayname =  _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["Units", "Groups"];
	MCC_spawnListsBusy = false;
	_comboBox lbSetCurSel ((missionNamespace getVariable ["MCC_spawnTypeMem", 0]) min 1 max 0);
	["DEBUG", "controlsHandle", "spawn panel opened on Type %1", [_comboBox lbText (lbCurSel _comboBox)]] call MCC_fnc_log;
	MCC_type_index = lbCurSel _comboBox;

	_comboBox = _mccdialog displayCtrl MCC_GGUNIT_BEHAVIOR;
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_index = _comboBox lbAdd _displayname;
	} foreach MCC_spawn_behaviors;
	_comboBox lbSetCurSel MCC_behavior_index;

	_comboBox = _mccdialog displayCtrl 3078;
	lbClear _comboBox;
	{_comboBox lbAdd _x} forEach ["No", "Yes"];
	_comboBox lbSetCurSel ([0, 1] select (missionNamespace getVariable ["MCC_spawnCommandable", false]));

	_comboBox = _mccdialog displayCtrl MCC_GGUNIT_EMPTY;
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_comboBox lbAdd _displayname;
	} foreach MCC_spawn_empty;
	_comboBox lbSetCurSel MCC_empty_index;

	_comboBox =(_mccdialog displayCtrl 0);		//fill zone locations
	lbClear _comboBox;
	{
		_displayname = _x select 0;
		_comboBox lbAdd _displayname;
	} foreach MCC_ZoneLocation;
	_comboBox lbSetCurSel mcc_hc;	//MCC_ZoneLocation_index;

	MCC_spawnListsBusy = false;
	isNil {["open"] call MCC_fnc_spawnLists};	//Branch and Class for the type now shown (unscheduled: not paused half way)
	[] spawn {{uiSleep _x; isNil {["sync"] call MCC_fnc_spawnLists}} forEach [0.15, 0.6]};
	{
		private _c = _mccdialog displayCtrl _x;
		if !(_c getVariable ["MCC_spawnSyncEH", false]) then {
			_c setVariable ["MCC_spawnSyncEH", true];
			_c ctrlAddEventHandler ["SetFocus", {isNil {["sync"] call MCC_fnc_spawnLists}}];
			_c ctrlAddEventHandler ["MouseButtonDown", {isNil {["sync"] call MCC_fnc_spawnLists}}];
		};
	} forEach [3010, 3011];
	private _ct = _mccdialog displayCtrl MCC_GGUNIT_TYPE;
	if !(_ct getVariable ["MCC_spawnTypeEH", false]) then {
		_ct setVariable ["MCC_spawnTypeEH", true];
		_ct ctrlAddEventHandler ["LBSelChanged", {params ["_c", "_i"]; isNil {["type", _i] call MCC_fnc_spawnLists}}];
	};
	if (mcc_delayed_spawn) then {(_mccdialog displayCtrl 3022) cbSetChecked true};
	if (mcc_caching) then {(_mccdialog displayCtrl 3023) cbSetChecked true};
	(_mccdialog displayCtrl 3022) ctrlRemoveAllEventHandlers "CheckedChanged";
	(_mccdialog displayCtrl 3022) ctrlAddEventHandler ["CheckedChanged", {mcc_delayed_spawn = (_this select 1) == 1}];
	(_mccdialog displayCtrl 3023) ctrlRemoveAllEventHandlers "CheckedChanged";
	(_mccdialog displayCtrl 3023) ctrlAddEventHandler ["CheckedChanged", {mcc_caching = (_this select 1) == 1}];
};

//-------------------------------------------------------------------------------------EVAC----------------------------------------------------------------------------------------------
if (_action == 7) exitWith
{
	_control = (_mccdialog displayCtrl 507);
	_control ctrlShow true;

	//--------------------------------------------------------EVAC Settings---------------------------------------------------------
	_comboBox =  (_mccdialog displayCtrl 40);		//EVAC type
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["Helicopters", "Vehicles","Tracked", "Ships"];
	[] call MCC_fnc_evacFillFactions;
	_comboBox lbSetCurSel (((missionNamespace getVariable ["MCCMK_evacType", 0]) max 0) min 3);
	[] call MCC_fnc_evacFillClass;

	_comboBox = (_mccdialog displayCtrl 44);		//fill combobox Fly in Hight
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x  select 0];
		_index = _comboBox lbAdd _displayname;
	} foreach MCC_evacFlyInHight_array;
	_comboBox lbSetCurSel MCC_evacFlyInHight_index;

	_evacVehicles = missionNamespace getvariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide],[]];
	[] call MCC_fnc_evacPanelRefresh;
	if !(missionNamespace getVariable ["MCC_evacPanelLoop", false]) then {
		MCC_evacPanelLoop = true;
		[] spawn {
			disableSerialization;
			private _last = [];
			while {!isNull (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) && {ctrlShown ((uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) displayCtrl 507)}} do {
				private _sig = (missionNamespace getVariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide], []]) apply {[_x, alive _x, alive (driver _x)]};
				if !(_sig isEqualTo _last) then {_last = _sig; [] call MCC_fnc_evacPanelRefresh};
				sleep 1;
			};
			MCC_evacPanelLoop = false;
			if (missionNamespace getVariable ["MCC_evacSpawnPending", false]) then {onMapSingleClick ""; MCC_evacSpawnPending = false};
		};
	};

	//Change evac type by vehicle class
	if (count _evacVehicles > (missionNameSpace getvariable ["MCC_evacVehicles_index",0])-1 && ((missionNameSpace getvariable ["MCC_evacVehicles_index",0]) >= 0)) then {
		private _insetionArray = [];
		private _type = nil;
		_insetionArray = ["Move (engine on)","Move (engine off)"];
		(_mccdialog displayCtrl 44) ctrlShow false;
		_type = _evacVehicles select (missionNameSpace getvariable ["MCC_evacVehicles_index",0]);

		if (isnil "_type") exitWith {};

		//Case we choose aircrft
		if (_type iskindof "helicopter") then
		{
			_insetionArray = ["Free Landing (engine on)","Free Landing (engine off)","Hover","Helocasting(Water)","Smoke Signal","Fast-Rope","Precise Landing"];
			(_mccdialog displayCtrl 44) ctrlShow true;
		};

		_comboBox = (_mccdialog displayCtrl 43);					//Adjust insertion type by evac type
		lbClear _comboBox;
		{
			_displayname = _x;
			_index = _comboBox lbAdd _displayname;
		} foreach _insetionArray;
		[_comboBox, 0] call MCC_fnc_comboRemember;
	};
};

//-------------------------------------------------------------------------------------IED----------------------------------------------------------------------------------------------
if (_action == 8) exitWith
{
	#define MCC_TRAPS_TYPE 2007
	#define MCC_TRAPS_OBJECT 2008
	#define MCC_TRAPS_EXPLOSIN_SIZE 2009
	#define MCC_TRAPS_EXPLOSIN_TYPE 2010
	#define MCC_TRAPS_TARGET_FACTION 2011
	#define MCC_TRAPS_JAMMABLE 2012
	#define MCC_TRAPS_DISARM 2013
	#define MCC_TRAPS_TRIGGER 2014
	#define MCC_TRAPS_PROXIMITY 2015
	#define MCC_TRAPS_AMBUSH 2016

	_control = (_mccdialog displayCtrl 508);
	_control ctrlShow true;

	//--------------------------------------------------------TRAPS Settings---------------------------------------------------------
	_comboBox = _mccdialog displayCtrl MCC_TRAPS_PROXIMITY;		//fill combobox IED Prox
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x];
		_index = _comboBox lbAdd _displayname;
	} foreach MCC_ied_proxArray;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_TARGET_FACTION;		//fill combobox IED Target
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x];
		_index = _comboBox lbAdd _displayname;
	} foreach MCC_ied_targetArray;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_TYPE;		//fill combobox IED Type
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["Small objects", "Medium objects", "Wrecks", "Hidden IED", "Mine Fields", "Ammoboxes", "Cars", "Armed Civilians","Suicide bombers"];
	if !(_comboBox getVariable ["MCC_iedTypeEH", false]) then {
		_comboBox setVariable ["MCC_iedTypeEH", true];
		_comboBox ctrlAddEventHandler ["LBSelChanged", {[0] execVM ((missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"]) + "mcc\fnc\ied\scripts\trap_change.sqf")}];
	};
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_EXPLOSIN_SIZE;		//fill combobox IED Explosion size
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["Small", "Medium", "Large"];
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_EXPLOSIN_TYPE;		//fill combobox IED Explosion type
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["Deadly", "Disabling", "Fake", "No Explosion"];
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_DISARM;		//fill combobox IED Disarm time
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["10 Sec", "20 Sec", "30 Sec", "40 Sec", "50 Sec", "1 Min", "2 Min", "3 Min", "4 Min", "5 Min"];
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_JAMMABLE;		//fill combobox IED Jameable
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["True", "False"];
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_TRIGGER;		//fill combobox IED Trigger Type
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach ["Proximity", "Radio - Spotter", "Mission maker only","Mini-Game(Proximity)","Mini-Game(Manual)"];
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRAPS_AMBUSH;		//fill combobox IED Ambush group
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 3];
		_index = _comboBox lbAdd _displayname;
	} foreach GEN_INFANTRY;
	_index = _comboBox lbAdd "Spotter - Civilian";
	_index = _comboBox lbAdd "Spotter - Camouflaged";
	[_comboBox, 0] call MCC_fnc_comboRemember;
};
//-------------------------------------------------------------------------------------CONVOY----------------------------------------------------------------------------------------------
if (_action == 9) exitWith
{
	_control = (_mccdialog displayCtrl 509);
	_control ctrlShow true;

	//------------------------------------------Convoy Generator--------------------------------------------------------
	_comboBox = (_mccdialog displayCtrl 50);		//fill combobox Car1
	lbClear _comboBox;
	{
		_displayname = format ["%1",(_x select 3) select 0];
		_index = _comboBox lbAdd _displayname;
		_comboBox lbsetpicture [_index, (_x select 3) select 1];
	} foreach U_GEN_CAR;
	_index = _comboBox lbAdd "None";
	_comboBox lbSetCurSel MCC_convoyCar1Index;

	_comboBox =  (_mccdialog displayCtrl 51);		//fill combobox Car2
	lbClear _comboBox;
	{
		_displayname = format ["%1",(_x select 3) select 0];
		_index = _comboBox lbAdd _displayname;
		_comboBox lbsetpicture [_index, (_x select 3) select 1];
	} foreach U_GEN_CAR;
	_index = _comboBox lbAdd "None";
	_comboBox lbSetCurSel MCC_convoyCar2Index;

	_comboBox =  (_mccdialog displayCtrl 52);		//fill combobox Car3
	lbClear _comboBox;
	{
		_displayname = format ["%1",(_x select 3) select 0];
		_index = _comboBox lbAdd _displayname;
		_comboBox lbsetpicture [_index, (_x select 3) select 1];
	} foreach U_GEN_CAR;
	_index = _comboBox lbAdd "None";
	_comboBox lbSetCurSel MCC_convoyCar3Index;

	_comboBox =  (_mccdialog displayCtrl 53);		//fill combobox Car4
	lbClear _comboBox;
	{
		_displayname = format ["%1",(_x select 3) select 0];
		_index = _comboBox lbAdd _displayname;
		_comboBox lbsetpicture [_index, (_x select 3) select 1];
	} foreach U_GEN_CAR;
	_index = _comboBox lbAdd "None";
	_comboBox lbSetCurSel MCC_convoyCar4Index;

	_comboBox =  (_mccdialog displayCtrl 54);		//fill combobox Car5
	lbClear _comboBox;
	{
		_displayname = format ["%1",(_x select 3) select 0];
		_index = _comboBox lbAdd _displayname;
		_comboBox lbsetpicture [_index, (_x select 3) select 1];
	} foreach U_GEN_CAR;
	_index = _comboBox lbAdd "None";
	_comboBox lbSetCurSel MCC_convoyCar5Index;

	_comboBox =  (_mccdialog displayCtrl 55);;		//fill combobox HVT
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_index = _comboBox lbAdd _displayname;
	} foreach MCC_convoyHVT;
	_comboBox lbSetCurSel MCC_convoyHVTIndex;

	_comboBox =  (_mccdialog displayCtrl 56);;		//fill combobox HVT car
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_index = _comboBox lbAdd _displayname;
	} foreach MCC_convoyHVTcar;
	_comboBox lbSetCurSel MCC_convoyHVTCarIndex;
};

//-------------------------------------------------------------------------------------Markers----------------------------------------------------------------------------------------------
if (_action == 10) exitWith
{
	_control = (_mccdialog displayCtrl 511);
	_control ctrlShow true;

	//------------------------------------------------Markers-------------------------------------------------------
	_comboBox =(_mccdialog displayCtrl 3051);		//fill Markers Colors 1
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_comboBox lbAdd _displayname;
	} foreach MCC_colorsarray;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = (_mccdialog displayCtrl 3053);		//fill Markers Shape
	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach MCC_shapeMarker;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox =(_mccdialog displayCtrl 3054);		//fill Markers Brush
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_index = _comboBox lbAdd _displayname;
		_pic = (_x select 1);
		if (!isnil "_pic") then {_comboBox lbsetpicture [_index, _x select 1]};
	} foreach MCC_brushesarray;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = (_mccdialog displayCtrl 3052);		//fill Markers Type
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_index = _comboBox lbAdd _displayname;
		_pic = (_x select 1);
		if (!isnil "_pic") then {_comboBox lbsetpicture [_index, _x select 1]};
	} foreach MCC_markerarray;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = (_mccdialog displayCtrl 3049);		//fill Available Markers
	lbClear _comboBox;
	{
		_displayname = _x;
		_index = _comboBox lbAdd _displayname;
	} foreach (missionNamespace getVariable ["MCC_activeMarkers",[]]);
	[_comboBox, 0] call MCC_fnc_comboRemember;
};

//-------------------------------------------------------------------------------------Briefing----------------------------------------------------------------------------------------------
if (_action == 11) exitWith
{
	_control = (_mccdialog displayCtrl 512);
	_control ctrlShow true;
};

//-------------------------------------------------------------------------------------TASKS------------------------------------------------------------------------------
if (_action == 12) exitWith {
	_control = (_mccdialog displayCtrl 513);
	_control ctrlShow true;

	//---------------------------------------------------Taskss--------------------------------------------------------
	_comboBox = (_mccdialog displayCtrl 3058);		//fill Tasks
	lbClear _comboBox;
	{
		_index = _comboBox lbAdd (_x select 0);
		_comboBox lbsetpicture [_index, [([_x select 1] call BIS_fnc_taskType)] call BIS_fnc_taskTypeIcon];
	} foreach (missionNameSpace getVariable ["MCC_tasks",[]]);
	[_comboBox, 0] call MCC_fnc_comboRemember;

	#define MCC_TASKS_ICON 30581
	_comboBox = (_mccdialog displayCtrl MCC_TASKS_ICON);		//fill Tasks
	lbClear _comboBox;
	{
		_index = _comboBox lbAdd (configName _x );
		_comboBox lbsetpicture [_index, (getText (_x >> "icon"))];
	} foreach ("true" configClasses (configfile >> "CfgTaskTypes"));
	[_comboBox, 0] call MCC_fnc_comboRemember;
};

//-------------------------------------------------------------------------------------JUKEBOX----------------------------------------------------------------------------------------------
if (_action == 13) exitWith {
	_control = (_mccdialog displayCtrl 514);
	_control ctrlShow true;

	//--------------------------------------------------Jukebox---------------------------------------------------------------------------
	#define MCC_JUKEBOX_VOLUME 3059
	#define MCC_JUKEBOX_TRACK 3060
	#define MCC_JUKEBOX_ACTIVATE 3061
	#define MCC_JUKEBOX_CONDITION 3062
	#define MCC_JUKEBOX_ZONE 3063

	private _trackArray = [];
	private _tracksCfg = configNull;
	private _track = configNull;
	private _cfgname = "";
	private _cfgclass = "";
	_trackArray = [];

	_tracksCfg = if (missionNamespace getvariable ["MCC_jukeboxMusic",true]) then {[missionConfigFile >> "CfgMusic",configFile >> "CfgMusic"]} else {[missionConfigFile >> "CfgSounds",ConfigFile >> "CfgSounds",configFile >> "CfgSFX"]};

	{
		for "_i" from 0 to ((count _x) - 1) do {
			_track = _x select _i;
			if (isClass _track) then {
				_cfgname = getText (_track >> "name");
				_cfgclass = configName(_track);
				_trackArray pushBack [_cfgname,_cfgclass,_foreachindex];
			};
		};
	} forEach _tracksCfg;


	//fill combobox music tracks
	_comboBox = _mccdialog displayCtrl MCC_JUKEBOX_TRACK;
	lbClear _comboBox;

	{
		_displayname = format ["%1",_x select 0];
		_comboBox lbAdd _displayname;
		_comboBox lbSetData [_foreachindex,_x select 1];
	} foreach _trackArray;
	_comboBox lbSetCurSel (missionNamespace getVariable ["MCC_musicTracks_index",0]);

	_comboBox = _mccdialog displayCtrl MCC_JUKEBOX_ACTIVATE; //fill combobox Activate by

	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach MCC_musicActivateby_array;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_JUKEBOX_CONDITION; //fill combobox Condition
	lbClear _comboBox;
	{
		_displayname =_x;
		_comboBox lbAdd _displayname;
	} foreach MCC_musicCond_array;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_JUKEBOX_ZONE; //fill combobox zone's numbers
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x];
		_comboBox lbAdd _displayname;
	} foreach (missionNamespace getVariable ["MCC_zones_numbers",[]]);
	_comboBox lbSetCurSel MCC_zone_index;

	sliderSetRange [MCC_JUKEBOX_VOLUME, 0, 1];
	sliderSetPosition [MCC_JUKEBOX_VOLUME, musicVolume];	//right = loud
};

//-------------------------------------------------------------------------------------JUKEBOX----------------------------------------------------------------------------------------------
if (_action == 14) exitWith
{
	_control = (_mccdialog displayCtrl 515);
	_control ctrlShow true;

	//--------------------------------------------------TRIGGERS---------------------------------------------------------------------------
	#define MCC_TRIGGERS_ACTIVATE 3064
	#define MCC_TRIGGERS_CONDITION 3065
	#define MCC_TRIGGERS_SHAPE 3066
	#define MCC_TRIGGERS_LIST 3067
	#define MCC_TRIGGERS_NAME 3068
	#define MCC_TRIGGERS_TIME_MIN 3071
	#define MCC_TRIGGERS_TIME_MAX 3072
	#define MCC_TRIGGERS_STAT_COND 3073
	#define MCC_TRIGGERS_STAT_DEACTIVE 3075

	//--------------------------------------------------Triggers---------------------------------------------------------------------------
	_comboBox = _mccdialog displayCtrl MCC_TRIGGERS_ACTIVATE; //fill combobox Activate by

	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach MCC_musicActivateby_array;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRIGGERS_CONDITION; //fill combobox Condition

	lbClear _comboBox;
	{
		_displayname =_x;
		_comboBox lbAdd _displayname;
	} foreach MCC_musicCond_array;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRIGGERS_SHAPE;		//fill combobox Trigger Shape
	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach MCC_shapeMarker;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	_comboBox = _mccdialog displayCtrl MCC_TRIGGERS_LIST;		//fill combobox Active triggers
	lbClear _comboBox;
	{
		_displayname = _x select 0;
		_comboBox lbAdd _displayname;
	} foreach MCC_triggers;
	[_comboBox, 0] call MCC_fnc_comboRemember;
};

//-------------------------------------------------------------------------------------CLIENT SIDE----------------------------------------------------------------------------------------------
if (_action == 15) exitWith
{
	_control = (_mccdialog displayCtrl 516);
	_control ctrlShow true;

	#define MCCVIEWDISTANCE 1006
	#define MCCGRASSDENSITY 1007

	//----------------------------------------------------------Client Side settings----------------------------------------------------------------------------

	_comboBox = _mccdialog displayCtrl MCCGRASSDENSITY;		//fill combobox Grass
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x select 0];
		_comboBox lbAdd _displayname;
	} foreach MCC_grass_array;
	_comboBox lbSetCurSel (MCC_terrainPref select 0);

	_comboBox = _mccdialog displayCtrl MCCVIEWDISTANCE;		//fill combobox View distance
	lbClear _comboBox;
	{
		_displayname = format ["%1",_x];
		_comboBox lbAdd _displayname;
	} foreach MCC_view_array;
	_comboBox lbSetCurSel (MCC_terrainPref select 1); // set viewdistance index to current vd

	sleep 1;
	MCC_GUI1initDone = true;
};

//-------------------------------------------------------------------------------------AIRDROP----------------------------------------------------------------------------------------------
if (_action == 16) exitWith
{
	_control = (_mccdialog displayCtrl 517);
	_control ctrlShow true;

	#define MCC_AIRDROPTYPE 1031
	#define MCC_airdropArray 1033

	if (isNil "MCCMK_adMem") then {MCCMK_adMem = createHashMap};
	[] call MCCMK_fnc_airdropAirList;

	private _mode = MCCMK_adMem getOrDefault ["mode", 0];
	missionNamespace setVariable ["MCC_airdropIsParachute", _mode];
	(_mccdialog displayCtrl 1037) lbSetCurSel _mode;
	for "_i" from 1033 to 1036 do {(_mccdialog displayCtrl _i) ctrlShow (_mode == 0)};

	_comboBox = _mccdialog displayCtrl MCC_AIRDROPTYPE;		//Airdrop Type
	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach ["Vehicles", "Tracked", "Motorcycles", "Ships", "Ammo"];
	if !(_comboBox getVariable ["MCC_airdropListEH", false]) then {
		_comboBox setVariable ["MCC_airdropListEH", true];
		_comboBox ctrlAddEventHandler ["LBSelChanged", {
			["DEBUG", "supplyDrop", "type list changed to %1", [_this select 1]] call MCC_fnc_log;
			[_this select 1] call MCCMK_fnc_airdropList;
		}];
	};
	_comboBox lbSetCurSel ((MCCMK_adMem getOrDefault ["type", 0]) min 4);
	{
		private _c = _mccdialog displayCtrl _x;
		if !(_c getVariable ["MCC_airdropSyncEH", false]) then {
			_c setVariable ["MCC_airdropSyncEH", true];
			_c ctrlAddEventHandler ["SetFocus", {[-2] call MCCMK_fnc_airdropList}];
			_c ctrlAddEventHandler ["MouseButtonDown", {[-2] call MCCMK_fnc_airdropList}];
		};
	} forEach [1032, 1035, 1038];
	if !(_mccdialog getVariable ["MCC_airdropSyncDispEH", false]) then {
		_mccdialog setVariable ["MCC_airdropSyncDispEH", true];
		{
			_mccdialog displayAddEventHandler [_x, {
				private _d = _this select 0;
				if (ctrlShown (_d displayCtrl 517)) then {[] spawn {uiSleep 0.1; isNil {[-2] call MCCMK_fnc_airdropList}}};
			}];
		} forEach ["MouseButtonUp", "KeyUp"];
	};

	_comboBox = _mccdialog displayCtrl MCC_airdropArray;		//Airdrop Current Airdrop
	lbClear _comboBox;
	{
		if (!isnil "_x") then
		{
			_displayname = getText(configFile >> "CfgVehicles" >> _x >> "displayname") ;
			_comboBox lbAdd _displayname;
		};
	} foreach MCC_airDropArray;
	[_comboBox, 0] call MCC_fnc_comboRemember;

	[] call MCCMK_fnc_airdropList;
};

//-------------------------------------------------------------------------------------DELETE----------------------------------------------------------------------------------------------
if (_action == 17) exitWith
{
	_control = (_mccdialog displayCtrl 518);
	_control ctrlShow true;

	#define MCCDELETEBRUSH 1030

	_comboBox = _mccdialog displayCtrl MCCDELETEBRUSH;		//Delete Brush
	lbClear _comboBox;
	{
		_displayname = _x;
		_comboBox lbAdd _displayname;
	} foreach ["Delete All",
			  "Delete All Units",
			  "Delete Man",
			  "Delete Vehicles",
			  "Delete Tanks",
			  "Delete Air",
			  "Delete Ammoboxs",
			  "Delete Markers",
			  "Lights (Off)",
			  "Lights (On)",
			  "Lock Doors (All)",
			  "Unlock Doors(All)",
			  "Lock Doors (Random)",
			  "Atmosphere - Warzone",
			  "Atmosphere - Sandstorm",
			  "Atmosphere - Blizzard",
			  "Atmosphere - Snow",
			  "Atmosphere - Heatwave",
			  "Atmosphere - Clear",
			  "Remove N/V from units",
			  "Add Flashlights to all units",
			  "Delete Bodies"];
	[_comboBox, 0] call MCC_fnc_comboRemember;
};

sleep 1;
MCC_GUI1initDone = true;
