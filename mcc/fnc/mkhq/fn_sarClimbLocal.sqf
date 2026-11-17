/*
	MCCMK_fnc_sarClimbLocal - (where the unit is local) up a rescue rope: [unit, helicopter, the rope's point on it, the
	height to climb, metres a second]. Off the deck of a boat first if aboard one; a ladder-climbing pose (the game has no
	rope climb - the fast-rope borrows a ladder pose too), moved up the rope, then into a seat.
*/
params [["_u", objNull], ["_h", objNull], ["_pt", [0, 0, 0]], ["_ht", 18], ["_spd", 1.5]];
if (isNull _u || {!local _u} || {isNull _h}) exitWith {};
if (vehicle _u != _u) then {unassignVehicle _u; moveOut _u; sleep 0.3};
private _z = -(_ht max 3);
_u attachTo [_h, [_pt select 0, _pt select 1, _z]];
_u switchMove "LadderCivilUpLoop";
private _step = (_spd max 0.3) * 0.05;
while {_z < -1.5 && {alive _u} && {alive _h}} do {
	_z = _z + _step;
	_u attachTo [_h, [_pt select 0, _pt select 1, _z]];
	sleep 0.05;
};
detach _u;
_u switchMove "";
if (alive _u && {alive _h}) then {
	_u moveInCargo _h;
	if (vehicle _u != _h) then {_u moveInAny _h};
};
