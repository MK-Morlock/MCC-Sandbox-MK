/*====================================================== MCC_fnc_campaignTileSetAlpha =====================================================================
	Set a campaign tile's intensity (0-1).

	The intensity is campaign data, not just looks: it is the chance enemy patrols spawn on that tile
	(fn_campaignSpawnAIInit) and it is saved to the campaign DB (fn_saveServer). It is stored on the
	server and read back with MCC_fnc_campaignTileAlpha.

	The Campaign init module's "Map Overlay Transparency" (MCC_campaignTileTransparency, 0-1) only changes
	how the marker is drawn: drawn alpha = intensity x (1 - transparency). 0 = normal, 1 = hidden.
	The stored intensity keeps working as normal, so shading differences between tiles are kept.

	<IN>	0: STRING marker name (MCCCampaignMarker_x_y)
			1: NUMBER intensity 0-1
	<OUT>	nothing
==========================================================================================================================================================*/
params [["_marker", "", [""]], ["_alpha", 0.2, [0]]];
if (_marker == "") exitWith {};

// The intensity store lives on the server - forward calls made anywhere else
if (!isServer) exitWith {[_marker, _alpha] remoteExecCall ["MCC_fnc_campaignTileSetAlpha", 2]};

if (isNil "MCC_campaignTileAlphaMap") then {MCC_campaignTileAlphaMap = createHashMap};
MCC_campaignTileAlphaMap set [_marker, _alpha];

private _transparency = ((missionNamespace getVariable ["MCC_campaignTileTransparency", 0]) max 0) min 1;
private _drawn = _alpha * (1 - _transparency);
if (hasInterface && {missionNamespace getVariable ["MCC_consoleTilesHidden", false]}) then {MCC_consoleTilesShown set [_marker, _drawn]} else {_marker setMarkerAlphaLocal _drawn};
[_marker, "", _drawn] call MCCMK_fnc_tileQueue;
