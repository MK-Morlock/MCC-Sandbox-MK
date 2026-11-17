// (server) The mission maker's "Map zones" slider (MCC console, cog panel): how strongly the campaign territory tiles
// are drawn for everyone - 1 = full, 0 = hidden. The same value as the Campaign init module's "Map Overlay
// Transparency" (reversed); the tiles' intensity (which also drives enemy patrols) isn't touched. [opacity 0-1]
params [["_o", 1, [0]]];
if (!isServer) exitWith {[_o] remoteExecCall ["MCCMK_fnc_zonesOpacity", 2]};
_o = (_o max 0) min 1;
missionNamespace setVariable ["MCC_campaignTileTransparency", 1 - _o, true];
{[_x, _y] call MCC_fnc_campaignTileSetAlpha} forEach (+(missionNamespace getVariable ["MCC_campaignTileAlphaMap", createHashMap]));
