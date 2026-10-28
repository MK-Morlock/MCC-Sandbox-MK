//==================================================================MCC_fnc_drawBox===============================================================================================
// Draw a box on the map localy between two points
// Example: [MCC_pointA,MCC_pointB,boxMarkerName,boxType,boxColor,maxDist] call MCC_fnc_drawBox; 
// MCC_pointA = Position, start position of the line
// MCC_pointB = Position, end position of the line
// boxMarkerName = Integer, uniq number, can't have two markers with the same number
//boxType = String, type of box
//boxWidth = Integer, width of the box
//boxColor = String, box color
//maxDist = Integer, maximum marker distance. 
//Returns : marker name
//==================================================================================================================================================================================
private _center = [];
private _boxMarkerName = "";
private _hight = 0;
private _width = 0;
params ["_start", "_end", "_markerName", "_boxShape", "_boxColor", "_boxType"];

_boxMarkerName = format ["mccbox_%1", _markerName];

_center = [(((_start select 0) + (_end select 0))/2),(((_start select 1) + (_end select 1))/2)];
_width = abs ((_end select 1) - (_center select 1));  
_hight = abs ((_end select 0) - (_center select 0)); 
//hint format ["center: %1, hight: %2, width: %3",_center,_hight,_width];
createMarkerLocal [_boxMarkerName, _center];
_boxMarkerName setMarkerShapeLocal _boxShape;
_boxMarkerName setMarkerSizeLocal [_hight,_width];
_boxMarkerName setMarkerColorLocal _boxColor;
_boxMarkerName setMarkerBrushLocal _boxType;
_boxMarkerName;
