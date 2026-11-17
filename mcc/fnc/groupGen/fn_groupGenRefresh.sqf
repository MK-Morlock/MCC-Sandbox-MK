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
	if (!isNull (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull])) then {
		[_map, missionNamespace getVariable ["MCC_GroupGenGroupSelected", []], (["MCC_artilleryEnabled", "MCC_spawnEnabled", "MCC_ConsoleRuler", "MCC_zone_drawing", "MCC3DRuning", "MCC_CASrequestMarker", "MCC_brush_drawing", "MCC_drawTriggers", "MCC_drawMinefield", "MCC_delete_drawing", "MCC_ambushPlacing", "MCC_UMParadropRequestMarker", "MCC_DrawLine", "MCC_evacParaWait", "MCCMK_makeHQPick", "MCC_evacSpawnPending"] findIf {(missionNamespace getVariable [_x, false]) isEqualTo true}) >= 0] call MCCMK_fnc_wpChainDraw;
	};

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
uiNamespace setVariable ["MCCMK_wpChain", nil];
// (MK) THE CONSOLE'S ICONS HELD AGAINST ARMA'S HIGH COMMAND. While the player is his side's commander, Arma's High Command
// script goes round EVERY group about once a second and blanks its icon's colour and name (colour [0,0,0,0], name '', on
// friendly and enemy groups alike, in his High Command or not, and its own "dummy" icons added). The console's colour
// and name are put back at three points of every frame: at its start, when the scene is drawn (after the scripts have
// run,
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

