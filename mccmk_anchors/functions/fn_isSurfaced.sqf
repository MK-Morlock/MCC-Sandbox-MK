/*
    ANC_fnc_isSurfaced
    True if the top of the hull is at least 0.2 m above the waves. Always true for ordinary boats; for submarines /
    SDVs it means they are afloat on the surface, not dived.
*/
params [["_boat", objNull, [objNull]]];
if !(_boat call ANC_fnc_isSubmersible) exitWith {true};
(_boat call ANC_fnc_boatGeometry) params ["_cx", "", "", "", "", "_topZ"];
// AGL over the sea is measured from the wave surface.
((_boat modelToWorldVisual [_cx, 0, _topZ]) select 2) > 0.2
