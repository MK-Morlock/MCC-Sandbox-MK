/*==================================================================MCC_fnc_manageWp==================================================================================
	Create and control AI WP on map
	Example [] call MCC_fnc_manageWp or [[action,WPlocation,[WPType,WPcombat,WPformation,WPspeed,WPbehavior,WPcondition, WPstatment,WPtimeout],[selectedGroup1,selectedGroup2......] ]],"MCC_fnc_manageWp", group, false] spawn BIS_fnc_MP;

	0	action: Integer, 0 - ADD WP,  1 - Replace WP, 2-Delete all WP
	1	WPlocation: Array location
			2.1		WPType: Integer, a indecator from this array ["MOVE", "DESTROY", "GETIN", "SAD", "JOIN", "LEADER", "GETOUT", "CYCLE", "LOAD", "UNLOAD", "TR UNLOAD", "HOLD","SENTRY","GUARD","SUPPORT","GETIN NEAREST","DISMISS"];
			2.2		WPcombat: string, ["NO CHANGE", "BLUE", "GREEN", "WHITE", "YELLOW", "RED"]
			2.3		WPformation: string, ["NO CHANGE", "COLUMN", "STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND"]
			2.4		WPspeed: string, ["UNCHANGED", "LIMITED", "NORMAL", "FULL"]
			2.5		WPbehavior: string, ["UNCHANGED", "CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH"]
			2.6		WPcondition: string, condition for WP to be complete
			2.7		WPstatment: string, code will run after the WP is complete
			2.8		WPtimeout: number, waiting time  between condition is made till the WP is set to complete
	3 	SelectedGroups: Array containing all the groups to be effected
//==========================================================================================================================================================*/
private _wp = [];
private _wpType = "";
private _objects = objNull;
private _wpObject = nil;
private _wp2 = [];
private _WPTypeIndecator = 0;
private _wpTypes = [];
private _isShown = false;

params ["_action", "_wpLoc", "_wpArray", "_groups"];
_isShown			= _this param [4, false, [false]];
private _fromJob = _this param [5, false, [false]];

// Waypoint condition/statement (indexes 5 and 6) must be strings for setWaypointStatements.
// Several callers pass {} (code) - convert code to its text, anything else to "", and an empty condition to "true".
if (count _wpArray > 6) then {
	_wpArray = +_wpArray;
	{
		private _s = _wpArray select _x;
		if (_s isEqualType {}) then {_s = str _s; _s = _s select [1, (count _s) - 2]};
		if !(_s isEqualType "") then {_s = ""};
		if (_x == 5 && {_s == ""}) then {_s = "true"};
		_wpArray set [_x, _s];
	} forEach [5, 6];
	if !(call MCC_fnc_secSenderOK) then {
		if !((_wpArray select 5) in ["true", ""]) then {_wpArray set [5, "true"]};
		private _st = _wpArray select 6;
		if !(_st == "" || {_st regexMatch "^\[thisList, [-+0-9.,\[\] e]*\] call MCC_fnc_rtsFortify$"}) then {_wpArray set [6, ""]};
	};
};

if (count _wpArray > 0) then
{
_WPTypeIndecator 	= _wpArray select 0;

	_wpTypes = ["MOVE", "DESTROY", "GETIN", "SAD", "JOIN", "LEADER", "GETOUT", "CYCLE", "LOAD", "UNLOAD", "TR UNLOAD", "HOLD", "SENTRY","GUARD","SUPPORT","GETIN NEAREST","DISMISS","Helicopter - Land","Helicopter - Get in","Artillery - Fire Mission","Loiter","Taru - Pick up pod","Taru - Winch drop pod","Taru - Parachute pod","Taru - Release pod"];
	//(MK) 25-31: the console's troop drops (handled before here); 32 / 33: the water landings (MCCMK_fnc_heliWaterLandWp)
	_wpTypes append ["MOVE", "MOVE", "MOVE", "MOVE", "MOVE", "MOVE", "MOVE", "Water landing (engine on)", "Water landing (engine off)", "MOVE", "Boat drop (landed)", "Boat drop (low hover)", "Boat load"];
	_wpType  = _wpTypes param [_WPTypeIndecator, "MOVE"];	//(MK) the console's troop drops (25-30) aren't in this list (Clear with one selected failed)
};

