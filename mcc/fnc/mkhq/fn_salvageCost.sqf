/*
	MCCMK_fnc_salvageCost - what a vehicle is worth for salvage and for selling a captured one: MCC's vehicle price formula
	(MCC_fnc_getVehicleCost - the RTS buy prices keep using that), with its own base per kind and two add-ons capped:
	  base: plane 12000, helicopter 8000, tank 4000, other land vehicles 2000; drones 1000; boats - inflatable (unarmed,
	  under 7 m) 800, other unarmed 1500, armed 3000; parachutes are worth nothing.
	  top speed counted up to 200 km/h, ammunition storage up to 100 slots (so jets and ammo trucks don't run away).
	[vehicle] -> cost (0 = worth nothing)
*/
params [["_v", objNull, [objNull]]];
if (isNull _v || {_v isKindOf "ParachuteBase"}) exitWith {0};
private _cfg = configOf _v;
// every weapon on it (hull and turrets), horns and smoke launchers aside
private _wpns = getArray (_cfg >> "weapons");
{_wpns append (getArray (_x >> "weapons"))} forEach ("true" configClasses (_cfg >> "Turrets"));
_wpns = _wpns select {private _w = toLower _x; (_w find "horn") < 0 && {(_w find "smokelauncher") < 0} && {(_w find "fake") < 0}};
private _base = switch (true) do {
	case (getNumber (_cfg >> "isUav") == 1): {1000};
	case (_v isKindOf "Ship"): {
		if (count _wpns > 0) then {3000} else {
			private _bb = boundingBoxReal _v;
			if ((((_bb select 1) select 1) - ((_bb select 0) select 1)) < 7) then {800} else {1500}
		}
	};
	case (_v isKindOf "Plane"): {12000};
	case (_v isKindOf "Helicopter"): {8000};
	case (_v isKindOf "Tank"): {4000};
	default {2000};
};
private _c = _base * (2 - (((1 - ((getNumber (_cfg >> "accuracy")) min 3)) max 0.1)));
_c = _c + (getNumber (_cfg >> "armor")) * _base * 0.005;
_c = _c + (getNumber (_cfg >> "transportSoldier")) * _base * 0.03;
if (getNumber (_cfg >> "laserScanner") > 0) then {_c = _c * 1.15};
if (getNumber (_cfg >> "nightVision") > 0) then {_c = _c * 1.05};
if (getNumber (_cfg >> "nvScanner") > 0) then {_c = _c * 1.05};
_c = _c + ((getNumber (_cfg >> "radarType")) max 1) * _base * 0.08;
_c = _c + ((((getNumber (_cfg >> "transportMaxMagazines")) max 1)) min 100) * _base * 0.005;
_c = _c + ((((getNumber (_cfg >> "maxSpeed")) max 1)) min 200) * _base * 0.005;
_c = _c + (count _wpns) * _base * 0.15;
floor (_c * 0.7)
