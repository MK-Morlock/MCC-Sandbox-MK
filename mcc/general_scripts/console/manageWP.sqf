//Made by Shay_Gman (c) 09.10
#define MCC_CONSOLEWPBCKGR 9157
#define MCC_CONSOLEWPCOMBO 9158
#define MCC_CONSOLEWPFORMATIONCOMBO 9166
#define MCC_CONSOLEWPSPEEDCOMBO 9167
#define MCC_CONSOLEWPBEHAVIORCOMBO 9168
#define MCC_CONSOLEWPADD 	9159
#define MCC_CONSOLEWPREPLACE 9160
#define MCC_CONSOLEWPCLEAR 9161
#define MCC_CONSOLEWPCANCEL 9169
private "_wpType";
private _groups = [];
private _wpFormation = [];
private _wpSpeed = [];
private _wpBehavior = [];

params ["_action"];
_wpType 	= lbValue [MCC_CONSOLEWPCOMBO, lbCurSel MCC_CONSOLEWPCOMBO];
// Pod drop (28) / Winch drop (29): the squads go by Taru drop pod - Bench (8 seats, open) or Transport (16 seats,
// enclosed) - parachuted in or lowered on the winch, along a line drawn on the map; free (troop drops). As the MCC
// console's drop pods: the Taru waits nearby and comes back for the empty pod.
if (_wpType in [28, 29] && {_action in [0, 1]}) exitWith {
	private _cd = findDisplay 2993;
	[_cd displayCtrl MCC_CONSOLEWPCOMBO, "MCC_ccWpType", true] call MCC_fnc_consoleListMemory;
	{ctrlShow [_x, false]} forEach [9207, 9208, 9209, 9210, 9219];
	{ctrlShow [_x, false]} forEach [MCC_CONSOLEWPBCKGR, MCC_CONSOLEWPCOMBO, MCC_CONSOLEWPFORMATIONCOMBO, MCC_CONSOLEWPSPEEDCOMBO, MCC_CONSOLEWPBEHAVIORCOMBO, MCC_CONSOLEWPADD, MCC_CONSOLEWPREPLACE, MCC_CONSOLEWPCLEAR, MCC_CONSOLEWPCANCEL];
	private _all = MCC_ConsoleGroupSelected select {!isNull _x};
	private _grps = _all select {(MCC_ConsoleCanCommandAI || {isPlayer leader _x}) && {(((units _x) findIf {isPlayer _x}) < 0) || {_x == group player}}};
	private _what = ["Pod drop", "Winch drop"] select (_wpType == 29);
	if (count _grps == 0) exitWith {[format ["%1: select AI groups or your own squad", _what]] call MCCMK_fnc_hint};
	if (count _grps < count _all) then {[format ["%1: other players' squads are not included", _what]] call MCCMK_fnc_hint};
	[_grps, _wpType, _what] spawn {
		params ["_grps", "_wpType", "_what"];
		private _pt = ["Bench (8)", "Cancel", "Transport (16)"] call MCC_fnc_choiceBar;
		if (_pt == "") exitWith {};
		private _type = ["covered", "bench"] select (_pt == "left");
		MCCMK_lineLabel = format ["%1: click and drag on the map to draw the approach line - the green dot is the drop point", _what];
		private _line = ["wait", controlNull, 0, 0, "drop"] call MCC_fnc_evacParaLine;
		if (count _line < 2) exitWith {["No drop line drawn"] call MCCMK_fnc_hint};
		MCCMK_lineLabel = "";
		_line params ["_a", "_b"];
		private _len = (_a distance2D _b) min 5000;
		private _dir = _a getDir _b;
		private _mid = _a getPos [_len / 2, _dir];
		private _spawn = _mid getPos [2000, _dir - 180];
		private _away = _mid getPos [2000, _dir];
		//(MK) your own squad: Flying (starting airborne) or Pickup (Tarus land at an LZ, you board and decide
		// when they go - MCCMK_fnc_taruPickup); the LZ chosen automatically or clicked on the map
		private _how = if (_grps isEqualTo [group player]) then {["Flying", "Cancel", "Pickup"] call MCC_fnc_choiceBar} else {"left"};
		if (_how == "") exitWith {};
		if (_how == "right") exitWith {
			private _lzHow = ["Automatic LZ", "Cancel", "Map click"] call MCC_fnc_choiceBar;
			if (_lzHow == "") exitWith {};
			private _lzW = [];
			private _ok = true;
			(findDisplay 2993) closeDisplay 2;
			if (_lzHow == "right") then {
				uiSleep 0.3;
				MCCMK_pickLZ = [];
				openMap [true, false];
				["Click the pickup LZ on the map"] call MCCMK_fnc_hint;
				private _eh = addMissionEventHandler ["MapSingleClick", {MCCMK_pickLZ = _this select 1}];
				waitUntil {uiSleep 0.1; (count MCCMK_pickLZ) > 0 || {!visibleMap}};
				removeMissionEventHandler ["MapSingleClick", _eh];
				openMap [false, false];
				_lzW = +MCCMK_pickLZ;
				if ((count _lzW) < 2) then {_ok = false; ["Pickup cancelled - no LZ clicked"] call MCCMK_fnc_hint};
			};
			if (!_ok) exitWith {};
			private _dd = [format ["dd%1_%2", clientOwner, round (diag_tickTime * 1000)], clientOwner];	//(MK) the drop id: its green dot stays until the drop is complete
			[group player, [_a, _b], [0, 1] select (_wpType == 29), _type, _lzW, "taru", "", [0, 120], _dd] remoteExec ["MCCMK_fnc_taruPickup", 2];
			["INFO", "console", "%1 (%2) by Pickup ordered for %3 - LZ %4", [_what, _type, groupId (group player), ["automatic", "clicked"] select ((count _lzW) >= 2)]] call MCC_fnc_log;
			["drop", _a, _b, 120, _dd select 0] call MCCMK_fnc_dropMarks;
		};
		private _dd = [format ["dd%1_%2", clientOwner, round (diag_tickTime * 1000)], clientOwner];	//(MK) the drop id: its green dot stays until the drop is complete
		[[_a, _b], _grps, 1, 1, _spawn, _away, ["", "", missionNamespace getVariable ["MCCMK_pdHeight", 300], [0, 120], [0, 120], true, true], [[0, 1] select (_wpType == 29), _type], [], [], _dd] remoteExec ["MCC_fnc_realParadrop", 2, false];
		["INFO", "console", "%1 (%2) ordered for %3 squad(s)", [_what, _type, count _grps]] call MCC_fnc_log;
		if ((group player) in _grps) then {(findDisplay 2993) closeDisplay 2};
		["drop", _a, _b, 40, _dd select 0] call MCCMK_fnc_dropMarks;
	};
};
//(MK) Boat pickup: a boat carrier comes for your squad's boat, lands on the water by it, and waits until the boat is in its
// bay (or you're aboard); your Take off then flies it to the point clicked, where it lands on the water to let the boat out
// (MCCMK_fnc_taruPickup, "boat")
if (_wpType == 34 && {_action in [0, 1]}) exitWith {
	(findDisplay 2993) closeDisplay 2;
	private _pt = +MCC_ConsoleWPpos;
	if (!surfaceIsWater _pt) exitWith {["Boat pickup: click a point on the water to take the boat to"] call MCCMK_fnc_hint};
	//(MK) the selected AI squads in boats (they go without a Take off - MCCMK_fnc_taruPickup), else your own squad
	private _sel = (missionNamespace getVariable ["MCC_ConsoleGroupSelected", []]) select {!isPlayer (leader _x) && {((units _x) findIf {(vehicle _x) isKindOf "Ship"}) >= 0}};
	if (_sel isNotEqualTo []) exitWith {
		{[_x, [_pt, _pt getPos [100, 0]], 0, "", [], "boat", "", [0, 120], []] remoteExec ["MCCMK_fnc_taruPickup", 2]} forEach _sel;
		[format ["Boat pickup ordered for %1 squad(s)", count _sel]] call MCCMK_fnc_hint;
	};
	if (!((vehicle player) isKindOf "Ship") && {((units group player) findIf {(vehicle _x) isKindOf "Ship"}) < 0}) exitWith {["Boat pickup: your squad, or the squads selected, must be in a boat"] call MCCMK_fnc_hint};
	[group player, [_pt, _pt getPos [100, 0]], 0, "", [], "boat", "", [0, 120], []] remoteExec ["MCCMK_fnc_taruPickup", 2];
	["INFO", "console", "Boat pickup ordered for %1 - to %2", [groupId (group player), mapGridPosition _pt]] call MCC_fnc_log;
};
if (_wpType == 25 && {_action in [0, 1]}) exitWith {
	private _cd = findDisplay 2993;
	{[_cd displayCtrl (_x select 0), _x select 1, true] call MCC_fnc_consoleListMemory} forEach [[MCC_CONSOLEWPCOMBO, "MCC_ccWpType"], [MCC_CONSOLEWPFORMATIONCOMBO, "MCC_ccHaloAircraft"], [MCC_CONSOLEWPSPEEDCOMBO, "MCC_ccHaloAIHeight"], [MCC_CONSOLEWPBEHAVIORCOMBO, "MCC_ccHaloChute"]];
	private _ho = [[0, 1] select ((lbCurSel MCC_CONSOLEWPBEHAVIORCOMBO) == 1), (lbValue [MCC_CONSOLEWPSPEEDCOMBO, lbCurSel MCC_CONSOLEWPSPEEDCOMBO]) max 75];
	private _form = cbChecked (_cd displayCtrl 9208);
	profileNamespace setVariable ["MCC_ccHaloForm", _form];
	private _lead = cbChecked (_cd displayCtrl 9210);
	profileNamespace setVariable ["MCC_ccHaloLead", _lead];
	{ctrlShow [_x, false]} forEach [9207, 9208, 9209, 9210, 9219];
	private _cls = lbData [MCC_CONSOLEWPFORMATIONCOMBO, lbCurSel MCC_CONSOLEWPFORMATIONCOMBO];
	{ctrlShow [_x, false]} forEach [MCC_CONSOLEWPBCKGR, MCC_CONSOLEWPCOMBO, MCC_CONSOLEWPFORMATIONCOMBO, MCC_CONSOLEWPSPEEDCOMBO, MCC_CONSOLEWPBEHAVIORCOMBO, MCC_CONSOLEWPADD, MCC_CONSOLEWPREPLACE, MCC_CONSOLEWPCLEAR, MCC_CONSOLEWPCANCEL];
	private _all = MCC_ConsoleGroupSelected select {!isNull _x};
	private _grps = _all select {(MCC_ConsoleCanCommandAI || {isPlayer leader _x}) && {(((units _x) findIf {isPlayer _x}) < 0) || {_x == group player}}};
	if (count _grps == 0) exitWith {["HALO: select AI groups or your own squad"] call MCCMK_fnc_hint};
	if (count _grps < count _all) then {["HALO: other players' squads are not included"] call MCCMK_fnc_hint};
	[_grps, _cls, _ho, _form, _lead] spawn {
		params ["_grps", "_cls", "_ho", "_form", "_lead"];
		MCCMK_lineLabel = "HALO: click and drag on the map to draw the drop line - the green dot is the target";
		private _line = ["wait", controlNull, 0, 0, "drop"] call MCC_fnc_evacParaLine;
		if (count _line < 2) exitWith {["No drop line drawn"] call MCCMK_fnc_hint};
		MCCMK_lineLabel = "";
		_line params ["_a", "_b"];
		private _len = (_a distance2D _b) min 5000;
		private _dir = _a getDir _b;
		private _mid = _a getPos [_len / 2, _dir];
		private _spawn = _mid getPos [2000, _dir - 180];
		private _away = _mid getPos [2000, _dir];
		private _dd = [format ["dd%1_%2", clientOwner, round (diag_tickTime * 1000)], clientOwner];	//(MK) the drop id: its green dot stays until the drop is complete
		[[_a, _b], _grps, 1, 2, _spawn, _away, ["", _cls, missionNamespace getVariable ["MCCMK_pdHeight", 300], [0, 120], _ho, _form, _lead], [], [], [], _dd] remoteExec ["MCC_fnc_realParadrop", 2, false];
		if ((group player) in _grps) then {(findDisplay 2993) closeDisplay 2};
		["drop", _a, _b, 40, _dd select 0] call MCCMK_fnc_dropMarks;
	};
};
//(MK) Fast-rope (30): the squads go in by helicopter and fast-rope at a point clicked on the map (MCCMK_fnc_fastRopeInsert);
// your own squad: Flying, or Pickup (the helicopter lands at an LZ first - MCCMK_fnc_taruPickup "rope")
//(MK) Rope extraction (31): a helicopter for each selected squad, hovering over it while they're winched up, then home
if (_wpType == 31 && {_action in [0, 1]}) exitWith {
	private _grps = (missionNamespace getVariable ["MCC_ConsoleGroupSelected", []]) select {!isNull _x && {((units _x) findIf {alive _x && {vehicle _x == _x}}) >= 0}};
	if (_grps isEqualTo []) exitWith {["Rope extraction: the squad must be on foot"] call MCCMK_fnc_hint};
	[_grps] remoteExec ["MCCMK_fnc_ropeExtract", 2];
	["INFO", "console", "Rope extraction ordered for %1 squad(s)", [count _grps]] call MCC_fnc_log;
	[format ["Rope extraction: %1 helicopter(s) on the way", count _grps]] call MCCMK_fnc_hint;
};
if (_wpType == 30 && {_action in [0, 1]}) exitWith {
	private _cd = findDisplay 2993;
	[_cd displayCtrl MCC_CONSOLEWPCOMBO, "MCC_ccWpType", true] call MCC_fnc_consoleListMemory;
	{ctrlShow [_x, false]} forEach [9207, 9208, 9209, 9210, 9219];
	{ctrlShow [_x, false]} forEach [MCC_CONSOLEWPBCKGR, MCC_CONSOLEWPCOMBO, MCC_CONSOLEWPFORMATIONCOMBO, MCC_CONSOLEWPSPEEDCOMBO, MCC_CONSOLEWPBEHAVIORCOMBO, MCC_CONSOLEWPADD, MCC_CONSOLEWPREPLACE, MCC_CONSOLEWPCLEAR, MCC_CONSOLEWPCANCEL];
	private _all = MCC_ConsoleGroupSelected select {!isNull _x};
	private _grps = _all select {(MCC_ConsoleCanCommandAI || {isPlayer leader _x}) && {(((units _x) findIf {isPlayer _x}) < 0) || {_x == group player}}};
	if (count _grps == 0) exitWith {["Fast-rope: select AI groups or your own squad"] call MCCMK_fnc_hint};
	if (count _grps < count _all) then {["Fast-rope: other players' squads are not included"] call MCCMK_fnc_hint};
	[_grps] spawn {
		params ["_grps"];
		private _own = _grps isEqualTo [group player];
		private _how = if (_own) then {["Flying", "Cancel", "Pickup"] call MCC_fnc_choiceBar} else {"left"};
		if (_how == "") exitWith {};
		private _lzHow = "";
		if (_how == "right") then {_lzHow = ["Automatic LZ", "Cancel", "Map click"] call MCC_fnc_choiceBar};
		if (_how == "right" && {_lzHow == ""}) exitWith {};
		// the approach line, drawn as a pod or winch drop's: the green dot at its start is where they rope down; they come
		// in from behind it along the line, and leave along the arrow
		MCCMK_lineLabel = "Fast-rope: click and drag on the map to draw the approach line - the green dot is where they rope down";
		private _line = ["wait", controlNull, 0, 0, "drop"] call MCC_fnc_evacParaLine;
		if (count _line < 2) exitWith {["No approach line drawn"] call MCCMK_fnc_hint};
		MCCMK_lineLabel = "";
		_line params ["_la", "_lb"];
		private _pt = [_la select 0, _la select 1, 0];
		private _hd = if ((_la distance2D _lb) > 5) then {_la getDir _lb} else {-1};
		(findDisplay 2993) closeDisplay 2;
		uiSleep 0.3;
		// for a clicked LZ: the LZ
		private _fnc_click = {
			params ["_what"];
			MCCMK_pickLZ = [];
			openMap [true, false];
			[_what] call MCCMK_fnc_hint;
			private _eh = addMissionEventHandler ["MapSingleClick", {MCCMK_pickLZ = _this select 1}];
			waitUntil {uiSleep 0.1; (count MCCMK_pickLZ) > 0 || {!visibleMap}};
			removeMissionEventHandler ["MapSingleClick", _eh];
			openMap [false, false];
			+MCCMK_pickLZ
		};
		private _lzW = [];
		if (_lzHow == "right") then {_lzW = ["Click the pickup LZ on the map"] call _fnc_click};
		if (_lzHow == "right" && {(count _lzW) < 2}) exitWith {["Fast-rope cancelled - no LZ clicked"] call MCCMK_fnc_hint};
		private _dd = [format ["dd%1_%2", clientOwner, round (diag_tickTime * 1000)], clientOwner];	//(MK) the drop id: its green dots stay until they're down
		private _lineB = if (_hd >= 0) then {_lb} else {_pt getPos [100, 0]};
		if (_how == "right") then {
			[group player, [_pt, _lineB], 0, "", _lzW, "rope", "", [0, 120], _dd] remoteExec ["MCCMK_fnc_taruPickup", 2];
		} else {
			[_grps, _pt, [], _hd, _dd] remoteExec ["MCCMK_fnc_fastRopeInsert", 2];
		};
		["INFO", "console", "Fast-rope ordered for %1 squad(s) - %2", [count _grps, ["flying in", "by Pickup"] select (_how == "right")]] call MCC_fnc_log;
		["drop", _pt, _lineB, [40, 120] select (_how == "right"), _dd select 0] call MCCMK_fnc_dropMarks;
	};
};
if (_wpType == 26 && {_action in [0, 1]}) exitWith {
	private _cd = findDisplay 2993;
	{[_cd displayCtrl (_x select 0), _x select 1, true] call MCC_fnc_consoleListMemory} forEach [[MCC_CONSOLEWPCOMBO, "MCC_ccWpType"], [MCC_CONSOLEWPFORMATIONCOMBO, "MCC_ccParaAircraft"], [MCC_CONSOLEWPSPEEDCOMBO, "MCC_ccParaAIHeight"], [MCC_CONSOLEWPBEHAVIORCOMBO, "MCC_ccParaChute"]];
	private _ho = [[0, 1] select ((lbCurSel MCC_CONSOLEWPBEHAVIORCOMBO) == 1), (lbValue [MCC_CONSOLEWPSPEEDCOMBO, lbCurSel MCC_CONSOLEWPSPEEDCOMBO]) max 75];
	{ctrlShow [_x, false]} forEach [9207, 9208, 9209, 9210, 9219];
	private _cls = lbData [MCC_CONSOLEWPFORMATIONCOMBO, lbCurSel MCC_CONSOLEWPFORMATIONCOMBO];
	{ctrlShow [_x, false]} forEach [MCC_CONSOLEWPBCKGR, MCC_CONSOLEWPCOMBO, MCC_CONSOLEWPFORMATIONCOMBO, MCC_CONSOLEWPSPEEDCOMBO, MCC_CONSOLEWPBEHAVIORCOMBO, MCC_CONSOLEWPADD, MCC_CONSOLEWPREPLACE, MCC_CONSOLEWPCLEAR, MCC_CONSOLEWPCANCEL];
	private _all = MCC_ConsoleGroupSelected select {!isNull _x};
	private _grps = _all select {(MCC_ConsoleCanCommandAI || {isPlayer leader _x}) && {(((units _x) findIf {isPlayer _x}) < 0) || {_x == group player}}};
	if (count _grps == 0) exitWith {["Paradrop: select AI groups or your own squad"] call MCCMK_fnc_hint};
	if (count _grps < count _all) then {["Paradrop: other players' squads are not included"] call MCCMK_fnc_hint};
	[_grps, _cls, _ho] spawn {
		params ["_grps", "_cls", "_ho"];
		private _line = ["wait", controlNull, 0, 0, "para"] call MCC_fnc_evacParaLine;
		if (count _line < 2) exitWith {["No drop line drawn"] call MCCMK_fnc_hint};
		_line params ["_a", "_b"];
		private _len = (_a distance2D _b) min 5000;
		private _dir = _a getDir _b;
		private _mid = _a getPos [_len / 2, _dir];
		private _spawn = _mid getPos [2000, _dir - 180];
		private _away = _mid getPos [2000, _dir];
		//(MK) your own squad: Flying or Pickup (MCCMK_fnc_taruPickup, "para"): the aircraft lands at an LZ, you
		// board and decide when it goes. Only a helicopter or VTOL can land - a plane chosen: Flying only
		if (_grps isEqualTo [group player]) then {
			private _lander = (_cls == "") || {(_cls isKindOf "Helicopter") || {getNumber (configFile >> "CfgVehicles" >> _cls >> "vtol") > 0}};
			private _how = if (_lander) then {["Flying", "Cancel", "Pickup"] call MCC_fnc_choiceBar} else {["Paradrop: Pickup needs a helicopter or VTOL - this one flies straight to the drop"] call MCCMK_fnc_hint; "left"};
			if (_how == "") exitWith {_a = []};
			if (_how == "right") exitWith {
				private _lzHow = ["Automatic LZ", "Cancel", "Map click"] call MCC_fnc_choiceBar;
				if (_lzHow == "") exitWith {_a = []};
				private _lzW = [];
				(findDisplay 2993) closeDisplay 2;
				if (_lzHow == "right") then {
					uiSleep 0.3;
					MCCMK_pickLZ = [];
					openMap [true, false];
					["Click the pickup LZ on the map"] call MCCMK_fnc_hint;
					private _eh = addMissionEventHandler ["MapSingleClick", {MCCMK_pickLZ = _this select 1}];
					waitUntil {uiSleep 0.1; (count MCCMK_pickLZ) > 0 || {!visibleMap}};
					removeMissionEventHandler ["MapSingleClick", _eh];
					openMap [false, false];
					_lzW = +MCCMK_pickLZ;
				};
				if (_lzHow == "right" && {(count _lzW) < 2}) exitWith {_a = []; ["Pickup cancelled - no LZ clicked"] call MCCMK_fnc_hint};
				private _dd = [format ["dd%1_%2", clientOwner, round (diag_tickTime * 1000)], clientOwner];	//(MK) the drop id
				[group player, [_a, _b], 0, "", _lzW, "para", _cls, _ho, _dd] remoteExec ["MCCMK_fnc_taruPickup", 2];
				["INFO", "console", "Paradrop by Pickup ordered for %1 (%2) - LZ %3", [groupId (group player), [_cls, "automatic aircraft"] select (_cls == ""), ["automatic", "clicked"] select ((count _lzW) >= 2)]] call MCC_fnc_log;
				_a = [];
				["para", _line select 0, _line select 1, 120, _dd select 0] call MCCMK_fnc_dropMarks;
			};
		};
		if (_a isEqualTo []) exitWith {};	// (cancelled, or ordered by Pickup)
		private _dd = [format ["dd%1_%2", clientOwner, round (diag_tickTime * 1000)], clientOwner];	//(MK) the drop id
		[[_a, _b], _grps, 1, 0, _spawn, _away, [_cls, "", missionNamespace getVariable ["MCCMK_pdHeight", 300], _ho, [0, 120], true, true], [], [], [], _dd] remoteExec ["MCC_fnc_realParadrop", 2, false];
		if ((group player) in _grps) then {(findDisplay 2993) closeDisplay 2};
		["para", _a, _b, 40, _dd select 0] call MCCMK_fnc_dropMarks;
	};
};
if (_wpType == 27 && {_action in [0, 1]}) exitWith {
	private _cd = findDisplay 2993;
	[_cd displayCtrl MCC_CONSOLEWPCOMBO, "MCC_ccWpType", true] call MCC_fnc_consoleListMemory;
	{ctrlShow [_x, false]} forEach [MCC_CONSOLEWPBCKGR, MCC_CONSOLEWPCOMBO, MCC_CONSOLEWPFORMATIONCOMBO, MCC_CONSOLEWPSPEEDCOMBO, MCC_CONSOLEWPBEHAVIORCOMBO, MCC_CONSOLEWPADD, MCC_CONSOLEWPREPLACE, MCC_CONSOLEWPCLEAR, MCC_CONSOLEWPCANCEL];
	{ctrlShow [_x, false]} forEach [9207, 9208, 9209, 9210, 9219];
	private _grps = (MCC_ConsoleGroupSelected select {!isNull _x}) select {!isPlayer (leader _x) && {((units _x) findIf {(vehicle _x) isKindOf "Ship" && {!((vehicle _x) getVariable ["MCC_isLHD", false])}}) >= 0}};
	if (count _grps == 0) exitWith {["Board ship: select AI groups that are in boats"] call MCCMK_fnc_hint};
	if (((missionNamespace getVariable ["MCC_staticShips", []]) select {!isNull _x}) isEqualTo []) exitWith {["Board ship: there is no ship"] call MCCMK_fnc_hint};
	{[_x] remoteExec ["MCCMK_fnc_boardShipOrder", leader _x]} forEach _grps;
	[format ["Board ship: %1 group(s) heading for the nearest ship", count _grps]] call MCCMK_fnc_hint;
};
{[(findDisplay 2993) displayCtrl (_x select 0), _x select 1, true] call MCC_fnc_consoleListMemory} forEach [[MCC_CONSOLEWPCOMBO, "MCC_ccWpType"]];
_groups		= [];
_wpFormation = ["read", [(findDisplay 2993) displayCtrl MCC_CONSOLEWPFORMATIONCOMBO, "NO CHANGE"]] call MCCMK_fnc_wpCombos;
_wpSpeed = ["read", [(findDisplay 2993) displayCtrl MCC_CONSOLEWPSPEEDCOMBO, "UNCHANGED"]] call MCCMK_fnc_wpCombos;
_wpBehavior = ["read", [(findDisplay 2993) displayCtrl MCC_CONSOLEWPBEHAVIORCOMBO, "UNCHANGED"]] call MCCMK_fnc_wpCombos;

