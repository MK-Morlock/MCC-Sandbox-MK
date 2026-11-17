params [["_ship", objNull, [objNull]], ["_amt", 0, [0]], ["_by", sideUnknown, [sideUnknown]]];
if (!isServer || {isNull _ship} || {_amt <= 0} || {_ship getVariable ["MCCMK_sinking", false]}) exitWith {};
private _t = _ship getVariable ["MCC_ShipType", 0];
private _strength = [30000, 80000, 15000, 50000] param [_t, 30000];
private _old = _ship getVariable ["MCCMK_hull", 1];
private _hull = (_old - (_amt / _strength)) max 0;
_ship setVariable ["MCCMK_hull", _hull, true];
_ship setVariable ["MCCMK_hullLastHit", serverTime, true];
private _side = _ship getVariable ["MCC_side", sideUnknown];
private _name = _ship getVariable ["MCC_LHDDisplayName", "Ship"];
if (_old >= 0.5 && {_hull < 0.5}) then {
	private _sm = [];
	{
		private _o = "test_EmptyObjectForSmoke" createVehicle [0, 0, 0];
		_o setPosWorld (_ship modelToWorldWorld _x);
		_sm pushBack _o;
	} forEach ([[[0, 20, 12], [0, -30, 10]], [[0, 60, 26], [0, -80, 26]], [[0, 0, 4]], [[0, 40, 14], [0, -40, 14]]] param [_t, [[0, 0, 10]]]);
	_ship setVariable ["MCCMK_smoke", _sm];
	[format ["%1 is damaged: hull at %2%3.", _name, round (_hull * 100), "%"]] remoteExec ["systemChat", _side];
};
if (_old >= 0.25 && {_hull < 0.25}) then {
	_ship setVariable ["MCCMK_crippled", true, true];
	[format ["%1 is crippled: hull at %2%3 - no purchases until repaired.", _name, round (_hull * 100), "%"]] remoteExec ["systemChat", _side];
};
if (_old > 0 && {_hull <= 0}) then {
	if (_t in [0, 2]) then {[_ship] spawn MCCMK_fnc_shipSink} else {
		_ship setVariable ["MCCMK_disabled", true, true];
		[format ["%1 is disabled: no spawning, purchases or HQ until its hull is repaired.", _name]] remoteExec ["systemChat", _side];
	};
};
["INFO", "ships", "%1 hit for %2 by %3: hull %4%5", [_name, round _amt, _by, round (_hull * 100), "%"]] call MCC_fnc_log;
