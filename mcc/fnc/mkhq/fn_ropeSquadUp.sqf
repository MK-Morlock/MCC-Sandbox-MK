/*
	MCCMK_fnc_ropeSquadUp - (server) "Pickup rope: my squad" (and the console's Rope extraction): [units, helicopter].
	The AI among them on foot within 30 m (across) of the helicopter each get a rope and are winched up (MCCMK_fnc_ropeUp)
	as rope points and seats come free; those further out are ordered in under it. Players climb their own (the "Request
	pickup rope" action). Until everyone is aboard, the helicopter flies off (over 30 km/h) or 4 minutes.
*/
params [["_us", []], ["_h", objNull]];
if (!isServer || {isNull _h}) exitWith {};
private _t = time + 240;
while {alive _h && {time < _t} && {(speed _h) < 30}} do {
	private _left = _us select {alive _x && {!((vehicle _x) isEqualTo _h)}};
	if (_left isEqualTo []) exitWith {};
	{
		if (!isPlayer _x && {vehicle _x == _x} && {!(_x getVariable ["ARMK_Is_Rappelling", false])}) then {
			if ((_x distance2D _h) < 30) then {[_x, _h] call MCCMK_fnc_ropeUp} else {
				if (time > (_x getVariable ["MCCMK_ropeMoveT", 0])) then {_x setVariable ["MCCMK_ropeMoveT", time + 5]; _x doMove (getPos _h)};
			};
		};
	} forEach _left;
	sleep 1;
};
