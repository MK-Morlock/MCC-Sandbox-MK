params [["_uav", objNull, [objNull]], ["_h", 100, [0]]];
if (!alive _uav) exitWith {};
_uav engineOn true;
_uav flyInHeight _h;
if !(_uav isKindOf "Plane") then {_uav doMove (getPosATL _uav)};
