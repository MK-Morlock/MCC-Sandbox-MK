params [["_ship", objNull, [objNull]]];
if (!isServer) exitWith {};
while {!isNull _ship && {!(_ship getVariable ["MCCMK_sunk", false])}} do {
	sleep 5;
	{
		if (!isNull _x && {alive _x} && {(damage _x) > 0} && {(time - (_x getVariable ["MCCMK_lastBusy", -100])) > 30}) then {_x setDamage (((damage _x) - 0.017) max 0)};
	} forEach (_ship getVariable ["MCCMK_weapons", []]);
};
