disableSerialization;
params [["_left", "Yes", [""]], ["_middle", "Cancel", [""]], ["_right", "No", [""]]];
private _tw = diag_tickTime + 1;
waitUntil {isNull (findDisplay 1031982) || {diag_tickTime > _tw}};
if (!isNull (findDisplay 1031982)) exitWith {""};
if !(createDialog ("MCC_DynamicDialog" call MCC_fnc_dialogName)) exitWith {""};
waitUntil {!isNull (findDisplay 1031982)};
private _d = findDisplay 1031982;

{(_d displayCtrl _x) ctrlShow false} forEach [10002, 10003];

private _bw = 0.0572917 * safezoneW;
private _bh = 0.0219914 * safezoneH;
private _gap = 0.006 * safezoneW;
private _padX = 0.008 * safezoneW;
private _padY = 0.011 * safezoneH;
private _pw = 3 * _bw + 2 * _gap + 2 * _padX;
private _ph = _bh + 2 * _padY;
private _px = safezoneX + (safezoneW - _pw) / 2;
private _py = safezoneY + (safezoneH - _ph) / 2;

private _bg = _d displayCtrl 10001;
_bg ctrlSetPosition [_px, _py, _pw, _ph];
_bg ctrlCommit 0;

missionNamespace setVariable ["MCC_choiceBarResult", ""];
{
	_x params ["_idc", "_text", "_i", "_result"];
	private _c = _d displayCtrl _idc;
	_c ctrlShow true;
	_c ctrlSetText _text;
	_c ctrlSetPosition [_px + _padX + _i * (_bw + _gap), _py + _padY, _bw, _bh];
	_c ctrlCommit 0;
	if (_result != "") then {
		_c ctrlSetEventHandler ["ButtonClick", format ["missionNamespace setVariable ['MCC_choiceBarResult', '%1'];", _result]];
	};
} forEach [[10006, _left, 0, "left"], [2, _middle, 1, ""], [10007, _right, 2, "right"]];

[_d] call MCC_fnc_applyTheme;
waitUntil {(missionNamespace getVariable ["MCC_choiceBarResult", ""]) != "" || {isNull (findDisplay 1031982)}};
private _result = missionNamespace getVariable ["MCC_choiceBarResult", ""];
if (!isNull (findDisplay 1031982)) then {(findDisplay 1031982) closeDisplay 1};
_result
