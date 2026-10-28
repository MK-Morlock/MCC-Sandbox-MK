#define TYPE_IDC 3012
#define BRANCH_IDC 3010
#define CLASS_IDC 3011
disableSerialization;
params [["_mode", "branch", [""]], ["_evIndex", -1, [0]]];
if (missionNamespace getVariable ["MCC_spawnListsBusy", false]) exitWith {};	//our own Branch refill fires the Branch event too
private _d = findDisplay 2994;
if (isNull _d) exitWith {};
private _cType = _d displayCtrl TYPE_IDC;
private _cBranch = _d displayCtrl BRANCH_IDC;
private _cClass = _d displayCtrl CLASS_IDC;
if (isNull _cType || {isNull _cBranch} || {isNull _cClass}) exitWith {};

//Type: the row the Type event reported, otherwise the list
private _typeRow = if (_mode == "type" && {_evIndex >= 0}) then {_evIndex} else {lbCurSel _cType};
if (_mode == "type") then {["DEBUG", "fn_spawnLists", "Type changed: event row %1, list row %2 (%3)", [_evIndex, lbCurSel _cType, _cType lbText (lbCurSel _cType)]] call MCC_fnc_log};	//(debug logging)
private _groups = _typeRow == 1;
if (_mode == "type" && {_evIndex >= 0}) then {MCC_spawnTypeMem = _typeRow};
private _singles = ["Infantry", "Vehicles", "Tracked/Static", "Motorcycle", "Helicopter", "Fixed-wing", "Ship", "Ammo"];
private _faction = missionNamespace getVariable ["mcc_faction", ""];
private _wanted = [["units", "groups"] select _groups, _faction];
private _built = _cBranch getVariable ["MCC_spawnBranchFor", []];
private _mismatch = !(_built isEqualTo _wanted) || {lbSize _cBranch == 0};

//"sync": nothing to do while the lists belong to what is shown
if (_mode == "sync" && {!_mismatch}) exitWith {};

//Remembered branch, separately for Units (row) and Groups (category name)
private _mem = missionNamespace getVariable ["MCC_spawnBranchMem", [0, ""]];

//---------------------------------------------------------------- Branch list ----------------------------------------------------------------
if (_mode in ["type", "open", "sync"] || {_mismatch}) then {
	MCC_spawnListsBusy = true;	//lbClear / lbSetCurSel below fire the Branch event; it must not run half way through
	lbClear _cBranch;
	private _sel = 0;
	if (_groups) then {
		{
			private _i = _cBranch lbAdd (_x select 1);
			_cBranch lbSetData [_i, _x select 0];
			if ((_x select 0) == (_mem select 1)) then {_sel = _i};
		} forEach (missionNamespace getVariable ["MCC_groupTypes", []]);
	} else {
		{_cBranch lbSetData [_cBranch lbAdd _x, str _forEachIndex]} forEach _singles;
		_sel = _mem select 0;
	};
	if (_sel < 0 || {_sel >= lbSize _cBranch}) then {_sel = 0};
	_cBranch lbSetCurSel _sel;
	_cBranch setVariable ["MCC_spawnBranchFor", _wanted];
	MCC_spawnListsBusy = false;
	if (_mismatch && {_mode in ["branch", "sync"]}) then {
		["DEBUG", "fn_spawnLists", "Branch list did not match Type %1 / faction %2 (built for %3) - rebuilt (%4)", [_wanted select 0, _faction, _built, _mode]] call MCC_fnc_log;
	};
	_evIndex = -1;	//the event row belonged to the old list
};

MCC_type_index = [0, 1] select _groups;
private _b = if (_mode == "branch" && {_evIndex >= 0}) then {_evIndex} else {lbCurSel _cBranch};
if (_b < 0 || {_b >= lbSize _cBranch}) then {_b = 0};

