// A Taru supply pod's cost [Ammo, Supply, Fuel, Meds] (Addon Options; the flight is included). [pod index 0-6]
// (MK) 5 Transport, 6 Bench: empty passenger pods - the flight only (no Addon Option)
params [["_i", 0, [0]]];
private _var = ["MCCMK_podCostFuel", "MCCMK_podCostRepair", "MCCMK_podCostAmmo", "MCCMK_podCostMedical", "MCCMK_podCostLogistics"] param [_i, ""];
private _def = [[0, 0, 250, 0], [0, 200, 50, 0], [200, 0, 50, 0], [0, 0, 50, 75], [0, 150, 50, 0], [0, 50, 50, 0], [0, 50, 50, 0]] param [_i, [0, 0, 0, 0]];
private _c = ((missionNamespace getVariable [_var, ""]) splitString ", ") apply {parseNumber _x};
if (count _c < 4) then {_def} else {_c}
