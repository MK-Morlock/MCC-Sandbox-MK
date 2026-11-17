/*
 ANC_fnc_hasLine
 - a unit carries a Heaving line, or (with a boat given) the boat or the unit does. [unit, boat]
*/
params [["_unit", objNull, [objNull]], ["_boat", objNull, [objNull]]];
("ANC_HeavingLine" in (items _unit)) || {!isNull _boat && {"ANC_HeavingLine" in (itemCargo _boat)}}
