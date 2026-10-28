//==================================================================MCC_fnc_drawArrow===============================================================================================
// Draw an arrow on the map localy between two points
// Example: [MCC_pointA,MCC_pointB,arrowMarkerName,arrowType, arrowWidth,arrowColor,maxDist] call MCC_fnc_drawArrow; 
// MCC_pointA = Position, start position of the line
// MCC_pointB = Position, end position of the line
// arrowMarkerName = Integer, uniq number, can't have two markers with the same number
//arrowType = String, type of arrow
//arrowWidth = Integer, width of the arrow
//arrowColor = String, arrow color
//maxDist = Integer, maximum marker distance. 
//Returns : marker name
//==================================================================================================================================================================================
private _dist = 0;
private _dir = 0;
private _center = [];
private _arrowMarkerName = "";
params ["_start", "_end", "_marker", "_arrowType", "_arrowWidth", "_arrowColor", "_maxDist"];

_arrowMarkerName = format ["mccarrow_%1", _marker];

_dist = _start distance _end;
if (_dist>_maxDist) then {_dist = _maxDist};			//Max distance

_dir = ((_end select 0) - (_start select 0)) atan2
((_end select 1) - (_start select 1));

_center = [(_start select 0) + ((sin _dir) * _dist / 2),
(_start select 1) + ((cos _dir) * _dist / 2)];

createMarkerLocal [_arrowMarkerName, _center];
_arrowMarkerName setMarkerShapeLocal "RECTANGLE";
_arrowMarkerName setMarkerTypeLocal _arrowType;
_arrowMarkerName setMarkerSizeLocal [_arrowWidth, _dist / 2];
_arrowMarkerName setMarkerColorLocal _arrowColor;
_arrowMarkerName setMarkerDirLocal _dir;
_arrowMarkerName;
