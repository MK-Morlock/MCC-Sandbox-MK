//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private _ctrl = controlNull;
private _pressed = 0;
private _posX = 0;
private _posY = 0;
private _shift = false;
private _ctrlKey = false;
private _alt = false;
private _marker = nil;
private _markerPos = [];
private _markerDir = 0;
private _spawn = [];
private _away = [];
private _ammount = 0;
private _dir = 0;
private _nearObjects = [];

#define MCCDELETEBRUSH 1030
#define MCCZONENUMBER 1023
#define MCC_MINIMAP 9000
#define MCC_GroupGenInfo_IDC 530

disableSerialization;

params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;
_posX = _params select 2;
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;
MCC_XYmap = [_posX,_posY];

if (mcc_missionmaker != (name player)) exitWith {};
private _clickT0 = diag_tickTime; private _mct = missionNamespace getVariable ["MCC_mapClickTime", -100]; if ((_clickT0 - _mct) < 2) then {_clickT0 = _mct};
private _clickHit = false;

if (_pressed == 1 && {missionNamespace getVariable ["MCCMK_lineDrawing", false]}) exitWith {MCCMK_lineCancel = true};
if (_pressed == 1 && {missionNamespace getVariable ["MCC_evacSpawnPending", false]}) exitWith {onMapSingleClick ""; MCC_evacSpawnPending = false; hint "Evac spawn cancelled"};
MCC_GroupGenMouseButtonDown = true;	//Mouse state
MCC_GroupGenMouseButtonUp = false;

if (isnil "MCC_doubleClicked") then {MCC_doubleClicked =false};

//Close Group info control
if (_pressed == 1 && !MCC_doubleClicked) then {
	ctrlShow [510,false];
	ctrlShow [MCC_GroupGenInfo_IDC,false];
	hintsilent "";
};

//Open Curator
if ((_pressed == 0) && (uiNameSpace getVariable ["MCC_ZeusOpen",false]))  exitWith {
	uiNameSpace setVariable ["MCC_ZeusOpen",false];

	//worldPos
	MCC_ConsoleWPpos = _ctrl ctrlMapScreenToWorld [_posX,_posY];

	cutText ["","BLACK",0.1];
	while {dialog} do {closeDialog 0; sleep 0.01};
	while {(isnull curatorcamera)} do {openCuratorInterface; sleep 0.5};

	MCC_ConsoleWPpos set [2,50];
	sleep 1;
	[MCC_ConsoleWPpos, MCC_ConsoleWPpos, 0] call BIS_fnc_setCuratorCamera;
	cutText ["","BLACK IN",0.5];
};

//Open 3D
if ((_pressed == 0) && _alt)  exitWith {
	//worldPos
	MCC_ConsoleWPpos = _ctrl ctrlMapScreenToWorld [_posX,_posY];

	[0,MCC_ConsoleWPpos] execVM format ["%1mcc\pop_menu\spawn_group3d.sqf",MCC_path];
};