//(MK) A group riding as passengers in a vehicle driven by another group can't take the vehicle anywhere itself: the order
// goes to the vehicle's crew (commandable or player-led, same side, not driven by a player), so the vehicle carries
// them there - once for each vehicle. Orders about the group itself (getting in or out, joining, leading, dismissing)
// stay with it, and once they're out they're ordered on their own again.
if !(_wpType in ["GETIN", "JOIN", "LEADER", "GETOUT", "GETIN NEAREST", "DISMISS", "Helicopter - Get in", "Artillery - Fire Mission"]) then {
	_groups = _groups apply {
		private _g = _x;
		private _l = leader _g;
		private _v = vehicle _l;
		private _d = driver _v;
		if (_v != _l && {!isNull _d} && {alive _d} && {!isPlayer _d} && {(group _d) != _g} && {(side group _d) == (side _g)}
			&& {((group _d) getVariable ["MCC_canbecontrolled", false]) || {isPlayer (leader (group _d))}}) then {
			["INFO", "console", "%1 is riding in %2: the order goes to its crew (%3)", [_g, typeOf _v, group _d]] call MCC_fnc_log;
			group _d
		} else {_g};
	};
	_groups = _groups arrayIntersect _groups;
};


{
	private _mkJobbed = if (_fromJob) then {false} else {[_x, _action, _wpLoc, _wpArray, _isShown, _wpType] call MCCMK_fnc_wpJob};
	if (!_mkJobbed) then {
	if (isPlayer (leader _x)) then {["DEBUG", "console", "manageWp: %1 (player-led) action %2 to %3, type %4, had %5 waypoints (current %6)", [_x, _action, _wpLoc apply {round _x}, _wpType, count (waypoints _x), currentWaypoint _x]] call MCC_fnc_log};
	if (_action != 0 || {isPlayer (leader _x)}) then {while {(count (waypoints _x)) > 0} do {deleteWaypoint ((waypoints _x) select 0)}};	//Delete WP
	if (_action <2) then																						//Add or replace WP
		{
			private _mkN0 = count (waypoints _x);
			private _mkC0 = currentWaypoint _x;
			private _mkPend = _mkC0 < _mkN0 && {!(_mkN0 == 1 && {_mkC0 == 0} && {((leader _x) distance2D (waypointPosition [_x, 0])) < 150})};
			switch _wpType do
			{
				case "GETIN":
					{
						//Find nearest transport
						_objects 	= nearestObjects [[_wpLoc select 0,_wpLoc select 1,0],["Car","Tank","AIR"], 100];
						{
							if ((_x emptyPositions "cargo")>1) exitWith {_wpObject = _x};
						} foreach _objects;

						if (isnil "_wpObject") exitWith 				//Exit - no vehicle found
							{
								_wp = _x addWaypoint [_wpLoc, 0];
								_wp setWaypointType _wpType;
								_wp setWaypointCombatMode (_wpArray select 1);
								_wp setWaypointFormation (_wpArray select 2);
								_wp setWaypointSpeed (_wpArray select 3);
								_wp setWaypointBehaviour (_wpArray select 4);
								_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
								_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
							};
						//If transport isn't empty
						if ({alive _x} count crew _wpObject != 0) then
							{
								while {(count (waypoints (group _wpObject))) > 0} do {deleteWaypoint ((waypoints (group _wpObject)) select 0)};

								{_x assignAsCargo _wpObject;} foreach (units _x);
								if (isNull driver _wpObject) then {(leader _x) assignAsDriver _wpObject};
								if ((isNull gunner _wpObject) && ((count units _x) > 1)) then {(units _x select 1) assignAsGunner _wpObject};
								if ((isNull commander _wpObject) && ((count units _x) > 2)) then {(units _x) select 2 assignAsCommander _wpObject};
								(units _x) orderGetIn true;

								_wp = _x addWaypoint [_wpLoc, 0];
								_wp setWaypointType _wpType;
								_wp setWaypointCombatMode (_wpArray select 1);
								_wp setWaypointFormation (_wpArray select 2);
								_wp setWaypointSpeed (_wpArray select 3);
								_wp setWaypointBehaviour (_wpArray select 4);
								_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
								_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
								_wp2 = (group _wpObject) addWaypoint [_wpLoc, 0];
								_wp2 setWaypointType "LOAD";
								_wp synchronizeWaypoint [_wp2];
							}
							else
							{
								_wp = _x addWaypoint [_wpObject, 0];	//If transport empty
								_wp setWaypointType _wpType;
								_wp setWaypointCombatMode (_wpArray select 1);
								_wp setWaypointFormation (_wpArray select 2);
								_wp setWaypointSpeed (_wpArray select 3);
								_wp setWaypointBehaviour (_wpArray select 4);
								_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
								_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
							};
					};

				case "JOIN":
					{
						_group = _x;
						//Find nearest group
						{
							if (((leader _x distance _wpLoc) < 50) &&(_x != _group) && (side _x == side _group) && !isPlayer leader _x)exitWith {_wpObject = _x};
						} foreach allGroups;

						if (isnil "_wpObject") exitWith 				//Exit - no group found
							{
								_wp = _x addWaypoint [_wpLoc, 0];
								_wp setWaypointType _wpType;
								_wp setWaypointCombatMode (_wpArray select 1);
								_wp setWaypointFormation (_wpArray select 2);
								_wp setWaypointSpeed (_wpArray select 3);
								_wp setWaypointBehaviour (_wpArray select 4);
								_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
								_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
							};

						//If group found
						while {(count (waypoints _wpObject)) > 0} do {deleteWaypoint ((waypoints _wpObject) select 0)};
						_wp = _x addWaypoint [_wpLoc, 0];
						_wp setWaypointType _wpType;
						_wp setWaypointCombatMode (_wpArray select 1);
						_wp setWaypointFormation (_wpArray select 2);
						_wp setWaypointSpeed (_wpArray select 3);
						_wp setWaypointBehaviour (_wpArray select 4);
						_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
						_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
						_wp2 = _wpObject addWaypoint [_wpLoc, 0];
						_wp2 setWaypointType "LEADER";
						_wp synchronizeWaypoint [_wp2];
					};

				case "LEADER":
					{
						_group = _x;
						//Find nearest group
						{
							if (((leader _x distance _wpLoc) < 50) &&(_x != _group) && (side _x == side _group))exitWith {_wpObject = _x};
						} foreach allGroups;

						if (isnil "_wpObject") exitWith 			//Exit - no group found
							{
								_wp = _x addWaypoint [_wpLoc, 0];
								_wp setWaypointType _wpType;
								_wp setWaypointFormation (_wpArray select 2);
								_wp setWaypointSpeed (_wpArray select 3);
								_wp setWaypointBehaviour (_wpArray select 4);
								_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
								_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];

							};

						//If group found
						while {(count (waypoints _wpObject)) > 0} do {deleteWaypoint ((waypoints _wpObject) select 0)};
						_wp = _x addWaypoint [_wpLoc, 0];
						_wp setWaypointType _wpType;
						_wp setWaypointFormation (_wpArray select 2);
						_wp setWaypointSpeed (_wpArray select 3);
						_wp setWaypointBehaviour (_wpArray select 4);
						_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
						_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
						_wp2 = _wpObject addWaypoint [_wpLoc, 0];
						_wp2 setWaypointType "JOIN";
						_wp synchronizeWaypoint [_wp2];
					};

				case "LOAD":
					{
						_group = _x;
						//Find nearest group
						{
							if (((leader _x distance _wpLoc) < 50) &&(_x != _group) && (side _x == side _group))exitWith {_wpObject = _x};
						} foreach allGroups;

						if (isnil "_wpObject") exitWith 			//Exit - no group found
						{
							_wp = _x addWaypoint [_wpLoc, 0];
							_wp setWaypointType _wpType;
							_wp setWaypointFormation (_wpArray select 2);
							_wp setWaypointSpeed (_wpArray select 3);
							_wp setWaypointBehaviour (_wpArray select 4);
							_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
							_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];

						};

						//If group found
						while {(count (waypoints _wpObject)) > 0} do {deleteWaypoint ((waypoints _wpObject) select 0)};
						_wp = _group addWaypoint [_wpLoc, 0];
						_wp setWaypointType _wpType;
						_wp setWaypointFormation (_wpArray select 2);
						_wp setWaypointSpeed (_wpArray select 3);
						_wp setWaypointBehaviour (_wpArray select 4);
						_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
						_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
						_wp2 = _wpObject addWaypoint [_wpLoc, 0];
						_wp2 setWaypointType "GETIN";
						_wp synchronizeWaypoint [_wp2];
					};

				//(MK) a water landing: its route, down to the water on the way in, settled onto it (the group's aircraft - a boat
				// carrier; refused, and said why, otherwise or if the point isn't water)
				case "Water landing (engine on)";
				case "Water landing (engine off)":
					{
						private _ac = vehicle (leader _x);
						if (_ac isKindOf "Air") then {[_ac, _wpLoc, _wpType == "Water landing (engine on)"] spawn MCCMK_fnc_heliWaterLandWp};
					};
				//(MK) Boat drop: a carrier takes the boat aboard to the point and lets it out (MCCMK_fnc_boatDrop)
				case "Boat drop (landed)";
				case "Boat drop (low hover)":
					{
						private _ac = vehicle (leader _x);
						if (_ac isKindOf "Air") then {[_ac, _wpLoc, _wpType == "Boat drop (low hover)"] spawn MCCMK_fnc_boatDrop};
					};
				case "Helicopter - Land":
					{
						_wp = _x addWaypoint [_wpLoc, 0];
						_wp setWaypointType "MOVE";
						_wp setWaypointFormation (_wpArray select 2);
						_wp setWaypointSpeed (_wpArray select 3);
						_wp setWaypointBehaviour (_wpArray select 4);
						_wp setWaypointStatements ["true",'vehicle this land "LAND"'];
						_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
					};

				case "Helicopter - Get in":
					{
						_wp = _x addWaypoint [_wpLoc, 0];
						_wp setWaypointType "MOVE";
						_wp setWaypointFormation (_wpArray select 2);
						_wp setWaypointSpeed (_wpArray select 3);
						_wp setWaypointBehaviour (_wpArray select 4);
						_wp setWaypointStatements ["true",'vehicle this land "GET IN"'];
						_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
					};

				case "Artillery - Fire Mission":
					{
						private _isArty = 0;
						_isArty= getNumber (configfile >> "CfgVehicles" >> typeof (vehicle leader _x) >> "artilleryScanner");
						 if ((vehicle (leader _x) != leader _x) && (_isArty ==1)) then
						 {
							[_x, _wpLoc] call GAIA_fnc_doMortar;
						 };
					};

				case "Taru - Pick up pod": {[_x, "pickup", _wpLoc] call MCC_fnc_taruWaypoint};
				case "Taru - Winch drop pod": {[_x, "winch", _wpLoc] call MCC_fnc_taruWaypoint};
				case "Taru - Parachute pod": {[_x, "parachute", _wpLoc] call MCC_fnc_taruWaypoint};
				case "Taru - Release pod": {[_x, "release", _wpLoc] call MCC_fnc_taruWaypoint};

				case "Loiter":
					{
						_wp = _x addWaypoint [_wpLoc, 0];
						_wp setWaypointType "LOITER";
						_wp setWaypointLoiterType "CIRCLE_L";
						_wp setWaypointSpeed "LIMITED";
						_wp setWaypointLoiterRadius 1000;
					};

				default
					{
						_wp = _x addWaypoint [_wpLoc, 0];
						_wp setWaypointType _wpType;
						_wp setWaypointFormation (_wpArray select 2);
						_wp setWaypointSpeed (_wpArray select 3);
						_wp setWaypointBehaviour (_wpArray select 4);
						_wp setWaypointStatements [(_wpArray select 5),(_wpArray select 6)];
						_wp setWaypointTimeout [_wpArray select 7,_wpArray select 7,_wpArray select 7];
						if (_isShown) then {_wp showWaypoint "ALWAYS"};
						if (isPlayer (leader _x)) then {
							[_x, _wpLoc] remoteExec ["MCC_fnc_formationMove", leader _x];
						} else {
							if (_action != 0) then {private _ld = leader _x; {if (_x != _ld) then {_x doFollow _ld}} forEach units _x};
						};
					};
			};
			private _mkFh = _wpArray param [8, 0];
			private _mkAc = vehicle (leader _x);
			if (_mkFh > 0 && {_mkAc isKindOf "Air"} && {(count (waypoints _x)) > _mkN0}) then {
				if (_mkPend) then {
					private _mkPw = [_x, _mkN0 - 1];
					(waypointStatements _mkPw) params [["_mkC", "true"], ["_mkS", ""]];
					private _mkAdd = format ["(vehicle this) flyInHeight %1; (vehicle this) setVariable ['MCCMK_flyH', %1, true]", _mkFh];
					_mkS = _mkS trim ["; ", 2];
					_mkPw setWaypointStatements [_mkC, if (_mkS == "") then {_mkAdd} else {_mkS + "; " + _mkAdd}];
				} else {
					[_mkAc, _mkFh] remoteExec ["flyInHeight", _mkAc];
					_mkAc setVariable ["MCCMK_flyH", _mkFh, true];
				};
			};
		};
	};
} foreach _groups;

