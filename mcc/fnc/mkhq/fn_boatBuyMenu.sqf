/*
	MCCMK_fnc_boatBuyMenu - the Naval Workshop's "Buy Boat": a map picker like Buy Ship - click any spot on the water, deep
	enough for a boat (1.5 m) and clear of other boats and ships - then the vehicle shop for boats, in commander mode (the
	side's resources), delivering the boat at that spot. Anywhere at sea, as ships are, so boats can go by a ship.
	[control]
*/
disableSerialization;
params [["_ctrl", controlNull, [controlNull]]];
private _parent = if (isNull _ctrl) then {findDisplay 46} else {ctrlParent _ctrl};
private _centre = getPos (missionNamespace getVariable ["MCC_selectedRtsObject", player]);
private _d = _parent createDisplay "RscDisplayEmpty";
private _map = _d ctrlCreate ["RscMapControl", 9701];
_map ctrlSetPosition [safezoneX, safezoneY, safezoneW, safezoneH];
_map ctrlCommit 0;
_map ctrlMapAnimAdd [0, 0.1, _centre];
ctrlMapAnimCommit _map;
private _bar = _d ctrlCreate ["RscText", 9702];
_bar ctrlSetPosition [safezoneX + 0.25 * safezoneW, safezoneY + 0.02 * safezoneH, 0.5 * safezoneW, 0.06 * safezoneH];
_bar ctrlSetBackgroundColor [0.08, 0.09, 0.1, 0.9];
_bar ctrlCommit 0;
private _txt = _d ctrlCreate ["RscStructuredText", 9703];
_txt ctrlSetPosition [safezoneX + 0.26 * safezoneW, safezoneY + 0.027 * safezoneH, 0.48 * safezoneW, 0.05 * safezoneH];
_txt ctrlCommit 0;
_txt ctrlSetStructuredText parseText "<t size='1.05'>Buy a boat: click a spot on the water.</t>  <t size='0.85' color='#aaaaaa'>Right-click or Esc cancels.</t>";
uiNamespace setVariable ["MCCMK_boatPickTxt", _txt];
// a spot is good: at sea, 1.5 m deep at least, no boat or ship within 15 m (a ship's own length counted)
MCCMK_fnc_boatSpotCheck = {
	params ["_p"];
	if !(surfaceIsWater _p) exitWith {"not on the water"};
	if ((getTerrainHeightASL _p) > -1.5) exitWith {"too shallow for a boat"};
	if (((nearestObjects [[_p select 0, _p select 1, 0], ["Ship"], 15]) select {alive _x}) isNotEqualTo []) exitWith {"another boat is there"};
	if (((missionNamespace getVariable ["MCC_staticShips", []]) findIf {!isNull _x && {(_x distance2D _p) < ((((([_x getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3) select 1) max 30) + 15)}}) >= 0) exitWith {"too close to a ship"};
	""
};
_map ctrlAddEventHandler ["MouseButtonClick", {
	params ["_c", "_btn", "_mx", "_my"];
	if (_btn == 1) exitWith {(ctrlParent _c) closeDisplay 2};
	if (_btn != 0) exitWith {};
	private _p = _c ctrlMapScreenToWorld [_mx, _my];
	private _why = [_p] call MCCMK_fnc_boatSpotCheck;
	if (_why != "") exitWith {
		(uiNamespace getVariable ["MCCMK_boatPickTxt", controlNull]) ctrlSetStructuredText parseText format ["<t size='1.05'>Buy a boat: click a spot on the water.</t>  <t size='0.9' color='#ff7766'>Not there: %1.</t>", _why];
	};
	(ctrlParent _c) closeDisplay 1;
	// the delivery point: a temporary invisible pad on the water - the shop delivers onto it - removed once the shop closes
	private _pad = createVehicle ["Land_HelipadEmpty_F", [_p select 0, _p select 1, 0], [], 0, "CAN_COLLIDE"];
	_pad setPosASL [_p select 0, _p select 1, 0];
	_pad setVariable ["MCC_vehicleSpawnerHelipad", true, true];
	_pad setVariable ["mcc_delete", false, true];
	["INFO", "rts", "%1 picked a boat delivery point at %2", [name player, mapGridPosition _p]] call MCC_fnc_log;
	[_pad] spawn {
		params ["_pad"];
		[player, ["ship", _pad], true] spawn MCC_fnc_vehicleSpawnerInitDialog;
		private _t = time + 10;
		waitUntil {sleep 0.2; !isNull (uiNamespace getVariable ["MCC_VEHICLESPAWNER_IDD", displayNull]) || {time > _t}};
		waitUntil {sleep 0.5; isNull (uiNamespace getVariable ["MCC_VEHICLESPAWNER_IDD", displayNull])};
		private _b = (nearestObjects [getPosASL _pad, ["Ship"], 8]) select {alive _x};
		if (_b isNotEqualTo []) then {[format ["Your boat is waiting at grid %1.", mapGridPosition _pad]] call MCCMK_fnc_hint};
		sleep 2;
		deleteVehicle _pad;
	};
}];