//Select zone
if (_pressed == 0) then {
	private _nearZone = false;
	private _selectedPos = [];
	private _newZone = 0;
	private _comboBox = controlNull;
	private _distance = controlNull;
	private _marker = nil;
	private _nearMarker = false;
	private _markerName = "";
	private _isIcon = 0;
	_selectedPos = _ctrl ctrlmapscreentoworld MCC_XYmap;
	_nearZone 	= false;
	_nearMarker	= false;
	_distance = (ctrlMapScale _ctrl) * 400;

	//Are we near a zone marker
	{
		if (!isnil "_x") then {
			if ((_selectedPos distance _x) < _distance) exitWith {
				_nearZone = true;
				_newZone = _foreachIndex;
			};
		};
	} foreach mcc_zone_pos;

	//Are we near MCC marker
	{
		if ((_selectedPos distance (markerpos _x)) < _distance) exitWith {
			_nearMarker = true;
			_markerName = _x;
		};
	} foreach (missionNamespace getVariable ["MCC_activeMarkers",[]]);

	if ((_nearZone || _nearMarker) && !(missionNameSpace getVariable ["MCC_artilleryEnabled",false]) && !(missionNameSpace getVariable ["MCC_spawnEnabled",false]) && !MCC_ConsoleRuler && !MCC_doubleClicked && !MCC_zone_drawing && !MCC_CASrequestMarker && !MCC_brush_drawing && !MCC_drawTriggers
		&& !MCC_drawMinefield && !MCC_delete_drawing && !MCC_ambushPlacing && !MCC_UMParadropRequestMarker) exitWith
	{
			_clickHit = true;
			private _size = [];
			private _pos = [];
			private _center = [];
			private _width = 0;
			private _hight = 0;
			if (_nearZone) then
			{
				//Change the combobox indicatior
				MCC_zone_index = _newZone -1;
				["select", _newZone] call MCC_fnc_zoneList;

				sleep 0.3;

				_markerName = str mcc_active_zone;
			};

			_isIcon = if (MarkerShape _markerName == "ICON") then {0} else {1};

			if (!MCC_GroupGenMouseButtonDown) exitWith {};
			_markerName setMarkerAlphalocal 0.6;

			//While mouse pressed
			while {MCC_GroupGenMouseButtonDown} do
			{
				//Moving the zone
				if (!_shift && !_ctrlKey) then
				{
					_markerName setMarkerposLocal MCCGroupGenDispPosXY;
					MCC_Marker_dir	= markerDir  _markerName;
				};

				//Resizing it
				if (_shift && (_isIcon != 0)) then
				{
					_center = (getMarkerpos _markerName);
					_width 	= abs ((MCCGroupGenDispPosXY select 1) - (_center select 1));
					_hight 	= abs ((MCCGroupGenDispPosXY select 0) - (_center select 0));

					_markerName setMarkerSizeLocal [_hight,_width];
				};

				//Changing dir
				if (_ctrlKey) then
				{
					_center 		= (getMarkerpos _markerName);
					MCC_Marker_dir	= [_center, MCCGroupGenDispPosXY] call BIS_fnc_dirTo;
					_markerName setMarkerdirLocal MCC_Marker_dir;
				};
				sleep 0.1;
			};

			_size = getMarkerSize _markerName;
			_pos = getMarkerPos  _markerName;

			sleep 0.2;

			mcc_isnewzone = false;
			mcc_grouptype = "";
			mcc_spawntype = "";
			mcc_classtype = "";
			mcc_spawnname = "";
			mcc_spawnfaction ="";
			mcc_resetmissionmaker = false;

			if (_nearZone) then
			{
				deletemarkerlocal _markerName;
				_null = [2,_pos,_size] execVM MCC_path + "mcc\pop_menu\zones.sqf";
			}
			else
			{
				[_isIcon, getMarkerColor _markerName , _size, MarkerShape _markerName, MarkerBrush _markerName, MarkerType _markerName, _markerName, _pos, MCC_Marker_dir] call MCC_fnc_makeMarker;
			};
	};
};

//Artillery
if ((missionNameSpace getVariable ["MCC_artilleryEnabled",false]) &&  _pressed == 0) exitWith
{
	if (!_ctrlKey) then {missionNameSpace setVariable ["MCC_artilleryEnabled",false]};
	if (MCC_capture_state) then
	{
		hint "Artillery captured.";
		MCC_capture_var = MCC_capture_var + FORMAT ["
		[%1, '%2', %3, %4, %5, %6] remoteExec ['MCC_fnc_artillery', 0, false];
		"
		,_ctrl ctrlMapScreenToWorld [_posX,_posY]
		,shelltype
		,shellspread
		,nshell
		,MCCSimulate
		,MCC_artyDelay
		];
	}
	else
	{
		hint "Artillery inbound.";
		[_ctrl ctrlMapScreenToWorld [_posX,_posY], shelltype, shellspread, nshell,MCCSimulate,MCC_artyDelay] remoteExec ["MCC_fnc_artillery",2];
	};
	sleep 0.5;
	deleteMarkerLocal "mcc_arty";
};

