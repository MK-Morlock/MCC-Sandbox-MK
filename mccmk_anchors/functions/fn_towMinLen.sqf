/*
    ANC_fnc_towMinLen
    Shortest the tow line may be hauled in to.
      Normally 2 m between the attachment points. If either attachment point is more than 2 m above its boat's
      waterline, a 2 m line would start lifting a boat's end, so instead the limit keeps the two HULLS 2 m apart at
      the ends the line joins (each attachment point's distance in from its hull end is added, and the height
      difference allowed for).
    [tower, towerPoint, towed, towedPoint]
*/
params ["_tower", "_tPt", "_towed", "_dPt"];
private _height = {
    params ["_v", "_p"];
    if (_v isKindOf "Ship" || {_v call ANC_fnc_isSubmersible}) then {(_p select 2) - ((_v call ANC_fnc_boatGeometry) select 7)} else {0}
};
if (([_tower, _tPt] call _height) <= 2 && {([_towed, _dPt] call _height) <= 2}) exitWith {2};

// How far each attachment point is in from the nearer end of its hull.
private _inFromEnd = {
    params ["_v", "_p"];
    (boundingBoxReal _v) params ["_bbMin", "_bbMax"];
    (abs ((_p select 1) - (_bbMax select 1))) min (abs ((_p select 1) - (_bbMin select 1)))
};
private _dz = ((_tower modelToWorldWorld _tPt) select 2) - ((_towed modelToWorldWorld _dPt) select 2);
sqrt ((_dz ^ 2) + ((2 + ([_tower, _tPt] call _inFromEnd) + ([_towed, _dPt] call _inFromEnd)) ^ 2))
