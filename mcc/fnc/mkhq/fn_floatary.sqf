/*
	MCCMK_fnc_floatary - (every computer, postInit) floating aircraft, scuttling and carrying boats - after "Simple
	Floatary" (crub), rewritten for MCC MK (no pop-up window, MCC functions for the network, no wiping of other actions).
	  Floating aircraft ("Floating aircraft", MCCMK Commander Console > Water): large aircraft (helicopters of size 24+,
	  planes of 24.75+) float on water, by their state - able to fly: watertight; crippled (engine or main rotor destroyed,
	  can't move, or heavily damaged): a slow leak (0.1, the original's), so it sinks; destroyed: a wreck. MCC's own water
	  landings (MCCMK_waterLanding on the aircraft): watertight.
	  Scuttling (any boat, any floating aircraft): a leak at "Scuttle leak" (setting) until it's plugged ("Plug the leak",
	  a toolkit: watertight again, the water pumped out slowly - MCCMK_fnc_floatLeak).
	  Carrying boats: Load / Unload Watercraft on the carrier aircraft (MCCMK_fnc_floatLoad) - the actions are in
	  MCCMK_fnc_boardingActions.
	The leak is set where the vehicle is local (MCCMK_fnc_floatLeak). The server checks the state every 5 s.
*/
// helpers (every computer: the actions' conditions use them)
MCCMK_fltAir = {
	params ["_v"];
	(_v isKindOf "Air") && {private _s = sizeOf (typeOf _v); _s >= 24 && {!(_v isKindOf "Plane") || {_s >= 24.75}}}
};
MCCMK_fltBoat = {
	params ["_v"];
	(_v isKindOf "Ship") && {!(_v getVariable ["MCC_isLHD", false])} && {!(_v in (missionNamespace getVariable ["MCC_staticShips", []]))}
};
MCCMK_fltCrippled = {
	params ["_v"];
	!canMove _v || {(damage _v) > 0.7} || {(_v getHitPointDamage "HitEngine") >= 0.9} || {(_v getHitPointDamage "HitHRotor") >= 0.9}
		|| {(_v isKindOf "Ship") && {(fuel _v) <= 0}}
};
// passenger seats - ordinary and firing-from-vehicle: free in a vehicle, and how many a class has
MCCMK_seatsFree = {params ["_v"]; {isNull (_x select 0) && {((_x select 1) == "cargo") || {((_x select 1) == "turret") && {_x param [4, false]}}}} count (fullCrew [_v, "", true])};
MCCMK_seatsOf = {
	params ["_c"];
	(getNumber (configFile >> "CfgVehicles" >> _c >> "transportSoldier")) + ({getNumber (_x >> "isPersonTurret") > 0} count ("true" configClasses (configFile >> "CfgVehicles" >> _c >> "Turrets")))
};
MCCMK_fltAfloat = {params ["_v"]; surfaceIsWater (getPos _v) && {((getPosASL _v) select 2) < 4}};
// the carrier aircraft (the original's list) and where a boat sits in them; aircraft of the same family (a mod's
// variant of one) use the family's place
MCCMK_fltCarriers = [
	["Heli_Transport_04_base_F", [0, 0.75, -0.75]],	// Taru
	["Heli_Transport_02_base_F", [0, 0.75, -0.75]],	// Mohawk
	["Heli_Transport_03_base_F", [0, 0.75, -0.75]],	// Huron
	["VTOL_01_base_F", [0, 0.75, -2.65]],	// Blackfish
	["VTOL_02_base_F", [0, 0.5, -0.75]]	// Xi'an
];
MCCMK_fltCarrierOffset = {
	params ["_v"];
	// (MK) the carriers: the original's (MCCMK_fnc_boatCarrier) - of the Taru only the covered one, or a plain Taru with an MCC
	// transport pod; not the Blackfish gunship
	if !([_v] call MCCMK_fnc_boatCarrier) exitWith {[]};
	if (_v isKindOf "VTOL_01_armed_base_F") exitWith {[]};	// (the gunship Blackfish: no cargo bay - by its class; "armed" in the name also matched "unarmed")
	private _i = MCCMK_fltCarriers findIf {_v isKindOf (_x select 0)};
	if (_i < 0) exitWith {[]};
	(MCCMK_fltCarriers select _i) select 1
};
MCCMK_fltAttached = {params ["_v"]; private _a = (attachedObjects _v) select {_x isKindOf "Ship"}; if (_a isEqualTo []) then {objNull} else {_a select 0}};
// the boat or floating aircraft a player could scuttle / plug: the one he's in, else one within 8 m while he swims
MCCMK_fltScuttleTarget = {
	params ["_u", "_scuttled"];
	private _v = vehicle _u;
	private _c = [];
	if (_v != _u) then {_c = [_v]} else {
		if (surfaceIsWater (getPos _u) && {((getPosASL _u) select 2) < 2}) then {_c = (nearestObjects [_u, ["Ship", "Air"], 12]) select {(_x distance _u) < 8}};
	};
	private _i = _c findIf {
		alive _x && {(_x getVariable ["MCCMK_scuttled", false]) isEqualTo _scuttled} && {
			([_x] call MCCMK_fltBoat) || {([_x] call MCCMK_fltAir) && {[_x] call MCCMK_fltAfloat}}
		}
	};
	if (_i < 0) then {objNull} else {_c select _i}
};

