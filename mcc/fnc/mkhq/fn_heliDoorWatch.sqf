/*
	MCCMK_fnc_heliDoorWatch - (server; spawn) an AI helicopter landing to pick up or drop off: its doors and ramp open as it
	touches down, and close as it takes off again (MCCMK_fnc_heliDoorsAll). [helicopter, how long to wait for it to land (s)]
	Used for the Commander Console's pickups (Tarus and their pods included), the rescue's landing at a base or on a ship,
	the Commander Console's rope extraction landing at a base, and the Evac's landings.
*/
params [["_h", objNull, [objNull]], ["_wait", 600]];
if (!isServer || {isNull _h} || {_h getVariable ["MCCMK_doorWatch", false]}) exitWith {};
_h setVariable ["MCCMK_doorWatch", true, true];
private _t = time + _wait;
private _down = {isTouchingGround _h || {((getPosATL _h) select 2) < 1.2}};
waitUntil {sleep 0.5; !alive _h || {time > _t} || {(call _down) && {(abs (speed _h)) < 5}}};
if (alive _h && {call _down}) then {
	[_h, true] call MCCMK_fnc_heliDoorsAll;
	["DEBUG", "doors", "%1 landed at %2: doors and ramp open", [typeOf _h, mapGridPosition _h]] call MCC_fnc_log;
	waitUntil {sleep 0.5; !alive _h || {((getPosATL _h) select 2) > 3 && {!isTouchingGround _h}}};
	if (alive _h) then {
		[_h, false] call MCCMK_fnc_heliDoorsAll;
		["DEBUG", "doors", "%1 taking off: doors and ramp closed", [typeOf _h]] call MCC_fnc_log;
	};
};
_h setVariable ["MCCMK_doorWatch", false, true];
