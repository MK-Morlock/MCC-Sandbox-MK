// (this computer) Draws a campaign map tile: its alpha x this player's own "Map zones opacity" (Addon Options). The
// base alpha is remembered, so changing the personal setting redraws every tile at once (MCCMK_fnc_zonesPersonalApply).
// While the console has the tiles hidden, the drawn value is kept for when they're shown again. [marker, alpha, hide now]
params [["_m", "", [""]], ["_a", 0, [0]], ["_hideNow", false, [false]]];
if (_m == "") exitWith {};
if (isNil "MCCMK_tileBase") then {MCCMK_tileBase = createHashMap};
MCCMK_tileBase set [_m, _a];
private _v = _a * (((missionNamespace getVariable ["MCCMK_zonesPersonal", 1]) max 0) min 1);
if (missionNamespace getVariable ["MCC_consoleTilesHidden", false]) then {
	MCC_consoleTilesShown set [_m, _v];
	if (_hideNow) then {_m setMarkerAlphaLocal 0};
} else {_m setMarkerAlphaLocal _v};
