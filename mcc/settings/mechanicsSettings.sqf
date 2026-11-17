if (count (allMissionObjects "MCC_Module_settingsMechanics") == 0) then {
    //Weapon Change
    [
        "MCC_quickWeaponChange",
        "CHECKBOX",
        ["Weapons Binds","Bind weapon to the 1 - 4 keys"],
        "MCCMK Mechanics",
        false,
        false
    ] call CBA_Settings_fnc_init;

    //Arcade tanks
    [
        "MCC_arcadeTanks",
        "CHECKBOX",
        ["One Man Tanks","Player can operate a tank by his own driving and\nshooting"],
        "MCCMK Mechanics",
        false,
        true
    ] call CBA_Settings_fnc_init;

    //Fatigue / stamina
    // The checkbox means "stamina ON" and has its own variable; MCC_disableFatigue keeps the meaning the rest of MCC gives
    // it ("stamina OFF": Mechanics module, Zeus dialog, respawn), so the respawn applies the choice the right way round.
    [
        "MCC_fatigueEnabled",
        "CHECKBOX",
        ["Fatigue / Stamina","Players get tired when running (stamina). Kept after\nrespawn."],
        "MCCMK Mechanics",
        true,
        true,
        {
            params [["_on", true, [true]]];
            missionNamespace setVariable ["MCC_disableFatigue", !_on];
            if (!isNull player) then {player enableStamina _on};
            if (!isNil "MCC_fnc_log") then {["INFO", "mechanicsSettings", "addon option: stamina %1", [["OFF","ON"] select _on]] call MCC_fnc_log};
        }
    ] call CBA_Settings_fnc_init;

    //(MK) Dropped items cleanup (MCCMK_fnc_dropCleanup)
    [
        "MCCMK_dropCleanup",
        "SLIDER",
        ["Dropped items cleanup (minutes)", "Piles of dropped weapons and items (left by players,\nby dead units outside generated missions, or by a\nbroken-down crate) are removed this long after, once no\nplayer is within 50 m or looking.\nKept: anything near an HQ or F.O.B., and weapons beside\nenemy bodies - the mission cleanup removes those.\n0 = off."],
        "MCCMK Mechanics",
        [0, 120, 30, 0],
        true
    ] call CBA_Settings_fnc_init;

    //(MK) Body cleanup (in the dropped-items cleanup's pass)
    [
        "MCCMK_bodyCleanup",
        "SLIDER",
        ["Body cleanup (minutes)", "Bodies no mission owns (enemy and friendly AI, at\nbases too) are removed this long after death, with\nthe weapons beside them, once no player is within 50 m\nor looking. Players' own bodies after twice the time.\n0 = off."],
        "MCCMK Mechanics",
        [0, 120, 30, 0],
        true
    ] call CBA_Settings_fnc_init;

    //(MK) Wreck salvage
    [
        "MCCMK_salvageRewards",
        "CHECKBOX",
        ["Salvage rewards", "Salvaging an ENEMY wreck your side never bought or\ncrewed gives about 10% of its price (Supply, Ammo,\nFuel). Your own and civilian wrecks clear for nothing.\nNo reward when costs are Free."],
        "MCCMK Mechanics",
        true,
        true
    ] call CBA_Settings_fnc_init;
    [
        "MCCMK_salvageAutoBase",
        "CHECKBOX",
        ["Clear base wrecks automatically", "Wrecks within 300 m of an RTS HQ are removed two\nminutes after they're destroyed (no reward)."],
        "MCCMK Mechanics",
        false,
        true
    ] call CBA_Settings_fnc_init;

    //3DTagging
    [
        "MCC_allow3DSpotting",
        "CHECKBOX",
        ["3D Tagging","Squad leader enemy tags and markers will be visible on\nHUD"],
        "MCCMK Mechanics",
        true,
        true
    ] call CBA_Settings_fnc_init;

    // ================================ COVER =========================================
    //Cover system
    [
        "MCC_cover",
        "CHECKBOX",
        ["Cover System","Players will automatically pop up or side out of cover\nwhile aiming down sights"],
       ["MCCMK Mechanics", "Cover"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //Cover system UI
    [
        "MCC_coverUI",
        "CHECKBOX",
        ["Cover System UI","Show icons on HUD when in cover"],
       	["MCCMK Mechanics", "Cover"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //Vault
    [
        "MCC_coverVault",
        "CHECKBOX",
        ["Vault System","Allow players to vault over walls and obstacles - see\nCBA keybinds"],
        ["MCCMK Mechanics", "Cover"],
        false,
        false
    ] call CBA_Settings_fnc_init;


    //============================ Interaction ====================================
    //Interaction
    [
        "MCC_interaction",
        "CHECKBOX",
        ["Interaction System","Players can interact with objects and themselves - see\nCBA keybinds"],
       ["MCCMK Mechanics", "Interaction"],
        true,
        true
    ] call CBA_Settings_fnc_init;

    //Interaction
    [
        "MCC_ingameUI",
        "CHECKBOX",
        ["Interaction System UI","Show icons on HUD when interaction is available"],
       ["MCCMK Mechanics", "Interaction"],
        true,
        true
    ] call CBA_Settings_fnc_init;

    /* =========================	SURVIVE MOD	========================================*/

    //Survive mod
    [
       "MCC_surviveModAllowSearch_index",
       "LIST",
       ["Survival Mode","Players can loot map objects and need to drink and eat"],
       ["MCCMK Mechanics", "Survival"],
       [[0,1,2],["Disabled","Enabled, with loot searching","Enabled, without loot searching"],0],
        true,
        {
        	MCC_surviveMod = MCC_surviveModAllowSearch_index > 0;
            MCC_surviveModAllowSearch = (MCC_surviveModAllowSearch_index == 1);
        }
    ] call CBA_Settings_fnc_init;

    //ACE: where the survival "Search" action is (GitHub #46)
    [
        "MCC_aceSearchMenu",
        "LIST",
        ["ACE: Search action in","Where survival mode's Search appears with ACE.\nInteraction menu only works on objects with a class;\nmany CUP/Arma 2 terrain props have none, so Both is\nsafest there."],
        ["MCCMK Mechanics", "Survival"],
        [[0,1,2],["Self-interaction","Interaction menu","Both"],0],
        true,
        {
            params ["_value"];
            if (_value > 0) then {[] spawn MCC_fnc_aceSearchActionInit};
        }
    ] call CBA_Settings_fnc_init;

    //Load Player Position
    [
        "MCC_surviveModPlayerPos",
        "CHECKBOX",
        ["Load Player Position","Load last known player position on mission start"],
        ["MCCMK Mechanics", "Survival"],
        false,
        true
    ] call CBA_Settings_fnc_init;

    //LLoad Player Gear
    [
        "MCC_surviveModPlayerGear",
        "CHECKBOX",
        ["Load Player Gear","Load last known player gear on mission start"],
        ["MCCMK Mechanics", "Survival"],
        false,
        true
    ] call CBA_Settings_fnc_init;

    //Load Player Stats 
    [
        "MCC_surviveModPlayerStats",
        "CHECKBOX",
        ["Load Player Stats","Load last known player stats on mission start"],
        ["MCCMK Mechanics", "Survival"],
        false,
        true
    ] call CBA_Settings_fnc_init;

    // ====================================== AMMO TYPE ========================================================

    //Breaching Ammo
    [
        "MCC_breacingAmmo",
        "EDITBOX",
        ["Breaching Ammo","Shooting this ammo from less then 10 meters will unlock\ndoors"],
        ["MCCMK Mechanics", "Ammo Type"],
        '["prpl_8Rnd_12Gauge_Slug","prpl_6Rnd_12Gauge_Slug","rhsusf_8Rnd_Slug","rhsusf_5Rnd_Slug"]',
        true,
        {
            params ["_value"];
            MCC_breacingAmmo = [_value, '["prpl_8Rnd_12Gauge_Slug","prpl_6Rnd_12Gauge_Slug","rhsusf_8Rnd_Slug","rhsusf_5Rnd_Slug"]', "MCC_breacingAmmo"] call MCC_fnc_parseSetting;
        }
    ] call CBA_Settings_fnc_init;

    //Non Lethal Ammo
    [
        "MCC_nonLeathalAmmo",
        "EDITBOX",
        ["Non Lethal Ammo","Shooting this ammo from less then 10 meters will unlock\ndoors"],
        ["MCCMK Mechanics", "Ammo Type"],
        '["prpl_8Rnd_12Gauge_Slug","prpl_6Rnd_12Gauge_Slug","rhsusf_8Rnd_Slug","rhsusf_5Rnd_Slug"]',
        true,
        {
            params ["_value"];
            MCC_nonLeathalAmmo = [_value, '["prpl_8Rnd_12Gauge_Slug","prpl_6Rnd_12Gauge_Slug","rhsusf_8Rnd_Slug","rhsusf_5Rnd_Slug"]', "MCC_nonLeathalAmmo"] call MCC_fnc_parseSetting;
        }
    ] call CBA_Settings_fnc_init;
};