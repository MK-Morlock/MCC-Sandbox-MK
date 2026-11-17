/*
	MCCMK_fnc_airTrack - (debug) notes what spawned an AI aircraft, and logs when it's destroyed or removed, with how long it
	was up and where. Called by the systems that spawn AI aircraft (enemy CAS, campaign patrols, Air Patrol, helicopter
	QRF, naval air) and by MCC_fnc_spawnVehicle for any other. [vehicle, source]
*/
params [["_v", objNull, [objNull]], ["_src", "", [""]]];
if (isNull _v || {!(_v isKindOf "Air")}) exitWith {};
private _had = _v getVariable ["MCCMK_airSrc", ""];
if (_src != "" && {_had == "" || {_had == "spawnVehicle"}}) then {_v setVariable ["MCCMK_airSrc", _src]};
if !(missionNamespace getVariable ["MCC_debug", false]) exitWith {};
private _name = getText (configOf _v >> "displayName");
if (_v getVariable ["MCCMK_airTracked", false]) exitWith {
	if (_src != "" && {_src != _had}) then {["INFO", "air", "%1 (%2): spawned by %3", [typeOf _v, _name, _src]] call MCC_fnc_log};
};
_v setVariable ["MCCMK_airTracked", true];
_v setVariable ["MCCMK_airT0", time];
["INFO", "air", "%1 (%2) spawned by %3 at %4, side %5", [typeOf _v, _name, _v getVariable ["MCCMK_airSrc", "?"], mapGridPosition _v, side (group (driver _v))]] call MCC_fnc_log;
_v addEventHandler ["Killed", {
	params ["_v", "_k"];
	["INFO", "air", "%1 (%2, spawned by %3) DESTROYED at %4 after %5 s%6", [typeOf _v, getText (configOf _v >> "displayName"), _v getVariable ["MCCMK_airSrc", "?"], mapGridPosition _v, round (time - (_v getVariable ["MCCMK_airT0", time])), if (isNull _k) then {""} else {format [" by %1", typeOf _k]}]] call MCC_fnc_log;
}];
_v addEventHandler ["Deleted", {
	params ["_v"];
	["INFO", "air", "%1 (%2, spawned by %3) REMOVED (deleted) at %4 after %5 s, %6, %7 m up, crew %8", [typeOf _v, getText (configOf _v >> "displayName"), _v getVariable ["MCCMK_airSrc", "?"], mapGridPosition _v, round (time - (_v getVariable ["MCCMK_airT0", time])), ["destroyed", "intact"] select (alive _v), round ((getPosATL _v) select 2), {alive _x} count (crew _v)]] call MCC_fnc_log;
}];
