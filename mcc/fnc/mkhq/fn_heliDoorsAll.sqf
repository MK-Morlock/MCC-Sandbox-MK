/*
	MCCMK_fnc_heliDoorsAll - an AI helicopter's doors AND ramp opened or closed: [helicopter, open?]. Its own side doors (read
	from its config - MCCMK_fnc_aircraftDoors), its ramp or rear doors (MCCMK_fnc_aircraftRamp), MCC's own list of door
	names (MCC_fnc_heliOpenCloseDoor), and a Taru's pod (its doors and ramp) when it carries one.
*/
params [["_h", objNull, [objNull]], ["_open", true, [true]]];
if (isNull _h || {!alive _h}) exitWith {};
[_h, _open] call MCCMK_fnc_aircraftDoors;
[_h, _open] call MCCMK_fnc_aircraftRamp;
[_h, _open] spawn MCC_fnc_heliOpenCloseDoor;
private _pod = _h getVariable ["MCC_attachedPod", objNull];
if (!isNull _pod) then {
	{
		private _an = toLower (configName _x);
		if ((_an find "door") >= 0 || {(_an find "ramp") >= 0}) then {_pod animateSource [configName _x, [0, 1] select _open]};
	} forEach ("true" configClasses (configOf _pod >> "AnimationSources"));
};
_h setVariable ["MCCMK_doorsOpen", _open, true];
