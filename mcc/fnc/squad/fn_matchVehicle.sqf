
params [["_oldCls", "", [""]], ["_pool", [], [[]]], ["_noLift", false, [false]]];
// (_noLift: the original's sling-load lift is not asked for - the supply drop, whose crate comes down on a
//  parachute, so any helicopter can fly it; the closest one is still chosen on everything else)

private _o = [_oldCls] call MCCMK_fnc_vehicleProfile;
if (count _o == 0 || {count _pool == 0}) exitWith {["", -1, 0, 0]};

// the same old class against the same pool always gives the same answer: cache it. (The pool is
// identified by its size and its first and last class - cheap, and a faction's own pool and the override
// pool are never the same list.)
private _poolSig = format ["%1_%2_%3", count _pool, _pool select 0, _pool select ((count _pool) - 1)];
private _cacheKey = format ["MCCMK_mv_%1_%2_%3%4", _oldCls, "", _poolSig, (if (_noLift) then {"_nolift"} else {""})];
private _hit = missionNamespace getVariable [_cacheKey, []];
if (count _hit > 0) exitWith {_hit};

_o params ["", "_oDom", "_oUav", "_oSpec", "_oLvl", "_oBkt", "_oCats", "_oAa", "_oSize", "_oSeats", "_oSpeed", "_oArmor", "_oCargo", "_oAce", "_oViv", "_oLift", ["_oArty", false], ["_oTruck", false], ["_oAtgm", 0], ["_oGunLvl", 0]];
if (_noLift) then { _oLift = 0; };
private _oGround = _oDom in ["wheeled", "tracked"];

private _fam = {
	switch (_this) do {
		case "tracked": {"ground"};
		case "wheeled": {"ground"};
		case "heli": {"rotary"};
		case "plane": {"fixed"};
		case "vtol": {"fixed"};
		case "ship": {"sea"};
		case "sub": {"sea"};
		case "static": {"static"};
		default {"other"};
	}
};
private _brd = {
	switch (_this) do {
		case "tracked": {"ground"};
		case "wheeled": {"ground"};
		case "heli": {"air"};
		case "plane": {"air"};
		case "vtol": {"air"};
		case "ship": {"sea"};
		case "sub": {"sea"};
		case "static": {"static"};
		default {"other"};
	}
};
private _oFam = _oDom call _fam;
private _oBrd = _oDom call _brd;

// [domain mode, function mode, armament mode, air-to-air mode, size tolerance, size ratio cap, drone mode]
//   domain    0 exact | 1 same family | 2 same broad kind
//   function  0 same   | 1 plain only  | 2 any
//   armament  0 same class | 1 same or lighter (armed stays armed) | 2 same or heavier | 3 any
//   air-to-air 0 same role | 1 any
//   size tol  max relative size difference, 0 = not used
//   size cap  max ratio between the two sizes (either way round), 0 = not used
//   drone     0 drone only for a drone | 1 also a fixed-wing drone for a manned fixed-wing aircraft | 2 any
private _stages = [
	[0, 0, 0, 0, 0.45, 0,   0],
	[0, 0, 0, 0, 0,    2.0, 0],
	[1, 0, 0, 0, 0,    3.0, 0],
	[0, 0, 1, 1, 0,    3.0, 0],
	[1, 1, 1, 1, 0,    3.0, 0],
	[1, 1, 2, 1, 0,    3.0, 0],
	[1, 2, 1, 1, 0,    3.0, 1],
	[1, 2, 2, 1, 0,    3.0, 1],
	[1, 2, 3, 1, 0,    0,   1],
	[2, 2, 3, 1, 0,    0,   2]
];
private _floors = missionNamespace getVariable ["MCCMK_MatchFloors", [0.35]];

// ARMED STAYS ARMED BEFORE SEATS ARE KEPT. Stages 0-7 never disarm an armed vehicle; stages 8-9 may. If
// an armed vehicle finds nothing in stages 0-7 only because every armed candidate has too few seats (a
// cannon APC with 9 seats, in a faction whose armed vehicles seat 2), stages 0-7 are run once more WITHOUT
// the seat floor before 8-9 are tried: it gets the closest armed vehicle, not an unarmed truck with
// enough seats. Size, cargo, lift, the armour band and the shortfall cap all still apply. Such a match is
// reported as stage 10-17 (10 + the stage). Each row gains two entries: seat floor on/off, its own stage number.
private _stagesRun = [];
{ if (_forEachIndex <= 7) then { _stagesRun pushBack (_x + [true, _forEachIndex]); }; } forEach _stages;
if (_oBkt > 0) then {
	{ if (_forEachIndex <= 7) then { _stagesRun pushBack (_x + [false, _forEachIndex]); }; } forEach _stages;
};
{ if (_forEachIndex > 7) then { _stagesRun pushBack (_x + [true, _forEachIndex]); }; } forEach _stages;

