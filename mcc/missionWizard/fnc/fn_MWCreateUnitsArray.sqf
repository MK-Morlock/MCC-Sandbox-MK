//======================================================MCC_fnc_MWCreateUnitsArray=========================================================================================================
// Create units array by type
// Example:[_] call MCC_fnc_MWCreateUnitsArray;
// Creates unit arrays by vehicle class
//	MCC_MWunitsArrayMen = [];			//vehicleClass = "Men";
//	MCC_MWunitsArrayMenDiver = []; 		// vehicleClass = "MenDiver";
//	MCC_MWunitsArrayMenRecon = []; 		// vehicleClass = "MenRecon";
//	MCC_MWunitsArrayMenSniper = []; 	// vehicleClass = "MenSniper";
//	MCC_MWunitsArrayMenSupport = []; 	// vehicleClass = "MenSupport";
//	MCC_MWunitsArrayMenStory = []; 		//  vehicleClass = "MenStory";
//
//	MCC_MWunitsArrayCar = []; 			// vehicleClass = "Car";
//	MCC_MWunitsArrayArmored = []; 		// vehicleClass = "Armored";
//	MCC_MWunitsArrayAir = []; 			// vehicleClass = "Air";
//	MCC_MWunitsArrayAutonomous = []; 	// vehicleClass = "Autonomous";
//	MCC_MWunitsArraySupport = []; 		// vehicleClass = "Support";
//
//	MCC_MWunitsArrayShip = []; 			// vehicleClass = "Ship";
//	MCC_MWunitsArraySubmarine = []; 	// vehicleClass = "Submarine";
//	MCC_MWunitsArrayStatic = []; 		// vehicleClass = "Static";
//========================================================================================================================================================================================
private _CfgVehicles = configNull;
private _type = "";
private _i = 0;
private _CfgVehicle = configNull;
private _vehicleClass = "";
private _simulation = "";
private _simTypesUnits = [];

params [["_faction", "", [""]], ["_side", sideUnknown, [sideUnknown, ""]], ["_mode", 2, [0]]];

// _side is polymorphic across callers - some pass a real Side (e.g. fn_campaignInit.sqf's
// `param [2, east]`), others pass mcc_sidename, which is a STRING ("WEST"/"EAST"/"GUER"/"CIV",
// see mcc_factions.sqf). Normalize once here so the rest of the function can always rely on
// _side being a genuine Side value.
if (typeName _side == "STRING") then {
	_side = switch (toUpper _side) do
	{
		case "EAST": {east};
		case "WEST": {west};
		case "GUER": {resistance};
		default {civilian};
	};
};

if (_faction == "") then
{
	while {isNil "mcc_faction"} do {sleep 1};
	_faction = mcc_faction;
	// mcc_sidename is a STRING ("WEST"/"EAST"/"GUER"/"CIV", see mcc_factions.sqf), not a
	// real Side - convert it properly rather than assign the string directly into a
	// variable that gets pushed into the unit arrays as a genuine Side value below.
	_side	 = switch (toUpper mcc_sidename) do
	{
		case "EAST": {east};
		case "WEST": {west};
		case "GUER": {resistance};
		default {civilian};
	};
};


MCC_MWunitsArrayMen = [];			//vehicleClass = "Men";
MCC_MWunitsArrayMenDiver = []; 		// vehicleClass = "MenDiver";
MCC_MWunitsArrayMenRecon = []; 		// vehicleClass = "MenRecon";
MCC_MWunitsArrayMenSniper = []; 	// vehicleClass = "MenSniper";
MCC_MWunitsArrayMenSupport = []; 	// vehicleClass = "MenSupport";
MCC_MWunitsArrayMenStory = []; 		//  vehicleClass = "MenStory";

MCC_MWunitsArrayCar = []; 			// vehicleClass = "Car";
MCC_MWunitsArrayArmored = []; 		// vehicleClass = "Armored";
MCC_MWunitsArrayAir = []; 			// vehicleClass = "Air";
MCC_MWunitsArrayHeli = []; 			// vehicleClass = "Air";
MCC_MWunitsArrayAutonomous = []; 	// vehicleClass = "Autonomous";
MCC_MWunitsArraySupport = []; 		// vehicleClass = "Support";