// (MK) EVERY group this console shows has its own colour and name put back every frame, just before the map is drawn - not
// only the groups under Arma's High Command. Something else writes the icons' colour and name while the player is the
// side's commander; whatever writes them, it doesn't reach the screen.
((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrlAddEventHandler ["Draw", {
	{
		private _w = _x getVariable "MCCMK_iconWant";
		// (only where this console's own icon is really on the group - Map Intel's icons on other groups are its own - and not
		// during Map Intel's gunfire flash)
		private _id = _x getVariable "MCCgroupIconData";
		if (!isNil "_w" && {!(_x getVariable ["MCCMK_miFlashing", false])}) then {
			// (debug on: said once a group, the first time its colour or name was found changed by something else)
			if ((missionNamespace getVariable ["MCC_debug", false]) && {!(_x getVariable ["MCCMK_iconFought", false])}) then {
				private _now = getGroupIconParams _x;
				// (a colour read back is rounded to 1/255 - compared with that allowance)
				private _dc = 0;
				{_dc = _dc max (abs (_x - ((_w select 0) param [_forEachIndex, 0])))} forEach (_now select 0);
				// its icons: the console's own (its symbol, its size marker, the selection ring) and any put there by something else
				private _all = getGroupIcons _x;
				private _own = {private _i = _x; !isNil "_i" && {_i isEqualType 0}} count [_id, (_x getVariable ["MCCgroupIconSize", [nil]]) select 0, _x getVariable "MCCgroupIconDataSelected"];
				if (_dc > 0.01 || {!((_now select 1) isEqualTo (_w select 1))} || {(count _all) > _own}) then {
					_x setVariable ["MCCMK_iconFought", true];
					["INFO", "console icons", "%1 (leader %8): found colour %2, name '%3' (the console's: %4, '%5') | in the player's High Command: %6 | Map Intel icon on it: %7 | %9 icon(s) on the group, %10 of them the console's: %11", [groupId _x, _now select 0, _now select 1, _w select 0, _w select 1, _x in (hcAllGroups player), (_x getVariable ["MCCMK_miIcon", -1]) >= 0, typeOf (leader _x), count _all, _own, _all]] call MCC_fnc_log;
				};
			};
			_x setGroupIconParams ([_x, _w] call MCCMK_fnc_iconWithWp);
		};
	} forEach allGroups;
}];

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
		private _lside = if (getNumber (configFile >> "CfgVehicles" >> typeOf _leader >> "side") == 3 && {_leader isKindOf "CAManBase"}) then {civilian} else {side group _leader};	//(MK) the group's side (a leader of another side showed the wrong colour)
		if (!isNil {(group _leader) getVariable "MCC_dropFor"}) then {_lside = (group _leader) getVariable ["MCC_dropFor", side group _leader]};

		//Draw loop
		if (alive _leader && {!(_leader iskindof "Logic")} && {["shows", _leader] call MCC_fnc_consoleFilter}) then
		{
			//Draw WP (MK: unless the Orders button has them hidden)
			if (count _wpArray > 0 && {missionNamespace getVariable ["MCCMK_showOrders", true]}) then
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
			private _mkPlan = (group _leader) getVariable ["MCCMK_wpPlan", []];
			if (_mkPlan isNotEqualTo [] && {missionNamespace getVariable ["MCCMK_showOrders", true]}) then
			{
				private _mkTex = gettext (configfile >> "CfgMarkers" >> "waypoint" >> "icon");
				private _mkLp = getPos _leader;
				private _mkWps = waypoints (group _leader);
				for "_mkK" from (currentWaypoint (group _leader)) to ((count _mkWps) - 1) do {
					private _mkP = waypointPosition (_mkWps select _mkK);
					if ((_mkP distance [0,0,0]) > 50) then {_mkLp = _mkP};
				};
				{
					_x params ["_mkP", "_mkT"];
					_tempArray1 set [count _tempArray1, [_mkTex,[0,0,1,1],_mkP,24,24,0,_mkT,0,0.04,"PuristaBold","center"]];
					_tempArray2 set [count _tempArray2, [[_mkLp select 0, _mkLp select 1],_mkP,[0,0,1,1]]];
					_mkLp = _mkP;
				} forEach _mkPlan;
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

			//(MK) debug: what decides each group's icon colour - logged the first time it's drawn, and again if that changes
			if (missionNamespace getVariable ["MCC_debug", false]) then {
				private _matched = _lside in [east, west, resistance, civilian];
				private _iconKey = str [_lside, _markerColor, _markerInf];
				if ((_x getVariable ["MCCMK_iconLogged", ""]) != _iconKey) then {
					_x setVariable ["MCCMK_iconLogged", _iconKey];
					[["INFO", "WARN"] select (!_matched), "console icons", "%1: group side %2 | leader %3 (%4, faction %5, config side %6), side %7 | dropFor %8 | console side %9%10 | colour %11, symbol %12 | %13", [groupId _x, side _x, name _leader, typeOf _leader, faction _leader, getNumber (configOf _leader >> "side"), side _leader, _x getVariable ["MCC_dropFor", "-"], _lside, ["", " - MATCHES NO SIDE (colour and symbol left over from the previous group)"] select (!_matched), _markerColor, _markerInf, ["", "GAIA"] select (_IsGaiaControlled find "(G)" >= 0)]] call MCC_fnc_log;
				};
			};
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

			//(MK) the icon updated in place, not deleted and re-created twice a second
			_icon = (_x getvariable "MCCgroupIconData");

			//No icon for a group riding as passengers in someone else's vehicle (the driver's group has the icon). A group whose
			//leader is a passenger but which also drives the vehicle, or whose vehicle has no driver (e.g. the convoy HVT group),
			//gets its icon: without one it could not be selected / deleted on the map.
			private _veh = vehicle _leader;
			// (MK) ONE icon a vehicle: a group whose leader rides in a vehicle driven by ANOTHER group has no icon of its own, in
			// whatever seat he sits - not only as a passenger. An evac helicopter has two groups (its pilot's, and its gunners' -
			// their leader in a gun turret): both had an icon on the same spot, one name written over the other ("Alpha 2-2"
			// over "Alpha 2-3").
			if ((_veh isEqualTo _leader) || {isNull (driver _veh)} || {(group (driver _veh)) == _x}) then
			{
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
				private _iconTxt = format ["%1%2",_IsGaiaControlled,groupID _x];
				if (!isnil "_groupStatus" && {(abs (time - (_groupStatus select 1))) < 180}) then {_iconTxt = format ["%1%2%3",_IsGaiaControlled,groupID _x,_groupStatus select 0]};
				if (_behaviour == "COMBAT") then {_iconCol = [1,1,1,1]; _iconTxt = format ["%1%2",_IsGaiaControlled,groupID _x]};	//Show in combat
				_x setGroupIconParams ([_x, [_iconCol,_iconTxt,1,true]] call MCCMK_fnc_iconWithWp);
				_x setVariable ["MCCMK_iconWant", [_iconCol,_iconTxt,1,true]];
			} else {
				// A group with Arma's Military Symbols icons is held invisible (its second group in the same vehicle
				// would show Arma's box under the first's)
				_x setVariable ["MCCMK_iconWant", if ([_x] call MCCMK_iconMartaHas) then {[[0,0,0,0], "", 1, false]} else {nil}];
				if (!isNil "_icon") then {_x removeGroupIcon _icon; _x setVariable ["MCCgroupIconData", nil]};
				private _szi = (_x getVariable ["MCCgroupIconSize", [-1]]) param [0, -1];
				if (_szi >= 0) then {_x removeGroupIcon _szi; _x setVariable ["MCCgroupIconSize", nil]};
			};
		} else {
			//(MK) hidden by the filter (or gone): all its icons cleared (group icons belong to the game, not to one
			//window: left, they'd show on the Commander console and the main map too)
			// (MK) a group with Arma's Military Symbols icons keeps them (cleared, High Command's own scripts fail): only this
			// console's own three are taken off it, and it is held invisible
			private _hasM = !isNil {_x getVariable "BIS_MARTA_ICON_TYPE"};
			_x setVariable ["MCCMK_iconWant", if (_hasM) then {[[0,0,0,0], "", 1, false]} else {nil}];
			if (count (getGroupIcons _x) > 0) then {
				if (!_hasM) then {clearGroupIcons _x} else {
					_x removeGroupIcon (_x getVariable ["MCCgroupIconData", -1]);
					_x removeGroupIcon ((_x getVariable ["MCCgroupIconSize", [-1]]) param [0, -1]);
					_x removeGroupIcon (_x getVariable ["MCCgroupIconDataSelected", -1]);
				};
				_x setVariable ["MCCgroupIconData", nil];
				_x setVariable ["MCCgroupIconSize", nil];
				_x setVariable ["MCCgroupIconDataSelected", nil];
			};
		};
	} foreach allgroups;

	//Draw IEDs. Armed civilians and suicide bombers are civilians: shown only with Civ (or All) selected, like the
	//civilian groups - they showed with West / East / Guer as well
	{
		private _isCivHazard = (_x getVariable ["iedMarkerName", ""]) in ["Armed Civilian", "Suicide Bomber"];
		//(MK) IEDs and ambushes follow the IEDs button; suicide bombers and armed civilians follow Civ
		if ((_x getVariable ["armed",false]) && {if (_isCivHazard) then {civilian in MCC_groupGenGroupStatus} else {missionNamespace getVariable ["MCCMK_showIEDs", true]}}) then
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

	//The unit list is rebuilt only when this summary changes (spawning, deaths, joins, the Units / Groups mode, the
	//side filter); mode switch and auto-select still rebuild it directly.
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

	//(MK) the faction box: the factions on the map, every 2 s (rebuilt only when that changes)
	if (diag_tickTime > (missionNamespace getVariable ["MCCMK_factionBoxNext", 0])) then {
		MCCMK_factionBoxNext = diag_tickTime + 2;
		[uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]] call MCCMK_fnc_factionBox;
	};

	sleep .5;
};

	//Clear stuff after exiting
	//(MK) the unit feed's camera stopped with the console, however it closes (the 3D View included): a picture-in-picture
	// camera left on can keep rendering the scene in the background. The feed starts afresh when a unit is clicked again.
	// (Broadcast has its own camera - not touched.)
	if (!isNil "MCC_PIPcam" && {!isNull MCC_PIPcam}) then {MCC_PIPcam cameraEffect ["TERMINATE", "BACK"]; camDestroy MCC_PIPcam; MCC_PIPcam = objNull};
	private _pipEH = missionNamespace getVariable ["MCC_pipFollowEH", -1];
	if (_pipEH >= 0) then {removeMissionEventHandler ["EachFrame", _pipEH]; MCC_pipFollowEH = -1};
	MCC_pipState = [];
	["restore"] call MCCMK_fnc_feedDist;
	removeMissionEventHandler ["EachFrame", _holdEHs select 0];
	removeMissionEventHandler ["Draw3D", _holdEHs select 1];
	call MCCMK_iconMartaOff;
	{
		_x removeGroupIcon (_x getVariable ["MCCgroupIconData",-1]);
		_x removeGroupIcon ((_x getVariable ["MCCgroupIconSize",[-1]]) select 0);
		_x removeGroupIcon (_x getVariable ["MCCgroupIconDataSelected",-1]);
		//(MK) other sides' groups: every icon cleared - the stored ids are shared with the Commander console, so
		//clearing by id would miss some
		if ((side _x) != (side player)) then {
			// (MK) not when the group carries Arma's own icons: those are never cleared (this console's own went just above)
			if (isNil {_x getVariable "BIS_MARTA_ICON_TYPE"}) then {clearGroupIcons _x};
			_x setVariable ["MCCgroupIconData", nil];
			_x setVariable ["MCCgroupIconSize", nil];
			_x setVariable ["MCCgroupIconDataSelected", nil];
		};
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
