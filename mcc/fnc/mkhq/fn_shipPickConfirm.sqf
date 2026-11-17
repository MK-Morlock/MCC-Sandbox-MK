params ["_mode", "_t", "_ship", "_pos", "_dir", "_free", "_parent"];
private _side = playerSide;
private _res = missionNamespace getVariable [format ["MCC_res%1", _side], [0, 0, 0, 0, 0]];
private _path = missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"];
([_t] call MCCMK_fnc_shipCfg) params ["_nm", "_price"];
MCCMK_pickArgs = [_t, _ship, _pos, _dir, _free];
if (_mode == "buy") exitWith {
	_price params ["_s", "_a", "_f"];
	private _can = _free || {(_res select 1) >= _s && {(_res select 0) >= _a} && {(_res select 2) >= _f}};
	private _arr = missionNamespace getVariable ["MCCMK_shipArrive", 120];
	[
		"Buy ship",
		format ["Buy a <t color='#99ff66'>%1</t> at grid %2?<br/><t color='#aaaaaa'>It arrives in about %3 min, as an F.O.B.</t>", toLower _nm, mapGridPosition _pos, ceil (_arr / 60) max 1],
		if (_free) then {[]} else {[
			[_path + "data\IconRepair.paa", [0, 0.5, 0.9, 1], "Supply", _s, _res select 1],
			[_path + "data\IconAmmo.paa", [0.9, 0, 0, 1], "Ammo", _a, _res select 0],
			[_path + "data\IconFuel.paa", [0, 0.9, 0.5, 1], "Fuel", _f, _res select 2]
		]},
		[
			["Confirm", {MCCMK_pickArgs params ["_t", "_ship", "_pos", "_dir", "_free"]; [_t, _pos, _dir, player, _free] remoteExec ["MCCMK_fnc_shipBuy", 2]}, _can, ["", "Not enough resources"] select (!_can)],
			["Cancel", {}]
		],
		_parent
	] call MCCMK_fnc_confirmPanel;
};
private _km = (_ship distance2D _pos) / 1000;
private _fuel = if (_free) then {0} else {
	private _perKm = missionNamespace getVariable ["MCCMK_shipMoveFuel", 50];
	if (_perKm <= 0) then {0} else {ceil ((_perKm * _km) max 100)}
};
private _secs = ((missionNamespace getVariable ["MCCMK_shipMoveTime", 60]) * _km) min (missionNamespace getVariable ["MCCMK_shipMoveTimeMax", 600]);
private _can = _fuel <= (_res select 2);
[
	"Move ship",
	format ["Move <t color='#99ff66'>%1</t> %2 km to grid %3?<br/><t color='#aaaaaa'>Anyone aboard moves with it. Repositioning: about %4 min.</t>", _ship getVariable ["MCC_LHDDisplayName", _nm], (round (_km * 10)) / 10, mapGridPosition _pos, ceil (_secs / 60) max 1],
	if (_fuel > 0) then {[[_path + "data\IconFuel.paa", [0, 0.9, 0.5, 1], "Fuel", _fuel, _res select 2]]} else {[]},
	[
		["Confirm", {MCCMK_pickArgs params ["_t", "_ship", "_pos", "_dir", "_free"]; [_ship, _pos, _dir, player, _free] remoteExec ["MCCMK_fnc_shipMove", 2]}, _can, ["", "Not enough Fuel"] select (!_can)],
		["Cancel", {}]
	],
	_parent
] call MCCMK_fnc_confirmPanel;
