/*
	MCCMK_fnc_pools - MCC MK's single faction filter: a faction's units and vehicles sorted into pools, built ONCE per faction
	(and content setting) and kept for the mission. Based on the MK Faction Framework's pool design and sorting rules (credit:
	MK), with MCC MK's own fuller chain for each pool:
	  1. the content setting: the faction, its DLC relatives, mods' additions or the whole side (MCCMK_fnc_scopeFactions);
	  2. a pool still empty: a faction of its family (MCCMK_fnc_factionFamily - FIA from FIA, CSAT from CSAT Pacific...);
	  3. still empty, for VEHICLE kinds only: the side's vanilla vehicle (soldiers and crews are never vanilla).
	Plus the jobs table - who fills each job - with the framework's pilot and crew fallback (crewman, engineer, rifleman).
	[faction, (no sibling step), (content setting: -1 = the faction's saved one)]  ->  HashMap: kind -> [classes]; "InfWeights" -> [weights]; "jobs" -> HashMap job -> class ("" = none)
	Kinds: Inf, Officer, Car, CarTurret, CarNoTurret, Truck, Motorcycle, Utility, APC, Tank, Arty, AA, Heli, HeliTransport,
	HeliArmed, Plane, PlaneCAS, Ship, ShipArmed, UAV, Mortar, Static, Ammo. "vanilla" -> the kinds filled with the side's
	vanilla vehicle (MCCMK_fnc_poolOwn leaves those out). Left out entirely (the campaign's rules): invisible targets, base
	classes, Taru pods and slingload cargo, radar and SAM sites, vehicles with no driver, karts, VR and virtual soldiers.
*/
params [["_fac", "", [""]], ["_noSibling", false, [false]], ["_modeIn", -1, [0]]];
if (_fac == "" || {!isClass (configFile >> "CfgFactionClasses" >> _fac)}) exitWith {createHashMap};
// the content setting: given (the Mission Generator's own), or the faction's saved one
private _mode = if (_modeIn >= 0) then {_modeIn} else {(missionNamespace getVariable ["MCC_MWContentModes", createHashMap]) getOrDefault [toLower _fac, 2]};
private _key = format ["%1|%2|%3", toLower _fac, _mode, _noSibling];
if (isNil "MCCMK_poolCache") then {MCCMK_poolCache = createHashMap};
if (_key in MCCMK_poolCache) exitWith {MCCMK_poolCache get _key};

