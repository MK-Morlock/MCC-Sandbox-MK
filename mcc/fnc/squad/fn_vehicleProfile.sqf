
params [["_cls", "", [""]]];
if (_cls == "") exitWith {[]};

private _key = "MCCMK_vp_" + _cls;
private _cached = missionNamespace getVariable [_key, []];
if (count _cached > 0) exitWith {_cached};

private _cfg = configFile >> "CfgVehicles" >> _cls;
if (!isClass _cfg) exitWith {[]};

private _dom = "other";
// (a static weapon - a tripod machine gun, grenade launcher, launcher or mortar - is its own kind: it is
//  only ever matched with another static weapon)
if (_cls isKindOf "StaticWeapon") then {
	_dom = "static";
} else {
if (_cls isKindOf "Helicopter") then {
	_dom = "heli";
} else {
	if (_cls isKindOf "Plane") then {
		_dom = if ((getNumber (_cfg >> "vtol")) > 0 || {_cls isKindOf "VTOL_Base_F"}) then {"vtol"} else {"plane"};
	} else {
		if (_cls isKindOf "Ship") then {
			// (a submersible is its own kind: matched with a submersible first, a surface boat only after)
			_dom = if ((toLower (getText (_cfg >> "simulation"))) == "submarinex") then {"sub"} else {"ship"};
		} else {
			if (_cls isKindOf "Tank") then {
				_dom = "tracked";
			} else {
				if (_cls isKindOf "Car") then {_dom = "wheeled";};
			};
		};
	};
};
};

// every magazine on the vehicle and (recursively) its turrets
private _fnc_mags = {
	params ["_c"];
	private _m = getArray (_c >> "magazines");
	private _t = _c >> "Turrets";
	if (isClass _t) then {
		{ _m append ([_x] call _fnc_mags); } forEach ("true" configClasses _t);
	};
	_m
};
private _mags = [_cfg] call _fnc_mags;

// default pylon attachments (a dynamic-loadout class has no weapons in its config)
private _pyl = _cfg >> "Components" >> "TransportPylonsComponent" >> "pylons";
if (isClass _pyl) then {
	{
		private _att = getText (_x >> "attachment");
		if (_att != "") then { _mags pushBack _att; };
	} forEach ("true" configClasses _pyl);
};

