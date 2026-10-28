params [["_pos", [0,0,0], [[]]], ["_cruise", false, [false]]];
if (isNil "MCCMK_lineN") then {MCCMK_lineN = 0};
MCCMK_lineN = MCCMK_lineN + 1;
private _m = format ["mccmk_tgt_%1", MCCMK_lineN];
createMarkerLocal [_m, _pos];
_m setMarkerShapeLocal "ICON";
_m setMarkerTypeLocal "mil_destroy";
_m setMarkerColorLocal "ColorRed";
_m setMarkerSizeLocal [0.9, 0.9];
if (_cruise) then {MCCMK_cruiseMarker = _m};
_m
