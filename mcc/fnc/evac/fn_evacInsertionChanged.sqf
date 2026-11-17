params [["_ctrl", controlNull, [controlNull]], ["_index", -1, [0]], ["_where", "cc", [""]]];
if (isNull _ctrl || {_index < 0}) exitWith {};
//(MK) the Hover height box beside Flight Height, for the insertions that hover (MCCMK_fnc_hoverCombo)
[ctrlParent _ctrl, [44, 9101] select (_where == "cc"), (_ctrl lbText _index) in ["Hover", "Fast-Rope", "Precise Landing", "Rope extraction"], (_ctrl lbText _index) == "Hover"] call MCCMK_fnc_hoverCombo;
private _key = ["MCC_mccEvacInsertion", "MCC_ccEvacInsertion"] select (_where == "cc");
if ((_ctrl lbText _index) != "RTB") exitWith {profileNamespace setVariable [_key, _ctrl lbText _index]};
private _d = ctrlParent _ctrl;
private _evacs = [];
private _evac = objNull;
private _height = 100;
if (_where == "cc") then {
	_evacs = missionNamespace getVariable [format ["MCC_evacVehicles_%1", playerSide], []];
	_evac = _evacs param [lbCurSel (_d displayCtrl 9103), objNull];
	_height = (MCC_evacFlyInHight_array param [lbCurSel (_d displayCtrl 9101), ["", 100]]) select 1;
} else {
	_evacs = missionNamespace getVariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide], []];
	_evac = _evacs param [lbCurSel (_d displayCtrl 42), objNull];
	_height = (MCC_evacFlyInHight_array param [lbCurSel (_d displayCtrl 44), ["", 100]]) select 1;
};
private _back = profileNamespace getVariable [_key, ""];
private _sel = 0;
for "_i" from 0 to ((lbSize _ctrl) - 1) do {if ((_ctrl lbText _i) == _back) exitWith {_sel = _i}};
_ctrl lbSetCurSel _sel;
if (isNull _evac || {!alive _evac}) exitWith {["No evac selected"] call MCCMK_fnc_hint};
private _start = _evac getVariable ["MCC_evacStartPos", []];
if (count _start < 2) exitWith {["This evac has no start position"] call MCCMK_fnc_hint};
if !(_evac isKindOf "Helicopter") then {_height = 5000};
[[_start], _height, 1, [netid _evac, _evac]] remoteExec ["MCC_fnc_evacMove", _evac, false];
["Evac returning to its start position"] call MCCMK_fnc_hint;
if (_where == "cc") then {[2030] call MCC_fnc_consoleFolderClose};
