/*
 ANC_fnc_isDinghy
 - Zodiac-type inflatables and any boat under 6 m.
*/
params [["_boat", objNull, [objNull]]];
(_boat isKindOf "Rubber_duck_base_F") || {((_boat call ANC_fnc_boatGeometry) select 6) < 6}
