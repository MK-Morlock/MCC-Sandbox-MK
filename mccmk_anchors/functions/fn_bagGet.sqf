/*
    ANC_fnc_bagGet  (server)
    "Get Bag": someone on foot within 4 m of a boat takes its rope bag in hand. The line is made fast at the boat's
    nearer end (bow or stern) and runs out to the distance they're standing from it; Needs a Heaving line in the boat
    or on them, and nothing else out from the boat (anchor, mooring, tow, another line).
    [player, boat]
*/
params ["_player", "_boat"];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
if (isNull _player || {isNull _boat} || {!alive _player} || {!alive _boat} || {!isNull objectParent _player}) exitWith {};
if (!isNull (_player getVariable ["ANC_holdingBoat", objNull])) exitWith {"You're already holding a line." call _say};
if (count (_boat getVariable ["ANC_shoreData", []]) > 0) exitWith {"That boat's rope bag is already out." call _say};
// Anchors handles one line at a time per boat - the bag can't come out while its anchor, mooring lines or tow line
// are out
if !((_boat getVariable ["ANC_mode", ""]) isEqualTo "") exitWith {"Bring in the anchor / cast off / let go the tow line first - the boat can only have one line out at a time." call _say};
if !([_player, _boat] call ANC_fnc_hasLine) exitWith {"No Heaving line in the boat or on you." call _say};
// the boat's nearer end
private _bowP = [_boat, "towBow"] call ANC_fnc_pointFor;
private _sternP = [_boat, "towStern"] call ANC_fnc_pointFor;
private _me = getPosASL _player;
private _pt = [_sternP, _bowP] select (((_boat modelToWorldWorld _bowP) distance _me) <= ((_boat modelToWorldWorld _sternP) distance _me));
// the bag at their feet, then in their hand (ANC_fnc_shorePick)
_boat setVariable ["ANC_mode", "shore"];
_boat setVariable ["ANC_owner", _player];
private _pad = [_boat, _pt, _me vectorAdd [0, 0, 0.1]] call ANC_fnc_shoreStart;
_boat setVariable ["ANC_state", "loose"];
[_boat, _pad, _pt, ((_boat modelToWorldWorld _pt) distance _me) + 0.5, 0, "loose"] call ANC_fnc_setShore;
call ANC_fnc_shoreLists;
[_boat] spawn ANC_fnc_shoreWatch;
[_player] call ANC_fnc_shorePick;
