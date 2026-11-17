/*
    ANC_fnc_aceMenus - Anchors' actions in the ACE menu? Yes with ACE loaded and MCC MK's "MCC actions with ACE" on (the default).
*/
isClass (configFile >> "CfgPatches" >> "ace_interact_menu") && {missionNamespace getVariable ["MCCMK_aceActions", true]}
