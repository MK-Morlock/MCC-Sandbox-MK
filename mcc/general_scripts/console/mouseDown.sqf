//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
private "_posX";
private "_posY";
private "_shift";
private "_ctrlKey";
private "_alt";
private _marker = [];
private "_markerPos";
private "_markerDir";
private _spawn = [];
private _away = [];
private _ammount = 0;
private _dir = [];
private _trg = [];
private _ok = false;
#define MCC_CONSOLEINFOTEXT 9150
#define MCC_CONSOLEINFOLIVEFEED 9151
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
#define MCC_ConsoleMapRulerDir 9164
#define MCC_ConsoleMapRulerDis 9165

#define BON_ARTY_DIRECTION 999907
#define BON_ARTY_DISTANCE 999908

disableSerialization;

params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;
_posX = _params select 2;
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;
if ((missionNamespace getVariable ["MCC_evacParaWait", false]) && {_pressed == 0}) exitWith {["down", _ctrl, _posX, _posY] call MCC_fnc_evacParaLine};
if ((missionNamespace getVariable ["MCCMK_makeHQPick", false]) && {_pressed in [0, 1]}) exitWith {["click", _ctrl ctrlMapScreenToWorld [_posX, _posY], _pressed] call MCCMK_fnc_makeHQPick};

if (_pressed == 1 && {missionNamespace getVariable ["MCCMK_lineDrawing", false]}) exitWith {MCCMK_lineCancel = true};
MCC_ConsoleMouseButtonDown = true;	//Mouse state
MCC_ConsoleMouseButtonUp = false;

missionNamespace setVariable ["MCCConsoleDispPosXYScreen",[_posX,_posY]];

if (isnil "MCC_doubleClicked") then {MCC_doubleClicked =false};

//Close Group info control
if ((_pressed == 0 || _pressed == 1)&& !MCC_doubleClicked) then
{
	ctrlShow [MCC_CONSOLEINFOTEXT,false];
	ctrlShow [MCC_CONSOLEINFOLIVEFEED,false];
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
};

