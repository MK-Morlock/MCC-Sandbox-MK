params [["_a", [], [[]]], ["_b", [], [[]]], ["_side", civilian, [civilian]]];
if (count _a < 2 || {count _b < 2}) exitWith {false};
if ((missionNamespace getVariable ["MCCMK_aiKeepOutZones", []]) isEqualTo []) exitWith {false};
private _d = _a distance2D _b;
private _dir = _a getDir _b;
private _hit = false;
for "_s" from 0 to _d step 25 do {
	if ([_a getPos [_s, _dir], _side] call MCCMK_fnc_inKeepOutZone) exitWith {_hit = true};
};
_hit
