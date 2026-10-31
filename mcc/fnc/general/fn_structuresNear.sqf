params [["_pos", [], [[], objNull]], ["_radius", 20, [0]]];
if (_pos isEqualType objNull) then {_pos = getPos _pos};
if (count _pos < 2) exitWith {false};
private _terrain = (nearestTerrainObjects [_pos, ["BUILDING", "HOUSE", "CHURCH", "CHAPEL", "FUELSTATION", "HOSPITAL", "LIGHTHOUSE", "POWER LINES", "POWERSOLAR", "POWERWAVE", "POWERWIND", "QUAY", "RUIN", "STACK", "TOURISM", "TRANSMITTER", "VIEW-TOWER", "WATERTOWER", "WALL", "FENCE", "BUNKER", "FORTRESS", "TOWER", "CROSS", "FOUNTAIN", "SHIPWRECK", "RAILWAY", "BUSSTOP"], _radius + 60, false, true]) select {!isObjectHidden _x && {((_x distance2D _pos) - (((boundingBoxReal _x) select 2) * 0.5)) < _radius}};
if (count _terrain > 0) exitWith {true};
((nearestObjects [_pos, ["Building", "Strategic", "NonStrategic"], _radius + 60]) findIf {!isObjectHidden _x && {!(_x isKindOf "AllVehicles")} && {((_x distance2D _pos) - (((boundingBoxReal _x) select 2) * 0.5)) < _radius}}) >= 0
