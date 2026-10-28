params [["_v", objNull, [objNull]], ["_t", [0, 0, 0], [[], objNull]], ["_spread", 0, [0]], ["_secs", 3, [0]]];
if (isNull _v) exitWith {};
if (isNil {_v getVariable "MCC_casGuideEH"}) then {
	_v setVariable ["MCC_casGuideEH", _v addEventHandler ["Fired", {
		params ["_veh", "", "", "", "", "", "_proj"];
		_veh setVariable ["MCC_firedCount", (_veh getVariable ["MCC_firedCount", 0]) + 1];
		private _g = _veh getVariable ["MCC_casGuide", []];
		if (count _g < 3 || {isNull _proj} || {time > (_g select 2)}) exitWith {};
		_g params ["_tgt", "_sp"];
		if (_tgt isEqualType []) then {_tgt = _tgt vectorAdd [(random (2 * _sp)) - _sp, (random (2 * _sp)) - _sp, 0]};
		["DEBUG", "guide", "%1 fired %2 (%3): steering it to %4", [typeOf _veh, typeOf _proj, _this select 1, if (_tgt isEqualType []) then {_tgt apply {round _x}} else {_tgt}]] call MCC_fnc_log;
		[_proj, _tgt] call MCC_fnc_casGuide;
	}]];
};
if (_t isEqualType [] && {count _t == 2}) then {_t = [_t select 0, _t select 1, 0]};
if (_t isEqualType []) then {_t = AGLToASL _t};
_v setVariable ["MCC_casGuide", [_t, _spread, time + _secs]];
