disableSerialization;
params [["_mode", "check", [""]]];

private _fnc_open = {
	({!isNull (findDisplay _x)} count [2994, 2993, 5000, 5010, 2996]) > 0
	|| {!isNull (uiNamespace getVariable ["MCC_SQLPDA_rscDisp", displayNull])}
	|| {!isNull (uiNamespace getVariable ["MCC_uavDialog", displayNull])}
};
private _fnc_isTile = {(_this find "MCCCampaignMarker_") == 0};

if (_mode == "start") then {
	//A tile whose strength is not in the campaign's store yet: put it there first, so the campaign never reads the hidden value
	if (isServer && {!isNil "MCC_campaignTileAlphaMap"}) then {
		{if ((_x call _fnc_isTile) && {!(_x in MCC_campaignTileAlphaMap)}) then {MCC_campaignTileAlphaMap set [_x, markerAlpha _x]}} forEach allMapMarkers;
	};
	//Arma's own events, added once
	if (isNil "MCC_consoleTilesEH") then {
		MCC_consoleTilesShown = createHashMap;	//marker -> alpha it had before it was hidden
		MCC_consoleTilesHidden = false;
		MCC_consoleTilesEH = [
			addMissionEventHandler ["Map", {["check"] call MCC_fnc_consoleCampaignTiles}],
			addMissionEventHandler ["MarkerUpdated", {
				params ["_m"];
				if (MCC_consoleTilesHidden && {(_m find "MCCCampaignMarker_") == 0} && {markerAlpha _m > 0}) then {
					MCC_consoleTilesShown set [_m, markerAlpha _m];
					_m setMarkerAlphaLocal 0;
				};
			}]
		];
	};
	//When each open screen closes: check again (the next frame, once it is gone)
	{
		if (!isNull _x && {!(_x getVariable ["MCC_tilesUnloadEH", false])}) then {
			_x setVariable ["MCC_tilesUnloadEH", true];
			_x displayAddEventHandler ["Unload", {[] spawn {uiSleep 0.05; ["check"] call MCC_fnc_consoleCampaignTiles}}];
		};
	} forEach (([2994, 2993, 5000, 5010, 2996] apply {findDisplay _x}) + [uiNamespace getVariable ["MCC_SQLPDA_rscDisp", displayNull], uiNamespace getVariable ["MCC_uavDialog", displayNull]]);
};

if (isNil "MCC_consoleTilesShown") then {MCC_consoleTilesShown = createHashMap; MCC_consoleTilesHidden = false};
private _hide = (call _fnc_open) && {!visibleMap};
if (_hide && {!MCC_consoleTilesHidden}) then {
	MCC_consoleTilesHidden = true;
	{
		if ((_x call _fnc_isTile) && {markerAlpha _x > 0}) then {
			MCC_consoleTilesShown set [_x, markerAlpha _x];
			_x setMarkerAlphaLocal 0;
		};
	} forEach allMapMarkers;
};
if (!_hide && {MCC_consoleTilesHidden}) then {
	MCC_consoleTilesHidden = false;
	//shown again as they were (the latest value seen, so changes made meanwhile are kept)
	{_x setMarkerAlphaLocal _y} forEach MCC_consoleTilesShown;
	MCC_consoleTilesShown = createHashMap;
};