//CAS Request
if (MCC_CASrequestMarker && _pressed==0) exitWith {
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];
	["DEBUG", "console", "support call placed: %1 at %2 (started by %3)", [MCC_spawnkind, MCC_pointA apply {round _x}, missionNamespace getVariable ["MCCMK_callSource", "Call button"]]] call MCC_fnc_log;
	MCCMK_callSource = "Call button";
	private _k0 = if (MCC_spawnkind isEqualType []) then {MCC_spawnkind param [0, ""]} else {MCC_spawnkind}; private _kind = if (_k0 isEqualType "") then {toLower _k0} else {""};
	private _p0 = if (MCC_planeType isEqualType []) then {MCC_planeType param [0, ""]} else {MCC_planeType}; private _isDrop = (if (_p0 isEqualType "") then {toLower _p0} else {""}) in ["west","east","guer","civ","logic"];
	private _w = if (_isDrop) then {8} else {5};
	private _lm = [["strike", "supply"] select _isDrop, MCC_pointA, MCC_pointA, [], _w] call MCCMK_fnc_supportLine;
	MCCMK_lineCancel = false;
	MCCMK_lineDrawing = true;
	//(MK) a strike: the target cross shown live while drawing, a little BEYOND the arrow's tip (not hidden under the
	// cursor) - the same gap on screen at any zoom - and the strike aimed at exactly where it is. The line is a 300 m TOWED
	// stick: past 300 m its start slides along behind the cursor, so the whole line and the cross follow it to the
	// target. Its strength (1-4: a quarter .. all of the payload) shown as a number in the middle of the line.
	// Supply drops and Air Patrol lines: unchanged.
	private _aimed = !_isDrop && {(_kind find "air patrol") < 0};
	private _fnc_aim = {
		params ["_a", "_m"];
		private _lead = (_ctrl ctrlMapScreenToWorld [0.5, 0.5]) distance2D (_ctrl ctrlMapScreenToWorld [0.525, 0.5]);
		private _tp = _m getPos [_lead, _a getDir _m];
		[_tp select 0, _tp select 1, 0]
	};
	private _live = "";
	private _lbl = "";
	sleep 0.25;

	while {MCC_ConsoleMouseButtonDown} do {
		if (_aimed && {(MCC_pointA distance2D MCCConsoleDispPosXY) > 300}) then {	// towed: the start slides behind the cursor
			private _np = MCCConsoleDispPosXY getPos [300, MCCConsoleDispPosXY getDir MCC_pointA];
			MCC_pointA = [_np select 0, _np select 1, 0];
		};
		_lm = [["strike", "supply"] select _isDrop, MCC_pointA, MCCConsoleDispPosXY, _lm, _w] call MCCMK_fnc_supportLine;
		if (_aimed && {(MCC_pointA distance2D MCCConsoleDispPosXY) > 1}) then {
			private _tp = [MCC_pointA, MCCConsoleDispPosXY] call _fnc_aim;
			if (_live == "") then {_live = [_tp, false] call MCCMK_fnc_strikeMarker} else {_live setMarkerPosLocal _tp};
			// the strength in the middle of the line
			private _len = (MCC_pointA distance2D MCCConsoleDispPosXY) min 300;
			private _mid = MCC_pointA getPos [_len / 2, MCC_pointA getDir MCCConsoleDispPosXY];
			if (_lbl == "") then {
				_lbl = format ["mccmk_lineStr_%1", round (diag_tickTime * 1000)];
				createMarkerLocal [_lbl, _mid];
				_lbl setMarkerTypeLocal "EmptyIcon";
				_lbl setMarkerColorLocal "ColorRed";
				_lbl setMarkerSizeLocal [0.6, 0.6];
			};
			_lbl setMarkerPosLocal _mid;
			_lbl setMarkerTextLocal str ((floor (((_len + 1) / 2) / 50) + 1) min 4);	// (+1 m: a towed line measures 299.99)
		};
		sleep 0.1;
	};
	MCCMK_lineDrawing = false;
	// the aim at the moment it was released (the cross moved there too - the strike lands on it)
	private _aimPos = if (_aimed) then {[MCC_pointA, MCCConsoleDispPosXY] call _fnc_aim} else {[]};
	if (_live != "") then {deleteMarkerLocal _live};
	if (_lbl != "") then {deleteMarkerLocal _lbl};
	if (missionNamespace getVariable ["MCCMK_lineCancel", false]) exitWith {
		MCCMK_lineCancel = false;
		{deleteMarkerLocal _x} forEach _lm;
		MCC_CASrequestMarker = false;
		MCCMK_consolePending = [];
		["Line cancelled."] call MCCMK_fnc_hint;
	};

	//(MK) Air Patrol: the line's end is where it patrols; it comes in along the line, from the map edge behind its start
	if ((_kind find "air patrol") >= 0) exitWith {
		{deleteMarkerLocal _x} forEach _lm;
		private _tgt = +MCCConsoleDispPosXY;
		private _bdir = (MCC_pointA getDir _tgt) + 180;
		private _dx = sin _bdir;
		private _dy = cos _bdir;
		private _edge = {params ["_p", "_d"]; if (_d > 0.001) exitWith {(worldSize - _p) / _d}; if (_d < -0.001) exitWith {(0 - _p) / _d}; 1e9};
		private _t = ([_tgt select 0, _dx] call _edge) min ([_tgt select 1, _dy] call _edge);
		private _entry = [(_tgt select 0) + _dx * _t, (_tgt select 1) + _dy * _t, 0];
		private _pend = missionNamespace getVariable ["MCCMK_consolePending", []];
		if (count _pend > 0) then {
			_pend params ["_pc", "_pa", "_ps"];
			if (count _pc > 0) then {[_pc] spawn MCC_fnc_baseResourceReduce} else {
				private _arr = missionNamespace getVariable [_pa, []];
				private _i = _arr findIf {_x isEqualTo _ps};
				if (_i >= 0) then {_arr deleteAt _i; missionNamespace setVariable [_pa, _arr]; publicVariable _pa};
			};
			MCCMK_consolePending = [];
		};
		//(MK) the loadout chosen in the panel (an entry added from the MCC console names its own)
		[playerSide, _tgt, _entry, _k0, _p0, faction player, uiNamespace getVariable ["MCCMK_apLoadoutNow", ""]] remoteExec ["MCCMK_fnc_airPatrol", 2];
		MCC_CASrequestMarker = false;
		private _mk = createMarkerLocal [format ["MCCMK_airPatrol_%1", diag_tickTime], _tgt];
		_mk setMarkerShapeLocal "ELLIPSE";
		_mk setMarkerSizeLocal ([[4000, 4000], [1500, 1500]] select ((_p0 isEqualType "" && {_p0 isKindOf "Helicopter"}) || {((toLower _k0) find "heli") >= 0}));
		_mk setMarkerBrushLocal "Border";
		_mk setMarkerColorLocal "ColorBlue";
		["Air Patrol called in."] call MCCMK_fnc_hint;
		sleep 60;
		deleteMarkerLocal _mk;
	};

	private _len = (MCC_pointA distance2D MCCConsoleDispPosXY) min 300;
	_markerDir 	= MCC_pointA getDir MCCConsoleDispPosXY;
	_markerPos 	= MCC_pointA getPos [[_len, 0] select _isDrop, _markerDir];
	if (_aimed) then {_markerPos = _aimPos};	//(MK) exactly where the cross was shown
	_spawn 		= [_markerPos,2000,(_markerDir -180)] call BIS_fnc_relpos;
	_away 		= [_markerPos,2000,_markerDir] call BIS_fnc_relpos;
	_ammount	=  (floor (((_len + 1) / 2)/50) + 1) min 4;	//(MK) +1 m: a towed 300 m line can measure 299.99 - still full strength
	if (!_isDrop) then {{deleteMarkerLocal _x} forEach _lm; _lm = [[_markerPos, _kind == "cruise missile"] call MCCMK_fnc_strikeMarker]};

	//Check if not on trigger
	_ok = true;
	{
		_trg = _x getVariable ["triggers", []];
		{
			if ([_x, _markerPos] call BIS_fnc_inTrigger || [_x, MCC_pointA] call BIS_fnc_inTrigger) exitWith {_ok = false};
		} forEach _trg;
	} forEach allMissionObjects "logic";

	if !(_ok) exitWith {{deleteMarkerLocal _x} forEach _lm; ["Can't call support to this location try again"] call MCCMK_fnc_hint};

	//(MK) a supply drop's green dot: kept until the drop is complete (MCCMK_fnc_dropDots), the line goes on its timer
	private _dd = [format ["dd%1_%2", clientOwner, round (diag_tickTime * 1000)], clientOwner];
	private _dots = _lm select {(markerType _x) == "mil_dot"};
	if (_dots isNotEqualTo []) then {["add", _dd select 0, _dots] call MCCMK_fnc_dropDots; _lm = _lm - _dots};
	// Taru supply pod (MK): the pod, the method, the mark and the direction it comes in from
	if (_k0 isEqualTo "MCCMK_TARUPOD") exitWith {
		(missionNamespace getVariable ["MCCMK_podReq", [0, 0]]) params [["_pi", 0], ["_pm", 0]];
		[player, playerSide, _pi, _pm, +MCC_pointA, _markerDir, false, "", _dd] remoteExec ["MCCMK_fnc_supplyPod", 2];
		MCC_CASrequestMarker = false;
		sleep 40;
		{deleteMarkerLocal _x} forEach _lm;
	};

	[MCC_spawnkind] call MCC_fnc_supportHint;
	MCC_cruiseFromCommander = true;
	MCC_cruiseFromMCC = false;

	private _pend = missionNamespace getVariable ["MCCMK_consolePending", []];
	if (count _pend > 0) then {
		_pend params ["_pc", "_pa", "_ps"];
		if (count _pc > 0) then {[_pc] spawn MCC_fnc_baseResourceReduce} else {
			private _arr = missionNamespace getVariable [_pa, []];
			private _i = _arr findIf {_x isEqualTo _ps};
			if (_i >= 0) then {_arr deleteAt _i; missionNamespace setVariable [_pa, _arr]; publicVariable _pa};
		};
		MCCMK_consolePending = [];
	};
	[_ammount, MCC_spawnkind , _markerPos, MCC_planeType, _spawn,_away,(missionNamespace getVariable ["MCC_airdropIsParachute",0]), _dd] spawn MCC_fnc_airDrop;

	//Wait and delete the marker
	MCC_CASrequestMarker = false;
	sleep 40;
	{deleteMarkerLocal _x} forEach _lm;
};

