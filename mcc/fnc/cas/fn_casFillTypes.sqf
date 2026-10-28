/*================================================================== MCC_fnc_casFillTypes ==================================================================
	Fills the CAS Type list for the aircraft chosen in the CAS Plane list (MCC console), so only attacks that aircraft
	can fly are offered (MCC_fnc_casAllowedTypes). The attack name is stored as list data for the Call / Add buttons.
	<IN>	0: DISPLAY the MCC console
==============================================================================================================================================================*/
disableSerialization;
params [["_display", displayNull, [displayNull]], ["_given", -1, [0]]];
if (isNull _display) exitWith {};

private _planeCombo = _display displayCtrl 25;
private _typeCombo = _display displayCtrl 26;
private _idx = if (_given >= 0) then {_given} else {lbCurSel _planeCombo};
private _class = if (_idx >= 0) then {_planeCombo lbData _idx} else {""};

private _previous = if (lbCurSel _typeCombo >= 0) then {_typeCombo lbData (lbCurSel _typeCombo)} else {""};
//The last attack chosen in this game session (the list is empty when the panel opens again)
if (_previous == "") then {_previous = uiNamespace getVariable ["MCC_casLastType", ""]};
if !(_typeCombo getVariable ["MCC_casTypeRemember", false]) then {
	_typeCombo setVariable ["MCC_casTypeRemember", true];
	_typeCombo ctrlAddEventHandler ["LBSelChanged", {
		params ["_c", "_i"];
		if (_i >= 0) then {uiNamespace setVariable ["MCC_casLastType", _c lbData _i]};
	}];
};
private _types = [_class] call MCC_fnc_casAllowedTypes;
if (getNumber (configFile >> "CfgVehicles" >> _class >> "isUav") == 1 && {!("S&D" in _types)}) then {_types = _types select {_x in ["UAV", "Controllable"]}};

lbClear _typeCombo;
{
	private _i = _typeCombo lbAdd _x;
	_typeCombo lbSetData [_i, _x];
} forEach _types;
private _sel = _types find _previous;
_typeCombo lbSetCurSel (_sel max 0);
_typeCombo ctrlSetTooltip (if (count _types == 0) then {"This aircraft has no weapons for CAS"} else {format ["%1 attack types available for this aircraft", count _types]});