//Spawn
if ((missionNameSpace getVariable ["MCC_spawnEnabled",false]) &&  _pressed == 0) exitWith
{
	if (!_ctrlKey) then {missionNameSpace setVariable ["MCC_spawnEnabled",false]};
	if (MCC_capture_state) then
	{
		hint "Spawned Captured";
		MCC_capture_var = MCC_capture_var + FORMAT ["
								[%1 , %2, %3, %4, %5] remoteExec ['MCC_fnc_groupSpawn', 2, false];
								"
								, _ctrl ctrlMapScreenToWorld [_posX,_posY]
								, MCC_groupBroadcast
								, mcc_hc
								, mcc_sidename
								, MCC_isEmpty
								];
	}
	else
	{
		hint "Spawned";

		private _groupsBefore = +allGroups;
		[_ctrl ctrlMapScreenToWorld [_posX,_posY], MCC_groupBroadcast, mcc_hc, mcc_sidename, MCC_isEmpty,missionNamespace getVariable ["mcc_caching",false], missionNamespace getVariable ["mcc_spawnbehavior", ""], missionNamespace getVariable ["MCC_spawnCommandable", false]] remoteExec ["MCC_fnc_groupSpawn", 2, false];
		//Select what was spawned in the unit list (Groups / Units) so it is on the camera at once
		if !(MCC_isEmpty) then {[_ctrl ctrlMapScreenToWorld [_posX,_posY], (lbCurSel ((uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) displayCtrl 3012)) == 1, _groupsBefore] spawn MCC_fnc_umAutoSelect};
	};
	sleep 0.5;
	deleteMarkerLocal "mcc_spawnMarker";
};


//Manually detonate IED
if (_ctrlKey && _pressed!=1) then
{
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];
	_nearObjects = MCC_pointA nearObjects [MCC_dummy,40];
	{_x setvariable ["iedTrigered", true, true]} forEach _nearObjects;
};

//Sync IED and ambush group
if (MCC_ambushPlacing && _pressed!=1) then
{
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];
};

//Sync with shift key
if (_shift && _pressed!=1) then
{
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];
};

 //CAS Request
if (MCC_CASrequestMarker && _pressed==0) then
{
	private _marker = nil;
	private _markerPos = [];
	private _markerDir = 0;
	private _spawn = [];
	private _away = [];
	private _ammount = 0;
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	private _k0 = if (MCC_spawnkind isEqualType []) then {MCC_spawnkind param [0, ""]} else {MCC_spawnkind}; private _kind = if (_k0 isEqualType "") then {toLower _k0} else {""};
	private _p0 = if (MCC_planeType isEqualType []) then {MCC_planeType param [0, ""]} else {MCC_planeType}; private _isDrop = (if (_p0 isEqualType "") then {toLower _p0} else {""}) in ["west","east","guer","civ","logic"];
	private _w = if (_isDrop) then {8} else {5};
	private _lm = [["strike", "supply"] select _isDrop, MCC_pointA, MCC_pointA, [], _w] call MCCMK_fnc_supportLine;
	MCCMK_lineCancel = false;
	MCCMK_lineDrawing = true;
	sleep 0.25;

	while {MCC_GroupGenMouseButtonDown} do {
		_lm = [["strike", "supply"] select _isDrop, MCC_pointA, MCCGroupGenDispPosXY, _lm, _w] call MCCMK_fnc_supportLine;
		sleep 0.25;
	};
	MCCMK_lineDrawing = false;
	if (missionNamespace getVariable ["MCCMK_lineCancel", false]) exitWith {
		MCCMK_lineCancel = false;
		{deleteMarkerLocal _x} forEach _lm;
		MCC_CASrequestMarker = false;
		hint "Line cancelled.";
	};

	private _len = (MCC_pointA distance2D MCCGroupGenDispPosXY) min 300;
	_markerDir 	= MCC_pointA getDir MCCGroupGenDispPosXY;
	_markerPos 	= MCC_pointA getPos [[_len, 0] select _isDrop, _markerDir];
	_spawn 		= [_markerPos,2000,(_markerDir -180)] call BIS_fnc_relpos;
	_away 		= [_markerPos,2000,_markerDir] call BIS_fnc_relpos;
	_ammount	=  floor ((_len / 2)/50) + 1;
	if (!_isDrop) then {{deleteMarkerLocal _x} forEach _lm; _lm = [[_markerPos, _kind == "cruise missile"] call MCCMK_fnc_strikeMarker]};

	if (MCC_capture_state) then {
		hint "Air support captured.";
		MCC_capture_var=MCC_capture_var + FORMAT ['
			[%1, %2 , %3, %4, %5, %6] remoteExec ["MCC_fnc_airDrop", 2, false];
			'
			,_ammount
			,MCC_spawnkind
			,_markerPos
			,MCC_planeType
			,_spawn
			,_away];
	} else {
		[MCC_spawnkind] call MCC_fnc_supportHint;
		MCC_cruiseFromCommander = false;
		MCC_cruiseFromMCC = true;
		[_ammount, MCC_spawnkind , _markerPos, MCC_planeType, _spawn,_away,(missionNamespace getVariable ["MCC_airdropIsParachute",0])] spawn MCC_fnc_airDrop;
	};

	MCC_CASrequestMarker = false;			//Wait and delete the marker
	sleep 40;
	{deleteMarkerLocal _x} forEach _lm;
};