private _cats = [false, false, false, false];
private _lvl = 0;
private _aa = false;
private _atgm = 0;
private _blast = 0;   // (the widest blast of any round it carries, in metres - see the artillery entry below)
{
	private _ammo = getText (configFile >> "CfgMagazines" >> _x >> "ammo");
	// Not armament: smoke launchers, flares / chaff, laser designators. A smoke launcher's rounds are
	// rockets to the game, so a vehicle with nothing but a smoke launcher - the plain Strider, say - was
	// read as "armed with rockets" (level 4, heavy): it was never offered for an unarmed car (the Hunter
	// got a truck) and it was an exact match for a cannon APC (the Marshall got the plain Strider, ahead
	// of the HMG and GMG ones). Told by name, and - for rockets, missiles and bombs - by doing next to no damage.
	private _nameL = (toLower _x) + " " + (toLower _ammo);
	if ((["smoke", "flare", "chaff", "laser", "cmflare"] findIf {(_nameL find _x) >= 0}) >= 0) then { _ammo = ""; };
	if (_ammo != "" && {(toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"))) in ["shotrocket", "shotmissile", "shotbomb"]}
		&& {((getNumber (configFile >> "CfgAmmo" >> _ammo >> "hit")) + (getNumber (configFile >> "CfgAmmo" >> _ammo >> "indirectHit"))) < 10}) then { _ammo = ""; };
	if (_ammo != "") then {
		private _a = configFile >> "CfgAmmo" >> _ammo;
		private _sim = toLower (getText (_a >> "simulation"));
		// A round that only carries other rounds - artillery rockets and shells, cluster and airburst rounds -
		// is neither bullet, shell, rocket nor missile to the game, so it was not counted at all: a rocket
		// artillery truck read as UNARMED and was handed out as a plain truck (it replaced fuel and ammo
		// trucks). Such a round is now read as what it carries; if that cannot be told, as a rocket.
		if ((getNumber (_a >> "indirectHit")) >= 50) then { _blast = _blast max (getNumber (_a >> "indirectHitRange")); };
		if (_sim == "shotsubmunitions") then {
			private _subCfg = _a >> "submunitionAmmo";
			private _subName = if (isArray _subCfg) then {(getArray _subCfg) param [0, ""]} else {getText _subCfg};
			if !(_subName isEqualType "") then {_subName = "";};
			private _subA = configFile >> "CfgAmmo" >> _subName;
			private _subSim = if (_subName != "" && {isClass _subA}) then {toLower (getText (_subA >> "simulation"))} else {""};
			if (_subSim in ["shotbullet", "shotshell", "shotrocket", "shotmissile", "shotbomb"]) then {
				_a = _subA;
				_sim = _subSim;
			} else {
				_sim = "shotrocket";
			};
		};
		private _hit = getNumber (_a >> "hit");
		private _ind = getNumber (_a >> "indirectHit");
		if (_ind >= 50) then { _blast = _blast max (getNumber (_a >> "indirectHitRange")); };
		switch (_sim) do {
			case "shotbullet": {
				_cats set [0, true];
				_lvl = _lvl max (if (_hit < 12) then {1} else { if (_hit < 45) then {2} else { if (_hit < 160) then {3} else {5} } });
			};
			case "shotshell": {
				_cats set [0, true];
				_lvl = _lvl max (if ((_hit + _ind) < 60) then {2} else { if ((_hit + _ind) < 200) then {3} else {5} });
			};
			case "shotrocket": {
				_cats set [1, true];
				_lvl = _lvl max 4;
			};
			case "shotmissile": {
				_cats set [2, true];
				_lvl = _lvl max 4;
				if ((getNumber (_a >> "airLock")) >= 2) then { _aa = true; };
				// guided anti-vehicle missile? (what the AI is told to use it on - a number, or a sum written as text)
				private _flC = _a >> "aiAmmoUsageFlags";
				private _fl = 0;
				if (isNumber _flC) then { _fl = getNumber _flC; } else {
					if (isText _flC && {(getText _flC) != ""}) then { private _r = call compile (getText _flC); if (!isNil "_r" && {_r isEqualType 0}) then { _fl = _r; }; };
				};
				private _antiVeh = ((floor (_fl / 128)) mod 2) == 1 || {((floor (_fl / 512)) mod 2) == 1};
				private _guided = (getNumber (_a >> "laserLock")) > 0 || {(getNumber (_a >> "irLock")) > 0} || {(getNumber (_a >> "manualControl")) > 0} || {(getNumber (_a >> "maxControlRange")) > 0};
				if (_antiVeh && {_guided} && {(getNumber (_a >> "airLock")) < 2}) then { _atgm = _atgm + ((getNumber (configFile >> "CfgMagazines" >> _x >> "count")) max 1); };
			};
			case "shotbomb": {
				_cats set [3, true];
				_lvl = _lvl max 5;
			};
			default {};
		};
	};
} forEach _mags;

private _bucket = if (_lvl == 0) then {0} else { if (_lvl <= 2) then {1} else { if (_lvl == 3) then {2} else {3} } };

// the heaviest weapon worked from a gunner seat (see the head of this file)
private _fnc_magLvl = {
	params ["_m"];
	private _ammo = getText (configFile >> "CfgMagazines" >> _m >> "ammo");
	private _nameL = (toLower _m) + " " + (toLower _ammo);
	if (_ammo == "" || {(["smoke", "flare", "chaff", "laser", "cmflare"] findIf {(_nameL find _x) >= 0}) >= 0}) exitWith {0};
	private _a = configFile >> "CfgAmmo" >> _ammo;
	private _sim = toLower (getText (_a >> "simulation"));
	private _hit = getNumber (_a >> "hit");
	private _ind = getNumber (_a >> "indirectHit");
	if (_sim in ["shotrocket", "shotmissile", "shotbomb"] && {(_hit + _ind) < 10}) exitWith {0};
	switch (_sim) do {
		case "shotbullet": { if (_hit < 12) then {1} else { if (_hit < 45) then {2} else { if (_hit < 160) then {3} else {5} } } };
		case "shotshell": { if ((_hit + _ind) < 60) then {2} else { if ((_hit + _ind) < 200) then {3} else {5} } };
		case "shotrocket": {4};
		case "shotmissile": {4};
		case "shotsubmunitions": {4};
		case "shotbomb": {5};
		default {0};
	}
};
private _gunMags = [];
private _fnc_gunTurrets = {
	params ["_c"];
	private _t = _c >> "Turrets";
	if (isClass _t) then {
		{
			if ((getNumber (_x >> "isPersonTurret")) == 0) then { _gunMags append (getArray (_x >> "magazines")); };
			[_x] call _fnc_gunTurrets;
		} forEach ("true" configClasses _t);
	};
};
[_cfg] call _fnc_gunTurrets;
if (isClass _pyl) then {
	{
		private _att = getText (_x >> "attachment");
		if (_att != "" && {count (getArray (_x >> "turret")) > 0}) then { _gunMags pushBack _att; };
	} forEach ("true" configClasses _pyl);
};
private _gunLvl = 0;
{ _gunLvl = _gunLvl max ([_x] call _fnc_magLvl); } forEach (_gunMags arrayIntersect _gunMags);

private _spec = "";
if ((getNumber (_cfg >> "transportFuel")) > 0) then { _spec = _spec + "F"; };
if ((getNumber (_cfg >> "transportRepair")) > 0) then { _spec = _spec + "R"; };
if ((getNumber (_cfg >> "transportAmmo")) > 0) then { _spec = _spec + "A"; };
if ((getNumber (_cfg >> "attendant")) > 0) then { _spec = _spec + "M"; };

// Passenger seats: the plain ones (transportSoldier) AND the seats a passenger can fire from, which the
// game keeps as turrets (isPersonTurret) - all of a Prowler's passenger seats, the benches of a light
// helicopter, the back of some trucks. Counting only the plain ones made such a vehicle report no seats.
private _fnc_personTurrets = {
	params ["_c"];
	private _n = 0;
	private _t = _c >> "Turrets";
	if (isClass _t) then {
		{
			if ((getNumber (_x >> "isPersonTurret")) > 0) then { _n = _n + 1; };
			_n = _n + ([_x] call _fnc_personTurrets);
		} forEach ("true" configClasses _t);
	};
	_n
};
private _seats = (getNumber (_cfg >> "transportSoldier")) + ([_cfg] call _fnc_personTurrets);

// Size. "sizeOf" only answers for a class that already has an object in the mission - for most candidates
// it gave 0, and every size check in the matcher was then skipped (a 16-seat Taru passed as "similar in
// size" to a Hummingbird). Every class is now measured the same way: a plain local model of it is made,
// its bounding sphere read, and it is deleted again. sizeOf is only the fallback if that cannot be done.
private _size = 0;
private _sizeObj = createSimpleObject [_cls, [0, 0, 0], true];
if (!isNull _sizeObj) then {
	// THE SIZE is the longer side of the box round what is SEEN of the vehicle (length, or width if that is more).
	// It was the diameter of the sphere round it, which the game gives wrongly for a model it has not fully
	// loaded: 36 mod vehicles read two-thirds of their size in the first mission of a session and their full
	// size afterwards, and picks changed with it. The box read the same every time, for all 782 classes measured.
	private _bb = 0 boundingBoxReal _sizeObj;
	_size = (abs (((_bb select 1) select 1) - ((_bb select 0) select 1))) max (abs (((_bb select 1) select 0) - ((_bb select 0) select 0)));
	deleteVehicle _sizeObj;
};
if (_size <= 0) then { _size = sizeOf _cls; };

private _profile = [
	_cls, _dom, (getNumber (_cfg >> "isUav")) > 0, _spec, _lvl, _bucket, _cats, _aa,
	_size, _seats, getNumber (_cfg >> "maxSpeed"), getNumber (_cfg >> "armor"),
	getNumber (_cfg >> "maximumLoad"),
	getNumber (_cfg >> "ace_cargo_space"),
	getNumber (_cfg >> "VehicleTransport" >> "Carrier" >> "maxLoadMass"),
	getNumber (_cfg >> "slingLoadMaxCargoMass"),
	// artillery: it has an artillery computer, or the editor lists it under Artillery - or it is a ground
	// vehicle carrying a round with a very wide blast (20 m or more: howitzer shells, artillery rockets and
	// ballistic missiles are there; tank shells, autocannon rounds and anti-tank missiles are far below it).
	// The last is for a launcher with no artillery computer of its own, which read as a plain missile truck.
	(getNumber (_cfg >> "artilleryScanner")) > 0 || {(toLower (getText (_cfg >> "editorSubcategory"))) == "edsubcat_artillery"}
		|| {_dom in ["wheeled", "tracked"] && {_blast >= 20}},
	// a truck (the 18th entry): the game's own truck class. A truck is not offered for a car, or a car for a truck,
	// in the filter's close stages (MCCMK_fnc_matchVehicle).
	_cls isKindOf "Truck_F",
	// how many guided anti-vehicle missiles (the 19th entry - see the head of this file)
	_atgm,
	// the heaviest weapon worked from a gunner seat (the 20th entry - see the head of this file)
	_gunLvl
];
missionNamespace setVariable [_key, _profile];
_profile
