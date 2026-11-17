private _ok = "(count (missionNamespace getVariable ['MCC_staticShips', []]) > 0) && {([_player] call MCCMK_fnc_boardSit) == '%1'}";
private _ready = " && {[_player, '%1', '%2'] call MCCMK_fnc_teamReady}";
private _boat = " && {[_player] call MCCMK_fnc_boatHere}";
private _gun = " && {leader group _player == _player} && {(vehicle _player) != _player} && {((fullCrew [vehicle _player, '', false]) findIf {((_x select 1) in ['gunner', 'commander', 'turret']) && {group (_x select 0) == group _player} && {!isPlayer (_x select 0)}}) >= 0}";
private _cross = "!isNull ([_player] call MCCMK_fnc_crossTarget)";
private _teams = [["RED", "Red"], ["GREEN", "Green"], ["BLUE", "Blue"], ["YELLOW", "Yellow"]];
private _list = [
	["MCCMK_climbSquad", "Climb aboard (squad)", {["squad"] call MCCMK_fnc_climbAboard}, format [_ok, "climb"] + format [_ready, "", "climb"]],
	["MCCMK_climbAlone", "Climb aboard (alone)", {["alone"] call MCCMK_fnc_climbAboard}, format [_ok, "climb"]],
	["MCCMK_climbGun", "Climb aboard (leave gunners)", {["gunners"] call MCCMK_fnc_climbAboard}, format [_ok, "climb"] + _gun],
	["MCCMK_bringSquad", "Bring aboard (squad)", {["squad"] call MCCMK_fnc_bringAboard}, format [_ok, "deck"] + format [_ready, "", "climb"]],
	["MCCMK_boatSquad", "Board boat (squad)", {["squad", objNull, true] call MCCMK_fnc_boardBoat}, format [_ok, "deck"] + _boat + format [_ready, "", "deck"], ["squad", true]],
	["MCCMK_boatAlone", "Board boat (alone)", {["alone", objNull, true] call MCCMK_fnc_boardBoat}, format [_ok, "deck"] + _boat, ["alone", true]],
	["MCCMK_sendSquad", "Send to boat (squad)", {["squad", objNull, false] call MCCMK_fnc_boardBoat}, format [_ok, "deck"] + _boat + format [_ready, "", "deck"], ["squad", false]],
	["MCCMK_crossSquad", "Cross to the other ship (squad)", {["squad"] call MCCMK_fnc_crossShip}, _cross + format [_ready, "", "deck"]],
	["MCCMK_crossAlone", "Cross to the other ship (alone)", {["alone"] call MCCMK_fnc_crossShip}, _cross],
	["MCCMK_wellOpen", "Open well deck", {[[player] call MCCMK_fnc_wellDeckPart, true] call MCCMK_fnc_wellDeck}, "private _w = [_player] call MCCMK_fnc_wellDeckPart; !isNull _w && {(_w animationPhase 'door_welldeck') < 0.5}"],
	["MCCMK_wellClose", "Close well deck", {[[player] call MCCMK_fnc_wellDeckPart, false] call MCCMK_fnc_wellDeck}, "private _w = [_player] call MCCMK_fnc_wellDeckPart; !isNull _w && {(_w animationPhase 'door_welldeck') >= 0.5}"],
	["MCCMK_sell", "Sell vehicle", {[[player] call MCCMK_fnc_sellTarget] call MCCMK_fnc_sellConfirm}, "!isNull ([_player] call MCCMK_fnc_sellTarget)"],
	["MCCMK_naval", "Call naval fire", {[] call MCCMK_fnc_navalPanel}, "[_player] call MCCMK_fnc_navalCan"],
	["MCCMK_sar", "Request rescue", {[player, "crew"] remoteExec ["MCCMK_fnc_sarRun", 2]; player setVariable ["MCCMK_sarActive", true]}, "[_player, 'crew'] call MCCMK_fnc_sarCan"],
	["MCCMK_sarCancel", "Cancel rescue", {(player getVariable ["MCCMK_sarVeh", objNull]) setVariable ["MCCMK_sarCancel", true, true]}, "(_player getVariable ['MCCMK_sarActive', false]) && {!isNull (_player getVariable ['MCCMK_sarVeh', objNull])} && {!(_player getVariable ['MCCMK_sarNoCancel', false])} && {!((_player getVariable ['MCCMK_sarVeh', objNull]) getVariable ['MCCMK_sarCancel', false])}"],
	["MCCMK_ropeMe", "Request pickup rope", {[player, [player] call MCCMK_ropeHeliNear] remoteExec ["MCCMK_fnc_ropeUp", 2]}, "!isNil 'MCCMK_ropeHarness' && {call MCCMK_ropeHarness} && {vehicle _player == _player} && {!(_player getVariable ['ARMK_Is_Rappelling', false])} && {!isNull ([_player] call MCCMK_ropeHeliNear)}"],
	["MCCMK_ropeSquad", "Pickup rope: my squad", {[(units group player) select {!isPlayer _x}, [player] call MCCMK_ropeHeliNear] remoteExec ["MCCMK_fnc_ropeSquadUp", 2]}, "!isNil 'MCCMK_ropeHarness' && {call MCCMK_ropeHarness} && {(leader group _player) == _player} && {((units group _player) findIf {!isPlayer _x && {alive _x} && {vehicle _x == _x}}) >= 0} && {!isNull ([_player] call MCCMK_ropeHeliNear)}"],
	["MCCMK_sarChoose", "Rescue: choose who goes up", {[] call MCCMK_sarChooseMenu}, "!isNil 'MCCMK_sarMyHeli' && {(leader group _player) == _player} && {!isNull ([_player] call MCCMK_sarMyHeli)} && {((units group _player) findIf {!isPlayer _x && {alive _x} && {!(_x getVariable ['MCCMK_sarSent', false])}}) >= 0}"],
	["MCCMK_sarGoOff", "Send the helicopter off", {([player] call MCCMK_sarMyHeli) setVariable ["MCCMK_sarGo", true, true]}, "!isNil 'MCCMK_sarMyHeli' && {(leader group _player) == _player} && {!isNull ([_player] call MCCMK_sarMyHeli)}"],
	["MCCMK_sarClimb", "Climb rope", {[player] remoteExec ["MCCMK_fnc_sarClimbReq", 2]}, "!isNil 'MCCMK_sarRopeNear' && {[_player] call MCCMK_sarRopeNear}"],
	["MCCMK_fltScuttle", "Scuttle", {[[player, false] call MCCMK_fltScuttleTarget, true, player] remoteExec ["MCCMK_fnc_floatScuttle", 2]}, "!isNil 'MCCMK_fltScuttleTarget' && {!isNull ([_player, false] call MCCMK_fltScuttleTarget)}"],
	["MCCMK_fltPlug", "Plug the leak", {[] spawn {private _v = [player, true] call MCCMK_fltScuttleTarget; if (isNull _v) exitWith {}; sleep 5; if (alive player && {(vehicle player) isEqualTo _v || {(player distance _v) < 10}}) then {[_v, false, player] remoteExec ["MCCMK_fnc_floatScuttle", 2]}}}, "!isNil 'MCCMK_fltScuttleTarget' && {'ToolKit' in (items _player)} && {!isNull ([_player, true] call MCCMK_fltScuttleTarget)}"],
	//(MK) the boat's driver, its boat in a floating helicopter's bay: scuttle the helicopter from there
	["MCCMK_fltScuttleHeli", "Scuttle helicopter", {private _a = attachedTo (vehicle player); if (!isNull _a) then {[_a, true, player] remoteExec ["MCCMK_fnc_floatScuttle", 2]}}, "private _b = vehicle _player; (_b isKindOf 'Ship') && {(driver _b) isEqualTo _player} && {private _a = attachedTo _b; !isNull _a && {_a isKindOf 'Air'} && {!(_a getVariable ['MCCMK_scuttled', false])}}"],
	//(MK) a damaged floating helicopter repaired from one of its seats or the boat in its bay - as a toolkit repair does (vanilla's,
	// or ACE's field repair) - with the player's toolkit, else the helicopter's own (MCCMK_fnc_fltRepair)
	["MCCMK_fltRepair", "Repair helicopter", {private _v = [player] call MCCMK_fltRepairTarget; if (!isNull _v) then {[_v, player] remoteExec ["MCCMK_fnc_fltRepair", 2]}}, "!isNil 'MCCMK_fltRepairTarget' && {!isNull ([_player] call MCCMK_fltRepairTarget)}"],
	["MCCMK_fltLoad", "Load watercraft", {[vehicle player, [player] call MCCMK_fltLoadTarget, true] remoteExec ["MCCMK_fnc_floatLoad", 2]}, "!isNil 'MCCMK_fltLoadTarget' && {!isNull ([_player] call MCCMK_fltLoadTarget)}"],
	["MCCMK_fltUnload", "Unload watercraft", {[objNull, [player] call MCCMK_fltUnloadTarget, false] remoteExec ["MCCMK_fnc_floatLoad", 2]}, "!isNil 'MCCMK_fltUnloadTarget' && {!isNull ([_player] call MCCMK_fltUnloadTarget)}"]
];
{
	_x params ["_t", "_n"];
	private _tm = format ["team:%1", _t];
	_list pushBack [format ["MCCMK_climb%1", _n], format ["Climb aboard (%1 team)", _n], compile format ["['%1'] call MCCMK_fnc_climbAboard", _tm], format [_ok, "climb"] + format [_ready, _t, "climb"]];
	_list pushBack [format ["MCCMK_bring%1", _n], format ["Bring aboard (%1 team)", _n], compile format ["['%1'] call MCCMK_fnc_bringAboard", _tm], format [_ok, "deck"] + format [_ready, _t, "climb"]];
	_list pushBack [format ["MCCMK_boat%1", _n], format ["Board boat (%1 team)", _n], compile format ["['%1', objNull, true] call MCCMK_fnc_boardBoat", _tm], format [_ok, "deck"] + _boat + format [_ready, _t, "deck"], [_tm, true]];
	_list pushBack [format ["MCCMK_send%1", _n], format ["Send to boat (%1 team)", _n], compile format ["['%1', objNull, false] call MCCMK_fnc_boardBoat", _tm], format [_ok, "deck"] + _boat + format [_ready, _t, "deck"], [_tm, false]];
	_list pushBack [format ["MCCMK_cross%1", _n], format ["Cross to the other ship (%1 team)", _n], compile format ["['%1'] call MCCMK_fnc_crossShip", _tm], _cross + format [_ready, _t, "deck"]];
} forEach _teams;
_list
