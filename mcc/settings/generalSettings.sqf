private _haloVals = ["", "MCC_ORIGINAL"];
private _haloNames = ["Automatic (faction's own C-130, then CUP C-130, then others)", "MCC original (Blackfish for West, Xi'an for East, Mohawk otherwise)"];
private _haloList = [];
{
	private _c = configName _x;
	private _uc = toUpper _c;
	private _seats = if (!isNil "MCC_fnc_crewCount") then {[_c, "allCargo"] call MCC_fnc_crewCount} else {getNumber (_x >> "transportSoldier")};
	if (_seats >= 8) then {
		private _fac = getText (configFile >> "CfgFactionClasses" >> getText (_x >> "faction") >> "displayName");
		_haloList pushBack [if ((_uc find "C130") >= 0) then {0} else {[1, 2] select ((_uc find "VTOL") >= 0)}, getText (_x >> "displayName"), _c, _fac, _seats];
	};
} forEach ("getNumber (_x >> 'scope') == 2 && {(configName _x) isKindOf 'Plane'}" configClasses (configFile >> "CfgVehicles"));
_haloList sort true;
{
	_x params ["", "_name", "_c", "_fac", "_seats"];
	_haloVals pushBack _c;
	_haloNames pushBack format ["%1 - %2 (%3 seats)", _name, [_fac, "no faction"] select (_fac == ""), _seats];
} forEach _haloList;
[
    "MCC_haloAircraft",
    "LIST",
    ["HALO aircraft","The aircraft for HALO drops.\nAutomatic: the faction's own C-130, else the CUP C-130, any other C-130,\nthen any transport plane with seats for the whole stick.\nMCC original: Blackfish (West), Xi'an (East), Mohawk otherwise.\nOr pick an installed plane with 8+ seats - used when it can carry the stick."],
    "MCC General",
    [_haloVals, _haloNames, 0],
    true
] call CBA_Settings_fnc_init;

{
    _x params ["_s", "_n"];
    [
        format ["MCC_taruLivery%1", _s],
        "LIST",
        [format ["Taru livery - %1", _n], format ["The livery of the Taru (and its pod) MCC uses for %1 drop pods: the faction's own Taru of that livery if it has one, otherwise the Taru Pod Mod's Taru for %1 (its own pilots) when the mcc_taru_pods add-on is in the addons folder, or the CSAT Taru without it.", _n]],
        "MCC General",
        [[0, 1], ["Hex", "Black"], [1, 0, 0] select (["B", "O", "I"] find _s)],
        true
    ] call CBA_Settings_fnc_init;
} forEach [["B", "West"], ["O", "East"], ["I", "Independent"]];

[
    "MCC_debug",
    "CHECKBOX",
    ["Debug logging","Write MCC's detailed DEBUG lines to the RPT log (and show MCC's debug\nmessages). Turn on to find a problem, then send the RPT; off for\nnormal play."],
    "MCC General",
    false,
    true,
    {
        params [["_on", false, [false]]];
        missionNamespace setVariable ["MCC_debug", _on];
        if (!_on && {!isNil "MCCMK_debugMarkers"}) then {{deleteMarkerLocal _x} forEach MCCMK_debugMarkers; MCCMK_debugMarkers = []};
        if (!isNil "MCC_fnc_log") then {["INFO", "generalSettings", "addon option: debug logging %1", [["OFF","ON"] select _on]] call MCC_fnc_log};
    }
] call CBA_Settings_fnc_init;

//Performance log (diagnostics, test builds)
[
    "MCC_perfLog",
    "CHECKBOX",
    ["Performance log","Write MCC [PERF] lines to the RPT: how long each part of mission\ngeneration takes, what it creates, FPS, and what happens as players\napproach an objective"],
    "MCC General",
    false,
    true,
    {
        params ["_value"];
        if (_value && {isServer}) then {["monitor"] call MCC_fnc_perfLog};
    }
] call CBA_Settings_fnc_init;

//Teleport
[
    "MCC_t2tIndex",
    "LIST",
    ["Teleport to Team","Players can teleport to squad leader"],
    "MCC General",
    [[0,1,2,3],["Disabled","JIP Only","After Respawn","Always"],1],
    true,
    {
        params ["_value"];
        if (_value isEqualTo 0) then {MCC_teleportToTeam = false};
    }
] call CBA_Settings_fnc_init;

//MCC Chat
[
    "MCC_MessagesIndex",
    "CHECKBOX",
    ["MCC Chat","Will show MCC chat"],
    "MCC General",
    true,
    true
] call CBA_Settings_fnc_init;

//Sync at start
[
    "MCC_syncOn",
    "CHECKBOX",
    ["Sync Jip","JIP players will sync with the server"],
    "MCC General",
    true,
    true
] call CBA_Settings_fnc_init;

//Ambient Birds
[
    "MCC_ambientBirdsSettingIndex",
    "CHECKBOX",
    ["Ambient Birds","Random flocks of birds will take flight when units are near"],
    ["MCC General", "Ambient Birds"],
    true,
    true,
    {
        params ["_value"];
         if (_value) then {
            [] spawn MCC_fnc_ambientBirdsSpawnInit;
        };
    }
] call CBA_Settings_fnc_init;

