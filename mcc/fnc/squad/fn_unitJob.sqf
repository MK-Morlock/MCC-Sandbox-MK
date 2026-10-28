params [["_cls", "", [""]]];
if (_cls == "") exitWith {"Rifleman"};
private _key = "MCCMK_job_" + _cls;
if (!isNil _key) exitWith {missionNamespace getVariable _key};

private _cfg = configFile >> "CfgVehicles" >> _cls;
private _name = " " + (toLower _cls) + " " + (toLower (getText (_cfg >> "displayName"))) + " ";
private _icon = toLower (getText (_cfg >> "icon"));
private _role = toLower (getText (_cfg >> "role"));
private _has = { private _w = _this; (_w findIf {(_name find _x) >= 0}) >= 0 };

// what it carries
private _cfgW = configFile >> "CfgWeapons";
private _cfgM = configFile >> "CfgMagazines";
private _weps = (getArray (_cfg >> "weapons")) select {!(_x in ["Throw", "Put"])};
private _primary = _weps select {(getNumber (_cfgW >> _x >> "type")) == 1};
private _launchers = _weps select {(getNumber (_cfgW >> _x >> "type")) == 4};
private _hasGL = (_primary findIf {
	private _w = _x;
	((getArray (_cfgW >> _w >> "muzzles")) findIf {
		private _m = _x;
		private _ml = toLower _m;
		_ml != "this" && {_ml != "safe"} && {
			(["gl", "ugl", "m203", "m320", "gp25", "gp30", "eglm", "40mm"] findIf {(_ml find _x) >= 0}) >= 0
			|| {((getArray (_cfgW >> _w >> _m >> "magazines")) findIf {
				private _a = getText (_cfgM >> _x >> "ammo");
				_a isKindOf ["G_40mm_HE", configFile >> "CfgAmmo"] || {(toLower (getText (configFile >> "CfgAmmo" >> _a >> "simulation"))) == "shotshell"}
			}) >= 0}
		}
	}) >= 0
}) >= 0;
private _launcherAA = (_launchers findIf {
	private _l = _x;
	((getArray (_cfgW >> _l >> "magazines")) findIf {
		private _a = getText (_cfgM >> _x >> "ammo");
		(getNumber (configFile >> "CfgAmmo" >> _a >> "airLock")) >= 2 && {(getNumber (configFile >> "CfgAmmo" >> _a >> "irLock")) > 0}
	}) >= 0
}) >= 0;

private _atWords = ["_at_", "_lat_", "_lat2", "light at", "(lat", "_mat_", "_hat_", "(at)", "(lat)", "(mat)", "(hat)", "anti-tank", "anti tank", "antitank", "missile", "javelin", "maaws", "metis", "konkurs", "kornet", " tow", "rpg", "carl gustaf", "nlaw", "smaw", "m136", "at4", "m72", "panzerfaust", "pzf", "spg", " law "];
private _aaWords = ["_aa_", "_aa ", "(aa)", "aa specialist", "aa missile", "anti-air", "anti air", "antiair", "stinger", "fim-92", "igla", "starstreak", "manpad", "strela", "verba", "titan aa"];