//UM Paradrop Request
if (MCC_UMParadropRequestMarker && _pressed==0 && {isNil "MCC_selectedUnits" || {count (MCC_selectedUnits select {!isNull _x}) == 0}}) exitWith {
	MCC_UMParadropRequestMarker = false;
	hint "No group or unit selected.\nSelect one or more groups or units in the list first.";
};

if (MCC_UMParadropRequestMarker && _pressed==0) then
{
	private _marker = nil;
	private _markerPos = [];
	private _markerDir = 0;
	private _spawn = [];
	private _away = [];
	private _ammount = 0;
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	private _pm = ["para", "pods", "drop"] param [MCC_UMparadropIsHalo, "drop"];
	private _nT = 1;
	if (MCC_UMparadropIsHalo == 1) then {
		private _men = 0;
		{_men = _men + (if (_x isEqualType grpNull) then {count units _x} else {1})} forEach (MCC_selectedUnits select {!isNull _x});
		private _ld = ["MCC_podBench", "allCargo"] call MCC_fnc_crewCount;
		if (_ld <= 0) then {_ld = 8};
		_nT = (ceil (_men / _ld)) max 1;
	};
	private _lm = [_pm, MCC_pointA, MCC_pointA, [], _nT] call MCCMK_fnc_supportLine;
	MCCMK_lineCancel = false;
	MCCMK_lineDrawing = true;
	sleep 0.25;

	while {MCC_GroupGenMouseButtonDown} do {
		_lm = [_pm, MCC_pointA, MCCGroupGenDispPosXY, _lm, _nT] call MCCMK_fnc_supportLine;
		sleep 0.25;
	};
	MCCMK_lineDrawing = false;
	if (missionNamespace getVariable ["MCCMK_lineCancel", false]) exitWith {
		MCCMK_lineCancel = false;
		{deleteMarkerLocal _x} forEach _lm;
		MCC_UMParadropRequestMarker = false;
		hint "Line cancelled.";
	};

	private _len = (MCC_pointA distance2D MCCGroupGenDispPosXY) min 5000;
	_markerDir 	= MCC_pointA getDir MCCGroupGenDispPosXY;
	_markerPos 	= MCC_pointA getPos [_len / 2, _markerDir];
	_spawn 		= [_markerPos,2000,(_markerDir -180)] call BIS_fnc_relpos;
	_away 		= [_markerPos,2000,_markerDir] call BIS_fnc_relpos;

	//[getmarkerpos _marker, MCC_selectedUnits, MCC_UMUnit, MCC_UMparadropIsHalo,_spawn,_away] execVM "mcc\fnc\general\fn_realParadrop.sqf";

	//Pass the line actually drawn (start and end), not the middle of the arrow marker: the drop follows the line,
	//HALO drops over the start point (where you clicked)
	[[+MCC_pointA, +(missionNamespace getVariable ["MCC_pointB", MCC_pointA])], MCC_selectedUnits, MCC_UMUnit, MCC_UMparadropIsHalo,_spawn,_away, [missionNamespace getVariable ["MCCMK_pdAirPara", ""], missionNamespace getVariable ["MCCMK_pdAirHalo", ""], missionNamespace getVariable ["MCCMK_pdHeight", 300], missionNamespace getVariable ["MCCMK_pdOpenPara", [0, 100]], missionNamespace getVariable ["MCCMK_pdOpenHalo", [0, 150]]]] remoteExec ["MCC_fnc_realParadrop", 2, false];

	MCC_UMParadropRequestMarker = false;			//Wait and delete the marker
	sleep 40;
	{deleteMarkerLocal _x} forEach _lm;
};


