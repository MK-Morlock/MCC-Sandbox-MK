/*
    ANC_fnc_builtIn
    - true if the mission has Anchors built in (its functions are TANC_fnc_*): then this mod stands
    aside - no settings, keys, drift or lines of its own - so boats are never handled twice. The mission's is used.
*/
isClass (missionConfigFile >> "CfgFunctions" >> "TANC")
