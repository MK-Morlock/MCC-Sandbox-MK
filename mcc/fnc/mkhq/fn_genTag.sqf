/*
	MCCMK_fnc_genTag - (server) marks something a generated mission has just created as that mission's: [object / group /
	marker name / array of them] -> what it was given. The mission's ID comes from the generator's own scope
	(_MCCMK_gen, set where the mission starts and passed on to every thread and server call that spawns its content -
	MCCMK_fnc_genRun); anything created outside a generator has none, so it is never marked. "Delete Missions", the
	automatic cleanup and a cancelled mission remove only what is marked (MCC_fnc_generatedMissions).
*/
params ["_t"];
if (isNil "_MCCMK_gen" || {!(_MCCMK_gen isEqualType "")} || {_MCCMK_gen == ""}) exitWith {_t};
private _id = _MCCMK_gen;
private _mark = {
	params ["_o"];
	switch (true) do {
		case (_o isEqualType objNull): {if (!isNull _o) then {_o setVariable ["MCCMK_genId", _id]}};
		case (_o isEqualType grpNull): {if (!isNull _o) then {_o setVariable ["MCCMK_genId", _id]; {_x setVariable ["MCCMK_genId", _id]} forEach (units _o)}};
		case (_o isEqualType ""): {
			if (_o != "") then {
				private _all = missionNamespace getVariable ["MCCMK_genMarkers", createHashMap];
				if !(_all isEqualType createHashMap) then {_all = createHashMap};
				private _l = _all getOrDefault [_id, []];
				_l pushBackUnique _o;
				_all set [_id, _l];
				missionNamespace setVariable ["MCCMK_genMarkers", _all];
			};
		};
		case (_o isEqualType []): {{[_x] call _mark} forEach _o};
	};
};
[_t] call _mark;
_t
