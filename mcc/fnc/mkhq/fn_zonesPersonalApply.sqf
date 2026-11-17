// (this computer) The personal "Map zones opacity" changed: every campaign tile is redrawn with it.
if (!hasInterface) exitWith {};
if (isNil "MCCMK_tileBase") then {MCCMK_tileBase = createHashMap};
private _old = missionNamespace getVariable ["MCCMK_zonesApplied", 1];
// tiles drawn before this player's setting was first used: their current alpha is the base
{
	if (((_x select [0, 18]) isEqualTo "MCCCampaignMarker_") && {!(_x in MCCMK_tileBase)}) then {
		MCCMK_tileBase set [_x, if (_old > 0.001) then {(markerAlpha _x) / _old} else {markerAlpha _x}];
	};
} forEach allMapMarkers;
{[_x, _y] call MCCMK_fnc_tileDraw} forEach (+MCCMK_tileBase);
MCCMK_zonesApplied = ((missionNamespace getVariable ["MCCMK_zonesPersonal", 1]) max 0) min 1;
