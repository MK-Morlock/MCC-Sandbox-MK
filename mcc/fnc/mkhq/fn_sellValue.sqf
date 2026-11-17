params [["_v", objNull, [objNull]], ["_cat", "", [""]], ["_rec", [], [[]]], ["_toCredits", false, [true]]];
private _dmg = if (missionNamespace getVariable ["MCCMK_sellDamage", true]) then {1 - (damage _v)} else {1};
if (_cat == "bought") exitWith {
	private _pct = ((missionNamespace getVariable ["MCCMK_sellBought", 60]) / 100) * _dmg;
	if ((_rec select 0) == "res") then {["res", (_rec select 1) apply {floor (_x * _pct)}]} else {["cr", floor ((_rec select 1) * _pct)]}
};
private _cost = [_v] call MCCMK_fnc_salvageCost;	// the same worth as salvage (drones, boats by size, capped add-ons)
private _pct = ((missionNamespace getVariable ["MCCMK_sellSeized", 40]) / 100) * _dmg;
if (_toCredits) then {["cr", floor (_cost * 0.3 * _pct)]} else {["res", [floor (_cost * 0.3 * 0.2 * _pct), floor (_cost * 0.5 * 0.2 * _pct), floor (_cost * 0.2 * 0.2 * _pct)]]}