private _res = switch (true) do {
	case (["diver", "frogman"] call _has): {"Diver"};
	case (["survivor", "unarmed"] call _has): {"Unarmed"};
	case (["helicopter pilot", "helipilot", "heli pilot", "ah-64 pilot", "_helo_pilot", "rotary"] call _has): {"HeliPilot"};
	case (["helicopter crew", "helicrew", "heli crew", "door gunner", "crew chief", "loadmaster"] call _has): {"HeliCrew"};
	case (["pilot"] call _has): {"Pilot"};
	case ([" driver", "_driver"] call _has): {"Driver"};
	case (["crewman", "_crew_", "crew (", " crew ", "_crew", "tank commander"] call _has || {_role == "crewman"}): {"Crewman"};
	case (["uav", "drone", "ugv"] call _has): {"UAVOperator"};
	case (["spotter", "observer", "jtac", " jfo", "_jfo", " fso", "_fso", "fire support", "forward air", " fac ", "_fac_"] call _has): {"Spotter"};
	case (["radio", " rto", "_rto", "radioman", "signaller", "signaler"] call _has): {"RadioOperator"};
	case (["officer", "commander", "commanding", "_off_", "platoon leader", "lieutenant", "captain"] call _has || {_icon == "iconmanofficer"}): {"Officer"};
	case (["squad leader", "squadleader", "_sl_", "section leader", "sectionleader", "squad lead"] call _has): {"SquadLeader"};
	case (["team leader", "teamleader", "_tl_", "fireteam leader", "fire team leader", "group leader"] call _has || {_icon == "iconmanleader"}): {"TeamLeader"};
	case (["asst", "assistant", "ass.", " ammo bearer", "ammobearer", "ammo carrier"] call _has): {
		switch (true) do {
			case (["auto", "_ar_", "(ar)", "_ar "] call _has): {"AsstAutorifleman"};   // (not "_ar": every "_army_" class has it)
			case (_aaWords call _has || {[" aa", "aa)"] call _has}): {"AsstAA"};
			case (_atWords call _has || {[" at", "at)"] call _has}): {"AsstAT"};
			case (["machine", "_mg", "(mg)", "mmg", "hmg", "gunner"] call _has): {"AsstMachineGunner"};
			default {"AmmoBearer"};
		}
	};
	case (["sniper"] call _has): {"Sniper"};
	case (["marksman", "sharpshooter", "dmr", "designated"] call _has || {_role == "marksman"}): {"Marksman"};
	case (_aaWords call _has || {_launcherAA}): {"AASpecialist"};
	case (["rifleman"] call _has && {_atWords call _has}): {"RiflemanAT"};
	case (_atWords call _has || {_role == "missilespecialist"}): {"ATSpecialist"};
	case (["autorifleman", "auto rifleman", "auto-rifleman", "_ar_", "(ar)", " lmg", "_lmg", "saw gunner"] call _has): {"Autorifleman"};
	case (["machine gunner", "machinegunner", "machine-gunner", "_mg_", "(mg)", "heavygunner", "heavy gunner", " mmg", "_mmg", "gpmg", "_hmg"] call _has): {"MachineGunner"};
	case (["grenadier", "(gl)", "_gl_", " gl ", "m203", "m320", "gp-25", "gp25", "ugl", "grenade launcher"] call _has || {_role == "grenadier"}): {"Grenadier"};
	case ((getNumber (_cfg >> "attendant")) > 0 || {["medic", "corpsman", "paramedic", "combat life", " cls", "_cls"] call _has} || {_role == "combatlifesaver"}): {"Medic"};
	case (["explosive", "demolition", "_exp_", "sapper", " eod", "_eod", "mine specialist", "minesweeper", "pioneer"] call _has || {_role == "sapper"}): {"ExplosiveSpecialist"};
	case (["engineer"] call _has): {"Engineer"};
	case (["repair", "mechanic"] call _has): {"RepairSpecialist"};
	case (["breacher", "shotgun", "_cqb"] call _has): {"Breacher"};
	// by the editor icon, for a unit whose name says nothing
	case (_icon == "iconmanmedic"): {"Medic"};
	case (_icon == "iconmanengineer"): {"Engineer"};
	case (_icon == "iconmanexplosive"): {"ExplosiveSpecialist"};
	case (_icon == "iconmanat"): {if (_launcherAA) then {"AASpecialist"} else {"ATSpecialist"}};
	case (_icon == "iconmanmg"): {"Autorifleman"};
	// by the config role
	case (_role == "machinegunner"): {"Autorifleman"};
	case (_role == "assistant"): {"AmmoBearer"};
	// by what he carries
	case (_hasGL): {"Grenadier"};
	case (count _launchers > 0): {"RiflemanAT"};
	case (["light", "(lite)", "riflemanl", "_lite"] call _has): {"RiflemanLight"};
	case (count _weps == 0): {"Unarmed"};
	default {"Rifleman"};
};
missionNamespace setVariable [_key, _res];
_res
