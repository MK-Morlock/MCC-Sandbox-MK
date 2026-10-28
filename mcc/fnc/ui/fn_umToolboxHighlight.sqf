/*================================================================== MCC_fnc_umToolboxHighlight ==================================================================
	Rounded grey box under the chosen entry of the MCC console Units / Groups (9134) and Regular / Night Vision / Thermal
	(9133) switches. The switches draw their own square grey box; that is turned off (colorSelectedBg transparent) and this
	rounded picture (mcc_round_hl_ca.paa) is moved under the chosen entry instead, so they match the rounded buttons.
	<IN>	0: NUMBER idc of the switch (9134 or 9133)
			1: NUMBER chosen entry (-1 = read it from the switch)
==============================================================================================================================================================*/
disableSerialization;
params [["_tbIdc", 9133, [0]], ["_sel", -1, [0]]];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _map = [[9134, 9136, 2], [9133, 9137, 3]];	//[switch, rounded box, entries]
private _i = _map findIf {(_x select 0) == _tbIdc};
if (_i < 0) exitWith {};
(_map select _i) params ["", "_hlIdc", "_cols"];
private _tb = _d displayCtrl _tbIdc;
private _hl = _d displayCtrl _hlIdc;
if (isNull _tb || {isNull _hl}) exitWith {};
if (_sel < 0) then {_sel = lbCurSel _tb};
if (_sel < 0 || {_sel >= _cols}) exitWith {_hl ctrlShow false};
(ctrlPosition _tb) params ["_px", "_py", "_pw", "_ph"];
private _cw = _pw / _cols;
_hl ctrlSetPosition [_px + _sel * _cw, _py, _cw, _ph];
_hl ctrlShow true;
_hl ctrlCommit 0;
