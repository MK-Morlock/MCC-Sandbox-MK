/*
	MCC_fnc_themeButtons - (MK) "Buttons" console look for a window that exists in one version only: its flat rounded
	buttons (MCC_RscButtonRound / MCC_RscButtonRoundSmall, own textures not changed) are swapped for their 3D versions
	(MCC_RscButtonRound3D / MCC_RscButtonRoundSmall3D) - same idc, place, text, tooltip, state and click actions. Does
	nothing with the "Flat" look. [display, window's class name, root config (configFile)]. Call it first in onLoad.
*/
disableSerialization;
params [["_d", displayNull, [displayNull]], ["_name", "", [""]], ["_root", configFile, [configFile]]];
if (isNull _d || {!(profileNamespace getVariable ["MCC_consoleButtons", false])}) exitWith {};
private _win = _root >> _name;
if (!isClass _win) then {_win = missionConfigFile >> _name};
if (!isClass _win) exitWith {};
// every control class in the window, nested groups included
private _cfgs = createHashMap;
private _walk = {
	params ["_c"];
	{
		_cfgs set [toLower configName _x, _x];
		{if (isClass (_x)) then {[_x] call _walk}} forEach [_x >> "controls", _x >> "Controls"];
	} forEach ("isClass _x" configClasses _c);
};
{if (isClass _x) then {[_x] call _walk}} forEach [_win >> "controls", _win >> "Controls"];
private _flatTex = getText (configFile >> "MCC_RscButtonRound" >> "animTextureNormal");
private _flatTexS = getText (configFile >> "MCC_RscButtonRoundSmall" >> "animTextureNormal");
private _n = 0;
{
	private _c = _x;
	private _cfg = _cfgs getOrDefault [toLower ctrlClassName _c, configNull];
	if (isNull _cfg) then {continue};
	// its parent classes (inheritance), nearest first
	private _par = [];
	private _p = inheritsFrom _cfg;
	while {!isNull _p} do {_par pushBack (toLower configName _p); _p = inheritsFrom _p};
	if ((_par findIf {_x in ["mcc_rscbuttonround3d", "mcc_rscbuttonroundsmall3d", "mcc_rscbuttonroundtiny3d"]}) >= 0) then {continue};
	private _cls = "";
	private _tex = getText (_cfg >> "animTextureNormal");
	if ("mcc_rscbuttonround" in _par && {_tex == _flatTex}) then {_cls = "MCC_RscButtonRound3D"};
	if ("mcc_rscbuttonroundsmall" in _par && {_tex == _flatTexS}) then {_cls = "MCC_RscButtonRoundSmall3D"};
	if (_cls == "") then {continue};
	private _grp = ctrlParentControlsGroup _c;
	private _new = if (isNull _grp) then {_d ctrlCreate [_cls, ctrlIDC _c]} else {_d ctrlCreate [_cls, ctrlIDC _c, _grp]};
	_new ctrlSetPosition (ctrlPosition _c);
	_new ctrlSetText (ctrlText _c);
	private _tip = getText (_cfg >> "tooltip");
	if (_tip != "") then {_new ctrlSetTooltip _tip};
	if (isNumber (_cfg >> "size") || {isText (_cfg >> "size")}) then {_new ctrlSetFontHeight (getNumber (_cfg >> "size"))};
	_new ctrlEnable (ctrlEnabled _c);
	_new ctrlShow (ctrlShown _c);
	// the click actions from the window's config, as event handlers
	{
		_x params ["_key", "_eh"];
		private _code = getText (_cfg >> _key);
		if (_code != "") then {_new ctrlAddEventHandler [_eh, _code]};
	} forEach [["action", "ButtonClick"], ["onButtonClick", "ButtonClick"], ["onMouseButtonClick", "MouseButtonClick"], ["onMouseButtonDown", "MouseButtonDown"], ["onMouseButtonUp", "MouseButtonUp"], ["onMouseEnter", "MouseEnter"], ["onMouseExit", "MouseExit"]];
	_new ctrlCommit 0;
	ctrlDelete _c;
	_n = _n + 1;
} forEach (allControls _d);
if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "themeButtons", "%1: %2 button(s) made 3D", [_name, _n]] call MCC_fnc_log};
