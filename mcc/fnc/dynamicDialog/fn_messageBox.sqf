/*================================================================== MCC_fnc_messageBox ==================================================================
	MCC-styled question box, a drop-in replacement for BIS_fnc_guiMessage (same arguments and result), so every MCC menu
	looks the same: dark panel with a cyan title like the CAS and Evac menus, instead of the coloured BIS title bar.
	Must be run scheduled (spawn / execVM).

	<IN>	0: STRING message (structured text allowed)
			1: STRING title
			2: STRING or BOOL text of the OK button (true / nil = OK)
			3: STRING or BOOL text of the Cancel button (true / nil = Cancel, false = no Cancel button)
	<OUT>	BOOL true when OK was pressed
==========================================================================================================================================================*/
disableSerialization;
params [["_text", "", [""]], ["_title", "", [""]], ["_okText", true, [true, ""]], ["_cancelText", true, [true, ""]], ["_compact", false, [false]]];

if (!isNull (findDisplay 1031982)) exitWith {false};
if !(createDialog ("MCC_DynamicDialog" call MCC_fnc_dialogName)) exitWith {false};
waitUntil {!isNull (findDisplay 1031982)};

private _display = findDisplay 1031982;
(_display displayCtrl 10002) ctrlSetText _title;

private _content = _display displayCtrl 10003;
(ctrlPosition _content) params ["", "", "_w", "_h"];
private _st = _display ctrlCreate ["RscStructuredText", -1, _content];
_st ctrlSetPosition [0, 0, _w, _h];
_st ctrlSetStructuredText parseText _text;
_st ctrlCommit 0;

private _ok = _display displayCtrl 10007;
private _cancel = _display displayCtrl 2;
private _need = (ctrlTextHeight _st) + 0.01;
private _newH = if (_need > _h) then {_need min ((safezoneH * 0.7) max _h)} else {[_h, _need max (0.04 * safezoneH)] select _compact};
if (_newH != _h) then {
	private _d = _newH - _h;
	{
		private _p = ctrlPosition _x;
		_x ctrlSetPosition [_p select 0, (_p select 1) - _d / 2, _p select 2, _p select 3];
		_x ctrlCommit 0;
	} forEach [_display displayCtrl 10002];
	(ctrlPosition _content) params ["_cx", "_cy", "_cw"];
	_content ctrlSetPosition [_cx, _cy - _d / 2, _cw, _newH];
	_content ctrlCommit 0;
	{
		private _p = ctrlPosition _x;
		_x ctrlSetPosition [_p select 0, (_p select 1) + _d / 2, _p select 2, _p select 3];
		_x ctrlCommit 0;
	} forEach [_ok, _cancel, _display displayCtrl 10006];
	_st ctrlSetPosition [0, 0, _w, _need];
	_st ctrlCommit 0;
};

if (_compact) then {
	private _tw = ctrlTextWidth _st;
	if (_tw <= 0) then {
		private _tmp = _display ctrlCreate ["RscText", -1];
		_tmp ctrlSetFontHeight ((ctrlTextHeight _st) * 0.8);
		_tmp ctrlSetText (_text regexReplace ["<[^>]*>", ""]);
		_tw = ctrlTextWidth _tmp;
		ctrlDelete _tmp;
	};
	if (_tw > 0) then {
		private _bw = (ctrlPosition _ok) select 2;
		private _W = ((_tw + 0.04) max ((2 * _bw) + 0.04)) min ((ctrlPosition (_display displayCtrl 10001)) select 2);
		private _l = safezoneX + (safezoneW / 2) - (_W / 2);
		{
			private _p = ctrlPosition _x;
			_x ctrlSetPosition [_l, _p select 1, _W, _p select 3];
			_x ctrlCommit 0;
		} forEach [_display displayCtrl 10001, _display displayCtrl 10002];
		private _cp = ctrlPosition _content;
		_content ctrlSetPosition [_l + 0.01, _cp select 1, _W - 0.02, _cp select 3];
		_content ctrlCommit 0;
		_st ctrlSetPosition [0, 0, _W - 0.02, (ctrlPosition _st) select 3];
		_st ctrlCommit 0;
		private _cn = ctrlPosition _cancel;
		_cancel ctrlSetPosition [_l, _cn select 1, _cn select 2, _cn select 3];
		_cancel ctrlCommit 0;
		private _op = ctrlPosition _ok;
		_ok ctrlSetPosition [_l + _W - (_op select 2), _op select 1, _op select 2, _op select 3];
		_ok ctrlCommit 0;
	};
};
_ok ctrlSetText (if (_okText isEqualType "") then {_okText} else {"OK"});	//(message boxes keep "OK"; settings pages say "Apply")
if (_cancelText isEqualType "") then {_cancel ctrlSetText _cancelText};
if (_cancelText isEqualTo false) then {_cancel ctrlShow false};
(_display displayCtrl 10006) ctrlShow false;

missionNamespace setVariable ["MCC_DynamicDialogOK", false];
_ok ctrlSetEventHandler ["ButtonClick", "missionNamespace setVariable ['MCC_DynamicDialogOK', true];"];

//One rounded window from above the title to below the buttons, like the settings pages
private _t = ctrlPosition (_display displayCtrl 10002);
private _b = ctrlPosition _ok;
private _bg = _display displayCtrl 10001;
private _bp = ctrlPosition _bg;
_bg ctrlSetPosition [(_bp select 0) - 0.006, (_t select 1) - 0.012, (_bp select 2) + 0.012, ((_b select 1) + (_b select 3) + 0.015) - ((_t select 1) - 0.012)];
_bg ctrlCommit 0;
[_display] call MCC_fnc_applyTheme;	//MCC look
waitUntil {(missionNamespace getVariable ["MCC_DynamicDialogOK", false]) || {isNull (findDisplay 1031982)}};
private _result = missionNamespace getVariable ["MCC_DynamicDialogOK", false];
if (!isNull (findDisplay 1031982)) then {(findDisplay 1031982) closeDisplay 1};
_result