private _side = [east, west, resistance, civilian] param [getNumber (configFile >> "CfgFactionClasses" >> _fac >> "side"), west];
private _kinds = ["Inf", "Officer", "Car", "CarTurret", "CarNoTurret", "Truck", "Motorcycle", "Utility", "APC", "Tank", "Arty", "AA", "Heli", "HeliTransport", "HeliArmed", "Plane", "PlaneCAS", "Ship", "ShipArmed", "UAV", "Mortar", "Static", "Ammo"];
private _p = createHashMap;
{_p set [_x, []]} forEach _kinds;
private _w = [];
private _unarmed = [];
private _weightKeywords = [
	["medic", 0.25], ["grenadier", 0.25], ["machine", 0.25], ["auto", 0.25], ["sniper", 0.1], ["marksman", 0.1],
	["spotter", 0.1], ["sharp", 0.1], ["asst.", 0.15], ["missile", 0.15], ["AT", 0.15], ["AA", 0.15], ["special", 0.15],
	["leader", 0.15], ["gunner", 0.15], ["ammo", 0.15], ["uav", 0.1], ["engineer", 0.1], ["pilot", 0], ["crew", 0], ["driver", 0]
];
private _isArmed = {	// a real weapon on a turret or a pylon (not a horn, smoke, flares, a searchlight or a laser)
	params ["_c"];
	private _ws = [];
	{_ws append getArray (_x >> "weapons")} forEach ([configFile >> "CfgVehicles" >> _c >> "Turrets"] + ("true" configClasses (configFile >> "CfgVehicles" >> _c >> "Turrets")));
	_ws append getArray (configFile >> "CfgVehicles" >> _c >> "weapons");
	if (isClass (configFile >> "CfgVehicles" >> _c >> "Components" >> "TransportPylonsComponent")) then {_ws pushBack "pylons"};
	(_ws findIf {private _l = toLower _x; (["horn", "smoke", "cmflare", "flare", "searchlight", "laserdesignator", "fakeweapon"] findIf {(_l find _x) >= 0}) < 0}) >= 0
};
private _cfgs = if (_mode in [1, 3, 4]) then {[_fac, _mode] call MCCMK_fnc_scopeClasses} else {(format ["getNumber (_x >> 'scope') == 2 && {toLower (getText (_x >> 'faction')) == '%1'}", toLower _fac]) configClasses (configFile >> "CfgVehicles")};
{
	private _c = configName _x;
	private _sub = toLower getText (_x >> "editorSubcategory");
	// left out entirely (the campaign's rules): invisible targets, base classes, pods and slingload cargo, radar and SAM
	// sites, vehicles with no driver (statics and crates apart), karts, VR and virtual soldiers
	private _lc = toLower _c;
	private _mdl = toLower getText (_x >> "model");
	private _dnl = toLower getText (_x >> "displayName");
	private _man = _c isKindOf "CAManBase";
	if (
		((_dnl find "invisible") >= 0) || {(_mdl find "invisible") >= 0}
		|| {(["invisibletarget", "targetsoldier", "target_vehicle", "targetvehicle"] findIf {(_lc find _x) >= 0}) >= 0}
		|| {_mdl in ["", "\a3\weapons_f\empty", "\a3\weapons_f\empty.p3d"]}
		|| {((_lc select [((count _lc) - 5) max 0]) == "_base") || {(_lc find "_base_") >= 0}}
		|| {(_mdl find "pod_heli_transport_04") >= 0} || {_c isKindOf "Slingload_base_F"}
		|| {(["radar_system", "sam_system"] findIf {(_mdl find _x) >= 0}) >= 0}
		|| {!_man && {getNumber (_x >> "hasDriver") == 0} && {getNumber (_x >> "isUav") != 1} && {!(_c isKindOf "StaticWeapon")} && {!(_c isKindOf "ReammoBox_F")}}
		|| {(toLower getText (_x >> "DLC")) == "kart"} || {(_sub find "vr") == 0 || {(toLower getText (_x >> "editorCategory")) find "vr" >= 0}}
		|| {_man && {(["virtual", "uav_ai", "uavai", "dummy"] findIf {((_lc find _x) >= 0) || {(_dnl find _x) >= 0}}) >= 0}}
	) then {continue};
	if (_c isKindOf "CAManBase") then {
		private _l = toLower _c;
		if ((["officer", "commander"] findIf {(_l find _x) >= 0}) >= 0) then {(_p get "Officer") pushBack _c} else {
			if ((["diver", "story", "competitor", "survivor", "unarmed", "protagonist", "_vr_"] findIf {(_l find _x) >= 0}) < 0 && {(_sub find "story") < 0}) then {
				if (count getArray (_x >> "weapons") <= 2) then {_unarmed pushBack _c} else {
					private _wt = switch (getText (_x >> "role")) do {
						case "Crewman": {0}; case "Assistant": {0.15}; case "CombatLifeSaver": {0.25}; case "Grenadier": {0.25};
						case "MachineGunner": {0.25}; case "Marksman": {0.1}; case "MissileSpecialist": {0.15}; case "Rifleman": {1};
						case "Sapper": {0.15}; case "SpecialOperative": {0.15}; default {0.5};
					};
					private _dn = getText (_x >> "displayName");
					{if ((_dn find (_x select 0)) >= 0 || {(toLower _dn) find (toLower (_x select 0)) >= 0 && {count (_x select 0) > 2}}) exitWith {_wt = _x select 1}} forEach _weightKeywords;
					(_p get "Inf") pushBack _c;
					_w pushBack _wt;
				};
			};
		};
	} else {
		// artillery - by Arma's own flag (the artillery computer) or its editor category: the Artillery pool only, never a car,
		// tank or APC (an MRL pickup is no motorized patrol, a self-propelled gun no armour). Mortars
		// (static weapons) keep their own pool.
		if (!(_c isKindOf "StaticWeapon") && {getNumber (_x >> "artilleryScanner") == 1 || {(_sub find "artillery") >= 0}}) then {
			(_p get "Arty") pushBack _c;
			continue;
		};
		switch (true) do {
			case (_c isKindOf "Motorcycle"): {(_p get "Motorcycle") pushBack _c};
			case (_c isKindOf "Car" && {[_c] call MCC_fnc_isUtilityVehicle}): {(_p get "Utility") pushBack _c};	// fuel, repair, ammo trucks: not combat cars
			case (_c isKindOf "Car"): {
				if (_sub == "edsubcat_drones") then {(_p get "UAV") pushBack _c} else {
					if (_sub == "edsubcat_apcs") then {(_p get "APC") pushBack _c} else {
						(_p get "Car") pushBack _c;
						if ([_c] call _isArmed) then {(_p get "CarTurret") pushBack _c} else {
							(_p get "CarNoTurret") pushBack _c;
							if (getNumber (_x >> "transportSoldier") >= 8) then {(_p get "Truck") pushBack _c};
						};
					};
				};
			};
			case (_c isKindOf "Tank" && {(_sub find "artillery") < 0} && {(["aa", "drone"] findIf {(_sub find _x) >= 0}) < 0}): {(_p get "Tank") pushBack _c};
			case (_c isKindOf "StaticMortar"): {(_p get "Mortar") pushBack _c};
			case (_c isKindOf "StaticMGWeapon" || {_c isKindOf "StaticGrenadeLauncher"}): {(_p get "Static") pushBack _c};
			case (_c isKindOf "ReammoBox_F"): {(_p get "Ammo") pushBack _c};
			default {
				private _hit = "";
				{if ((_sub find _x) >= 0) exitWith {_hit = _x}} forEach ["artillery", "aa", "tank", "apc", "helicopter", "plane", "boat", "drone"];
				if (_hit == "") then {_hit = switch (true) do {
					case (_c isKindOf "Helicopter"): {"helicopter"}; case (_c isKindOf "Plane"): {"plane"};
					case (_c isKindOf "Ship"): {"boat"}; case (_c isKindOf "Tank"): {"tank"}; default {""}
				}};
				if (getNumber (_x >> "isUav") == 1 && {_hit in ["helicopter", "plane"]}) then {_hit = "drone"};
				switch (_hit) do {
					case "artillery": {(_p get "Arty") pushBack _c};
					case "aa": {(_p get "AA") pushBack _c};
					case "tank"; case "apc": {(_p get "Tank") pushBack _c};
					case "helicopter": {
						(_p get "Heli") pushBack _c;
						if (getNumber (_x >> "transportSoldier") >= 6) then {(_p get "HeliTransport") pushBack _c};
						if ([_c] call _isArmed) then {(_p get "HeliArmed") pushBack _c};
					};
					case "plane": {(_p get "Plane") pushBack _c; if ([_c] call _isArmed) then {(_p get "PlaneCAS") pushBack _c}};
					case "boat": {(_p get "Ship") pushBack _c; if ([_c] call MCCMK_fnc_isArmedBoat) then {(_p get "ShipArmed") pushBack _c}};
					case "drone": {(_p get "UAV") pushBack _c};
				};
			};
		};
	};
} forEach _cfgs;
// officers fall back to the infantry; a too-small armed pool takes the unarmed soldiers in (as the framework does)
if (count (_p get "Inf") < count _unarmed) then {(_p get "Inf") append _unarmed; _w append (_unarmed apply {0.5})};
// 1. the content chain on each pool (own -> official DLC -> all); the infantry keeps its weights in step
{
	private _k = _x;
	private _list = _p get _k;
	if (_list isNotEqualTo []) then {
		private _f = [_list, _fac, _mode] call MCC_fnc_contentFilterList;
		if (_k == "Inf" && {count _f != count _list}) then {
			private _nw = [];
			{_nw pushBack (_w param [_list find _x, 0.5])} forEach _f;
			_w = _nw;
		};
		_p set [_k, _f];
	};
} forEach _kinds;
if ((_p get "Officer") isEqualTo []) then {_p set ["Officer", +(_p get "Inf")]};
// 2. a pool still empty: a faction of its family (MCCMK_fnc_factionFamily - FIA from FIA, CSAT from CSAT Pacific...)
if (!_noSibling) then {
	{
		private _k = _x;
		if ((_p get _k) isEqualTo []) then {
			{
				if ((_p get _k) isEqualTo []) then {
					private _sp = [_x, true, [0, 1, 2, 2, 2] param [_mode, 2]] call MCCMK_fnc_pools;
					private _sl = _sp getOrDefault [_k, []];
					if (_sl isNotEqualTo []) then {_p set [_k, +_sl]; if (_k == "Inf") then {_w = +(_sp getOrDefault ["InfWeights", []])}};
				};
			} forEach ([_fac] call MCCMK_fnc_factionFamily);
		};
	} forEach _kinds;
};
// 3. still empty, vehicle kinds only: the side's vanilla vehicle (never soldiers or crews)
private _vanKinds = [];
if (!_noSibling) then {
	private _si = [west, east, resistance] find _side;
	if (_si >= 0) then {
		private _van = [
			["Car", ["B_MRAP_01_F", "O_MRAP_02_F", "I_MRAP_03_F"]], ["CarTurret", ["B_MRAP_01_hmg_F", "O_MRAP_02_hmg_F", "I_MRAP_03_hmg_F"]],
			["CarNoTurret", ["B_MRAP_01_F", "O_MRAP_02_F", "I_MRAP_03_F"]], ["Truck", ["B_Truck_01_transport_F", "O_Truck_03_transport_F", "I_Truck_02_transport_F"]],
			["APC", ["B_APC_Wheeled_01_cannon_F", "O_APC_Wheeled_02_rcws_v2_F", "I_APC_Wheeled_03_cannon_F"]], ["Tank", ["B_MBT_01_cannon_F", "O_MBT_02_cannon_F", "I_MBT_03_cannon_F"]],
			["Arty", ["B_MBT_01_arty_F", "O_MBT_02_arty_F", "I_Truck_02_MRL_F"]], ["AA", ["B_APC_Tracked_01_AA_F", "O_APC_Tracked_02_AA_F", "I_LT_01_AA_F"]],
			["Heli", ["B_Heli_Transport_01_F", "O_Heli_Light_02_unarmed_F", "I_Heli_Transport_02_F"]], ["HeliTransport", ["B_Heli_Transport_01_F", "O_Heli_Light_02_unarmed_F", "I_Heli_Transport_02_F"]],
			["HeliArmed", ["B_Heli_Attack_01_dynamicLoadout_F", "O_Heli_Attack_02_dynamicLoadout_F", "I_Heli_light_03_dynamicLoadout_F"]],
			["Plane", ["B_Plane_CAS_01_dynamicLoadout_F", "O_Plane_CAS_02_dynamicLoadout_F", "I_Plane_Fighter_03_dynamicLoadout_F"]],
			["PlaneCAS", ["B_Plane_CAS_01_dynamicLoadout_F", "O_Plane_CAS_02_dynamicLoadout_F", "I_Plane_Fighter_03_dynamicLoadout_F"]],
			["Ship", ["B_Boat_Transport_01_F", "O_Boat_Transport_01_F", "I_Boat_Transport_01_F"]], ["ShipArmed", ["B_Boat_Armed_01_minigun_F", "O_Boat_Armed_01_hmg_F", "I_Boat_Armed_01_minigun_F"]],
			["UAV", ["B_UAV_02_dynamicLoadout_F", "O_UAV_02_dynamicLoadout_F", "I_UAV_02_dynamicLoadout_F"]], ["Mortar", ["B_Mortar_01_F", "O_Mortar_01_F", "I_Mortar_01_F"]],
			["Static", ["B_HMG_01_high_F", "O_HMG_01_high_F", "I_HMG_01_high_F"]]
		];
		{
			_x params ["_k", "_cls"];
			private _c = _cls select _si;
			if ((_p get _k) isEqualTo [] && {isClass (configFile >> "CfgVehicles" >> _c)}) then {_p set [_k, [_c]]; _vanKinds pushBack _k};
		} forEach _van;
	};
};
_p set ["InfWeights", _w];
// the ordinary infantry: soldiers filed under the "Men" category - no recon, snipers or support (the original rule for the
// squads MCC builds itself); none: the whole infantry pool
private _men = (_p get "Inf") select {(toLower ([_x] call MCC_fnc_unitCategory)) == "men"};
_p set ["InfMen", [_men, +(_p get "Inf")] select (_men isEqualTo [])];
_p set ["vanilla", _vanKinds];
// the jobs table: matched by name and display name, the most exact word first (the framework's words); the pilot and
// crew fall back to the crewman, the engineer, the rifleman - never a vanilla soldier ("" = the faction has none)
private _men = (_p get "Inf") + ((_p get "Officer") - (_p get "Inf"));
private _names = _men apply {[toLower _x, " " + (((toLower (getText (configFile >> "CfgVehicles" >> _x >> "displayName"))) splitString "()[],-/.") joinString " ") + " "]};
private _by = {
	params ["_words", ["_not", []]];
	private _found = "";
	{
		private _k = _x;
		private _i = _names findIf {
			private _e = _x;
			(((_e select 0) find _k) >= 0 || {((_e select 1) find _k) >= 0}) && {(_not findIf {((_e select 0) find _x) >= 0 || {((_e select 1) find _x) >= 0}}) < 0}
		};
		if (_i >= 0) exitWith {_found = _men select _i};
	} forEach _words;
	_found
};
private _rif = [["rifleman", "soldier_f", "_soldier"], ["unarmed", "pilot", "crew", "diver", "sniper"]] call _by;
if (_rif == "" && {_men isNotEqualTo []}) then {_rif = _men select 0};
private _crewman = [["crewman", "_crew", "crew"], ["heli"]] call _by;
private _engineer = [["engineer", "repair specialist"]] call _by;
private _pilot = [["helicopter pilot", "helipilot", "heli_pilot", "helicrew", "heli_crew", "pilot"], ["jet", "fighter", "plane", "fixed"]] call _by;
private _jet = [["jet pilot", "fighter pilot", "pilot_jet", "fighter_pilot", "jet"], ["heli"]] call _by;
private _crewC = ([_crewman, _engineer, _rif] select {_x != ""}) param [0, ""];
private _j = createHashMap;
_j set ["Team Leader", [["team leader", "teamleader", "squad leader", "squadleader", "section leader"]] call _by];
_j set ["Rifleman", _rif];
_j set ["Grenadier", [["grenadier", "(gl)", " gl ", "_gl_"]] call _by];
_j set ["Medic", [["medic", "combat life", "paramedic"]] call _by];
_j set ["AT", [["(at)", " at ", "_at_", "_lat_", "_mat_", "_hat_", "anti-tank", "anti tank", "antitank", "javelin", "nlaw", "maaws", "rpg", "launcher"]] call _by];
_j set ["AA", [["(aa)", " aa ", "_aa_", "anti-air", "anti air", "antiair", "stinger", "igla", "starstreak", "manpad"]] call _by];
_j set ["Sniper", [["sniper", "sharpshooter", "marksman"]] call _by];
_j set ["Autorifleman", [["autorifleman", "machine gunner", "machinegunner", "_ar_", "(ar)"]] call _by];
_j set ["Engineer", _engineer];
_j set ["Explosive Specialist", [["explosive", "demolition", "sapper", "_exp_"]] call _by];
_j set ["UAV Operator", [["uav", "drone operator"]] call _by];
_j set ["Officer", (_p get "Officer") param [0, ""]];
_j set ["Crew", _crewC];
_j set ["Pilot", [_pilot, _crewC] select (_pilot == "")];
_j set ["Jet Pilot", [_jet, _j get "Pilot"] select (_jet == "")];
// a faction with no soldiers: the jobs of a faction of its family (never a vanilla soldier)
if (!_noSibling && {_men isEqualTo []}) then {
	{
		if ((_j get "Rifleman") == "") then {
			private _sj = ([_x, true, _mode] call MCCMK_fnc_pools) getOrDefault ["jobs", createHashMap];
			if ((_sj getOrDefault ["Rifleman", ""]) != "") then {_j = +_sj};
		};
	} forEach ([_fac] call MCCMK_fnc_factionFamily);
};
_p set ["jobs", _j];
MCCMK_poolCache set [_key, _p];
if (missionNamespace getVariable ["MCC_debug", false]) then {
	["INFO", "pools", "%1 (content %2): %3 | vanilla for: %4 | family: %5 | jobs: %6", [_fac, _mode, _kinds apply {format ["%1 %2", _x, count (_p get _x)]}, _vanKinds, [_fac] call MCCMK_fnc_factionFamily, (keys _j) apply {format ["%1=%2", _x, _j get _x]}]] call MCC_fnc_log;
};
_p
