/*====================================================== MCC_fnc_campaignTileAlpha ========================================================================
	Get a campaign tile's intensity (0-1) as set by MCC_fnc_campaignTileSetAlpha.
	Falls back to the marker's own alpha for tiles set before the store existed.

	<IN>	0: STRING marker name
	<OUT>	NUMBER intensity
==========================================================================================================================================================*/
params [["_marker", "", [""]]];
if (_marker == "") exitWith {0};
(missionNamespace getVariable ["MCC_campaignTileAlphaMap", createHashMap]) getOrDefault [_marker, markerAlpha _marker]
