params [["_b", objNull, [objNull]]];
if (isNull _b || {!(_b isKindOf "Ship")} || {isNil "ANC_fnc_doAnchor"}) exitWith {};
[_b] spawn {
	params ["_b"];
	private _t = time + 60;
	waitUntil {
		sleep 0.5;
		!alive _b || {time > _t} || {isNull (attachedTo _b) && {surfaceIsWater (getPosASL _b)} && {(abs ((getPosASL _b) select 2)) < 2} && {(vectorMagnitude (velocity _b)) < 1}}
	};
	if (!alive _b || {time > _t} || {(_b getVariable ["ANC_mode", ""]) != ""} || {[_b] call ANC_fnc_isAground}) exitWith {};
	[_b] call ANC_fnc_doAnchor;
	if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "spawnAnchor", "%1 at %2: anchor ordered after spawning", [typeOf _b, mapGridPosition _b]] call MCC_fnc_log};
};
