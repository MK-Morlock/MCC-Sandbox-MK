/*
	MCCMK_fnc_hcCommander - (server, postInit) "Commandable groups go to High Command": the side's commander (the
	Commander Console role) gets Arma's High Command of every COMMANDABLE AI group of his side - spawned with Commandable:
	Yes, RTS-bought, UAVs - as they appear (checked every 3 s), so he can order them from the map (Ctrl+Space by default)
	as well as from the Commander Console. Left out: his own squad, player-led squads, GAIA groups (not commandable).
	A new commander (the role taken, the mutiny rule, a respawn) gets them instead. As the original MCC's own High Command
	(hc_server.sqf): a "HighCommand" module created on the server and synchronised with the commander - but under its own
	names (MCCMK_hcModules), since the Commander Console skips its group handling when the original's HCWest/HCEast/HCGuer
	exist. Only the groups this added are ever taken away again.
*/
if (!isServer) exitWith {};
[] spawn {
	waitUntil {sleep 1; time > 10};
	MCCMK_hcModules = createHashMap;	// side -> [module, commander unit]
	private _teardown = {
		params ["_key"];
		(MCCMK_hcModules getOrDefault [_key, [objNull, objNull]]) params ["_mod", "_old"];
		// (MK) EVERY group this module's High Command holds is taken away, not only the ones added here: Arma's module, given
		// no subordinates, puts ALL the side's groups under the commander by itself (his own squad, the evac helicopter...), and
		// those would stay behind when the option is switched off. (Not when the original MCC's own HCWest/HCEast/HCGuer
		// exists:
		// its groups are its own.)
		private _orig = !isNil ((["HCWest", "HCEast", "HCGuer"] select ((["WEST", "EAST", "GUER"] find _key) max 0)));
		if (!isNull _old) then {{if (!_orig || {_x getVariable ["MCCMK_hcAdded", false]}) then {_old hcRemoveGroup _x; _x setVariable ["MCCMK_hcAdded", nil, true]}} forEach (hcAllGroups _old)};
		private _sub = if (isNull _mod) then {objNull} else {_mod getVariable ["MCCMK_hcSub", objNull]};
		if (!isNull _mod) then {_mod synchronizeObjectsRemove (synchronizedObjects _mod); private _g = group _mod; if (!isNull _sub) then {deleteVehicle _sub}; deleteVehicle _mod; deleteGroup _g};
		MCCMK_hcModules set [_key, [objNull, objNull]];
	};
	while {true} do {
		private _on = missionNamespace getVariable ["MCCMK_hcCommandable", true];
		{
			private _sd = _x;
			private _key = str _sd;
			if (!_on) then {[_key] call _teardown} else {
				private _uid = (missionNamespace getVariable ["MCC_server", objNull]) getVariable [format ["CP_commander%1", _sd], ""];
				private _cmd = if (_uid == "") then {objNull} else {(allPlayers select {(getPlayerUID _x) == _uid && {alive _x}}) param [0, objNull]};
				(MCCMK_hcModules getOrDefault [_key, [objNull, objNull]]) params ["_mod", "_old"];
				if !(_cmd isEqualTo _old) then {
					[_key] call _teardown;
					if (!isNull _cmd) then {
						private _lg = createGroup [sideLogic, true];
						private _m = _lg createUnit ["HighCommand", getPosATL _cmd, [], 0, "NONE"];
						// (MK) ONLY the commandable groups. Arma's High Command module with no "Subordinate" module linked to it adds
						// every group of the commander's side by itself, and it keeps writing those groups' map icons (its own colour,
						// no name) - the MCC console and the Commander Console write theirs twice a second, so every friendly icon
						// flashed, the commander's own squad included. An (empty) Subordinate module is linked: Arma's own rule then
						// adds nothing by itself, and the groups are the ones given below.
						private _sb = _lg createUnit ["HighCommandSubordinate", getPosATL _cmd, [], 0, "NONE"];
						if (isNull _sb) then {_m synchronizeObjectsAdd [_cmd]} else {_m synchronizeObjectsAdd [_cmd, _sb]; _m setVariable ["MCCMK_hcSub", _sb]};
						_m setVariable ["addAllGroups", false, true];
						// (MK) "the waypoint under the mouse" given its empty value from the start. Arma's script (HC_GUI.sqf) only
						// sets it when the mouse passes over a group icon on the main map, and its right-click code reads it without
						// checking: a right-click on a group icon before that - on the MCC console's map, say - gave "Undefined
						// variable _wpover" (lines 196 and 224). With the empty value it simply does nothing.
						_m setVariable ["wpover", [grpNull]];
						MCCMK_hcModules set [_key, [_m, _cmd]];
						["INFO", "MCCMK_fnc_hcCommander", "%1 commander %2: High Command of the side's commandable groups", [_sd, name _cmd]] call MCC_fnc_log;
					};
				};
				if (!isNull _cmd) then {
					private _want = allGroups select {
						(side _x) isEqualTo _sd && {_x getVariable ["MCC_canbecontrolled", false]} && {!isPlayer (leader _x)}
						&& {_x != group _cmd} && {((units _x) findIf {alive _x}) >= 0}
					};
					private _have = hcAllGroups _cmd;
					{_cmd hcSetGroup [_x]; _x setVariable ["MCCMK_hcAdded", true, true]} forEach (_want - _have);
					// (MK) anything else Arma's module put under him by itself is taken away again (see above), and said in the log
					private _orig = !isNil ((["HCWest", "HCEast", "HCGuer"] select ((["WEST", "EAST", "GUER"] find _key) max 0)));
					private _out = _have select {!(_x in _want) && {!_orig || {_x getVariable ["MCCMK_hcAdded", false]}}};
					{
						// (MK) why it is no longer one of the commander's: said in the log
						private _why = switch (true) do {
							case (((units _x) findIf {alive _x}) < 0): {"no one alive in it"};
							case !((side _x) isEqualTo _sd): {format ["its side is now %1", side _x]};
							case (isPlayer (leader _x)): {format ["its leader is a player (%1)", name (leader _x)]};
							case (_x == group _cmd): {"it is the commander's own group"};
							case !(_x getVariable ["MCC_canbecontrolled", false]): {"it is no longer set as commandable"};
							default {"not one this adds (Arma's module put it there)"};
						};
						["INFO", "MCCMK_fnc_hcCommander", "%1 (leader %2, %3) taken out of High Command: %4", [groupId _x, name (leader _x), typeOf (vehicle (leader _x)), _why]] call MCC_fnc_log;
						_cmd hcRemoveGroup _x; _x setVariable ["MCCMK_hcAdded", nil, true];
					} forEach _out;
					private _modNow = (MCCMK_hcModules getOrDefault [_key, [objNull, objNull]]) select 0;
					if (!isNull _modNow) then {_modNow setVariable ["addAllGroups", false, true]};
					private _hcKey = str [count _want, count _have, count _out];
					if ((_cmd getVariable ["MCCMK_hcLogged", ""]) != _hcKey) then {
						_cmd setVariable ["MCCMK_hcLogged", _hcKey];
						["INFO", "MCCMK_fnc_hcCommander", "%1: %2 commandable group(s) wanted | Arma's High Command held %3 | %4 taken away again%5", [_sd, count _want, count _have, count _out, if (_out isEqualTo []) then {""} else {format [": %1", (_out apply {groupId _x}) joinString ", "]}]] call MCC_fnc_log;
					};
				};
			};
		} forEach [west, east, independent];
		sleep 3;
	};
};
