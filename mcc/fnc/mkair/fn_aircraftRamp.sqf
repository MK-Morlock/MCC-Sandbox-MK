params [["_v", objNull, [objNull]], ["_open", true, [true]]];
if (isNull _v) exitWith {false};
if (!local _v) exitWith {[_v, _open] remoteExec ["MCCMK_fnc_aircraftRamp", _v]; true};
private _phase = [0, 1] select _open;
private _anims = (animationNames _v) apply {toLower _x};
private _done = [];
private _parts = [];
{
	if (_x in _anims) then {_v animate [_x, _phase, 0.7]; _done pushBack _x; _parts pushBack ["anim", _x]};
} forEach ["ramp_top", "ramp_bottom"];
if (count _done == 0) then {
	private _srcs = "isClass _x" configClasses (configFile >> "CfgVehicles" >> (typeOf _v) >> "AnimationSources");
	private _doors = _srcs select {(toLower (getText (_x >> "source"))) == "door"};
	private _pick = _srcs select {((toLower configName _x) find "ramp") >= 0};
	if (count _pick == 0) then {_pick = _doors select {private _n = toLower configName _x; (_n find "rear") >= 0 || {(_n find "cargo") >= 0} || {(_n find "back") >= 0}}};
	if (count _pick == 0 && {_v isKindOf "Plane"}) then {_pick = _doors};
	{
		private _n = configName _x;
		if ((toLower (getText (_x >> "source"))) == "door") then {_v animateDoor [_n, _phase]; _parts pushBack ["door", _n]} else {_v animateSource [_n, _phase]; _parts pushBack ["source", _n]};
		_done pushBack _n;
	} forEach _pick;
};
_v setVariable ["MCCMK_rampParts", _parts];
["INFO", "aircraftRamp", "%1: %2", [typeOf _v, if (count _done == 0) then {"no ramp found"} else {format ["ramp %1 (%2)", ["closing", "opening"] select _open, _done joinString ", "]}]] call MCC_fnc_log;
count _done > 0