//Zone drawing
if (MCC_zone_drawing && _pressed==0) then
{
	private "_marker";
private _size = [];
private _pos = [];
private _null = [];
	MCC_Marker_dir = 0;
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,"RECTANGLE","ColorYellow","SOLID"] call MCC_fnc_drawBox;	//Drow it first
	sleep 0.1;

	while {MCC_GroupGenMouseButtonDown} do
	{														//While mouse pressed
		deleteMarkerLocal _marker;
		_marker = [MCC_pointA, MCCGroupGenDispPosXY,1,"RECTANGLE","ColorYellow","SOLID"] call MCC_fnc_drawBox;
		sleep 0.1;
	};

	_size = getMarkerSize _marker;
	_pos = getMarkerPos  _marker;
	deletemarkerlocal _marker;
	if (((_size select 0) min (_size select 1)) < 5) exitWith {systemChat "Click and drag on the map to draw the zone"};
	MCC_zone_drawing = false;
	_null = [1,_pos,_size] execVM MCC_path + "mcc\pop_menu\zones.sqf";
};

 //Brush Drawing
if (MCC_brush_drawing && _pressed==0) then
{
	private _marker = nil;
	private _size = [];
	private _pos = [];
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,Mshape,Mcolor,Mbrush] call MCC_fnc_drawBox;	//Drow it first
	sleep 0.1;

	while {MCC_GroupGenMouseButtonDown} do
	{														//While mouse pressed
		deleteMarkerLocal _marker;
		_marker = [MCC_pointA, MCCGroupGenDispPosXY,1,Mshape,Mcolor,Mbrush] call MCC_fnc_drawBox;
		sleep 0.1;
	};

	_size = getMarkerSize _marker;
	_pos = getMarkerPos  _marker;
	if (!isnil "_marker") then {deletemarkerlocal _marker};
	MCC_brush_drawing = false;
	[Mcase, Mcolor, _size, Mshape, Mbrush, Mtype, Mtext, _pos, MCC_Marker_dir] call MCC_fnc_makeMarker;
};

//Triggerd drawing
if (MCC_drawTriggers && _pressed==0) then
{
	private _marker = [];
	private _size = [];
	private _pos = [];
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,Mshape,Mcolor,Mtype] call MCC_fnc_drawBox;	//Drow it first
	sleep 0.1;

	while {MCC_GroupGenMouseButtonDown} do
	{														//While mouse pressed
		deleteMarkerLocal _marker;
		_marker = [MCC_pointA, MCCGroupGenDispPosXY,1,Mshape,Mcolor,Mtype] call MCC_fnc_drawBox;
		sleep 0.1;
	};

	_size = getMarkerSize _marker;
	_pos = getMarkerPos  _marker;
	deletemarkerlocal _marker;
	MCC_drawTriggers = false;
	nul=[1,_pos,_size] execVM MCC_path + 'mcc\general_scripts\triggers\triggers.sqf';
};

 //Minefield drawing
