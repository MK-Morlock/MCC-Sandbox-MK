/*================================================================== MCC_fnc_comboRemember ==================================================================
	MCC console panels (Spawn, CAS, Supply Drop, Artillery, Evac, IED, ...): a drop-down list opens on the entry chosen last
	time instead of the first entry. Used where a panel fills a list and used to select entry 0.
	The choice is kept per list (idc) for the game session; it is saved whenever the list changes. Because choosing an
	entry can refill a list that depends on it (e.g. Type -> Class), the remembered entry is set again a moment later.
	<IN>	0: CONTROL the drop-down list (already filled)
			1: NUMBER  entry to use when nothing is remembered (default 0)
==============================================================================================================================================================*/
disableSerialization;
params [["_ctrl", controlNull, [controlNull]], ["_default", 0], ["_reapply", true]];	//_reapply false: lists whose contents depend on each other (Spawn)
if (isNull _ctrl) exitWith {};
private _mem = uiNamespace getVariable ["MCC_comboMemory", createHashMap];
uiNamespace setVariable ["MCC_comboMemory", _mem];
private _idc = ctrlIDC _ctrl;

//Remember every change of this list
if !(_ctrl getVariable ["MCC_comboRemember", false]) then {
	_ctrl setVariable ["MCC_comboRemember", true];
	_ctrl ctrlAddEventHandler ["LBSelChanged", {
		params ["_c", "_i"];
		if (_i >= 0) then {(uiNamespace getVariable ["MCC_comboMemory", createHashMap]) set [ctrlIDC _c, _i]};
	}];
};

private _want = _mem getOrDefault [_idc, _default];
if (_want >= lbSize _ctrl || {_want < 0}) then {_want = _default};
_ctrl lbSetCurSel _want;

//Set it again once lists that depend on another one have been refilled
if (_reapply) then {[_ctrl, _idc] spawn {
	disableSerialization;
	params ["_ctrl", "_idc"];
	sleep 0.4;
	if (isNull _ctrl) exitWith {};
	private _w = (uiNamespace getVariable ["MCC_comboMemory", createHashMap]) getOrDefault [_idc, -1];
	if (_w >= 0 && {_w < lbSize _ctrl} && {lbCurSel _ctrl != _w}) then {_ctrl lbSetCurSel _w};
}};
