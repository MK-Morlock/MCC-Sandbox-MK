params [
	["_budget", 0, [0]],
	["_zoneNumber", 0, [0, ""]],
	["_arrayGroup", [], [[]]],
	["_arrayUnits", [], [[]]],
	["_side", sideUnknown, [sideUnknown]],
	["_center", [], [[]]],
	["_radius", 0, [0]]
];
if ((count _arrayUnits == 0 && {count _arrayGroup == 0}) || {count _center < 2}) exitWith {0};
if ((missionNamespace getVariable ["MCC_MWBoats", 0]) == 1) exitWith {0};
private _c = [_center select 0, _center select 1, 0];
// (MK) Which boats: the mission's boat budget - each boat costs 15, a group of boats 15 per boat.
// Where they go and how they patrol: MCCMK_fnc_boatPatrol (a sweep along up to 3 km of
// coast each way, gentle turns, U-turn arcs, safety margins and a watchdog, so they don't run aground).
// armed boats only (a dinghy with one man steering isn't dangerous): single boats without a real weapon are left out,
// and so are the unarmed boats of a group; a faction with boats but no armed ones gets the side's vanilla armed speedboat
_arrayUnits = _arrayUnits select {[_x select 1] call MCCMK_fnc_isArmedBoat};
private _fleet = [];
private _placed = 0;
private _tries = 0;
while {_placed < _budget && {_tries < 12}} do {
	_tries = _tries + 1;
	private _added = false;
	if (random 1 < 0.5 && {count _arrayGroup > 0}) then {
		private _g = selectRandom _arrayGroup;
		if ((15 * (_g select 1)) <= _budget) then {
			private _cfg = call compile (_g select 2);
			private _cls = (("true" configClasses _cfg) apply {getText (_x >> "vehicle")}) select {_x isKindOf "Ship" && {[_x] call MCCMK_fnc_isArmedBoat}};
			if (_cls isNotEqualTo []) then {_fleet append _cls; _placed = _placed + 15 * (count _cls); _added = true};
		};
	};
	if (!_added) then {
		_fleet pushBack (if (count _arrayUnits > 0) then {(selectRandom _arrayUnits) select 1} else {
			//(MK) the faction's own armed boats (or a sibling's - MCCMK_fnc_poolOwn), then the side's vanilla speedboat
			private _own = [missionNamespace getVariable ["MCCMK_genFaction", ""], "ShipArmed"] call MCCMK_fnc_poolOwn;
			if (_own isEqualTo []) then {[_side] call MCCMK_fnc_armedBoatFallback} else {selectRandom _own}
		});
		_placed = _placed + 15;
	};
};
_fleet = _fleet - [""];	//(MK) no armed boat to send (the vanilla fallback off)
if (_fleet isEqualTo []) exitWith {0};
// the boats are out before this returns, so they're recorded with the mission (for its cleanup)
private _key = format ["MCCMK_boatsOut_%1", round (diag_tickTime * 1000)];
private _h = [[_c, _side, _fleet, _key, missionNamespace getVariable ["MCCMK_genFaction", ""]], (if (isNil "_MCCMK_gen") then {""} else {_MCCMK_gen})] spawn {private _MCCMK_gen = _this select 1; (_this select 0) call MCCMK_fnc_boatPatrol};	// the enemy faction crews them
private _t0 = time;
waitUntil {sleep 0.5; (missionNamespace getVariable [_key, false]) || {scriptDone _h} || {time > _t0 + 90}};
missionNamespace setVariable [_key, nil];
_placed
