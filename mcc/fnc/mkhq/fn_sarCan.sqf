/*
	MCCMK_fnc_sarCan - (any computer) can this unit request it? [unit, "crew"]
	  crew:     in the water, aboard a crippled or out-of-fuel floating aircraft, or aboard a boat that is crippled, out of
	            fuel, aground or capsized
	And a rescue can come: a ship of the side within 6 km, or "Search and rescue without a ship" (out of sight).
*/
params [["_u", objNull, [objNull]], ["_mode", "crew"]];
if (isNull _u || {!alive _u} || {!(missionNamespace getVariable ["MCCMK_sarEnabled", true])} || {isNil "MCCMK_fltCrippled"}) exitWith {false};
private _side = side group _u;
private _src = ((missionNamespace getVariable ["MCCMK_sarNoShip", 1]) == 1) || {
	((missionNamespace getVariable ["MCC_staticShips", []]) findIf {!isNull _x && {(_x getVariable ["MCC_side", sideUnknown]) isEqualTo _side} && {(_x distance2D _u) < 6000} && {!(_x getVariable ["MCCMK_sinking", false])}}) >= 0
};
if (!_src) exitWith {false};
private _v = vehicle _u;
// (MK) in trouble: crippled or out of fuel (afloat), aground (Anchors' own test - at the shore too), or capsized
private _boatOk = {
	params ["_b"];
	([_b] call MCCMK_fltBoat) && {alive _b} && {
		(([_b] call MCCMK_fltCrippled) && {surfaceIsWater (getPos _b)})
		|| {!isNil "ANC_fnc_isAground" && {_b call ANC_fnc_isAground}}
		|| {((vectorUp _b) select 2) < 0.3}
	}
};
switch (_mode) do {
	case "crew": {
		if (_u getVariable ["MCCMK_sarActive", false]) exitWith {false};
		if (_v == _u) exitWith {surfaceIsWater (getPos _u) && {((getPosASL _u) select 2) < 1.5}};
		([_v] call _boatOk) || {([_v] call MCCMK_fltAir) && {alive _v} && {[_v] call MCCMK_fltAfloat} && {([_v] call MCCMK_fltCrippled) || {(fuel _v) <= 0}}}
	};
	default {false};
};