//---------------------------------------------------------------- Class list ----------------------------------------------------------------
MCC_spawnListsBusy = true;
lbClear _cClass;
private _gType = "";
if (_groups) then {
	_gType = _cBranch lbData _b;
	if (_gType == "") then {_gType = ((missionNamespace getVariable ["MCC_groupTypes", []]) param [_b, [""]]) select 0};
	_mem set [1, _gType];
	switch (_gType) do {
		case "Reinforcement": {
			{_cClass lbAdd _x} forEach ["Paradrop: Small - Spec-Ops", "Paradrop: Medium - QRF", "Paradrop: Large - Airborne",
				"Drop-off: Small - Spec-Ops", "Drop-off: Medium - QRF", "Drop-off: Large - Airborne",
				"Fast-rope: Small - Spec-Ops", "Fast-rope: Medium - QRF", "Fast-rope: Large - Airborne",
				"Motorized: Small", "Motorized: Medium", "Motorized: Large"];
		};
		case "Garrison": {{_cClass lbAdd _x} forEach ["Light", "Light With Vehicles", "Heavy", "Heavy With Vehicles"]};
		case "Custom": {
			private _n = 0;
			{
				if (MCC_faction == (_x select 0)) then {
					_cClass lbAdd format ["%1 (%2 Units)", _x select 3, _x select 4];
					_cClass lbSetData [_n, str _forEachIndex];
					_n = _n + 1;
				};
			} forEach (missionNamespace getVariable ["MCC_customGroupsSave", []]);
		};
		default {
			MCC_groupArray = [mcc_sidename, mcc_faction, _gType, "LAND"] call mcc_make_array_grps;
			{_cClass lbAdd format ["%1 (%2 Units)", _x select 3, _x select 4]} forEach MCC_groupArray;
		};
	};
	(_d displayCtrl 3016) ctrlShow false;	//Empty: single units only
	(_d displayCtrl 3017) ctrlShow false;
} else {
	_mem set [0, _b];
	MCC_class_index = _b;
	private _list = missionNamespace getVariable [["U_GEN_SOLDIER", "U_GEN_CAR", "U_GEN_TANK", "U_GEN_MOTORCYCLE", "U_GEN_HELICOPTER", "U_GEN_AIRPLANE", "U_GEN_SHIP", "U_AMMO"] param [_b, ""], []];
	if !(_list isEqualType []) then {_list = []};
	{
		private _i = _cClass lbAdd format ["%1", (_x select 3) select 0];
		if !(_b in [0, 7]) then {_cClass lbSetPicture [_i, (_x select 3) select 1]};
	} forEach _list;
	(_d displayCtrl 3016) ctrlShow !(_b in [0, 7]);	//Empty
	(_d displayCtrl 3017) ctrlShow !(_b in [0, 7]);
	if (_b == 7) then {MCC_isEmpty = true};
};
missionNamespace setVariable ["MCC_spawnBranchMem", _mem];
//its first row, e.g. after a spawn closed the panel). The memory is kept in missionNamespace as
//MCC_spawnClassMem_<units|groups>_<faction>_<branch>; the list's own selection event stores it.
private _classKey = format ["MCC_spawnClassMem_%1_%2_%3", _wanted select 0, _faction, [str _b, _gType] select _groups];
_cClass setVariable ["MCC_spawnClassKey", _classKey];
if !(_cClass getVariable ["MCC_spawnClassEH", false]) then {
	_cClass setVariable ["MCC_spawnClassEH", true];
	_cClass ctrlAddEventHandler ["LBSelChanged", {
		params ["_c", "_i"];
		if (_i >= 0 && {!(missionNamespace getVariable ["MCC_spawnListsBusy", false])}) then {
			missionNamespace setVariable [_c getVariable ["MCC_spawnClassKey", "MCC_spawnClassMem_none"], _i];
		};
	}];
};
MCC_spawnListsBusy = false;
private _classRow = missionNamespace getVariable [_classKey, 0];
if (_classRow < 0 || {_classRow >= lbSize _cClass}) then {_classRow = 0};
_cClass lbSetCurSel _classRow;

//Buttons that belong to Units (add to list, the list, save) or Groups
{(_d displayCtrl _x) ctrlShow !_groups} forEach [3013, 3014, 3015, 3018, 3019, 3020, 9003];
if (!_groups) then {
	(_d displayCtrl 3020) ctrlSetTooltip "Save the group as a custom group";
	(_d displayCtrl 3020) ctrlSetText "Save as Custom";
	(_d displayCtrl 3021) ctrlShow true;
} else {
	(_d displayCtrl 3021) ctrlShow !(_gType in ["Reinforcement", "Garrison"]);
	if (_gType == "Custom") then {
		(_d displayCtrl 3020) ctrlShow true;
		(_d displayCtrl 3020) ctrlSetText "Delete Group";
		(_d displayCtrl 3020) ctrlSetTooltip "Delete the group from the custom groups";
	};
};

["DEBUG", "fn_spawnLists", "%1: Type %2, Branch %3 (%4), %5 classes", [_mode, _wanted select 0, _b, [_cBranch lbText _b, _gType] select _groups, lbSize _cClass]] call MCC_fnc_log;
