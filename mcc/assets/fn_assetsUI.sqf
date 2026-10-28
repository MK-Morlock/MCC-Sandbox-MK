/*================================================================== MCC_fnc_assetsUI ==================================================================
	The console Assets page (dialog MCC_AssetsDialog). Run scheduled: ["mode"] spawn MCC_fnc_assetsUI.
	Modes: init, faction, selectSlot, previewList, previewCand, add, remove, resetSlot, resetAll, copy, showAll
	The preset belongs to the enemy faction selected in the console (mcc_faction); the faction list at the top changes it.
==============================================================================================================================================================*/
#define IDD_ASSETS 1031985
#define IDC_TITLE 9501
#define IDC_SLOTS 9502
#define IDC_INFO 9503
#define IDC_LIST 9504
#define IDC_CANDS 9506
#define IDC_SHOWALL 9508
#define IDC_COPYFROM 9511
#define IDC_FACTION 9520
#define IDC_PREVTITLE 9532
disableSerialization;
params [["_mode", "init", [""]]];
private _d = findDisplay IDD_ASSETS;
if (isNull _d) exitWith {};

private _faction = call MCC_fnc_MWEnemyFaction;	//presets are for the Mission Generator enemy faction
private _factionName = getText (configFile >> "CfgFactionClasses" >> _faction >> "displayName");
private _slots = ["slots"] call MCC_fnc_assetsData;
private _preset = ["get", [_faction]] call MCC_fnc_assetsData;
private _ctrlSlots = _d displayCtrl IDC_SLOTS;
private _slotIndex = uiNamespace getVariable ["MCC_assetsCurrentSlot", 0];
if (_mode == "selectSlot" && {lbCurSel _ctrlSlots >= 0}) then {
	_slotIndex = lbCurSel _ctrlSlots;
	uiNamespace setVariable ["MCC_assetsCurrentSlot", _slotIndex];
};
if (_mode == "init" && {isNil {uiNamespace getVariable "MCC_assetsCurrentSlot"}}) then {_slotIndex = 0};
_slotIndex = (_slotIndex max 0) min (count _slots - 1);
private _slot = _slots select _slotIndex;
_slot params ["_id", "_label", "_var", "_role", "_group"];

private _listOf = {
	params ["_sid"];
	private _e = _preset select {(_x select 0) == _sid};
	if (count _e > 0) then {+((_e select 0) select 1)} else {[]}
};
private _save = {
	params ["_sid", "_list"];
	private _i = _preset findIf {(_x select 0) == _sid};
	if (_i < 0) then {_preset pushBack [_sid, _list]} else {_preset set [_i, [_sid, _list]]};
	["set", [_faction, _preset]] call MCC_fnc_assetsData;
};
private _nameOf = {
	params ["_c"];
	private _n = getText (configFile >> "CfgVehicles" >> _c >> "displayName");
	if (_n == "") then {format ["%1 (not loaded)", _c]} else {format ["%1 (%2)", _n, _c]}
};
private _refreshSlots = {
	private _sel = uiNamespace getVariable ["MCC_assetsCurrentSlot", 0];
	lbClear _ctrlSlots;
	{
		_x params ["_sid", "_slabel"];
		private _n = count ([_sid] call _listOf);
		_ctrlSlots lbAdd format ["%1  -  %2", _slabel, if (_n == 0) then {"Auto"} else {format ["%1 chosen", _n]}];
		_ctrlSlots lbSetColor [_forEachIndex, [[0.85,0.85,0.85,1], [0.77,0.51,0.08,1]] select (_n > 0)];
	} forEach _slots;
	_ctrlSlots lbSetCurSel _sel;
};

private _preview = {
	params ["_c"];
	if (_c == "") exitWith {};
	["show", [_c]] call MCC_fnc_assetsPreview;
	(_d displayCtrl IDC_PREVTITLE) ctrlSetText ("Preview: " + getText (configFile >> "CfgVehicles" >> _c >> "displayName"));
};

