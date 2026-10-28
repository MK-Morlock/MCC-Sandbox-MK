#define MCC_UM_LIST 3069
#define MCC_UM_PIC 3070
#define MCC_UM_FEEDBTN 9135
disableSerialization;
params [["_mode", "toggle", [""]]];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};

if (_mode == "toggle") then {MCC_umFeedOn = !(missionNamespace getVariable ["MCC_umFeedOn", true])};
private _on = missionNamespace getVariable ["MCC_umFeedOn", true];

private _btn = _d displayCtrl MCC_UM_FEEDBTN;
_btn ctrlSetText (["Off", "On"] select _on);
_btn ctrlSetTextColor ([[0.88, 0.89, 0.90, 1], [0.56, 0.75, 0.42, 1]] select _on);
(_d displayCtrl 9138) ctrlShow false;
if (_mode != "toggle") exitWith {};

if (_on) then {
	private _list = _d displayCtrl MCC_UM_LIST;
	private _target = missionNamespace getVariable ["UMName", objNull];
	private _row = -1;
	if (!isNil "_target" && {_target isEqualType objNull} && {!isNull _target} && {alive _target}) then {
		_row = if ((missionNamespace getVariable ["MCC_UMUnit", 0]) == 0) then {
			(missionNamespace getVariable ["MCC_UMunitsNames", []]) find _target
		} else {
			(missionNamespace getVariable ["UMgroupNames", []]) findIf {leader _x == _target}
		};
	};
	if (_row < 0) then {private _sel = lbSelection _list; if (count _sel > 0) then {_row = _sel select 0}};
	if (_row >= 0 && {_row < lbSize _list}) then {
		_list lbSetSelected [_row, true];
		ctrlSetFocus _list;
		[4, [_list, _row]] execVM format ["%1mcc\general_scripts\unitManage\um.sqf", MCC_path];
	};
	["INFO", "fn_umFeedToggle", "unit feed on: %1 (row %2)", [_target, _row]] call MCC_fnc_log;
} else {
	MCC_umFeedToken = (missionNamespace getVariable ["MCC_umFeedToken", 0]) + 1;
	if (!isNil "MCC_PIPcam" && {!isNull MCC_PIPcam}) then {
		MCC_PIPcam cameraEffect ["TERMINATE", "BACK"];
		camDestroy MCC_PIPcam;
	};
	MCC_pipState = [];
	(_d displayCtrl MCC_UM_PIC) ctrlSetText "";
	["INFO", "fn_umFeedToggle", "unit feed off", []] call MCC_fnc_log;
};
