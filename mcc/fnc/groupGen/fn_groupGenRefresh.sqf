//===================================================================MCC_fnc_groupGenRefresh=========================================================================================
// Refresh the group gen markers
// Example:[] call MCC_fnc_groupGenRefresh
//==============================================================================================================================================================================
private _markerSupport = "";
private _markerAutonomous = "";
private _markerNaval = "";
private _markerRecon = "";
private _side = sideUnknown;
private _unitsCount = [];
private _markerType = nil;
private _markerColor = [];
private _leader = objNull;
private _markerInf = "";
private _markerMech = "";
private _markerArmor = "";
private _markerAir = "";
private _icon = nil;
private _wpArray = [];
private _behaviour = "";
private _unitsSize = 0;
private _unitsSizeMarker = "";
private _IsGaiaControlled = "";
private _players = false;
private _groupIconVisible = false;
private _groupIconSelectable = false;
#define groupGen_IDD 2994

//Group info while clicked
if (!isnil "HCEast" ||  !isnil "HCWest" || !isnil "HCGuer") exitWith {}; 			//If HC is working aboart process
private _groupIconHandle = addMissionEventHandler ["GroupIconClick", {
								params [
									"_is3D", "_group", "_waypointId",
									"_mouseButton", "_posX", "_posY",
									"_shift", "_control", "_alt"
								];

								MCC_groupIconClickTime = diag_tickTime;
								[_group,_mouseButton,[_posX,_posY],_shift,_control,_alt] execVm format ["%1mcc\general_scripts\groupGen\ClickGroupIcon.sqf",MCC_path];
							}];

MCC_groupGenRefreshLoop = true;
MCC_groupGenRefreshTerminate = false;

_groupIconVisible = groupIconsVisible;
_groupIconSelectable = groupIconSelectable;

setGroupIconsVisible [true,false];
setGroupIconsSelectable true;

MCC_fnc_mapDrawWP =
{
	_map = _this select 0;

	//Draw WP
	{
		if !(isNil "_x") then {
			_map drawIcon _x;
		};
	} foreach (missionNamespace getVariable ["MCC_GGIcons",[]]);

	{
		// skip malformed entries (e.g. a start point that was never set) instead of erroring every frame
		if (!(isNil "_x") && {(_x isEqualType []) && {count _x >= 3} && {((_x select 0) isEqualType []) && {count (_x select 0) >= 2} && {(_x select 0) isEqualTypeAll 0}}}) then {
			_map drawLine _x;
		};
	} foreach (missionNamespace getVariable ["MCC_GGLines",[]]);

	//Show towns name up to1.5Km
	if (!isnil "MCC_3D_CAM") then
	{
		{
			_pos = locationposition _x;
			_pos set [2,0];
			drawIcon3D [
							"#(argb,8,8,3)color(0,0,0,0)",
							[1,1,1,1],
							_pos,
							0,
							0,
							0,
							text _x,
							2,
							0.05
						];
		} foreach (nearestlocations [getpos MCC_3D_CAM,["nameVillage","nameCity","nameCityCapital"],1500]);

		{
			if ((markerType _x != "") && ((markerPos _x distance MCC_3D_CAM) < 1000)) then
			{
				private _color = [];

				_texture = gettext (configfile >> "CfgMarkers" >> markerType _x >> "icon");
				_pos = getMarkerpos _x;
				_pos set [2,10];
				private _size = if ((1.5 - ((MCC_3D_CAM distance _pos)*0.001)) < 0) then {0} else {(1.5 - ((MCC_3D_CAM distance _pos)*0.001))};
				_color = switch (tolower (markerColor _x)) do
							{
								case "default": {[1,1,1,1]};
								case "colorblack": {[0,0,0,1]};
								case "colorgrey": {[0.2,0.2,0.2,1]};
								case "colorred": {[1,0,0,1]};
								case "colorredalpha": {[1,0,0,1]};
								case "colorgreen": {[0,1,0,1]};
								case "colorgreenalpha": {[0,1,0,1]};
								case "colorblue": {[0,0,1,1]};
								case "coloryellow": {[0.255,0.255,0,1]};
								case "colororange": {[0.255,0.165,0,1]};
								case "colorwhite": {[1,1,1,1]};
								case "colorpink": {[0.255,0.192,0.203,1]};
								case "colorbrown": {[0.165,0.42,0.42,1]};
								case "colorkhaki": {[0.240,0.230,0.140,1]};
								case "colorwest": {[0,0,1,1]};
								case "coloreast": {[1,0,0,1]};
								case "colorguer": {[0,1,0,1]};
								case "colorciv": {[1,1,1,1]};
								case "colorunknown": {[1,1,1,1]};
								case "color1_fd_f": {[0.8,0,0,1]};
								case "color2_fd_f": {[0.240,0.230,0.140,1]};
								case "color3_fd_f": {[0.255,0.165,0,1]};
								case "color4_fd_f": {[0,0,0.8,1]};
								default {[1,1,1,1]};
							};
				drawIcon3D [
								_texture,
								_color,
								_pos,
								_size,
								_size,
								markerDir _x,
								MarkerText _x,
								0,
								(_size*0.03),
								"PuristaBold",
								"center"
							];
			};
		} foreach allMapMarkers;
	};
};