//Ruler drawing select
if (_pressed==0 && MCC_ConsoleRuler) exitWith
{
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,"mil_arrow",20,"ColorBlue",1000000] call MCC_fnc_drawArrow;	//Drow it first
	sleep 0.25;

	while {MCC_ConsoleMouseButtonDown} do
		{														//While mouse pressed
			deleteMarkerLocal _marker;
			_marker = [MCC_pointA, MCCConsoleDispPosXY,1,"mil_arrow",20,"ColorBlue",1000000] call MCC_fnc_drawArrow;
			sleep 0.25;
		};

	sleep 0.01;
	deletemarkerLocal _marker;

	//get distance and directio
	_dir = [MCC_pointA, MCCConsoleDispPosXY] call BIS_fnc_dirTo;
	_dir = if (_dir < 0) then {360 + _dir} else {_dir};

	MCC_ConsoleRulerData set [0,floor _dir];
	MCC_ConsoleRulerData set [1,floor (MCC_pointA distance MCCConsoleDispPosXY)];

	//Set control
	ctrlSetText [MCC_ConsoleMapRulerDir,format ["Dir: %1",MCC_ConsoleRulerData select 0]];
	ctrlSetText [MCC_ConsoleMapRulerDis,format ["Dis: %1m",MCC_ConsoleRulerData select 1]];
	ctrlSetText [BON_ARTY_DIRECTION,format["%1",MCC_ConsoleRulerData select 0]]; //degrees
	ctrlSetText [BON_ARTY_DISTANCE,format["%1",MCC_ConsoleRulerData select 1]]; //distance

	MCC_ConsoleRuler = false;

};

