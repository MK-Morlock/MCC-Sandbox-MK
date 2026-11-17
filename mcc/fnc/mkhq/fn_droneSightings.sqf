/*
	MCCMK_fnc_droneSightings - on a player's machine: what a friendly AI drone has just seen (MCC_fnc_aiDrones, "Friendly
	drone sightings"). Given to the player's group, so Arma shows them with its own known-enemy map icons (where the
	difficulty allows them; placed where seen, fading as the knowledge gets old). With "on any difficulty" and the difficulty
	hiding enemy icons, matching icons are drawn on the map instead - the game's own unit and vehicle icons, in the target's
	side colour, where it was seen, faded out over 60 s - for those sightings only.
	[[[unit, position, direction, icon, colour], ...], mode (1 Arma's icons / 2 on any difficulty)]
*/
params [["_list", [], [[]]], ["_mode", 1, [0]]];
if (!hasInterface || {isNull player}) exitWith {};
private _g = group player;
{
	_x params ["_u"];
	if (!isNull _u) then {_g reveal [_u, 2]};
} forEach _list;
if (_mode < 2 || {(difficultyOption "mapContentEnemy") > 0}) exitWith {};
if (isNil "MCCMK_droneMarks") then {MCCMK_droneMarks = createHashMap};
{
	_x params ["_u", "_p", "_d", "_ic", "_col"];
	MCCMK_droneMarks set [if (isNull _u) then {str _p} else {netId _u}, [_p, _d, _ic, _col, time]];
} forEach _list;
if (isNil "MCCMK_droneDrawEH") then {
	MCCMK_droneDrawEH = -2;
	[] spawn {
		disableSerialization;
		waitUntil {sleep 1; !isNull ((findDisplay 12) displayCtrl 51)};
		MCCMK_droneDrawEH = ((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw", {
			params ["_m"];
			{
				(MCCMK_droneMarks get _x) params ["_p", "_d", "_ic", "_col", "_t"];
				private _a = 1 - ((time - _t) / 60);
				if (_a <= 0) then {MCCMK_droneMarks deleteAt _x} else {
					_m drawIcon [_ic, [_col select 0, _col select 1, _col select 2, _a], _p, 22, 22, _d, "", 0];
				};
			} forEach (keys MCCMK_droneMarks);
		}];
	};
};
