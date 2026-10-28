/*================================================================== MCC_fnc_edenFactionCombo ==================================================================
	Eden faction drop-down for MCC module attributes (Cfg3DEN Attributes MCC_AttributeFaction).
	Lists every faction that has public soldiers, mod (custom) factions included, sorted by side then name, shown as
	SIDE - Name (CLASS). The list is built once per game session. A saved faction that is not loaded is kept and marked.

	<IN>	0: CONTROL attribute controls group
			1: STRING  saved value (load)
			2: STRING  load, loadOptional (adds a not-set entry at the top) or save
	<OUT>	save: STRING faction class name
==============================================================================================================================================================*/
params ["_group", ["_value", ""], ["_mode", "load"]];
private _ctrl = _group controlsGroupCtrl 100;

if (_mode == "save") exitWith {
	private _i = lbCurSel _ctrl;
	if (_i < 0) then {""} else {_ctrl lbData _i}
};

if !(_value isEqualType "") then {_value = str _value};

//Factions with soldiers: [sideOrder, name, class, icon], built once per session
private _list = uiNamespace getVariable ["MCC_edenFactionList", []];
if (_list isEqualTo []) then {
	private _sides = createHashMap;
	{
		private _f = toLower getText (_x >> "faction");
		if (_f != "" && {!(_f in _sides)}) then {_sides set [_f, getNumber (_x >> "side")]};
	} forEach ("getNumber (_x >> 'scope') == 2 && {toLower getText (_x >> 'simulation') in ['soldier','soldierx']}" configClasses (configFile >> "CfgVehicles"));
	{
		private _c = configName _x;
		if (toLower _c in _sides) then {
			private _side = _sides get (toLower _c);
			_list pushBack [[1, 0, 2, 3] find _side, getText (_x >> "displayName"), _c, getText (_x >> "icon")];
		};
	} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
	_list sort true;
	uiNamespace setVariable ["MCC_edenFactionList", _list];
};

private _sideNames = ["BLUFOR", "OPFOR", "Independent", "Civilian"];
lbClear _ctrl;
private _sel = -1;
if (_mode == "loadOptional") then {
	private _i = _ctrl lbAdd "(not set)";
	_ctrl lbSetData [_i, ""];
	if (_value == "") then {_sel = _i};
};
{
	_x params ["_order", "_name", "_class", "_icon"];
	private _i = _ctrl lbAdd format ["%1 - %2 (%3)", _sideNames param [_order, "Other"], _name, _class];
	_ctrl lbSetData [_i, _class];
	if (_icon != "") then {_ctrl lbSetPicture [_i, _icon]};
	if (toLower _class == toLower _value) then {_sel = _i};
} forEach _list;

//Saved faction not loaded (mod removed): keep it so the setting is not lost
if (_sel < 0 && {_value != ""}) then {
	_sel = _ctrl lbAdd format ["%1 (not loaded)", _value];
	_ctrl lbSetData [_sel, _value];
};
_ctrl lbSetCurSel (_sel max 0);
