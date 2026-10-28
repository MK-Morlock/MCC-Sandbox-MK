/*================================================================== MCC_fnc_assetsData ==================================================================
	Asset presets for the console Assets page: which classes MCC uses for HVTs, destroy objectives and support aircraft.
	Presets are saved per enemy faction in the profile (profileNamespace MCC_assetPresets), so choosing a faction again
	brings its choices back. A slot with an empty list is Auto: MCC picks as before (faction, its mod, then default list).

	Modes
		["slots"]                         slot definitions: [id, label, variable, role, group]
		["get", [faction]]                the preset of a faction: [[slotId, [classes]], ...]
		["set", [faction, preset]]        save a faction preset (and apply it if it is the active faction)
		["factions"]                      factions that have a preset
		["list", [value]]                 a list variable as an array (also when it is still a setting text)
		["apply", [faction]]              make a faction preset active: custom lists go into the variables MCC reads,
		                                  Auto slots get their default list back. Global, so the server uses them too.
	Variables: each slot list goes into its variable (for example MCC_MWTanks). MCC_assetCustom_<variable> is true while the
	list is a custom one, so MCC uses it as it is instead of looking up the faction first.
==============================================================================================================================================================*/
params [["_mode", "", [""]], ["_args", []]];

private _slots = [
	["hvt",       "HVT (Kill / Secure HVT)",        "MCC_MWHVT",           "officer",    "Objectives"],
	["tanks",     "Destroy: Tank",                  "MCC_MWTanks",         "tank",       "Objectives"],
	["aa",        "Destroy: Anti-air",              "MCC_MWAA",            "aa",         "Objectives"],
	["artillery", "Destroy: Artillery",             "MCC_MWArtillery",     "artillery",  "Objectives"],
	["air",       "Destroy: Aircraft",              "MCC_MWAir",           "air",        "Objectives"],
	["cache",     "Destroy: Weapons cache",         "MCC_MWcache",         "cache",      "Objectives"],
	["radio",     "Destroy: Radio tower",           "MCC_MWRadio",         "radio",      "Objectives"],
	["radar",     "Destroy: Radar",                 "MCC_MWradar",         "radar",      "Objectives"],
	["fuel",      "Destroy: Fuel depot",            "MCC_MWFuelTanks",     "fuel",       "Objectives"],
	["intel",     "Intel items",                    "MCC_MWIntelObjects",  "intel",      "Objectives"],
	["gunship",   "Support: Gunship",               "MCC_assetGunship",    "gunship",    "Support"],
	["pod",       "Support: Drop-pod helicopter",   "MCC_assetPodCarrier", "podCarrier", "Support"],
	["supply",    "Support: Supply-drop helicopter","MCC_assetSupplyHeli", "cargoHeli",  "Support"],
	["paradrop",  "Support: Paradrop aircraft",     "MCC_assetParadrop",   "transport",  "Support"]
];

private _all = profileNamespace getVariable ["MCC_assetPresets", []];
//A list variable as an array. CBA keeps the text of an MCC Mission Generator setting in the same variable for a
//moment before MCC turns it into a list, so the value can be a string like ["B_officer_F","O_officer_F"].
private _asList = {
	params ["_v"];
	if (_v isEqualType []) exitWith {+_v};
	if (_v isEqualType "") exitWith {
		private _p = [];
		if (_v != "") then {_p = parseSimpleArray (_v regexReplace ["'", """"])};
		if (_p isEqualType []) then {_p select {_x isEqualType ""}} else {[]}
	};
	[]
};
private _find = {params ["_f"]; _all findIf {toLower (_x select 0) == toLower _f}};

switch (_mode) do {
	case "slots": {_slots};

	case "list": {_args params [["_v", []]]; [_v] call _asList};

	case "get": {
		_args params [["_faction", ""]];
		private _i = [_faction] call _find;
		if (_i < 0) then {[]} else {+((_all select _i) select 1)}
	};

	case "factions": {
		(_all select {count ((_x select 1) select {count (_x select 1) > 0}) > 0}) apply {_x select 0}
	};

	case "set": {
		_args params [["_faction", ""], ["_preset", []]];
		if (_faction == "") exitWith {};
		private _i = [_faction] call _find;
		if (_i < 0) then {_all pushBack [_faction, _preset]} else {_all set [_i, [_faction, _preset]]};
		profileNamespace setVariable ["MCC_assetPresets", _all];
		saveProfileNamespace;
		if (toLower _faction == toLower (call MCC_fnc_MWEnemyFaction)) then {["apply", [_faction]] call MCC_fnc_assetsData};
	};

	case "apply": {
		_args params [["_faction", ""]];
		private _preset = ["get", [_faction]] call MCC_fnc_assetsData;
		//Only the server, the mission maker or a machine that has this preset sets the shared variables, so other
		//players (joining, or without presets) do not reset the mission maker choices
		if (!hasInterface) exitWith {};	//a dedicated server has no presets
		if (!isServer && {count _preset == 0} && {(missionNamespace getVariable ["mcc_missionmaker", ""]) != name player}) exitWith {};
		{
			_x params ["_id", "", "_var"];
			private _baseVar = "MCC_assetBase_" + _var;
			private _flagVar = "MCC_assetCustom_" + _var;
			//Remember the default list once (CBA setting / module value), before any custom list replaces it
			if (isNil {missionNamespace getVariable _baseVar} && {!(missionNamespace getVariable [_flagVar, false])}) then {
				missionNamespace setVariable [_baseVar, [missionNamespace getVariable [_var, []]] call _asList, true];
			};
			private _entry = _preset select {(_x select 0) == _id};
			private _list = if (count _entry > 0) then {(_entry select 0) select 1} else {[]};
			_list = _list select {isClass (configFile >> "CfgVehicles" >> _x)};	//classes from mods that are not loaded are skipped
			if (count _list > 0) then {
				missionNamespace setVariable [_var, _list, true];
				missionNamespace setVariable [_flagVar, true, true];
			} else {
				if (missionNamespace getVariable [_flagVar, false]) then {
					missionNamespace setVariable [_var, [missionNamespace getVariable [_baseVar, []]] call _asList, true];
				};
				missionNamespace setVariable [_flagVar, false, true];
			};
		} forEach _slots;
		missionNamespace setVariable ["MCC_assetActiveFaction", _faction, true];
	};
};
