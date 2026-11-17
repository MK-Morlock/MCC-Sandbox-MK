/*
    ANC_fnc_groundCanMove  (128; server)
    Can the people holding this shore line drag the boat over the ground towards them? (Aground or on land.) The same
    rules as the pull itself (ANC_fnc_rodeTick): a boat under 8 m, the ground ahead not too steep (the "Steepest
    shore" setting) or rocky, and their pull - the "Pulling force over ground" setting, per person on the line -
    beating the hull's grip along its length (about a third of its weight for an inflatable, half for a hard hull).
    Used when hauling in: if the boat can come, the line can be taken in even though you haven't moved closer. [boat,
    line end]
*/
params [["_boat", objNull, [objNull]], ["_pad", objNull, [objNull]]];
if (isNull _boat || {isNull _pad}) exitWith {false};
(_boat call ANC_fnc_boatGeometry) params ["", "", "", "", "", "", "_length"];
if (_length >= 8) exitWith {false};
true
