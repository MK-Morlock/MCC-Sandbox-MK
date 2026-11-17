/*
    ANC_fnc_tellBoat  (any computer)
    Sends a message about a boat to the players who need it: everyone aboard it, and anyone holding its shore line.
    Nobody else - not the whole server, and not someone who dropped the anchor and has since left the boat.
    [boat, message, extra player (optional, e.g. the one who asked)]
*/
params [["_boat", objNull, [objNull]], ["_msg", "", [""]], ["_extra", objNull, [objNull]]];
if (isNull _boat || {_msg isEqualTo ""}) exitWith {};
private _to = ((crew _boat) select {isPlayer _x})
    + (allPlayers select {(_x getVariable ["ANC_holdingBoat", objNull]) isEqualTo _boat});
if (!isNull _extra && {isPlayer _extra}) then {_to pushBackUnique _extra};
_to = _to arrayIntersect _to; // no duplicates
if (count _to > 0) then {[[_msg], "notify", _to] call ANC_fnc_remote};