switch (_mode) do {
	case "init": {
		//Mouse control of the 3D preview (added once per page)
		if ((uiNamespace getVariable ["MCC_assetPrevAttached", displayNull]) != _d) then {
			["attach", [_d]] call MCC_fnc_assetsPreview;
			uiNamespace setVariable ["MCC_assetPrevAttached", _d];
		};
		(_d displayCtrl IDC_TITLE) ctrlSetText format ["MCC Assets for %1 - Used for the tasks and supports listed below.", if (_factionName == "") then {"(no faction)"} else {_factionName}];
		//Enemy faction list (the MCC console list)
		private _cfac = _d displayCtrl IDC_FACTION;
		lbClear _cfac;
		{_cfac lbAdd format ["%1 (%2)", _x select 0, _x select 1]} forEach (missionNamespace getVariable ["U_FACTIONS", []]);
		_cfac lbSetCurSel (((missionNamespace getVariable ["U_FACTIONS", []]) findIf {toLower (_x select 2) == toLower _faction}) max 0);
		uiNamespace setVariable ["MCC_assetShowAll", false];
		(_d displayCtrl IDC_SHOWALL) ctrlSetText "Show all mods: Off";
		call _refreshSlots;
		//Copy-from list: factions that have a preset
		private _cf = _d displayCtrl IDC_COPYFROM;
		lbClear _cf;
		{
			if (toLower _x != toLower _faction) then {
				private _i = _cf lbAdd (getText (configFile >> "CfgFactionClasses" >> _x >> "displayName") + " (" + _x + ")");
				_cf lbSetData [_i, _x];
			};
		} forEach (["factions"] call MCC_fnc_assetsData);
		if (lbSize _cf == 0) then {_cf lbAdd "(no other presets)"; _cf lbSetData [0, ""]};
		_cf lbSetCurSel 0;
		_ctrlSlots lbSetCurSel _slotIndex;
		["selectSlot"] spawn MCC_fnc_assetsUI;
	};

	case "faction": {
		//Change the Mission Generator enemy faction (the console faction, the player's side, is not changed)
		private _i = lbCurSel (_d displayCtrl IDC_FACTION);
		private _list = missionNamespace getVariable ["U_FACTIONS", []];
		if (_i < 0 || {_i >= count _list} || {toLower ((_list select _i) select 2) == toLower _faction}) exitWith {};
		MCC_MWEnemyFaction = (_list select _i) select 2;
		["apply", [MCC_MWEnemyFaction]] call MCC_fnc_assetsData;
		["init"] spawn MCC_fnc_assetsUI;
	};

	case "previewList": {
		private _ctrlList = _d displayCtrl IDC_LIST;
		[_ctrlList lbData (lbCurSel _ctrlList)] call _preview;
	};

	case "previewCand": {
		//Ignore the selection made while the list is being filled (only a pick by the player previews)
		if (diag_tickTime - (uiNamespace getVariable ["MCC_assetCandFillTime", -10]) < 0.5) exitWith {};
		private _ctrlCands = _d displayCtrl IDC_CANDS;
		[_ctrlCands lbData (lbCurSel _ctrlCands)] call _preview;
	};

	case "selectSlot": {
		//What Auto picks, and the list for this slot
		private _support = _group == "Support";
		private _autoFaction = if (_support) then {faction player} else {_faction};
		private _auto = if (_role in ["cache", "radio", "radar", "fuel", "intel"]) then {
			(["list", [missionNamespace getVariable ["MCC_assetBase_" + _var, missionNamespace getVariable [_var, []]]]] call MCC_fnc_assetsData)
		} else {
			[_autoFaction, _role] call MCC_fnc_factionVehicles
		};
		//Nothing of that kind in the faction: what MCC falls back to
		if (count _auto == 0) then {
			_auto = switch (_id) do {
				case "gunship": {["B_T_VTOL_01_armed_F"]};
				case "pod": {["O_Heli_Transport_04_F"]};
				case "supply": {["B_Heli_Transport_03_unarmed_F", "O_Heli_Transport_04_F", "I_Heli_Transport_02_F"]};
				case "paradrop": {["B_T_VTOL_01_infantry_F", "O_T_VTOL_02_infantry_F", "I_Heli_Transport_02_F"]};
				default {(["list", [missionNamespace getVariable ["MCC_assetBase_" + _var, missionNamespace getVariable [_var, []]]]] call MCC_fnc_assetsData)};
			};
			_auto = _auto select {isClass (configFile >> "CfgVehicles" >> _x)};
		};
		private _autoText = if (count _auto == 0) then {"the MCC default"} else {((_auto select [0, 3]) apply {[_x] call _nameOf}) joinString ", "};
		if (count _auto > 3) then {_autoText = _autoText + format [" and %1 more", count _auto - 3]};
		private _mine = [_id] call _listOf;
		private _usedText = if (count _mine == 0) then {"Auto"} else {
			format ["your list: %1%2", ((_mine select [0, 3]) apply {[_x] call _nameOf}) joinString ", ", if (count _mine > 3) then {format [" and %1 more", count _mine - 3]} else {""}]
		};
		(_d displayCtrl IDC_INFO) ctrlSetStructuredText parseText format [
			"<t size='0.9' color='#C48214'>%1</t><br/><t size='0.8'>Now used: %4<br/>Auto uses %2: %3<br/>With several entries in your list one is picked at random each time.</t>",
			_label, if (_support) then {"your faction"} else {"the enemy faction (then its mod, then the default list)"}, _autoText, _usedText
		];

		private _ctrlList = _d displayCtrl IDC_LIST;
		lbClear _ctrlList;
		private _list = [_id] call _listOf;
		{
			private _i = _ctrlList lbAdd ([_x] call _nameOf);
			_ctrlList lbSetData [_i, _x];
		} forEach _list;
		if (count _list == 0) then {_ctrlList lbAdd "(empty - Auto)"};

		//Candidates (the first full scan can take a few seconds)
		private _ctrlCands = _d displayCtrl IDC_CANDS;
		lbClear _ctrlCands;
		_ctrlCands lbAdd "Loading...";
		uiNamespace setVariable ["MCC_assetCandFillTime", diag_tickTime];
		_ctrlCands lbSetCurSel 0;
		private _showAll = uiNamespace getVariable ["MCC_assetShowAll", false];
		private _factions = [_faction, faction player] select {_x != ""};
		private _cands = [_role, _showAll, _factions] call MCC_fnc_assetsCandidates;
		if (isNull _d || {(uiNamespace getVariable ["MCC_assetsCurrentSlot", 0]) != _slotIndex}) exitWith {};	//closed or another slot picked meanwhile
		lbClear _ctrlCands;
		{
			private _i = _ctrlCands lbAdd (_x select 0);
			_ctrlCands lbSetData [_i, _x select 1];
		} forEach _cands;
		if (count _cands == 0) then {_ctrlCands lbAdd (if (_showAll) then {"(nothing found)"} else {"(nothing found - try Show all mods)"})};
		uiNamespace setVariable ["MCC_assetCandFillTime", diag_tickTime];
		_ctrlCands lbSetCurSel 0;
		//Preview: what is used now - the first entry of your list, otherwise what Auto picks (so you can see whether it
		//needs changing), otherwise the first suggestion
		[switch (true) do {
			case (count _list > 0): {_list select 0};
			case (count _auto > 0): {_auto select 0};
			default {_ctrlCands lbData 0};
		}] call _preview;
	};

	case "add": {
		private _ctrlCands = _d displayCtrl IDC_CANDS;
		private _c = _ctrlCands lbData (lbCurSel _ctrlCands);
		if (_c == "") exitWith {};
		private _list = [_id] call _listOf;
		_list pushBackUnique _c;
		[_id, _list] call _save;
		call _refreshSlots;
		["selectSlot"] spawn MCC_fnc_assetsUI;
	};

	case "remove": {
		private _ctrlList = _d displayCtrl IDC_LIST;
		private _c = _ctrlList lbData (lbCurSel _ctrlList);
		if (_c == "") exitWith {};
		private _list = ([_id] call _listOf) - [_c];
		[_id, _list] call _save;
		call _refreshSlots;
		["selectSlot"] spawn MCC_fnc_assetsUI;
	};

	case "resetSlot": {
		[_id, []] call _save;
		call _refreshSlots;
		["selectSlot"] spawn MCC_fnc_assetsUI;
	};

	case "resetAll": {
		if !(["<t size='0.8' align='center'>Set every asset of this faction back to Auto?</t>", "MCC Assets", "Reset all", true, true] call MCC_fnc_messageBox) exitWith {};
		_d = findDisplay IDD_ASSETS;
		if (isNull _d) exitWith {};
		["set", [_faction, []]] call MCC_fnc_assetsData;
		["init"] spawn MCC_fnc_assetsUI;
	};

	case "copy": {
		private _cf = _d displayCtrl IDC_COPYFROM;
		private _from = _cf lbData (lbCurSel _cf);
		if (_from == "") exitWith {};
		["set", [_faction, ["get", [_from]] call MCC_fnc_assetsData]] call MCC_fnc_assetsData;
		["init"] spawn MCC_fnc_assetsUI;
	};

	case "showAll": {
		private _on = !(uiNamespace getVariable ["MCC_assetShowAll", false]);
		uiNamespace setVariable ["MCC_assetShowAll", _on];
		(_d displayCtrl IDC_SHOWALL) ctrlSetText (["Show all mods: Off", "Show all mods: On"] select _on);
		["selectSlot"] spawn MCC_fnc_assetsUI;
	};
};
