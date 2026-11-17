/*
	MCCMK_fnc_feedDist - the view distance of the MCC console's unit feed (the slider under the feed, 9298, and its label
	9299). The slider is a share of the view distance for the unit watched (MCCMK_fnc_vdFor: with TAW View Distance, TAW's
	distance for what he is in - foot, vehicle or air; else the player's own) - fully right is that distance (nothing
	beyond the view distance is loaded for any camera to see), halfway half of it - the label follows it as the unit changes - kept in the profile as that share (half to
	start with), so it keeps its place if the view distance is changed. The label shows the distance it gives (300 m at
	least). Arma's picture-in-picture view distance is set to it while the feed runs, and put back as it was when the feed
	stops (it is the game's, for every picture-in-picture - mirrors, screens - so it is not left changed).
	["load", slider] / ["set", share] / ["apply"] / ["restore"]
*/
disableSerialization;
params [["_mode", "load", [""]], ["_v", 0]];
private _frac = ((profileNamespace getVariable ["MCCMK_feedFrac", 0.5]) max 0.05) min 1;
private _full = ["full", missionNamespace getVariable ["UMName", objNull]] call MCCMK_fnc_vdFor;
private _distOf = {params ["_f"]; ((round ((_f * _full) / 100)) * 100) max 300};
private _label = {
	params ["_d", "_m"];
	private _t = if (_m < 1000) then {format ["%1 m", round _m]} else {format ["%1 km", (_m / 1000) toFixed 1]};
	private _c = _d displayCtrl 9299;
	if (isNull _c) exitWith {};
	if ((ctrlText _c) == _t && {(missionNamespace getVariable ["MCCMK_feedLblShown", ""]) == _t}) exitWith {};	// (the same - not shown again)
	MCCMK_feedLblShown = _t;
	_c ctrlSetText _t;
	// shown, then faded out 3 s later (a newer change starts the 3 s again)
	_c ctrlSetFade 0;
	_c ctrlCommit 0;
	MCCMK_feedLblTok = (missionNamespace getVariable ["MCCMK_feedLblTok", 0]) + 1;
	[_c, MCCMK_feedLblTok] spawn {
		disableSerialization;
		params ["_c", "_tok"];
		uiSleep 3;
		if (isNull _c || {(missionNamespace getVariable ["MCCMK_feedLblTok", 0]) != _tok}) exitWith {};
		_c ctrlSetFade 1;
		_c ctrlCommit 0.6;
	};
};
switch (_mode) do {
	case "load": {
		_v sliderSetRange [0.05, 1];
		_v sliderSetSpeed [0.05, 0.2];
		_v sliderSetPosition _frac;
		MCCMK_feedLblShown = "";
		[ctrlParent _v, [_frac] call _distOf] call _label;
	};
	case "set": {
		_frac = (_v max 0.05) min 1;
		profileNamespace setVariable ["MCCMK_feedFrac", _frac];
		[uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull], [_frac] call _distOf] call _label;
		if (!isNil "MCC_PIPcam" && {!isNull MCC_PIPcam}) then {["apply"] call MCCMK_fnc_feedDist};
	};
	case "apply": {
		if (isNil "MCCMK_pipVD0") then {MCCMK_pipVD0 = getPiPViewDistance};
		setPiPViewDistance ([_frac] call _distOf);
		[uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull], [_frac] call _distOf] call _label;	// (the unit may have changed)
		["start", "feed", {missionNamespace getVariable ["UMName", objNull]}] call MCCMK_fnc_vdFor;
	};
	case "restore": {
		if (!isNil "MCCMK_pipVD0") then {setPiPViewDistance MCCMK_pipVD0; MCCMK_pipVD0 = nil};
		["stop", "feed"] call MCCMK_fnc_vdFor;
	};
};
