// (client) Selling a ship: the commander (or mission maker). Nobody may be on its deck; vehicles parked on it are either
// moved off first ("Sell ship") or sold along with it ("Sell ship + vehicles"). [ship, parent display]
disableSerialization;
params [["_ship", objNull, [objNull]], ["_parent", displayNull, [displayNull]]];
if (isNull _ship) exitWith {};
private _side = _ship getVariable ["MCC_side", playerSide];
if !(([player] call MCCMK_fnc_isMissionMaker) || {[player, _side] call MCCMK_fnc_shipCanCommand}) exitWith {["Only the commander can sell ships."] call MCCMK_fnc_hint};
if (isNull _parent) then {_parent = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", findDisplay 46]};
private _name = _ship getVariable ["MCC_LHDDisplayName", ["Destroyer", "Aircraft carrier", "Submarine", "LHD"] param [_ship getVariable ["MCC_ShipType", 0], "Ship"]];
([_ship] call MCCMK_fnc_shipAboard) params ["_men", "_veh"];
([_ship] call MCCMK_fnc_shipSellValue) params ["_a", "_s", "_f", "_bought"];
private _path = missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"];
private _body = format ["Sell the <t color='#99ff66'>%1</t>? It's removed for good.<br/><t color='#aaaaaa'>%2, hull %3%4.%5</t>",
	_name, ["Placed for free: 40% of its price", "Bought: 60% of what was paid"] select _bought, round (100 * ((_ship getVariable ["MCCMK_hull", 1]) max 0)), "%",
	if (count _veh > 0) then {format ["<br/>%1 vehicle(s) parked on it - move them off first, or sell them with the ship.", count _veh]} else {""}];
if (count _men > 0) then {_body = _body + format ["<br/><t color='#ff6666'>%1 soldier(s) on its deck - everyone must leave the ship first.</t>", count _men]};
MCCMK_sellShipArg = _ship;
[
	"Sell ship", _body,
	[
		[_path + "data\IconRepair.paa", [0, 0.5, 0.9, 1], "Supply", _s, -1],
		[_path + "data\IconAmmo.paa", [0.9, 0, 0, 1], "Ammo", _a, -1],
		[_path + "data\IconFuel.paa", [0, 0.9, 0.5, 1], "Fuel", _f, -1]
	],
	[
		["Sell ship", {[MCCMK_sellShipArg, player, false] remoteExec ["MCCMK_fnc_shipSell", 2]}, (count _men == 0) && {count _veh == 0}, ["", "Move the vehicles off first, or sell them with the ship"] select (count _veh > 0)],
		[format ["Sell ship + %1 vehicles", count _veh], {[MCCMK_sellShipArg, player, true] remoteExec ["MCCMK_fnc_shipSell", 2]}, (count _men == 0) && {count _veh > 0}],
		["Cancel", {}]
	],
	_parent
] call MCCMK_fnc_confirmPanel;
