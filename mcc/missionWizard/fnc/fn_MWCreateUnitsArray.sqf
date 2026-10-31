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

_simTypesUnits 	= ["soldier", "car","carx", "motorcycle", "tank", "helicopter", "airplane", "ship", "parachute","helicopterX","shipx","shipX","tankX","submarinex","airplanex","helicopterrtd"];
_CfgVehicles 		= [_faction] call MCC_fnc_factionClasses;	//only the faction public classes, picked by the engine (was every class, one by one)

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


for "_i" from 0 to (count _CfgVehicles - 1) do
{
	_CfgVehicle = _CfgVehicles select _i;
	if (isclass _CfgVehicle) then
	{
		//Keep going when it is a public entry
		if ((getNumber(_CfgVehicle >> "scope") == 2)) then
		{
			_vehicleDisplayName 	= getText(_CfgVehicle >> "displayname");
			_cfgclass 				= (configName (_CfgVehicle));
			_cfgFaction 			= getText(_CfgVehicle >> "faction");
			_simulation 			= getText(_CfgVehicle >> "simulation");
			_vehicleDisplayName		= [_vehicleDisplayName, gettext(_CfgVehicle >> "picture")];
			_vehicleclass			= "";

			private _mdl = toLower getText (_CfgVehicle >> "model");
			private _dnr = getText (_CfgVehicle >> "displayName");
			private _dnl = toLower (if ((_dnr select [0, 1]) == "$") then {localize (_dnr select [1])} else {_dnr});
			private _lcc = toLower _cfgclass;
			private _isMan = toLower _simulation in ["soldier", "soldierx"];
			private _isTemplate = ((_lcc select [((count _lcc) - 5) max 0]) == "_base") || {(_lcc find "_base_") >= 0};
			if (_isTemplate) then {["DEBUG", "spawn lists", "template class left out: %1", [_cfgclass]] call MCC_fnc_log};
			private _junk = _isTemplate || {!_isMan && {_cfgclass isKindOf "Car"} && {[_cfgclass] call MCC_fnc_isUtilityVehicle}} || {(_mdl find "invisible") >= 0} || {(_dnl find "invisible") >= 0}
				|| {(["invisibletarget", "targetvehicle", "target_vehicle", "targetsoldier"] findIf {(_lcc find _x) >= 0}) >= 0}
				|| {_mdl in ["", "\a3\weapons_f\empty", "\a3\weapons_f\empty.p3d"]}
				|| {(_mdl find "pod_heli_transport_04") >= 0} || {_cfgclass isKindOf "Pod_Heli_Transport_04_base_F"} || {_cfgclass isKindOf "Slingload_base_F"}
				|| {_isMan && {(["virtual", "uav_ai", "uavai", "dummy"] findIf {((_lcc find _x) >= 0) || {(_dnl find _x) >= 0}}) >= 0}}
				|| {!_isMan && {getNumber (_CfgVehicle >> "hasDriver") == 0} && {getNumber (_CfgVehicle >> "isUav") != 1} && {!(_cfgclass isKindOf "StaticWeapon")}};
			if ((_simulation in _simTypesUnits) && {!_junk} && {[_CfgVehicle, _faction, _mode] call MCC_fnc_contentAllowed}) then
			{
				if (toUpper(_cfgFaction) == toUpper _faction) then
				{
					_vehicleclass = [_CfgVehicle] call MCC_fnc_unitCategory;	//mod vehicleClass names mapped to MCCs (GitHub #48)
					if ((_vehicleclass in ["Car","Armored","Support","Air","Ship","Submarine"]) && {(getNumber (_CfgVehicle >> "hasDriver") == 0 && {getNumber (_CfgVehicle >> "isUav") != 1}) || {_cfgclass isKindOf "Pod_Heli_Transport_04_base_F"} || {_cfgclass isKindOf "Slingload_base_F"} || {((toLower getText (_CfgVehicle >> "model")) find "pod_heli_transport_04") >= 0}}) then {_vehicleclass = ""};
					if (_vehicleclass in ["Men","MenDiver","MenRecon","MenSniper","MenSupport","MenStory","Car","Armored","Air","Autonomous","Support","Ship","Submarine","Static"]) then
					{
						switch (toLower(_vehicleclass)) do
						{
							case "men"		: 	{
													_type="LAND";
													if (count(getArray (_CfgVehicle >> "weapons")) > 2) then {
														MCC_MWunitsArrayMen pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
													};
												};

							case "mendiver"	: 	{
													_type="WATER";
													if (count(getArray (_CfgVehicle >> "weapons")) > 2) then {
														MCC_MWunitsArrayMenDiver pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
													};
												};

							case "menrecon"	: 	{
													_type="LAND";
													if (count(getArray (_CfgVehicle >> "weapons")) > 2) then {
														MCC_MWunitsArrayMenRecon pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
													};
												};

							case "mensniper": 	{
													_type="LAND";
													if (count(getArray (_CfgVehicle >> "weapons")) > 2) then {
														MCC_MWunitsArrayMenSniper pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
													};
												};

							case "mensupport": 	{
													_type="LAND";
													if (count(getArray (_CfgVehicle >> "weapons")) > 2) then {
														MCC_MWunitsArrayMenSupport pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
													};
												};

							case "car"		: 	{
													_type="LAND";
													MCC_MWunitsArrayCar pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
												};

							case "armored"	: 	{
													_type="LAND";
													MCC_MWunitsArrayArmored pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
												};

							case "support"		: 	{
													_type="LAND";
													MCC_MWunitsArraySupport pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
												};

							case "air"		: 	{
													_type="AIR";
													if (_simulation == "helicopterrtd") then {
														MCC_MWunitsArrayHeli pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
													} else {
														MCC_MWunitsArrayAir pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
													};
												};

							case "ship"		: 	{
													_type="WATER";
													MCC_MWunitsArrayShip pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
												};

							case "submarine"	: 	{
													_type="WATER";
													MCC_MWunitsArraySubmarine pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
												};

							case "static"	: 	{
													_type="LAND";
													MCC_MWunitsArrayStatic pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
												};

						};
					}
					else
					{
						switch (toLower(_simulation)) do
						{
							case "soldier":
							{
								_type="LAND";
								if (count(getArray (_CfgVehicle >> "weapons")) > 2) then {
									MCC_MWunitsArrayMen pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
								};
							};

							case "car":
							{
								_type="LAND";
								MCC_MWunitsArrayCar pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};

							case "carx":
							{
								_type="LAND";
								MCC_MWunitsArrayCar pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "motorcycle":
							{
								_type="LAND";
								MCC_MWunitsArrayCar pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "tank":
							{
								_type="LAND";
								MCC_MWunitsArrayArmored pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "tankx":
							{
								_type="LAND";
								MCC_MWunitsArrayArmored pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "helicopter":
							{
								_type="AIR";
								MCC_MWunitsArrayAir pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "helicopterx":
							{
								_type="AIR";
								MCC_MWunitsArrayAir pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "airplane":
							{
								_type="AIR";
								MCC_MWunitsArrayAir pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "airplanex":
							{
								_type="AIR";
								MCC_MWunitsArrayAir pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "ship":
							{
								_type="WATER";
								MCC_MWunitsArrayShip pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "shipx":
							{
								_type="WATER";
								MCC_MWunitsArrayShip pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
							case "submarinex":
							{
								_type="WATER";
								MCC_MWunitsArraySubmarine pushBack [_type,_cfgclass,_side,_vehicleDisplayName];
							};
						};
					};
				};
			};
		};
	};
};

if (_mode < 2) then {
	private _names = ["MCC_MWunitsArrayMen", "MCC_MWunitsArrayMenDiver", "MCC_MWunitsArrayMenRecon", "MCC_MWunitsArrayMenSniper", "MCC_MWunitsArrayMenSupport", "MCC_MWunitsArrayMenStory", "MCC_MWunitsArrayCar", "MCC_MWunitsArrayArmored", "MCC_MWunitsArrayAir", "MCC_MWunitsArrayHeli", "MCC_MWunitsArrayAutonomous", "MCC_MWunitsArraySupport", "MCC_MWunitsArrayShip", "MCC_MWunitsArraySubmarine", "MCC_MWunitsArrayStatic"];
	private _kept = _names apply {+(missionNamespace getVariable [_x, []])};
	[_faction, _side, 2] call MCC_fnc_MWCreateUnitsArray;
	{
		private _f = _kept select _forEachIndex;
		if (count _f > 0 || {count (missionNamespace getVariable [_x, []]) == 0}) then {
			missionNamespace setVariable [_x, _f];
		} else {
			["INFO", "MCC_fnc_MWCreateUnitsArray", "%1: nothing left in %2 with the content filter - using all content", [_faction, _x]] call MCC_fnc_log;
		};
	} forEach _names;
};

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

