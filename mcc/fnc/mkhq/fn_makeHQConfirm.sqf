params [["_t", objNull, [objNull]], ["_free", false, [true]]];
if (isNull _t) exitWith {};
private _side = _t getVariable ["side", _t getVariable ["MCC_side", sideUnknown]];
private _name = if (_t getVariable ["MCC_isLHD", false]) then {_t getVariable ["MCC_LHDDisplayName", "Ship"]} else {_t getVariable ["mcc_fob_name", "F.O.B."]};
private _res = missionNamespace getVariable [format ["MCC_res%1", _side], [0, 0, 0, 0, 0]];
private _cS = missionNamespace getVariable ["MCC_makeHQCostSupply", 600];
private _cF = missionNamespace getVariable ["MCC_makeHQCostFuel", 200];
private _can = _free || {(_res param [1, 0]) >= _cS && {(_res param [2, 0]) >= _cF}};
private _p = findDisplay 2993;
if (isNull _p) then {_p = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]};
MCCMK_hqConfirmArgs = [_t, _free];
private _path = missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"];
private _rows = if (_free) then {[]} else {[
	[_path + "data\IconRepair.paa", [0, 0.5, 0.9, 1], "Supply", _cS, _res param [1, 0]],
	[_path + "data\IconFuel.paa", [0, 0.9, 0.5, 1], "Fuel", _cF, _res param [2, 0]]
]};
[
	"Make HQ",
	format ["Make <t color='#99ff66'>%1</t> (grid %2) your HQ?<br/><t color='#aaaaaa'>Your current HQ becomes an F.O.B.%3</t>", _name, mapGridPosition _t, ["", " Free (mission maker)."] select _free],
	_rows,
	[
		["Confirm", {MCCMK_hqConfirmArgs params ["_t", "_free"]; [_t, player, _free] remoteExec ["MCCMK_fnc_makeHQ", 2]}, _can, ["", "Not enough resources"] select (!_can)],
		["Cancel", {["Make HQ cancelled."] call MCCMK_fnc_hint}]
	],
	_p
] call MCCMK_fnc_confirmPanel;