if (MCC_drawMinefield && _pressed==0) then
{
	private _marker = [];
	private _size = [];
	private _pos = [];
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,Mshape,Mcolor,Mtype] call MCC_fnc_drawBox;	//Drow it first
	sleep 0.1;

	while {MCC_GroupGenMouseButtonDown} do
	{														//While mouse pressed
		deleteMarkerLocal _marker;
		_marker = [MCC_pointA, MCCGroupGenDispPosXY,1,Mshape,Mcolor,Mtype] call MCC_fnc_drawBox;
		sleep 0.1;
	};

	MCC_drawBoxZoneSize = getMarkerSize _marker;
	MCC_drawBoxZonePos = getMarkerPos  _marker;
	deletemarkerlocal _marker;
	MCC_drawMinefield = false;
};

 //Delete Drawing
if (MCC_delete_drawing && _pressed==0) then
{
	private _marker = [];
	private _size = [];
	private _pos = [];
	private _type = 0;
	_type	= lbCurSel MCCDELETEBRUSH;
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the box
	_marker = [MCC_pointA,MCC_pointA,1,"ELLIPSE","colorRed","SOLID"] call MCC_fnc_drawBox;	//Drow it first
	sleep 0.1;

	while {MCC_GroupGenMouseButtonDown} do
	{														//While mouse pressed
		deleteMarkerLocal _marker;
		_marker = [MCC_pointA,MCCGroupGenDispPosXY,1,"ELLIPSE","colorRed","SOLID"] call MCC_fnc_drawBox;
		sleep 0.1;
	};

	_size = getMarkerSize _marker;
	_pos = getMarkerPos  _marker;
	deletemarkerlocal _marker;
	MCC_delete_drawing = false;

	mcc_safe=mcc_safe + FORMAT ['
							[%1, %2, %3] remoteExec ["MCC_fnc_deleteBrush",2];
							sleep 1;'
							, _pos
							, _size
							, _type
							];
	[_pos, _size select 0, _type] remoteExec ["MCC_fnc_deleteBrush",2];
};

//Line drawing
if (_pressed==0 && (missionNameSpace getVariable ["MCC_DrawLine",false] )) exitWith
{
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,"mil_arrow",10,"ColorBlue",1000000] call MCC_fnc_drawArrow;	//Drow it first
	sleep 0.25;

	while {MCC_GroupGenMouseButtonDown} do
		{														//While mouse pressed
			deleteMarkerLocal _marker;
			_marker = [MCC_pointA, MCCGroupGenDispPosXY,1,"mil_arrow",10,"ColorRed",3000] call MCC_fnc_drawArrow;
			sleep 0.05;
		};

	sleep 0.01;
	//Front Lines keeps the line on the map until the attack side is clicked
	if (missionNamespace getVariable ["MCC_FLKeepLine", false]) then {MCC_FLLineMarker = _marker} else {deletemarkerLocal _marker};

	MCC_DrawLine = false;

};

