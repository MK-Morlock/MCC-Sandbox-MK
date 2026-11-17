private _haloVals = ["", "MCC_ORIGINAL"];
private _haloNames = ["Automatic (faction's own C-130, then CUP C-130, then others)", "MCC original (Blackfish for West, Xi'an for East,\nMohawk otherwise)"];
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
//(MK) the last step of every faction vehicle choice: the faction's own, then a sibling faction's (same mod, same side),
// then - with this on - the side's vanilla vehicle; off: nothing spawns that the faction (or its siblings) doesn't have
[
    "MCCMK_vanillaFallback",
    "CHECKBOX",
    ["Vanilla vehicle fallback", "When a faction (and its sibling factions from the same\nmod) has no suitable vehicle - an armed helicopter for\nCAS, an armed boat, tanks, a transport helicopter - use\nthe side's vanilla one, so every mechanic still works.\nOff: only the faction's own kit; what it doesn't have\ndoesn't spawn. Soldiers and crews are never vanilla.\n(Mission air defence has its own fallback setting.)"],
    "MCCMK General",
    true,
    true
] call CBA_Settings_fnc_init;

//(MK) where MCC MK's own actions go with ACE loaded (MCCMK_fnc_aceMenus) - replaces "Ship actions in"
[
    "MCCMK_aceActions",
    "LIST",
    ["MCC actions with ACE", "With ACE: where MCC MK's own actions (Hide body,\nCheck supplies, salvage, the ship and pod actions, Taru\npods, Anchors...) go - directly in the ACE menu, on the\nscroll menu, or both. Without ACE they're always scroll\nactions. The original MCC's interactions aren't affected.\nNeeds a mission restart."],
    "MCCMK General",
    [[2, 0, 1], ["ACE menu only", "ACE menu and scroll menu", "Scroll menu only"], 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_haloAircraft",
    "LIST",
    ["HALO aircraft","The aircraft for HALO drops.\nAutomatic: the faction's own C-130, else CUP's or any\nother C-130, then any transport plane that seats the\nwhole stick.\nMCC original: Blackfish, Xi'an or Mohawk.\nOr pick an installed plane with 8+ seats."],
    "MCCMK General",
    [_haloVals, _haloNames, 0],
    true
] call CBA_Settings_fnc_init;

{
    _x params ["_s", "_n"];
    [
        format ["MCC_taruLivery%1", _s],
        "LIST",
        [format ["Taru livery - %1", _n], format ["The livery of the Taru (and its pod) MCC uses for %1 drop pods: the faction's own Taru of that livery if it has one, otherwise the Taru Pod Mod's Taru for %1 (its own pilots) when the mcc_taru_pods add-on is in the addons folder, or the CSAT Taru without it.", _n]],
        "MCCMK General",
        [[0, 1], ["Hex", "Black"], [1, 0, 0] select (["B", "O", "I"] find _s)],
        true
    ] call CBA_Settings_fnc_init;
} forEach [["B", "West"], ["O", "East"], ["I", "Independent"]];

[
    "MCC_debug",
    "CHECKBOX",
    ["Debug logging","Write MCC's detailed DEBUG lines to the RPT log (and\nshow MCC's debug messages). Turn on to find a problem,\nthen send the RPT; off for normal play."],
    "MCCMK General",
    false,
    true,
    {
        params [["_on", false, [false]]];
        missionNamespace setVariable ["MCC_debug", _on];
        if (!_on && {!isNil "MCCMK_debugMarkers"}) then {{deleteMarkerLocal _x} forEach MCCMK_debugMarkers; MCCMK_debugMarkers = []};
        // debug off: every debug-only marker goes (IEDs, suicide bombers, armed civilians, roadblocks, road network)
        if (!_on) then {
            {
                private _m = _x;
                if ((["iedMarker_", "SBMarker", "ACMarker_", "Rpdblock_", "markername_"] findIf {(_m find _x) == 0}) >= 0) then {deleteMarkerLocal _m};
            } forEach allMapMarkers;
        };
        if (!isNil "MCC_fnc_log") then {["INFO", "generalSettings", "addon option: debug logging %1", [["OFF","ON"] select _on]] call MCC_fnc_log};
    }
] call CBA_Settings_fnc_init;

//Performance log (diagnostics, test builds)
[
    "MCC_perfLog",
    "CHECKBOX",
    ["Performance log","Write MCC [PERF] lines to the RPT: how long each part\nof mission generation takes, what it creates, FPS, and\nwhat happens as players approach an objective"],
    "MCCMK General",
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
    "MCCMK General",
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
    ["MCCMK Chat", "Will show MCC chat"],
    "MCCMK General",
    true,
    true
] call CBA_Settings_fnc_init;

//Sync at start
[
    "MCC_syncOn",
    "CHECKBOX",
    ["Sync Jip","JIP players will sync with the server"],
    "MCCMK General",
    true,
    true
] call CBA_Settings_fnc_init;

//Ambient Birds
[
    "MCC_ambientBirdsSettingIndex",
    "CHECKBOX",
    ["Ambient Birds","Random flocks of birds will take flight when units are\nnear"],
    ["MCCMK General", "Ambient Birds"],
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
    ["Ambient Fire","Explosions may start fires that spread with the wind.\nUnticking puts out all fires and stops new ones."],
    ["MCCMK General", "Ambient Fire"],
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
    ["MCCMK General", "Ambient Fire"],
    [0,100,50,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;

//Ambient Fire explosives burn chance
[
    "MCC_fnc_ambientFireInitExplosivesBurnChance",
    "SLIDER",
    ["Explosives rounds fire chance","Chance an explosive round starts a new fire. Also\naffects the chance of non-explosive rounds starting one"],
    ["MCCMK General", "Ambient Fire"],
    [0,100,3,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;


//Ambient Fire spread chance
[
    "MCC_ambientFireSpreadChance",
    "SLIDER",
    ["Fire spread chance","Chance a burning tree or house starts a new fire around\nit. Lower = fires stay smaller."],
    ["MCCMK General", "Ambient Fire"],
    [0,100,40,0],
    true,
    {},
    false
] call CBA_Settings_fnc_init;

//Ambient Fire crew burn chance
[
    "MCC_fnc_ambientFireInitCrewBurnChance",
    "SLIDER",
    ["Burning crew escape chance","Chance of each crew member of a destroyed vehicle\ncatching fire and running out of it"],
    ["MCCMK General", "Ambient Fire"],
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
    ["MCCMK General", "Ambient Fire"],
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
    ["MCCMK General", "Artillery"],
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
    ["MCCMK General", "Artillery"],
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
    "MCCMK General",
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
    ["Disable MCC Zeus Edit","Disable the custom MCC interface when editing an object\nin Zeus"],
    "MCCMK General",
    false,
    false
] call CBA_Settings_fnc_init;

//Logistics
[
    "MCC_allowlogistics",
    "CHECKBOX",
    ["Logistics System","Allows player to load equipment, vehicles, resources\nand items into vehicles"],
    "MCCMK General",
    true,
    true
] call CBA_Settings_fnc_init;

//Armed Civilians Weapons
[
    "MCC_armedCivilansWeapons",
    "EDITBOX",
    ["Armed Civilians Weapons","Armed Civilians default Weapons"],
    "MCCMK General",
    '["hgun_P07_F","hgun_Rook40_F","hgun_ACPC2_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","SMG_01_F","SMG_02_F","hgun_PDW2000_F"]',
    true,
    {
        params ["_value"];
        MCC_armedCivilansWeapons = [_value, '["hgun_P07_F","hgun_Rook40_F","hgun_ACPC2_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","SMG_01_F","SMG_02_F","hgun_PDW2000_F"]', "MCC_armedCivilansWeapons"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;
//Hostile civilians
[
    "MCC_hostileCivAmount",
    "SLIDER",
    ["Hostile Civilian Amount","Multiplies how many armed civilians and suicide bombers\ngenerated and campaign missions create.\n1 = original MCC amount, 0.5 = about half, 2 = about\ndouble, 0 = none.\nExample at 1: 120 enemies and 2 objectives give about\n13 armed civilians and 7 suicide bombers.\nOrdinary civilians aren't affected."],
    ["MCCMK General", "Hostile Civilians"],
    [0, 4, 1, 2],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_armedCivReactDist",
    "SLIDER",
    ["Armed Civilian Reaction Distance","How close (metres) a player-side unit must come before\nan armed civilian may draw a weapon. Original MCC: 25.\nIED ambush leaders and ambient civilians keep their own\ndistances."],
    ["MCCMK General", "Hostile Civilians"],
    [5, 100, 25, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_armedCivDrawChance",
    "SLIDER",
    ["Armed Civilian Draw Chance","Chance (percent) an armed civilian draws a weapon at\neach check, every 2 s while a player-side unit is\nwithin the reaction distance. Original MCC: 15 (about\n56% after 10 s, 80% after 20 s)."],
    ["MCCMK General", "Hostile Civilians"],
    [1, 100, 15, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_bomberReactDist",
    "SLIDER",
    ["Suicide Bomber Reaction Distance","How close (metres) a player-side unit or crewed vehicle\nmust come before a suicide bomber arms and moves in.\nOriginal MCC: 100. Under 40 m it runs at the target and\ndetonates at about 15 m."],
    ["MCCMK General", "Hostile Civilians"],
    [20, 300, 100, 0],
    true
] call CBA_Settings_fnc_init;


// ==================== SQL PDA ==========================================

//SQL PDA
[
    "MCC_allowsqlPDA",
    "CHECKBOX",
    ["SQL PDA Enabled","Any team leader will have access to a PDA with a Blue\nForce tracker"],
    ["MCCMK General", "Squad Leader PDA"],
    true,
    true
] call CBA_Settings_fnc_init;

//MCC's own Zeus
[
    "MCC_giveZeus",
    "CHECKBOX",
    ["Give MCC's Zeus","Ticked (original): the mission maker gets MCC's Zeus\nwhen logging in or opening the MCC console.\nUntick to use your own Game Master module instead.\nPlayers who already own a Zeus keep it."],
    "MCCMK General",
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_zonesPersonal",
    "SLIDER",
    ["Map zones opacity (personal)","How strongly the campaign territory squares are drawn\non YOUR map - only on your computer. 1 = as the mission\nmaker set them, 0 = hidden."],
    ["MCCMK General","Map"],
    [0, 1, 1, 2],
    false,
    {[] call MCCMK_fnc_zonesPersonalApply}
] call CBA_Settings_fnc_init;

//(MK) Swimming - after "Swim Faster" by Alkanet (MCCMK_fnc_swimFaster)
[
    "MCCMK_swimFaster",
    "CHECKBOX",
    ["Swim faster", "Faster swimming and diving (after 'Swim Faster' by Alkanet,\nused with permission): normal and Shift swimming alike,\ndiving with or without a weapon. Off: vanilla speeds."],
    ["MCCMK General", "Swimming"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_swimSurface",
    "LIST",
    ["Swim faster: surface speed", "Swimming on the surface, times vanilla speed\n(1.5x: as Swim Faster)."],
    ["MCCMK General", "Swimming"],
    [[0, 1, 2, 3], ["1.25x", "1.5x", "1.75x", "2x"], 1],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_swimDive",
    "LIST",
    ["Swim faster: diving speed", "Diving, times vanilla speed\n(1.5x: as Swim Faster)."],
    ["MCCMK General", "Swimming"],
    [[0, 1, 2, 3], ["1.25x", "1.5x", "1.75x", "2x"], 1],
    true
] call CBA_Settings_fnc_init;