// (MK) "Repair helicopter": a damaged floating aircraft - the one he's in (a seat), or the one his boat is in (its bay) - with a
// toolkit: his own, else one in its inventory
MCCMK_fltRepairTarget = {
	params ["_u"];
	private _v = vehicle _u;
	if (_v isKindOf "Ship") then {_v = attachedTo _v};
	if (isNull _v || {!(_v isKindOf "Air")} || {!alive _v} || {!([_v] call MCCMK_fltAir)} || {!([_v] call MCCMK_fltAfloat)}) exitWith {objNull};
	private _hurt = (damage _v) > 0.01 || {((getAllHitPointsDamage _v) param [2, []]) findIf {_x > 0.05} >= 0};
	if (!_hurt) exitWith {objNull};
	if (("ToolKit" in (items _u)) || {"ToolKit" in (itemCargo _v)}) then {_v} else {objNull}
};
// Load Watercraft: driving a small boat (size 10 or less; 15 for a plane) within 25 m behind a carrier with no boat in it
MCCMK_fltLoadTarget = {
	params ["_u"];
	private _b = vehicle _u;
	if (_b == _u || {!(_b isKindOf "Ship")} || {(driver _b) != _u} || {!isNull (attachedTo _b)}) exitWith {objNull};
	private _c = (nearestObjects [_b, ["Air"], 30]) select {
		(_x distance _b) < 25 && {alive _x} && {([_x] call MCCMK_fltCarrierOffset) isNotEqualTo []} && {isNull ([_x] call MCCMK_fltAttached)}
		&& {private _rd = _x getRelDir _b; _rd > 160 && {_rd < 200}} && {(sizeOf (typeOf _b)) <= ([10, 15] select (_x isKindOf "Plane"))}
	};
	if (_c isEqualTo []) then {objNull} else {_c select 0}
};
// Unload Watercraft: the carrier's pilot, or the driver of the boat in it
MCCMK_fltUnloadTarget = {
	params ["_u"];
	private _v = vehicle _u;
	if (_v == _u) exitWith {objNull};
	if ((driver _v) == _u && {!isNull ([_v] call MCCMK_fltAttached)}) exitWith {_v};
	private _a = attachedTo _v;
	if ((driver _v) == _u && {!isNull _a} && {([_a] call MCCMK_fltCarrierOffset) isNotEqualTo []}) exitWith {_a};
	objNull
};
// the rope rescue hovering for this unit's squad (its ropes down) - the leader's rescue orders
MCCMK_sarMyHeli = {
	params ["_u"];
	private _h = objNull;
	{private _x2 = _x getVariable ["MCCMK_sarRopeHeli", objNull]; if (!isNull _x2) exitWith {_h = _x2}} forEach ([_u] + (units group _u));
	if (alive _h && {!isNil {_h getVariable "MCCMK_sarRope"}}) then {_h} else {objNull}
};
// "Rescue: choose who goes up" - your AI not yet sent, by name, and Everyone; pick again for more (a numbered menu: the
// F keys would open Arma's command menu)
MCCMK_sarChooseMenu = {
	// (MK) only men still waiting: in the water near the ropes, or aboard the boat they came down to - not aboard a helicopter,
	// not back at base
	private _h = [player] call MCCMK_sarMyHeli;
	private _ai = (units group player) select {!isPlayer _x && {alive _x} && {!(_x getVariable ["MCCMK_sarSent", false])} && {
		((vehicle _x == _x) && {surfaceIsWater (getPos _x)} && {((getPosASL _x) select 2) < 2} && {isNull _h || {(_x distance2D _h) < 250}})
		|| {private _d = _x getVariable ["MCCMK_sarRopeDeck", objNull]; !isNull _d && {(vehicle _x) isEqualTo _d}}
	}};
	if (_ai isEqualTo []) exitWith {};
	MCCMK_sarChooseList = _ai;
	private _labels = ["Everyone"] + (_ai apply {name _x});
	if (isNil "ANC_fnc_listMenu") exitWith {{_x setVariable ["MCCMK_sarSent", true, true]} forEach _ai};
	["Who goes up?", _labels, {
		params ["_i"];
		if (_i == 0) then {{_x setVariable ["MCCMK_sarSent", true, true]} forEach MCCMK_sarChooseList} else {
			(MCCMK_sarChooseList param [_i - 1, objNull]) setVariable ["MCCMK_sarSent", true, true];
			[] spawn {sleep 0.3; [] call MCCMK_sarChooseMenu};	// (pick again for more)
		};
	}] call ANC_fnc_listMenu;
};
// "Climb rope": in a rope rescue, a free rope's end within 3.5 m (in the water), or aboard the boat it came down to
MCCMK_sarRopeNear = {
	params ["_u"];
	private _h = _u getVariable ["MCCMK_sarRopeHeli", objNull];
	if (isNull _h || {_u getVariable ["MCCMK_sarClimbing", false]}) exitWith {false};
	private _st = _h getVariable ["MCCMK_sarRope", []];
	if (_st isEqualTo [] || {!(true in (_st select 1))}) exitWith {false};
	if (([_h] call MCCMK_seatsFree) < 1) exitWith {false};	// (no seat left: the next helicopter)
	private _d = _u getVariable ["MCCMK_sarRopeDeck", objNull];
	if (!isNull _d && {(vehicle _u) isEqualTo _d}) exitWith {true};
	if ((vehicle _u) != _u) exitWith {false};
	((_st select 0) findIf {private _w = _h modelToWorld _x; (_u distance2D [_w select 0, _w select 1, 0]) < 3.5}) >= 0
};

