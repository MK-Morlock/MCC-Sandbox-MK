/*
    ANC_fnc_towPoint
    Where a tow line is made fast: the vehicle doing the towing at its STERN, the vehicle being towed at its BOW. Uses
    ANC_fnc_pointFor, so adjusted points are used. [vehicle, true] = stern.
*/
params [["_veh", objNull, [objNull]], ["_stern", false, [false]]];
[_veh, ["towBow", "towStern"] select _stern] call ANC_fnc_pointFor
