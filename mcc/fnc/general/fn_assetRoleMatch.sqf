/*================================================================== MCC_fnc_assetRoleMatch ==================================================================
	Does a CfgVehicles class fit an asset role? Shared by MCC_fnc_factionVehicles and the console Assets page.

	Vehicle and unit roles
		tank        tracked armour that is neither artillery nor anti-air
		aa          anti-air (editor category Anti-Air, air-lock missiles, or an AA name)
		artillery   has an artillery computer (self-propelled guns, MLRS, mortars)
		air         helicopters and planes (no parachutes)
		podCarrier  the Taru family (carries the drop pods)
		gunship     planes with a gunner-operated gun
		cargoHeli   helicopters that can sling-load 4 t or more
		transport   helicopters and planes with 8 or more passenger seats (paradrops)
		officer     soldiers named or categorised as officer, commander, colonel or general
	Object roles (buildings and props, any faction)
		cache       ammo crates and boxes
		radio       radio towers, antennas and masts
		radar       radars
		fuel        fuel tanks and fuel depots
		intel       laptops, files, documents, photos, phones, tablets, maps, suitcases

	<IN>	0: CONFIG class
			1: STRING role
	<OUT>	BOOL
==============================================================================================================================================================*/
params [["_cfg", configNull, [configNull]], ["_role", "", [""]]];
if (!isClass _cfg) exitWith {false};
private _class = configName _cfg;
private _text = toLower (_class + " " + getText (_cfg >> "displayName") + " " + getText (_cfg >> "editorSubcategory"));
private _has = {params ["_words"]; (_words findIf {_text find _x >= 0}) >= 0};
private _isVehicle = _class isKindOf "AllVehicles";
//Gear placed as objects (helmets, vests, uniforms, belts, glasses, backpacks, weapons, ground items) is never an asset
private _isGear = (["Item_Base_F", "Weapon_Base_F", "Bag_Base", "Headgear_Base_F", "Vest_Base_F", "Uniform_Base", "Glasses_Base_F", "WeaponHolder", "WeaponHolderSimulated", "NVGoggles_Base_F"] findIf {_class isKindOf _x}) >= 0
	|| {toLower getText (_cfg >> "editorCategory") in ["edcat_equipment", "edcat_weapons"]}
	|| {(toLower getText (_cfg >> "vehicleClass")) in ["itemsheadgear", "itemsvests", "itemsuniforms", "weaponsprimary", "weaponssecondary", "weaponshandguns", "weaponaccessories", "backpacks", "items"]}
	|| {!_isVehicle && {[["helmet", "vest", "uniform", "belt", "beret", "cap ", "hat ", "glasses", "goggles", "bandana", "balaclava", "backpack", "rucksack", "holster", "webbing", "chest rig", "plate carrier"]] call {params ["_w"]; (_w findIf {(toLower getText (_cfg >> "displayName")) find _x >= 0}) >= 0}}};
if (_isGear && {!(toLower _role in ["officer"])}) exitWith {false};

private _isArty = {getNumber (_cfg >> "artilleryScanner") == 1};
private _isAA = {
	(toLower getText (_cfg >> "editorSubcategory") == "edsubcat_aas")
	|| {[["anti-air", " aa", "aa ", "flak", "zsu", "shilka", "tunguska", "gepard", "cheetah", "tigris"]] call _has}
	|| {
		private _mags = [];
		{
			_mags append getArray (_x >> "magazines");
			{_mags append getArray (_x >> "magazines")} forEach ("true" configClasses (_x >> "Turrets"));
		} forEach ("true" configClasses (_cfg >> "Turrets"));
		(_mags findIf {
			private _ammo = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo");
			(configName _ammo) isKindOf ["MissileCore", configFile >> "CfgAmmo"] && {getNumber (_ammo >> "airLock") >= 2}
		}) >= 0
	}
};

switch (toLower _role) do {
	case "artillery": {(_class isKindOf "LandVehicle") && {call _isArty}};
	case "aa": {(_class isKindOf "LandVehicle") && {!(call _isArty)} && {call _isAA}};
	case "tank": {(_class isKindOf "Tank") && {!(_class isKindOf "StaticWeapon")} && {!(call _isArty)} && {!(call _isAA)}};
	case "air": {(_class isKindOf "Air") && {!(_class isKindOf "ParachuteBase")}};
	case "podcarrier": {_class isKindOf "Heli_Transport_04_base_F"};
	case "gunship": {(_class isKindOf "Plane") && {"AC-130" in ([_class] call MCC_fnc_casAllowedTypes)}};
	case "cargoheli": {(_class isKindOf "Helicopter") && {getNumber (_cfg >> "slingLoadMaxCargoMass") >= 4000}};
	case "transport": {(_class isKindOf "Air") && {!(_class isKindOf "ParachuteBase")} && {([_class, "allCargo"] call MCC_fnc_crewCount) >= 8}};
	case "officer": {(_class isKindOf "CAManBase") && {[["officer", "commander", "colonel", "general"]] call _has}};
	case "cache": {!_isVehicle && {(_class isKindOf "ReammoBox_F") || {_class isKindOf "ReammoBox"} || {[["ammo", "crate", "weapons box", "cache"]] call _has}}};
	case "radio": {!_isVehicle && {[["tower", "antenna", "mast", "radio"]] call _has}};
	case "radar": {[["radar"]] call _has};
	case "fuel": {!_isVehicle && {[["fuel", "reservoir"]] call _has || {_class find "_Tank_" >= 0 || {toLower _class find "smalltank" >= 0} || {toLower _class find "bigtank" >= 0}}}};
	case "intel": {!_isVehicle && {[["laptop", "file", "document", "photo", "phone", "tablet", "map", "suitcase", "briefcase", "intel"]] call _has}};
	default {false};
}