if (_pressed == 0 && !_shift && !_ctrlKey && !_alt && !MCC_ConsoleRuler && {["active"] call MCCMK_fnc_wpChain}) exitWith
{
	private _mkP = _ctrl ctrlMapScreenToWorld [_posX, _posY];
	private _mkT = diag_tickTime;
	["pend", _mkP] call MCCMK_fnc_wpChain;
	sleep 0.35;
	if ((missionNamespace getVariable ["MCCMK_ccDblClickTime", -1]) >= (_mkT - 0.5)) exitWith {["unpend"] call MCCMK_fnc_wpChain};
	["add", _mkP] call MCCMK_fnc_wpChain;
};

//Box drawing select
if (_pressed==0 && !MCC_ConsoleRuler && !MCC_doubleClicked) exitWith
{
	private _marker = [];
	private "_markersize";
	private "_markerpos";
	private "_markerposX";
	private "_markerposY";
	private "_markersize";
	private _markersizeX = 0;
	private _markersizeY = 0;
	private "_borderXleft";
	private "_borderXright";
	private "_borderYdown";
	private "_borderYtop";
	private "_group";
	private "_groupX";
	private "_groupY";
	private "_leader";
	private "_icon";
	private "_groupControl";

	//Close WP dialog
	ctrlShow [MCC_CONSOLEWPBCKGR,false];
	ctrlShow [MCC_CONSOLEWPCOMBO,false];
	ctrlShow [MCC_CONSOLEWPADD,false];
	ctrlShow [MCC_CONSOLEWPREPLACE,false];
	ctrlShow [MCC_CONSOLEWPCLEAR,false];
	ctrlShow [MCC_CONSOLEWPCANCEL,false];
	ctrlShow [9219,false];

	//Start creating the box
	MCC_pointA = _ctrl ctrlmapscreentoworld [_posX,_posY];									//Base of the arrow
	_marker = [MCC_pointA,MCC_pointA,1,"RECTANGLE","ColorGreen","Border"] call MCC_fnc_drawBox;	//Drow it first
	sleep 0.1;
	//if (!MCC_ConsoleMouseButtonDown) exitWith {};				//looks like we are not making a box
	while {MCC_ConsoleMouseButtonDown} do
		{														//While mouse pressed
			deleteMarkerLocal _marker;
			_marker = [MCC_pointA, MCCConsoleDispPosXY,1,"RECTANGLE","ColorGreen","Border"] call MCC_fnc_drawBox;
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
	if (isnil "MCC_ConsoleGroupSelected") then {MCC_ConsoleGroupSelected=[]};
	if (_markersizeX < 10 || _markersizeY<10) exitWith {};
	{_x removeGroupIcon (_x getvariable "MCCgroupIconDataSelected")} foreach MCC_ConsoleGroupSelected;
	MCC_ConsoleGroupSelected = [];
	{
		_groupControl = nil;
		_leader = (leader _x);
		_groupControl = if ((isplayer _leader) || (getText (configfile >> "CfgVehicles" >> typeOF vehicle _leader >> "vehicleClass")== "Autonomous")) then {true} else {_x getvariable ["MCC_canbecontrolled",false]};	//Can we control this group
		if ((side _leader == side player) && alive _leader && count (units _x)>0 && _groupControl) then
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
					MCC_ConsoleGroupSelected = MCC_ConsoleGroupSelected + [_group];
				};
			};
	} foreach allgroups;
	if (count MCC_ConsoleGroupSelected == 0) exitWith {};
	{
		_icon = _x addGroupIcon ["selector_selectedFriendly",[0,0]];
		_x setvariable ["MCCgroupIconDataSelected",_icon,false];
	} foreach MCC_ConsoleGroupSelected;

};