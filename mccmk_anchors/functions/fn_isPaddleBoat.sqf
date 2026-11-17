/*
    ANC_fnc_isPaddleBoat
    True if Paddle Mod is loaded and this is one of Paddle Mod's boats - its own
    list: Rubber_duck_base_F (Zodiacs), Boat_Armed_01_Base_F (Speedboats),
    Boat_Civil_01_Base_F (Motorboat), Boat_Transport_02_base_F (RHIB), ASH_MKVSOC / rhsusf_mkvsoc (Mk V SOC) - without
    D41_Trawler and TxT_LCS1, and without the boats Paddle Mod rejects for its rope features (SDV, Sailing Mod boat).
*/
params [["_boat", objNull, [objNull]]];
if (isNull _boat || {!isClass (configFile >> "CfgPatches" >> "PaddleMod")}) exitWith {false};
private _t = typeOf _boat;
if (_t in ["D41_Trawler", "TxT_LCS1"]) exitWith {false};
if (_boat isKindOf "SDV_01_base_F" || {_boat isKindOf "sab_Boat_01_base_F"}) exitWith {false};
(["Rubber_duck_base_F", "Boat_Armed_01_Base_F", "Boat_Civil_01_Base_F", "Boat_Transport_02_base_F", "ASH_MKVSOC", "rhsusf_mkvsoc"] findIf {_boat isKindOf _x}) != -1
