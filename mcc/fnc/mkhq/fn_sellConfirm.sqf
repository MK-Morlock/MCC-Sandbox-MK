params [["_v", objNull, [objNull]]];
if (isNull _v) exitWith {};
([_v, player] call MCCMK_fnc_sellCheck) params ["_cat", "_rec", "_who"];
if (_cat == "") exitWith {["This vehicle can't be sold here."] call MCCMK_fnc_hint};
MCCMK_sellArgs = [_v];
private _path = missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"];
private _name = getText (configOf _v >> "displayName");
private _rowsFor = {
	params ["_val"];
	_val params ["_cur", "_amt"];
	if (_cur == "cr") then {[["\mcc_sandbox_mod\mcc\rts\data\valorIcon.paa", [1, 0.85, 0.1, 1], "Credits", _amt, -1]]} else {[
		[_path + "data\IconAmmo.paa", [0.9, 0, 0, 1], "Ammo", _amt select 0, -1],
		[_path + "data\IconRepair.paa", [0, 0.5, 0.9, 1], "Supply", _amt select 1, -1],
		[_path + "data\IconFuel.paa", [0, 0.9, 0.5, 1], "Fuel", _amt select 2, -1]
	]};
};
private _dmgTxt = if (damage _v > 0.01) then {format [" Damage %1%2 lowers the price.", round (100 * damage _v), "%"]} else {""};
if (_cat == "seized" && {_who == "cmd"}) exitWith {
	private _res = [_v, _cat, _rec, false] call MCCMK_fnc_sellValue;
	private _cr = [_v, _cat, _rec, true] call MCCMK_fnc_sellValue;
	[
		"Sell seized vehicle",
		format ["Sell the captured <t color='#99ff66'>%1</t>?%2<br/><t color='#aaaaaa'>Side resources, or %3 credits for you.</t>", _name, _dmgTxt, _cr select 1],
		[_res] call _rowsFor,
		[
			["To side resources", {[MCCMK_sellArgs select 0, player, false] remoteExec ["MCCMK_fnc_sellVehicle", 2]}],
			["To my credits", {[MCCMK_sellArgs select 0, player, true] remoteExec ["MCCMK_fnc_sellVehicle", 2]}],
			["Cancel", {}]
		]
	] call MCCMK_fnc_confirmPanel;
};
private _toCr = (_cat == "seized") || {(_rec select 0) == "cr"};
private _val = [_v, _cat, _rec, _toCr] call MCCMK_fnc_sellValue;
private _note = switch (true) do {
	case (_cat == "seized"): {"The credits are yours."};
	case ((_rec select 0) == "res"): {"The refund goes to the side's resources."};
	case ((_rec param [2, ""]) == getPlayerUID player): {"The refund goes to your credits."};
	default {format ["The refund goes to %1, who bought it.", _rec param [4, "the buyer"]]};
};
[
	["Sell vehicle", "Sell seized vehicle"] select (_cat == "seized"),
	format ["Sell <t color='#99ff66'>%1</t>?%2<br/><t color='#aaaaaa'>%3</t>", _name, _dmgTxt, _note],
	[_val] call _rowsFor,
	[
		["Sell", {[MCCMK_sellArgs select 0, player, true] remoteExec ["MCCMK_fnc_sellVehicle", 2]}],
		["Cancel", {}]
	]
] call MCCMK_fnc_confirmPanel;