//Box drawing select
if (_pressed==0
    && !MCC_ConsoleRuler
    && !MCC_doubleClicked
    && !MCC_zone_drawing
    && !MCC3DRuning
    && !MCC_CASrequestMarker
    && !MCC_brush_drawing
    && !MCC_drawTriggers
    && !MCC_drawMinefield
    && !MCC_delete_drawing
    && !MCC_ambushPlacing
    && !MCC_UMParadropRequestMarker && !(missionNameSpace getVariable ["MCC_DrawLine",false])
    && !_shift) then
{
	private _marker = [];
	private _markersize = [];
	private _markerpos = [];
	private _null = scriptNull;
	private _markerposX = 0;
	private _markerposY = 0;
	private _markersize = [];
	private _markersizeX = 0;
	private _markersizeY = 0;
	private _borderXleft = 0;
	private _borderXright = 0;
	private _borderYdown = 0;
	private _borderYtop = 0;
	private _group = grpNull;
	private _groupX = 0;
	private _groupY = 0;
	private _leader = objNull;
	private _icon = 0;
	private _groupControl = nil;

	//Close WP dialog and hints
	ctrlShow [510,false];
	ctrlShow [MCC_GroupGenInfo_IDC,false];
	hintsilent "";

	//Start creating the box
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,"RECTANGLE","ColorGreen","Border"] call MCC_fnc_drawBox;	//Drow it first
	sleep 0.1;

	while {MCC_GroupGenMouseButtonDown} do
		{														//While mouse pressed
			deleteMarkerLocal _marker;
			_marker = [MCC_pointA, MCCGroupGenDispPosXY,1,"RECTANGLE","ColorGreen","Border"] call MCC_fnc_drawBox;
			sleep 0.1;
		};
	_markersize = getMarkerSize _marker;
	_markerpos = markerpos  _marker;
	deletemarkerlocal _marker;

	_markerposX = _markerpos select 0;
	_markerposY = _markerpos select 1;
	_markersizeX = abs(_markersize select 0);
	_markersizeY = abs(_markersize select 1);

	_borderXleft = _markerposX - _markersizeX;
	_borderXright = _markerposX + _markersizeX;
	_borderYdown = _markerposY - _markersizeY;
	_borderYtop = _markerposY + _markersizeY;
	if (isnil "MCC_GroupGenGroupSelected") then {MCC_GroupGenGroupSelected=[]};
	if (_markersizeX < 10 || _markersizeY<10) exitWith {
		if (_clickHit || _ctrlKey || _alt) exitWith {};
		sleep 0.35;
		if ((missionNamespace getVariable ["MCC_groupIconClickTime", -1]) >= (_clickT0 - 0.05)) exitWith {};
		if ((missionNamespace getVariable ["MCC_mapDblClickTime", -1]) >= _clickT0) exitWith {};
		if (MCC_doubleClicked || {MCC_GroupGenMouseButtonDown}) exitWith {};
		private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
		if (isNull _d) exitWith {};
		{_x removeGroupIcon (_x getVariable ["MCCgroupIconDataSelected", -1])} forEach MCC_GroupGenGroupSelected;
		MCC_GroupGenGroupSelected = [];
		MCC_selectedUnits = [];
		MCC_ConsoleGroupFocused = grpNull;
		UMName = objNull;
		deleteMarkerLocal "currentUnitSelected";
		MCC_umFeedToken = (missionNamespace getVariable ["MCC_umFeedToken", 0]) + 1;
		if (!isNil "MCC_PIPcam" && {!isNull MCC_PIPcam}) then {
			MCC_PIPcam cameraEffect ["TERMINATE", "BACK"];
			camDestroy MCC_PIPcam;
		};
		MCC_pipState = [];
		(_d displayCtrl 3070) ctrlSetText "";
		[] call MCC_fnc_groupGenUMRefresh;
		["INFO", "mouseDown.sqf", "map click on empty space: selection and camera cleared", []] call MCC_fnc_log;
	};
	{_x removeGroupIcon (_x getvariable "MCCgroupIconDataSelected")} foreach MCC_GroupGenGroupSelected;

	MCC_GroupGenGroupSelected = [];
	{
		_groupControl = nil;
		_leader = (leader _x);
		if ((["shows", _leader] call MCC_fnc_consoleFilter) && alive _leader && count (units _x)>0) then
		{
			_group = _x;

			//--- Check if group is assigned to local commander
			_groupX = (position _leader) select 0;
			_groupY = (position _leader) select 1;
			if (
				_groupX > _borderXleft &&
				_groupX < _borderXright &&
				_groupY > _borderYdown &&
				_groupY < _borderYtop
			) then
			{
				MCC_GroupGenGroupSelected = MCC_GroupGenGroupSelected + [_group];
			};
		};
	} foreach allgroups;

	if (count MCC_GroupGenGroupSelected == 0) exitWith {};

	{
		_icon = _x addGroupIcon ["selector_selectedFriendly",[0,0]];
		_x setvariable ["MCCgroupIconDataSelected",_icon,false];
	} foreach MCC_GroupGenGroupSelected;
};
