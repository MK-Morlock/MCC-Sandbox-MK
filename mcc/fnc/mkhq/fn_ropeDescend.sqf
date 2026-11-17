/*
	MCCMK_fnc_ropeDescend - (server) MCC's fast-rope, with "Rope animation": Harness - each man down an Advanced
	Rappelling rope (ARMK_Rappel_From_Heli: a rope per man from its rope points, swinging; players hold S - Shift faster -
	AI go by themselves), in seat order as rope points come free. [helicopter, men] -> true once they're all down (or 3
	minutes, a player who hasn't come down included); false if not used (Ladder, or Advanced Rappelling not there) - the
	caller then ropes them down its own way.
*/
params [["_h", objNull], ["_men", []]];
if (!(call MCCMK_ropeHarness) || {isNull _h}) exitWith {false};
private _t = time + 180;
{
	private _u = _x;
	private _tu = time + 60;
	while {alive _u && {alive _h} && {(vehicle _u) isEqualTo _h} && {!(_u getVariable ["ARMK_Is_Rappelling", false])} && {time < _tu}} do {
		// (MK) only once one of its rope points is free: asked while they are all in use, Advanced Rappelling tells a waiting
		// player "All rappel anchors in use. Please try again." once a second
		private _free = false;
		{if (isNull (_h getVariable ["ARMK_Rappelling_Player_" + str _forEachIndex, objNull])) exitWith {_free = true}} forEach ([_h] call ARMK_Get_Heli_Rappel_Points);
		if (_free) then {[_u, _h] call ARMK_Rappel_From_Heli};
		sleep 1;
	};
	sleep 0.6;
} forEach ((((fullCrew _h) apply {_x select 0}) select {_x in _men}) select {alive _x});	// (seat order, as MCC's fast-rope)
waitUntil {sleep 1; !alive _h || {time > _t} || {(_men findIf {alive _x && {((vehicle _x) isEqualTo _h) || {_x getVariable ["ARMK_Is_Rappelling", false]}}}) < 0}};
sleep 2;
true