MCC_MWunitsArrayShip = []; 			// vehicleClass = "Ship";
MCC_MWunitsArraySubmarine = []; 	// vehicleClass = "Submarine";
MCC_MWunitsArrayStatic = []; 		// vehicleClass = "Static";


//(MK) From the faction's pools (MCCMK_fnc_pools - MCC MK's single faction filter, based on the MK Faction Framework's
// sorting): its own content, then official DLC, then all, by this generator's content setting; then a sibling faction's;
// then - with the "Vanilla vehicle fallback" setting on (the default) - the side's vanilla vehicle for a kind it has
// none of (MCCMK_fnc_poolOwn). The lists keep their shape:
// [type, class, side, [name, picture]]. (The diver, story, recon, sniper, support-soldier and submarine lists aren't
// read by anything; they stay empty.)
private _entry = {
	params ["_type", "_cls"];
	[_type, _cls, _side, [getText (configFile >> "CfgVehicles" >> _cls >> "displayName"), getText (configFile >> "CfgVehicles" >> _cls >> "picture")]]
};
private _fill = {
	params ["_kinds", "_type", ["_filter", {true}]];
	private _l = [];
	{_l append ([_faction, _x, _mode] call MCCMK_fnc_poolOwn)} forEach _kinds;
	((_l arrayIntersect _l) select _filter) apply {[_type, _x] call _entry}
};
// the soldiers: the armed ones (more than two weapons) when there are any
private _inf = [_faction, "Inf", _mode] call MCCMK_fnc_poolOwn;
private _armedInf = _inf select {count (getArray (configFile >> "CfgVehicles" >> _x >> "weapons")) > 2};
MCC_MWunitsArrayMen = ([_inf, _armedInf] select (_armedInf isNotEqualTo [])) apply {["LAND", _x] call _entry};
MCC_MWunitsArrayCar = [["Car", "Motorcycle"], "LAND"] call _fill;
MCC_MWunitsArrayArmored = [["Tank", "APC", "AA"], "LAND"] call _fill;	// no artillery: it isn't armour on patrol (the artillery features have their own lists)
MCC_MWunitsArraySupport = [["Utility"], "LAND"] call _fill;
MCC_MWunitsArrayAir = [["Plane", "Heli"], "AIR"] call _fill;
MCC_MWunitsArrayHeli = [["Heli"], "AIR"] call _fill;
MCC_MWunitsArrayAutonomous = [["UAV"], "AIR"] call _fill;
MCC_MWunitsArrayShip = [["Ship"], "WATER", {!(_x isKindOf "SDV_01_base_F")}] call _fill;
MCC_MWunitsArraySubmarine = [["Ship"], "WATER", {_x isKindOf "SDV_01_base_F"}] call _fill;
MCC_MWunitsArrayStatic = [["Static", "Mortar"], "LAND"] call _fill;
["INFO", "MCC_fnc_MWCreateUnitsArray", "%1 (content %2): men %3, cars %4, armour %5, support %6, air %7, drones %8, boats %9, statics %10", [_faction, _mode, count MCC_MWunitsArrayMen, count MCC_MWunitsArrayCar, count MCC_MWunitsArrayArmored, count MCC_MWunitsArraySupport, count MCC_MWunitsArrayAir, count MCC_MWunitsArrayAutonomous, count MCC_MWunitsArrayShip, count MCC_MWunitsArrayStatic]] call MCC_fnc_log;

publicvariableserver "MCC_MWunitsArrayMen";
publicvariableserver "MCC_MWunitsArrayMenDiver";
publicvariableserver "MCC_MWunitsArrayMenRecon";
publicvariableserver "MCC_MWunitsArrayMenSniper";
publicvariableserver "MCC_MWunitsArrayMenSupport";
publicvariableserver "MCC_MWunitsArrayCar";
publicvariableserver "MCC_MWunitsArrayArmored";
publicvariableserver "MCC_MWunitsArrayAir";
publicvariableserver "MCC_MWunitsArraySupport";
publicvariableserver "MCC_MWunitsArrayShip";
publicvariableserver "MCC_MWunitsArraySubmarine";
publicvariableserver "MCC_MWunitsArrayStatic";
publicvariableserver "MCC_MWunitsArrayAutonomous";

true