if (!isServer) exitWith {};
[] spawn {
	waitUntil {sleep 1; time > 2};
	while {true} do {
		private _on = missionNamespace getVariable ["MCCMK_floatAircraft", true];
		{
			private _v = _x;
			private _want = -1;	// (-1: leave it as it is)
			// (MK) a DESTROYED aircraft on the water: a fast leak, so it sinks within a minute or so (kept watertight, a wreck
			// floated for good); once under, MCC MK's clean-up removes it
			if (!alive _v && {_v isKindOf "Air"} && {surfaceIsWater (getPos _v)} && {!isNull _v}) then {_want = 50};
			if (alive _v) then {
				if (_v getVariable ["MCCMK_scuttled", false]) then {_want = if (_v isKindOf "Ship") then {-1} else {missionNamespace getVariable ["MCCMK_scuttleLeak", 10]}} else {
					if (_on && {[_v] call MCCMK_fltAir}) then {
						// (MK) on a water landing: watertight only while it can fly - crippled, it leaks and sinks like any other ("Plug the
						// leak" saves it; "Repair helicopter" makes it fly, and watertight, again)
						_want = [0, 10] select ([_v] call MCCMK_fltCrippled);	// (litres a second)
					};
				};
			};
			// (MK) a carrier filling up: its boat let out once it is half full, before it goes under
			if (alive _v && {_v isKindOf "Air"} && {(getWaterFillPercentage _v) >= 0.5}) then {
				private _b = [_v] call MCCMK_fltAttached;
				if (!isNull _b) then {
					[objNull, _v, false] call MCCMK_fnc_floatLoad;
					["INFO", "floatary", "%1 half full of water: its boat (%2) let out", [typeOf _v, typeOf _b]] call MCC_fnc_log;
				};
			};
			// (MK) a boat carrier: no damage from boats while it's on the water (every computer, once - MCCMK_fnc_boatDmgGuard)
			if (alive _v && {_v isKindOf "Air"} && {!(_v getVariable ["MCCMK_boatDmgSent", false])}) then {
				if ([_v] call MCCMK_fnc_boatCarrier) then {
					_v setVariable ["MCCMK_boatDmgSent", true];
					[_v] remoteExec ["MCCMK_fnc_boatDmgGuard", 0, _v];
				} else {
					// not a carrier: not asked again every 5 s (a Taru is - with a pod it becomes one)
					if !(_v isKindOf "Heli_Transport_04_base_F") then {_v setVariable ["MCCMK_boatDmgSent", true]};
				};
			};
			private _now = _v getVariable ["MCCMK_fltLeak", -1];
			if (_want < 0 && {_now >= 0} && {alive _v}) then {
				// floating switched off (or a boat's scuttling ended): back to how the game had it
				[_v, -1] remoteExec ["MCCMK_fnc_floatLeak", _v];
				_v setVariable ["MCCMK_fltLeak", -1, true];
			};
			if (_want >= 0 && {!(_want isEqualTo _now)}) then {
				[_v, _want] remoteExec ["MCCMK_fnc_floatLeak", _v];
				_v setVariable ["MCCMK_fltLeak", _want, true];
			};
		} forEach (vehicles select {(_x isKindOf "Air") || {_x isKindOf "Ship"}});
		sleep 5;
	};
};
