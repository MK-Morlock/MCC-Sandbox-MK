params [["_cfg", configNull, [configNull]], ["_cat", "", [""]]];
private _n = " " + (toLower ((configName _cfg) + " " + (getText (_cfg >> "name")))) + " ";
_n = ((_n splitString "_-()[],./") joinString " ");
private _c = toLower _cat;
private _units = "true" configClasses _cfg;
private _vehicles = (_units apply {getText (_x >> "vehicle")}) select {!(_x isKindOf "CAManBase")};
private _has = { params ["_words"]; (_words findIf {(_n find _x) >= 0}) >= 0 };
if (count _vehicles > 0 || {(["motor", "mechan", "armor", "armour", "air", "naval", "boat", "support"] findIf {(_c find _x) >= 0}) >= 0}) exitWith {
	switch (true) do {
		case ((["air", "heli", "plane"] findIf {(_c find _x) >= 0}) >= 0 || {(_vehicles findIf {_x isKindOf "Air"}) >= 0}): {"Air"};
		case ((["naval", "boat"] findIf {(_c find _x) >= 0}) >= 0 || {(_vehicles findIf {_x isKindOf "Ship"}) >= 0}): {"Naval"};
		case ((["armor", "armour"] findIf {(_c find _x) >= 0}) >= 0): {"Armored"};
		case ((_c find "mechan") >= 0 || {(_vehicles findIf {_x isKindOf "Tank"}) >= 0}): {"Mechanized"};
		case ((_c find "support") >= 0): {"Support"};
		default {"Motorized"};
	}
};
switch (true) do {
	case ([[" at ", "anti tank", "antitank", " lat ", " mat ", " hat "]] call _has): {"AT Team"};
	case ([[" aa ", "anti air", "antiair", "manpad"]] call _has): {"AA Team"};
	case ([["sniper", "marksman", "sharpshoot"]] call _has): {"Sniper Team"};
	case ([["recon", " sf ", "special", "spec ops", "specops", "diver", "pathfinder"]] call _has || {(_c find "spec") >= 0}): {"Recon Team"};
	case ([["weapons", " wpn ", "support squad", "heavy"]] call _has): {"Weapons Squad"};
	case ([["sentry", "sentries", "guard"]] call _has): {"Sentry"};
	case ([["patrol"]] call _has): {"Patrol"};
	case ([["fire team", "fireteam", " ft ", "team"]] call _has): {"Fire Team"};
	case ([["squad", "section", "platoon"]] call _has): {"Squad"};
	case (count _units <= 2): {"Sentry"};
	case (count _units <= 5): {"Fire Team"};
	default {"Squad"};
}