//Ambient Fire
[
    "MCC_ambientFireSettingIndex",
    "CHECKBOX",
    ["Ambient Fire","Explosions may start fires that spread with the wind. Unticking puts\nout all fires and stops new ones."],
    ["MCC General", "Ambient Fire"],
    false,
    true,
    {
        params ["_value"];
        if (_value) then {
            [] spawn MCC_fnc_ambientFireInit;
        } else {
            // switched off: put out existing fires (server); new ones are blocked in ambientFireStart/Propagation
            if (isServer && {time > 0}) then {[] call MCC_fnc_ambientFireExtinguish};
        };
    },
    false
] call CBA_Settings_fnc_init;

//Ambient Fire vehicle burn chance
[
    "MCC_fnc_ambientFireInitVehicleBurnChance",
    "SLIDER",
    ["Vehicle fire chance","Chance a destroyed vehicle will start a fire"],
    ["MCC General", "Ambient Fire"],
    [0,100,50,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;

//Ambient Fire explosives burn chance
[
    "MCC_fnc_ambientFireInitExplosivesBurnChance",
    "SLIDER",
    ["Explosives rounds fire chance","Chance an explosive round starts a new fire. Also affects the chance\nof non-explosive rounds starting one"],
    ["MCC General", "Ambient Fire"],
    [0,100,3,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;


//Ambient Fire spread chance (was a fixed 40 %)
[
    "MCC_ambientFireSpreadChance",
    "SLIDER",
    ["Fire spread chance","Chance a burning tree or house starts a new fire around it. Lower =\nfires stay smaller."],
    ["MCC General", "Ambient Fire"],
    [0,100,40,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;

//Ambient Fire crew burn chance
[
    "MCC_fnc_ambientFireInitCrewBurnChance",
    "SLIDER",
    ["Burning crew escape chance","Chance of each crew member of a destroyed vehicle catching fire and\nrunning out of it"],
    ["MCC General", "Ambient Fire"],
    [0,100,50,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;

//Ambient Fire burnt crew member will start a new fire
[
    "MCC_fnc_ambientFireInitCrewNewFireChance",
    "SLIDER",
    ["Burning crew new fire chance","Chance a burnet crew member will start a new fire"],
    ["MCC General", "Ambient Fire"],
    [0,100,10,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;

//Artillery computer
[
    "MCC_artilleryComputerIndex",
    "CHECKBOX",
    ["Artillery Computer","Enable/disable BI artillery computer"],
    ["MCC General", "Artillery"],
    true,
    true,
    {
        _this spawn {
            params ["_value"];
            waitUntil {time > 10};
            enableEngineArtillery _value;
        };
    },
    true
] call CBA_Settings_fnc_init;

//Artillery Spread
[
    "MCC_artillerySpreadArray",
    "EDITBOX",
    ["Artillery spread","First element display name second spread in meters"],
    ["MCC General", "Artillery"],
    '[["On-target",0], ["Precise",100], ["Tight",200], ["Wide",400]]',
    true,
    {
        params ["_value"];
        MCC_artillerySpreadArray = [_value, '[["On-target",0], ["Precise",100], ["Tight",200], ["Wide",400]]', "MCC_artillerySpreadArray"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Time Multiplier
[
    "MCC_timeMultiplier_settings",
    "SLIDER",
    "Time Multiplier",
    "MCC General",
    [0.5, 24, 1, 1],
    true,
    {
        _this spawn {
            params ["_value"];
            waitUntil {time > 10};
            if (isServer) then {setTimeMultiplier _value};
        };
    }
] call CBA_Settings_fnc_init;

//Disable Curator Edit
[
    "MCC_CuratorEditDisabled",
    "CHECKBOX",
    ["Disable MCC Zeus Edit","Disable the custom MCC interface when editing an object in Zeus"],
    "MCC General",
    false,
    false
] call CBA_Settings_fnc_init;

//Logistics
[
    "MCC_allowlogistics",
    "CHECKBOX",
    ["Logistics System","Allows player to load equipment, vehicles, resources and items into vehicles"],
    "MCC General",
    true,
    true
] call CBA_Settings_fnc_init;

//Armed Civilians Weapons
[
    "MCC_armedCivilansWeapons",
    "EDITBOX",
    ["Armed Civilians Weapons","Armed Civilians default Weapons"],
    "MCC General",
    '["hgun_P07_F","hgun_Rook40_F","hgun_ACPC2_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","SMG_01_F","SMG_02_F","hgun_PDW2000_F"]',
    true,
    {
        params ["_value"];
        MCC_armedCivilansWeapons = [_value, '["hgun_P07_F","hgun_Rook40_F","hgun_ACPC2_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","SMG_01_F","SMG_02_F","hgun_PDW2000_F"]', "MCC_armedCivilansWeapons"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

// ==================== SQL PDA ==========================================

//SQL PDA
[
    "MCC_allowsqlPDA",
    "CHECKBOX",
    ["SQL PDA Enabled","Any team leader will have access to a PDA with a Blue Force tracker"],
    ["MCC General","Squad Leader PDA"],
    true,
    true
] call CBA_Settings_fnc_init;

//MCC's own Zeus
[
    "MCC_giveZeus",
    "CHECKBOX",
    ["Give MCC's Zeus","When ticked (original behaviour) the mission maker gets MCC's Zeus\nwhen logging in or opening the MCC console.\nUntick to stop MCC handing out a Zeus - use your own Game Master\nmodule instead. Players who already own a Zeus always keep it."],
    "MCC General",
    true,
    true
] call CBA_Settings_fnc_init;
