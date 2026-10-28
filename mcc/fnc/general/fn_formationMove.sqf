params [["_g", grpNull, [grpNull]], ["_pos", [0, 0, 0], [[]]]];
if (isNull _g) exitWith {};
private _l = leader _g;
private _d = (getPosATL _l) getDir _pos;
private _form = toUpper (formation _g);
["DEBUG", "console", "%1 (player-led) order to %2: leader %3 at %4, travel dir %5, formation %6", [_g, _pos apply {round _x}, name _l, (getPosATL _l) apply {round _x}, round _d, _form]] call MCC_fnc_log;
private _sent = [];
{
	private _i = _forEachIndex + 1;
	private _row = ceil (_i / 2);
	private _s = [1, -1] select (_i % 2 == 0);
	private _off = switch (_form) do {
		case "LINE": {[_s * 5 * _row, 0]};
		case "COLUMN";
		case "FILE": {[0, -5 * _i]};
		case "STAG COLUMN": {[_s * 2.5, -5 * _i]};
		case "ECH LEFT": {[-5 * _i, -5 * _i]};
		case "ECH RIGHT": {[5 * _i, -5 * _i]};
		case "VEE": {[_s * 5 * _row, 5 * _row]};
		default {[_s * 5 * _row, -5 * _row]};
	};
	_off params ["_lx", "_ly"];
	private _slot = [(_pos select 0) + (_lx * cos _d) + (_ly * sin _d), (_pos select 1) + (_ly * cos _d) - (_lx * sin _d), 0];
	if (alive _x && {!isPlayer _x} && {vehicle _x == _x}) then {
		_x doMove _slot;
		_sent pushBack [_x, _slot];
		["DEBUG", "console", "  %1 at %2 | slot %3 (right %4, forward %5) | sent to %6", [name _x, (getPosATL _x) apply {round _x}, _i, _lx, _ly, _slot apply {round _x}]] call MCC_fnc_log;
	};
} forEach ((units _g) select {_x != _l});
private _tok = (_g getVariable ["MCC_fmToken", 0]) + 1;
_g setVariable ["MCC_fmToken", _tok];
if (missionNamespace getVariable ["MCC_debug", false]) then {
	[_g, _sent, _tok] spawn {
		params ["_g", "_sent", "_tok"];
		for "_i" from 1 to 9 do {
			sleep 10;
			if (isNull _g || {(_g getVariable ["MCC_fmToken", 0]) != _tok}) exitWith {};
			{
				_x params ["_u", "_s"];
				if (alive _u) then {
					["DEBUG", "console", "  +%1s %2 at %3 | %4 m from his spot | command %5 | heading for %6", [_i * 10, name _u, (getPosATL _u) apply {round _x}, round (_u distance2D _s), currentCommand _u, ((expectedDestination _u) param [0, []]) apply {round _x}]] call MCC_fnc_log;
				};
			} forEach _sent;
		};
	};
};
[_g, _pos, _tok] spawn {
	params ["_g", "_p", "_tok"];
	private _t = time + 1200;
	waitUntil {sleep 2; isNull _g || {time > _t} || {(_g getVariable ["MCC_fmToken", 0]) != _tok} || {((leader _g) distance2D _p) < 25}};
	if (!isNull _g && {(_g getVariable ["MCC_fmToken", 0]) == _tok}) then {
		["DEBUG", "console", "%1: leader reached the order point, AI fall back in (formation dir set to %2)", [_g, round (getDir (leader _g))]] call MCC_fnc_log;
		_g setFormDir (getDir (leader _g));
		{if (!isPlayer _x && {alive _x}) then {_x doFollow (leader _g)}} forEach (units _g);
	};
};