_handler = ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrladdeventhandler ["draw","_this call MCC_fnc_mapDrawWP;"];

//Draw WP
MCC_UMListSig = [];
while {dialog && (str (finddisplay groupGen_IDD) != "no display") && !MCC_groupGenRefreshTerminate} do {

	private _tempArray1 = [];
	private _tempArray2 = [];

	{
		_leader = (leader _x);
		_groupStatus = _x getvariable "MCC_support";
		_wpArray = waypoints (group _leader);
		_behaviour = behaviour _leader;
		_players = if ("players" in MCC_groupGenGroupStatus && (count MCC_groupGenGroupStatus == 1)) then {alive _leader && isPlayer _leader} else {alive _leader};
		//Civilians that joined a side (suicide bombers, armed civilians) are listed under Civ, not under that side
		private _lside = if (getNumber (configFile >> "CfgVehicles" >> typeOf _leader >> "side") == 3 && {_leader isKindOf "CAManBase"}) then {civilian} else {side _leader};
		if (!isNil {(group _leader) getVariable "MCC_dropFor"}) then {_lside = (group _leader) getVariable ["MCC_dropFor", side group _leader]};

		//Draw loop
		if (alive _leader && {!(_leader iskindof "Logic")} && {["shows", _leader] call MCC_fnc_consoleFilter}) then
		{
			//Draw WP
			if (count _wpArray > 0) then
			{
				private _wp = [];
				private _wPos = [];
				private _wType = "";
				private _lastPos = nil;
				_texture = gettext (configfile >> "CfgMarkers" >> "waypoint" >> "icon");
				for [{_i= currentWaypoint (group _leader)},{_i < count _wpArray},{_i=_i+1}] do 	//Draw the current WP
				{
					_wp = (_wpArray select _i);
					_wPos  = waypointPosition _wp;
					if ((_wPos  distance [0,0,0]) > 50) then {
						_wType = waypointType _wp;
						_tempArray1 set [count _tempArray1, [_texture,[0,0,1,1],_wPos,24,24,0,_wType,0,0.04,"PuristaBold","center"]];

						if (isNil "_lastPos" || _i== currentWaypoint (group _leader) ) then {_lastPos = getpos _leader};

						_tempArray2 set [count _tempArray2, [[_lastPos select 0, _lastPos select 1],_wPos,[0,0,1,1]]];

						_lastPos = _wPos;
					};
				};
			};

			//Draw group markers
			switch (_lside) do
			{
				case east: //East
					{
					_side			= east;
					_markerColor 	= [1,0,0,0.7];
					_markerInf		= "o_inf";
					_markerRecon	= "o_recon";
					_markerSupport	= "o_support";
					_markerAutonomous = "o_uav";
					_markerMech		= "o_mech_inf";
					_markerArmor	= "o_armor";
					_markerAir		= "o_air";
					_markerNaval	= "o_naval";
					};

				case west: //West
					{
					_side			= west;
					_markerColor 	= [0,0,1,1];
					_markerInf		= "b_inf";
					_markerRecon	= "b_recon";
					_markerSupport	= "b_support";
					_markerAutonomous = "b_uav";
					_markerMech		= "b_mech_inf";
					_markerArmor	= "b_armor";
					_markerAir		= "b_air";
					_markerNaval	= "b_naval";
					};

				case resistance: //Resistance
					{
					_side			= resistance;
					_markerColor 	= [0,1,0,0.7];
					_markerInf		= "n_inf";
					_markerRecon	= "n_recon";
					_markerSupport	= "n_support";
					_markerAutonomous = "n_uav";
					_markerMech		= "n_mech_inf";
					_markerArmor	= "n_armor";
					_markerAir		= "n_air";
					_markerNaval	= "n_naval";
					};
				case civilian: //Resistance
					{
					_side			= civilian;
					_markerColor 	= [1,1,1,0.7];
					_markerInf		= "n_inf";
					_markerRecon	= "n_recon";
					_markerSupport	= "n_support";
					_markerAutonomous = "n_uav";
					_markerMech		= "n_mech_inf";
					_markerArmor	= "n_armor";
					_markerAir		= "n_air";
					_markerNaval	= "n_naval";
					};
			};

			if (isPlayer _leader) then {_markerColor = switch (_side) do {case east: {[1,0.5,0.5,1]}; case resistance: {[0.5,1,0.5,1]}; case civilian: {[1,1,1,1]}; default {[0,0.5,1,1]}}};
			_IsGaiaControlled = if ((count(_x getVariable  ["GAIA_zone_intend",[]])>1)) then {"(G) "} else
				{
					if (_x getVariable  ["MCC_canbecontrolled",false]) then {"(P) "} else {""};
				};

			if (_x getVariable ["mcc_gaia_cache",false]) then {_IsGaiaControlled = _IsGaiaControlled + "(C) ";};
			if ((_x getVariable ["MCC_GAIA_RESPAWN",0]) > 0) then {_IsGaiaControlled = _IsGaiaControlled + "(R-" + (str (_x getVariable ["MCC_GAIA_RESPAWN",0])) + ") ";};

			_x setGroupIconParams [_markerColor,format ["%1%2",_IsGaiaControlled,(groupID _x)],1,true];
			_unitsCount = [group _leader] call MCC_fnc_countGroupHC; if (isNil "_unitsCount" || {!(_unitsCount isEqualType [])}) then {_unitsCount = [0,0,0,0,0,0,0,0]};
			_unitsSize = 0;
			_markerType = _markerInf;
			if (_unitsCount select 0 > 0) then {_markerType = _markerInf; _unitsSize = _unitsSize + (1*(_unitsCount select 0))};
			if (_unitsCount select 1 > 0) then {_markerType = _markerMech; _unitsSize = _unitsSize + (3*(_unitsCount select 1))};
			if (_unitsCount select 2 > 0) then {_markerType = _markerArmor; _unitsSize = _unitsSize + (3*(_unitsCount select 2))};
			if (_unitsCount select 3 > 0) then {_markerType = _markerAir; _unitsSize = _unitsSize + (3*(_unitsCount select 3))};
			if (_unitsCount select 4 > 0) then {_markerType = _markerNaval; _unitsSize = _unitsSize + (3*(_unitsCount select 4))};
			if (_unitsCount select 5 > 0) then {_markerType = _markerRecon; _unitsSize = _unitsSize + (1*(_unitsCount select 5))};
			if (_unitsCount select 6 > 0) then {_markerType = _markerSupport; _unitsSize = _unitsSize + (3*(_unitsCount select 6))};
			if (_unitsCount select 7 > 0) then {_markerType = _markerAutonomous; _unitsSize = _unitsSize + (1*(_unitsCount select 7))};

			if (isnil "_markerType") then
			{
				_unitsCount = [group _leader] call MCC_fnc_countGroup; if (isNil "_unitsCount" || {!(_unitsCount isEqualType [])}) then {_unitsCount = [0,0,0,0,0,0,0,0]};
				if (_unitsCount select 0 > 0) then {_markerType = _markerInf; _unitsSize = _unitsSize + (1*(_unitsCount select 0))};
				if (_unitsCount select 1 > 0) then {_markerType = _markerMech; _unitsSize = _unitsSize + (3*(_unitsCount select 1))};
				if (_unitsCount select 2 > 0) then {_markerType = _markerArmor; _unitsSize = _unitsSize + (3*(_unitsCount select 2))};
				if (_unitsCount select 3 > 0) then {_markerType = _markerAir; _unitsSize = _unitsSize + (3*(_unitsCount select 3))};
				if (_unitsCount select 4 > 0) then {_markerType = _markerNaval; _unitsSize = _unitsSize + (3*(_unitsCount select 4))};
			};

			//How big is the squad
			_unitsSize = floor (_unitsSize/4);
			if (_unitsSize > 10) then {_unitsSize = 10};
			_unitsSizeMarker = format ["group_%1",_unitsSize];

			_icon = (_x getvariable "MCCgroupIconData");
			if (!isnil "_icon") then {_x removeGroupIcon _icon};

			//No icon for a group riding as passengers in someone else's vehicle (the driver's group has the icon). A group whose
			//leader is a passenger but which also drives the vehicle, or whose vehicle has no driver (e.g. the convoy HVT group),
			//gets its icon: without one it could not be selected / deleted on the map.
			private _veh = vehicle _leader;
			if (!(_leader in (assignedCargo _veh)) || {isNull (driver _veh)} || {(group (driver _veh)) == _x}) then
			{
				private _iconType = _markerType;
				if (_behaviour == "COMBAT" && {_side != civilian}) then {
					private _c = format [["MCC_%1_combat", "MCC_%1_combatP"] select (isPlayer _leader), _markerType];
					if (isClass (configFile >> "CfgGroupIcons" >> _c)) then {_iconType = _c};
				};
				_icon = _x addGroupIcon [_iconType,[0,0]];
				_x setGroupIconParams [_markerColor,format ["%1%2",_IsGaiaControlled,(groupID _x)],1,true];
				_x setvariable ["MCCgroupIconData",_icon,false];

				_icon = (_x getvariable "MCCgroupIconSize") select 0;
				if (!isnil "_icon") then {_x removeGroupIcon _icon};

				_icon = _x addGroupIcon [_unitsSizeMarker,[0,0]];
				_x setvariable ["MCCgroupIconSize",[_icon,_unitsSizeMarker],false];

				if (! isnil "_groupStatus") then 					//Draw group status
				{
					private _time = _groupStatus select 1;
					private _status = _groupStatus select 0;

					if (abs (time - _time) < 180) then
						{

							_x setGroupIconParams [_markerColor,format ["%1%2%3",_IsGaiaControlled,groupID _x,_status],1,true];
						}
						else
						{
							_x setGroupIconParams [_markerColor,format ["%1%2",_IsGaiaControlled,groupID _x],1,true];
						};
				};

				if (_behaviour == "COMBAT") then				//Show in combat
				{
					_x setGroupIconParams [[1,1,1,1],format ["%1%2",_IsGaiaControlled,groupID _x],1,true];
				};
			};
		};
	} foreach allgroups;

	//Draw IEDs. Armed civilians and suicide bombers are civilians: shown only with Civ (or All) selected, like the
	//civilian groups - they showed with West / East / Guer as well
	{
		if ((_x getVariable ["armed",false]) && {!((_x getVariable ["iedMarkerName", ""]) in ["Armed Civilian", "Suicide Bomber"]) || {civilian in MCC_groupGenGroupStatus}}) then
		{
			_texture =	if (_x getVariable ["isAmbush",false]) then
						{
							 gettext (configfile >> "CfgMarkers" >> "mil_ambush" >> "icon");
						}
						else
						{
							gettext (configfile >> "CfgMarkers" >> "selector_selectedMission" >> "icon");
						};

			_tempArray1 set [count _tempArray1, [_texture, [1,0,0,1], getpos _x, 24, 24, (_x getvariable ["dir",0])-90, _x getvariable ["iedMarkerName", ""],0,0.04,"PuristaBold","right"]];

			//Draw synced IED lines
			_syncedObject = _x getVariable ["syncedObject",[0,0,0]];
			if (str _syncedObject != "[0,0,0]") then
			{
				_tempArray2 set [count _tempArray2, [getpos _x,	_syncedObject,[1,0,0,1]]];
			};
		};
	} foreach (allMissionObjects MCC_dummy);

	MCC_GGIcons = _tempArray1;
	MCC_GGLines = _tempArray2;

	//Units / Groups mode, side filter) - it was rebuilt every 0.5 s. Spawning, deaths, joins and side / mode changes
	//all change this summary; mode switch and auto-select still rebuild it directly.
	private _picked = +(missionNamespace getVariable ["MCC_GroupGenGroupSelected", []]);
	private _umSig = [missionNamespace getVariable ["MCC_UMUnit", 0], +(missionNamespace getVariable ["MCC_groupGenGroupStatus", []]), allGroups apply {[_x, {alive _x} count (units _x)]}, _picked];
	if (!(_umSig isEqualTo (missionNamespace getVariable ["MCC_UMListSig", []])) && {!(missionNamespace getVariable ["MCC_UMFocus", false])}) then {
		private _pickedChanged = !(_picked isEqualTo ((missionNamespace getVariable ["MCC_UMListSig", [0,0,0,[]]]) param [3, []]));
		MCC_UMListSig = _umSig;
		if (_pickedChanged && {count _picked > 0}) then {
			private _sel = if ((missionNamespace getVariable ["MCC_UMUnit", 0]) == 0) then {
				private _u = []; {_u append ((units _x) select {alive _x})} forEach _picked; _u
			} else {_picked};
			MCC_selectedUnits = _sel;
		};
		[] call MCC_fnc_groupGenUMRefresh;
		if (_pickedChanged && {count _picked > 0}) then {
			private _l = (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) displayCtrl 3069;
			private _sel = missionNamespace getVariable ["MCC_selectedUnits", []];
			if (!isNull _l && {count _sel > 0}) then {
				private _names = if ((missionNamespace getVariable ["MCC_UMUnit", 0]) == 0) then {missionNamespace getVariable ["MCC_UMunitsNames", []]} else {missionNamespace getVariable ["UMgroupNames", []]};
				private _row = _names find (_sel select 0);
				if (_row >= 0) then {
					_l lbSetCurSel _row;
					{private _r = _names find _x; if (_r >= 0) then {_l lbSetSelected [_r, true]}} forEach _sel;
				};
			};
		};
	};

	sleep .5;
};

	//Clear stuff after exiting
	{
		_x removeGroupIcon (_x getVariable ["MCCgroupIconData",-1]);
		_x removeGroupIcon ((_x getVariable ["MCCgroupIconSize",[-1]]) select 0);
		_x removeGroupIcon (_x getVariable ["MCCgroupIconDataSelected",-1]);
	} foreach allgroups;

setGroupIconsVisible _groupIconVisible;
setGroupIconsSelectable _groupIconSelectable;

//Artillery
missionNameSpace setVariable ["MCC_artilleryEnabled",false];
deleteMarkerLocal "mcc_arty";

//Spawn
missionNameSpace setVariable ["MCC_spawnEnabled",false];
deleteMarkerLocal "mcc_spawnMarker";

//Remove EH
((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrlRemoveEventHandler ["draw",_handler];

removeMissionEventHandler ["GroupIconClick",_groupIconHandle];

MCC_groupGenRefreshLoop = false;
