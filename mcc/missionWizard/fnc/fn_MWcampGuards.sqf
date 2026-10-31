params [["_pos", [], [[]]], ["_radius", 30, [0]], ["_intensity", 4, [0]], ["_faction", "", [""]], ["_side", sideUnknown, [sideUnknown]]];
if (!isServer || {count _pos < 2} || {_faction == ""}) exitWith {};
private _positions = 0;
{_positions = _positions + (_x call MCC_fnc_buildingPosCount)} forEach ((nearestObjects [_pos, ["House", "Ruins", "Church", "FuelStation", "Strategic"], _radius]) select {!(_x call MCC_fnc_isWaterStructure)});
if (_positions >= 5) exitWith {};
private _count = 0;
for "_i" from 1 to 20 do {if (random 30 < _intensity) then {_count = _count + 1}};
_count = _count max 1;
private _units = [[[_faction, "soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry, _faction] call MCC_fnc_contentFilterList;
if (_units isEqualTo []) exitWith {};
private _grp = createGroup _side;
for "_i" from 1 to _count do {
	private _spot = [_pos, (_radius * 0.8) max 10, 25, 2] call MCC_fnc_landSpot;
	if (_spot isEqualTo []) then {_spot = _pos getPos [5 + random 10, random 360]};
	private _unit = _grp createUnit [(selectRandom _units) select 0, _spot, [], 0, "NONE"];
	_unit setDir (_pos getDir _unit);
	doStop _unit;
	{_x addCuratorEditableObjects [[_unit], false]} forEach allCurators;
};
_grp setBehaviour "SAFE";
if (missionNamespace getVariable ["MCC_debug", false]) then {
	["DEBUG", "MCC_fnc_MWcampGuards", "%1 guards at %2 (%3 interior positions nearby)", [_count, mapGridPosition _pos, _positions]] call MCC_fnc_log;
};
