params [["_b", objNull], ["_c", objNull], ["_cond", {true}], ["_owner", -1]];
if (!isServer || {isNull _b} || {isNull _c} || {!alive _b} || {!alive _c}) exitWith {false};
private _mkSay = {
	params ["_m"];
	if (_owner >= 0) then {[_m] remoteExec ["MCCMK_fnc_hint", _owner]};
	["INFO", "aiBoat", "%1 and %2: %3", [typeOf _b, typeOf _c, _m]] call MCC_fnc_log;
};
private _mkBn = getText (configOf _b >> "displayName");
private _mkCn = getText (configOf _c >> "displayName");
if (!isNull ([_c] call MCCMK_fltAttached)) exitWith {["Boat load: the helicopter already has a boat aboard"] call _mkSay; false};
if ((sizeOf (typeOf _b)) > ([10, 15] select (_c isKindOf "Plane"))) exitWith {[format ["Boat load: %1 is too big for the %2's bay", _mkBn, _mkCn]] call _mkSay; false};
private _mkCrewG = group (driver _c);
if (((crew _c) select {!((group _x) isEqualTo _mkCrewG)}) isNotEqualTo []) exitWith {["Boat load: the helicopter has men in its seats"] call _mkSay; false};
private _mkBg = group (driver _b);
private _mkRel = _c worldToModel (ASLToAGL (getPosASL _b));
if (missionNamespace getVariable ["MCC_debug", false]) then {
	["INFO", "aiBoat", "%1 group %2: side %3, driver side %4, captive %5, icons %6, icon params %7", [typeOf _b, groupId _mkBg, side _mkBg, side (driver _b), captive (driver _b), getGroupIcons _mkBg, getGroupIconParams _mkBg]] call MCC_fnc_log;
};
private _mkRamp = _c modelToWorld [0, -15, 0];
_mkBg setVariable ["MCCMK_wpNow", [[_mkRamp select 0, _mkRamp select 1, 0], "LOAD BOAT"]];
[_mkBg] call MCCMK_fnc_wpPlan;
["INFO", "aiBoat", "%1 to %2: boat at %3 in the helicopter's frame", [typeOf _b, typeOf _c, _mkRel apply {round _x}]] call MCC_fnc_log;
if (missionNamespace getVariable ["MCC_debug", false]) then {
	private _mkBox = [0, 1, 2, 3] apply {private _bb = _x boundingBoxReal _c; [((_bb select 0) select 1) toFixed 1, ((_bb select 1) select 1) toFixed 1]};
	["INFO", "aiBoat", "%1 size: rear and front from centre, m - visual %2, shadow %3, geometry %4, general %5; sizeOf %6; boat %7 geometry %8", [typeOf _c, _mkBox select 0, _mkBox select 1, _mkBox select 2, _mkBox select 3, (sizeOf (typeOf _c)) toFixed 1, typeOf _b, (2 boundingBoxReal _b) apply {if (_x isEqualType []) then {(_x select 1) toFixed 1} else {_x toFixed 1}}]] call MCC_fnc_log;
};
private _mkOk = false;
private _mkWhy = "";
private _mkStillT = -1;
private _mkStillSaid = false;
_b doMove (_c getPos [15, (getDir _c) + 180]);
while {_mkWhy == ""} do {
	if !(call _cond) exitWith {_mkWhy = "cancel"};
	if (!alive _b || {isNull (driver _b)} || {!alive (driver _b)}) exitWith {_mkWhy = "boat"};
	if (isNull _c || {!alive _c} || {(_c getVariable ["MCCMK_waterState", ""]) != "afloat"}) exitWith {_mkWhy = "left"};
	if (!isNull ([_c] call MCCMK_fltAttached)) exitWith {_mkWhy = "full"};
	private _mkRd = _c getRelDir _b;
	if ((_b distance _c) < 25 && {_mkRd > 150} && {_mkRd < 210}) exitWith {
		[_b, _c, true] call MCCMK_fnc_floatLoad;
		_mkOk = !isNull ([_c] call MCCMK_fltAttached);
		_mkWhy = ["fail", "loaded"] select _mkOk;
	};
	if ((abs (speed _b)) < 2) then {
		if (_mkStillT < 0) then {_mkStillT = time};
		if (!_mkStillSaid && {(time - _mkStillT) > 3}) then {
			_mkStillSaid = true;
			["INFO", "aiBoat", "%1 at rest, not loaded: %2 in the helicopter's frame, %3 m away, %4 deg from dead astern, waypoint %5 of %6", [typeOf _b, (_c worldToModel (ASLToAGL (getPosASL _b))) apply {round _x}, round (_b distance _c), round (abs (_mkRd - 180)), currentWaypoint _mkBg, count (waypoints _mkBg)]] call MCC_fnc_log;
		};
	} else {
		_mkStillT = -1;
		_mkStillSaid = false;
	};
	sleep ([1, 0.25] select ((_b distance _c) < 80));
};
if (_mkWhy != "cancel") then {
	_mkBg setVariable ["MCCMK_wpNow", nil];
	[_mkBg] call MCCMK_fnc_wpPlan;
};
switch (_mkWhy) do {
	case "loaded": {["Boat loaded"] call _mkSay};
	case "left": {["Boat load: the helicopter has left"] call _mkSay};
	case "full": {["Boat load: the helicopter already has a boat aboard"] call _mkSay};
	default {["INFO", "aiBoat", "%1 not loaded into %2 (%3)", [typeOf _b, typeOf _c, _mkWhy]] call MCC_fnc_log};
};
_mkOk
