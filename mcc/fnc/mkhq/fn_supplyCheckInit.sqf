/*
	MCCMK_fnc_supplyCheckInit - "Check supplies" on anything with a fuel, ammo or repair capacity (Taru pods, Huron and
	MCC containers, supply trucks...): how much is left. Arma shows it nowhere in play. A scroll action within 6 m on foot;
	with ACE, in the ACE interaction menu. (postInit, every player)
*/
if (!hasInterface) exitWith {};

MCCMK_fnc_supplyHas = {
	params ["_o"];
	if (isNull _o || {!alive _o}) exitWith {false};
	private _c = configOf _o;
	(getNumber (_c >> "transportFuel")) > 0 || {(getNumber (_c >> "transportAmmo")) > 0} || {(getNumber (_c >> "transportRepair")) > 0}
};
MCCMK_fnc_supplyShow = {
	params ["_o"];
	private _c = configOf _o;
	private _l = [];
	if (getNumber (_c >> "transportFuel") > 0) then {_l pushBack format ["Fuel: %1%% left", round (((getFuelCargo _o) max 0) * 100)]};
	if (getNumber (_c >> "transportAmmo") > 0) then {_l pushBack format ["Ammo: %1%% left", round (((getAmmoCargo _o) max 0) * 100)]};
	if (getNumber (_c >> "transportRepair") > 0) then {_l pushBack format ["Repair: %1%% left", round (((getRepairCargo _o) max 0) * 100)]};
	[format ["%1\n\n%2", getText (_c >> "displayName"), _l joinString "\n"]] call MCCMK_fnc_hint;
};

if (call MCCMK_fnc_aceMenus) then {
	private _a = ["MCCMK_checkSupplies", "Check supplies", "\a3\ui_f\data\IGUI\Cfg\Actions\gear_ca.paa",
		{[_target] call MCCMK_fnc_supplyShow}, {[_target] call MCCMK_fnc_supplyHas}] call ace_interact_menu_fnc_createAction;
	{[_x, 0, ["ACE_MainActions"], _a, true] call ace_interact_menu_fnc_addActionToClass} forEach ["AllVehicles", "ThingX", "ReammoBox_F"];
};
if !(call MCCMK_fnc_scrollMenus) exitWith {};	//(MK) "ACE menu only": no scroll action too

private _add = {
	player addAction ["Check supplies", {[cursorObject] call MCCMK_fnc_supplyShow}, nil, 1.4, false, true, "",
		"(vehicle _this == _this) && {!isNull cursorObject} && {(_this distance cursorObject) < 6} && {[cursorObject] call MCCMK_fnc_supplyHas}"];
};
[_add] spawn {
	params ["_add"];
	waitUntil {sleep 1; !isNull player};
	call _add;
	player addEventHandler ["Respawn", _add];
};
