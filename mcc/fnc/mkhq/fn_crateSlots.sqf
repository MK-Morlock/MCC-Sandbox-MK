/*
	MCCMK_fnc_crateSlots - how many logistics crates a vehicle takes (the Logistics window's slots). A helicopter: 1 (sling
	load). A vehicle-in-vehicle carrier: worked out from its cargo bay (the two corner points its config names) and a
	crate's size, as Arma lines cargo up in the bay. A cargo truck with MCC's own placement: as many as its bed is long. Never fewer than the
	crates on it now, and at most 8 (the window's slots). [vehicle] -> number
*/
params [["_v", objNull, [objNull]]];
if (isNull _v) exitWith {0};
if (_v isKindOf "Helicopter") exitWith {1};
private _loaded = count ([_v] call MCCMK_fnc_crateOnTruck);
private _car = configFile >> "CfgVehicles" >> typeOf _v >> "VehicleTransport" >> "Carrier";
if !(isClass _car) exitWith {
	// a cargo truck: as many crates as its bed is long (MCC's 1.6 m spacing), measured once per truck type
	private _cache = missionNamespace getVariable ["MCCMK_bedSlotCache", createHashMap];
	private _m = _cache get (typeOf _v);
	if (isNil "_m") then {
		(boundingBoxReal _v) params ["_lo", "_hi"];
		private _y = (_lo select 1) + 0.3;
		private _floor = nil;
		private _len = 0;
		while {_y < (_hi select 1)} do {
			private _hits = (lineIntersectsSurfaces [_v modelToWorldWorld [0, _y, 0.5], _v modelToWorldWorld [0, _y, -2.5], objNull, objNull, true, 5, "GEOM", "NONE"]) select {(_x select 2) isEqualTo _v};
			if (_hits isEqualTo []) exitWith {};
			private _z = (_v worldToModel (ASLToAGL ((_hits select 0) select 0))) select 2;
			if (isNil "_floor") then {_floor = _z};
			if (_z > _floor + 0.4) exitWith {};	// the front of the bed or the cab
			_len = _len + 0.25;
			_y = _y + 0.25;
		};
		_m = ((floor ((_len - 0.8) / 1.6)) + 1) max 1;
		_cache set [typeOf _v, _m];
		missionNamespace setVariable ["MCCMK_bedSlotCache", _cache];
	};
	(_m max _loaded) min 8
};
private _n = (missionNamespace getVariable ["MCCMK_crateSlotCache", createHashMap]) get (typeOf _v);
if (isNil "_n") then {
	_n = 1;
	private _pts = getArray (_car >> "cargoBayDimensions");
	if (count _pts == 2) then {
		private _a = _v selectionPosition [_pts select 0, "Memory"];
		private _b = _v selectionPosition [_pts select 1, "Memory"];
		private _bay = (_a vectorDiff _b) apply {abs _x};
		private _sp = getArray (_car >> "cargoSpacing");
		if (count _sp < 3) then {_sp = [0, 0.15, 0]};
		// a crate's footprint (measured once, on a local copy far away)
		private _cs = missionNamespace getVariable "MCCMK_crateSize";
		if (isNil "_cs") then {
			private _t = "MCC_crateAmmo" createVehicleLocal [0, 0, 1000];
			(boundingBoxReal _t) params ["_lo", "_hi"];
			_cs = (_hi vectorDiff _lo) apply {abs _x};
			deleteVehicle _t;
			missionNamespace setVariable ["MCCMK_crateSize", _cs];
		};
		private _along = floor (((_bay select 1) + (_sp select 1)) / ((_cs select 1) + (_sp select 1)));
		_n = _along max 1;	// Arma lines vehicle-in-vehicle cargo up in one row along the bay
	};
	private _c = missionNamespace getVariable ["MCCMK_crateSlotCache", createHashMap];
	_c set [typeOf _v, _n];
	missionNamespace setVariable ["MCCMK_crateSlotCache", _c];
};
((_n max _loaded) max 1) min 8
