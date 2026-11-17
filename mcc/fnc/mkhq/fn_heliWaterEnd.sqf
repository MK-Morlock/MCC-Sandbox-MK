/*
	MCCMK_fnc_heliWaterEnd - (server) a helicopter's water landing ENDED by its next order (any new waypoint or order - see
	MCCMK_fnc_heliWaterLand, which watches for one): [helicopter, flying height]. The water hold let go, the doors and ramp
	shut, the engine started, the pilot given his flying height (50 m unless given); it climbs and goes wherever it was
	sent, boat aboard or not. Its water-landing mark (watertight) stays until it is 5 m up.
*/
params [["_h", objNull], ["_fly", 50]];
if (!isServer || {isNull _h} || {!alive _h}) exitWith {};
if (isNil {_h getVariable "MCCMK_waterState"} && {!(_h getVariable ["MCCMK_waterLanding", false])}) exitWith {};
_h setVariable ["MCCMK_waterId", (_h getVariable ["MCCMK_waterId", 0]) + 1, true];
_h setVariable ["MCCMK_waterEngineOff", nil, true];
[_h] remoteExec ["MCCMK_fnc_heliWaterHold", _h];
[_h, false] call MCCMK_fnc_heliDoorsAll;
_h engineOn true;
private _mkD = driver _h;
if (!isNull _mkD && {!isPlayer _mkD}) then {_mkD doFollow (leader (group _mkD))};
_h flyInHeight _fly;
["INFO", "waterLand", "%1 at %2: water landing ended by a new order - lifting off", [typeOf _h, mapGridPosition _h]] call MCC_fnc_log;
[_h] spawn {
	params ["_h"];
	private _t = time + 180;
	waitUntil {sleep 1; !alive _h || {time > _t} || {((getPosATL _h) select 2) > 5}};
	if (alive _h && {((getPosATL _h) select 2) > 5}) then {_h setVariable ["MCCMK_waterLanding", nil, true]};
};
