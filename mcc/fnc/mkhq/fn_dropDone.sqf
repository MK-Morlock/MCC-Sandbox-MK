/*
	MCCMK_fnc_dropDone - (server) a drop complete (its men on the ground, its cargo landed - or it failed): its green dot
	(or all of them, -1) taken off the ordering player's map. [[drop id, owner], index]
*/
params [["_dd", []], ["_i", -1]];
if (count _dd < 2 || {(_dd select 0) == ""}) exitWith {};
["done", _dd select 0, _i] remoteExec ["MCCMK_fnc_dropDots", _dd select 1];
