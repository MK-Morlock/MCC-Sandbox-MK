//==================================================================MCC_fnc_drawLine===============================================================================================
// Draw a line on the map localy between two points
// Example: [MCC_pointA,MCC_pointB,MCC_IEDLineCount] call MCC_fnc_drawLine; 
// MCC_pointA = position, start position of the line
// MCC_pointB = position, end position of the line
// MCC_IEDLineCount = integer, uniq number, can't have two markers with the same number
//==================================================================================================================================================================================
private "_dist";
private "_dir";
private _center = [];
private _lineMarkerName = "";
params ["_start", "_end", "_marker"];
_lineMarkerName = format ["line_%1", _marker];
_dist = _start distance _end;
_dir = ((_end select 0) - (_start select 0)) atan2
((_end select 1) - (_start select 1));

_center = [(_start select 0) + ((sin _dir) * _dist / 2),
(_start select 1) + ((cos _dir) * _dist / 2)];

createMarkerLocal [_lineMarkerName, _center];
_lineMarkerName setMarkerShapeLocal "RECTANGLE";
_lineMarkerName setMarkerSizeLocal [1.5, _dist / 2];
_lineMarkerName setMarkerColorLocal "ColorBlack";
_lineMarkerName setMarkerDirLocal _dir;