{
	if (MCC_ConsoleCanCommandAI || (!MCC_ConsoleCanCommandAI && isplayer leader _x)) then
		{
			_groups set [count _groups, _x];
		};
} foreach MCC_ConsoleGroupSelected;

if (_action != 3) then {
//Call the server to handle WP
private _mkFh = if (ctrlShown ((findDisplay 2993) displayCtrl 9219)) then {["readFly", [(findDisplay 2993) displayCtrl 9219]] call MCCMK_fnc_wpCombos} else {0};
[_action,MCC_ConsoleWPpos,[_wpType,"NO CHANGE",_wpFormation,_wpSpeed,_wpBehavior,"true","",0,_mkFh],_groups,true] remoteExec ["MCC_fnc_manageWp", 2, false];
if (_wpType == 0 && {_action in [0, 1]} && {profileNamespace getVariable ["MCCMK_wpChainOn", false]}) then {["start", [true, _groups, [0,"NO CHANGE",_wpFormation,_wpSpeed,_wpBehavior,"true","",0,_mkFh]]] call MCCMK_fnc_wpChain} else {["end"] call MCCMK_fnc_wpChain};
};

ctrlShow [MCC_CONSOLEWPBCKGR,false];
ctrlShow [MCC_CONSOLEWPCOMBO,false];
ctrlShow [MCC_CONSOLEWPFORMATIONCOMBO,false];
ctrlShow [MCC_CONSOLEWPSPEEDCOMBO,false];
ctrlShow [MCC_CONSOLEWPBEHAVIORCOMBO,false];
ctrlShow [MCC_CONSOLEWPADD,false];
ctrlShow [MCC_CONSOLEWPREPLACE,false];
ctrlShow [MCC_CONSOLEWPCLEAR,false];
ctrlShow [MCC_CONSOLEWPCANCEL,false];
{ctrlShow [_x, false]} forEach [9207, 9208, 9209, 9210, 9219];
if (_action == 3) then {
	(missionNamespace getVariable ["MCC_consoleWPHidden", []]) params [["_i", false], ["_f", false], ["_u", false]];
	ctrlShow [9150, _i];
	ctrlShow [9151, _f];
	ctrlShow [9162, _u];
};