private _profiles = (_pool arrayIntersect _pool) apply {[_x] call MCCMK_fnc_vehicleProfile};
_profiles = _profiles select {count _x > 0};

// VEHICLE-CARRYING is only asked for when the pool has a vehicle that can carry vehicles at all: with none,
// a flatbed found nothing whatever and stayed as it was - it now takes the nearest plain truck.
private _poolHasViv = (_profiles findIf {(_x param [14, 0]) > 0}) >= 0;
// A SUPPORT VEHICLE (fuel / repair / ammo / medical) is matched on its job: the seat floor and the ACE cargo
// floor are not asked of a candidate that does the job - a medical carrier with 3 seats stands in for a medical
// truck with 16.
private _oSupport = _oSpec != "";

private _best = "";
private _bestStage = -1;
private _bestScore = 1e9;
private _bestFloor = 0;

{
	if (_best == "") then {
		private _f = _x;
		{
			if (_best == "") then {
				_x params ["_dm", "_sm", "_am", "_aam", "_tol", "_cap", "_um", "_seatFloor", "_stageIndex"];
				{
					_x params ["_cCls", "_cDom", "_cUav", "_cSpec", "_cLvl", "_cBkt", "_cCats", "_cAa", "_cSize", "_cSeats", "_cSpeed", "_cArmor", "_cCargo", "_cAce", "_cViv", "_cLift", ["_cArty", false], ["_cTruck", false], ["_cAtgm", 0], ["_cGunLvl", 0]];
					private _ok = true;
					// artillery is only ever a match for artillery (any stage)
					if (_cArty && {!_oArty}) then {_ok = false;};
					// and among static weapons the other way too: a mortar is only replaced by a mortar
					if (_oArty && {!_cArty} && {_oDom == "static"}) then {_ok = false;};

					// domain
					if (_dm == 0 && {_cDom != _oDom}) then {_ok = false;};
					if (_dm == 1 && {(_cDom call _fam) != _oFam}) then {_ok = false;};
					if (_dm == 2 && {(_cDom call _brd) != _oBrd}) then {_ok = false;};
					// a drone only for a drone - except a fixed-wing drone for a manned fixed-wing aircraft (mode 1) and the last stage (mode 2)
					if (_ok && {_cUav != _oUav}) then {
						switch (_um) do {
							case 0: {_ok = false;};
							case 1: { if (!(_oFam == "fixed" && {(_cDom call _fam) == "fixed"} && {_cUav} && {!_oUav})) then {_ok = false;}; };
							default {};
						};
					};
					// function
					if (_ok && {_sm == 0} && {_cSpec != _oSpec}) then {_ok = false;};
					if (_ok && {_sm == 1} && {_cSpec != ""}) then {_ok = false;};
					if (_ok && {_oSpec != ""} && {_cSpec != _oSpec}) then {
						if (((_oSpec splitString "") findIf {!(_x in _cSpec)}) >= 0) then {_ok = false;};
					};
					// armament
					if (_ok) then {
						switch (_am) do {
							case 0: { if (_cBkt != _oBkt) then {_ok = false;}; };
							case 1: { if (_cBkt > _oBkt || {_oBkt > 0 && {_cBkt < 1}}) then {_ok = false;}; };
							case 2: { if (_oBkt > 0 && {_cBkt < 1}) then {_ok = false;}; };
							default {};
						};
					};
					// air-to-air role
					if (_ok && {_aam == 0} && {_cAa != _oAa}) then {_ok = false;};
					// size
					if (_ok && {_tol > 0} && {_oSize > 0} && {_cSize > 0}) then {
						if (((abs (_cSize - _oSize)) / _oSize) > _tol) then {_ok = false;};
					};
					if (_ok && {_cap > 0} && {_oSize > 0} && {_cSize > 0}) then {
						if (((_cSize / _oSize) max (_oSize / _cSize)) > _cap) then {_ok = false;};
					};
					// capability floors: keep a fraction of what the original could do (a coarse reject - the score ranks)
					if (_ok && {_oSize > 0} && {_cSize > 0} && {_cSize < (_f * _oSize)}) then {_ok = false;};
					if (_ok && {_seatFloor} && {!_oSupport} && {_oSeats >= 3} && {_cSeats < (floor (_f * _oSeats))}) then {_ok = false;};
					if (_ok && {_oLift >= 2000} && {_cLift < (_f * _oLift)}) then {_ok = false;};
					if (_ok && {_oGround}) then {
						if (_oCargo > 0 && {_cCargo < (_f * _oCargo)}) then {_ok = false;};
						if (_ok && {!_oSupport} && {_oAce > 0} && {_cAce < (_f * _oAce)}) then {_ok = false;};
						if (_ok && {_poolHasViv} && {_oViv > 0} && {_cViv < (_f * _oViv)}) then {_ok = false;};
					};

					// A TRUCK IS NOT A CAR (ground, stages 0-5): a truck is not given for a car, nor a car for a truck -
					// only the looser stages cross that line.
					if (_ok && {_oGround} && {_stageIndex < 6} && {_cTruck isNotEqualTo _oTruck}) then {_ok = false;};

					// armour band (ground, stages 0-5): protected stays protected
					if (_ok && {_oGround} && {_stageIndex < 6} && {_oArmor > 0} && {_cArmor > 0}) then {
						if (((_cArmor / _oArmor) max (_oArmor / _cArmor)) > 2.7) then {_ok = false;};   // (2.7, was 2.5: a light protected car - armour 80 - may take a jeep of 30; 3x and over stays out)
					};
					// shortfall: how much worse it is on what the original could do (summed, proportional)
					private _short = 0;
					if (_ok) then {
						if (_oSeats > 0 && {_cSeats < _oSeats}) then {_short = _short + (3 * (1 - (_cSeats / _oSeats)));};
						if (_oCargo > 0 && {_oGround} && {_cCargo < _oCargo}) then {_short = _short + (3 * (1 - (_cCargo / _oCargo)));};
						if (_oLift > 0 && {_cLift < _oLift}) then {_short = _short + (3 * (1 - (_cLift / _oLift)));};
						if (_oSize > 0 && {_cSize > 0} && {_cSize < _oSize}) then {_short = _short + (1.5 * (1 - (_cSize / _oSize)));};
						if (_short > 5) then {_ok = false;};
					};

					if (_ok) then {
						private _s = _short;
						_s = _s + (0.5 * (abs (_cLvl - _oLvl)));
						// over-armed is worse than under-armed
						_s = _s + (0.6 * ((_cBkt - _oBkt) max 0)) + (0.3 * ((_oBkt - _cBkt) max 0));
						{ if ((_cCats select _forEachIndex) != _x) then {_s = _s + 0.4;}; } forEach _oCats;
						if (_cAa != _oAa) then {_s = _s + 0.8;};
						// firepower: how many guided anti-vehicle missiles each carries, closest by ratio (a gunship with 8-16
						// against an armed transport with 4, an anti-tank car against a machine-gun car with none)
						if (!(_oAtgm isEqualType 0)) then {_oAtgm = 0;};
						if (!(_cAtgm isEqualType 0)) then {_cAtgm = 0;};
						_s = _s + (1 * (abs (ln ((_cAtgm + 1) / (_oAtgm + 1)))));
						// who works the heavy weapons: a gunner seat (gunship, APC) or the pilot / door guns only (armed
						// transport) - 0.5 for each level of difference in the heaviest weapon worked from a gunner seat
						if (!(_oGunLvl isEqualType 0)) then {_oGunLvl = 0;};
						if (!(_cGunLvl isEqualType 0)) then {_cGunLvl = 0;};
						_s = _s + (0.5 * (abs (_cGunLvl - _oGunLvl)));
						if (_oSize > 0 && {_cSize > 0}) then {_s = _s + (2 * (abs (ln (_cSize / _oSize))));};
						_s = _s + (1.5 * (abs (ln ((_cSeats + 1) / (_oSeats + 1)))));
						if (_oSpeed > 0 && {_cSpeed > 0}) then {_s = _s + (1.2 * (abs (ln (_cSpeed / _oSpeed))));};
						// armour: an MRAP is not a soft-skinned truck (read from config before, never scored)
						_s = _s + (0.8 * (abs (ln ((_cArmor + 1) / (_oArmor + 1)))));
						// closest cargo and lift within the floors
						if (_oCargo > 0 && {_oGround}) then {_s = _s + (0.6 * (abs (ln ((_cCargo + 1) / (_oCargo + 1)))));};
						if (_oLift > 0) then {_s = _s + (0.6 * (abs (ln ((_cLift + 1) / (_oLift + 1)))));};
						// (the proportional shortfall, _short, is already in the score: 53% of the trunk is worse than 90%)
						if (_cDom != _oDom) then {_s = _s + 1;};
						if (_cSpec != _oSpec) then {_s = _s + 1.5;};
						// a dynamic-loadout class only wins a tie against its plain sibling
						if (((toLower _cCls) find "dynamicloadout") >= 0 && {((toLower _oldCls) find "dynamicloadout") < 0}) then {_s = _s + 0.02;};

						if (_s < _bestScore) then {
							_bestScore = _s;
							_best = _cCls;
							_bestStage = if (_seatFloor) then {_stageIndex} else {10 + _stageIndex};
							_bestFloor = _f;
						};
					};
				} forEach _profiles;
				// (a stage that found nothing leaves _best empty, so the next, looser stage runs)
				if (_best == "") then {_bestScore = 1e9;};
			};
		} forEach _stagesRun;
	};
} forEach _floors;

private _result = [_best, _bestStage, _bestScore, _bestFloor];
missionNamespace setVariable [_cacheKey, _result];
_result
