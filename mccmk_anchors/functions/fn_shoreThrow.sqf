/*
    ANC_fnc_shoreThrow  (server, spawned)
    Anchor key menu "Throw line ashore" (anyone aboard; the boat or the thrower must have a Heaving line). The bag is
    thrown from the player, in the direction they're looking: it lands on the first dry land within 20 m that way (up
    to 30 degrees either side), or - if there's no shore that way - in the water about 15 m out. It lies there until
    someone picks it up (or the boat takes it back with Shift+R). A loose end doesn't hold the boat; if the boat
    drifts beyond the line's 30 m, it drags the end.
*/
params ["_boat", "_player", ["_aim", []], ["_end", ""]];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
private _fail = {
    params ["_msg"];
    _boat setVariable ["ANC_mode", ""];
    _boat setVariable ["ANC_state", ""];
    _msg call _say;
};
if !([_player, _boat] call ANC_fnc_hasLine) exitWith {"No Heaving line in the boat or on you." call _fail};
private _hand = if (isNull _player) then {_boat modelToWorldWorld ([_boat, "towBow"] call ANC_fnc_pointFor)} else {eyePos _player};
private _land = if (count _aim == 3) then {[_boat, _aim, _hand] call ANC_fnc_shoreFind} else {[_boat] call ANC_fnc_shoreFind};
private _inWater = false;
// No shore where you're looking: the nearest shore within 20 m instead.
if (count _land == 0) then {_land = [_boat] call ANC_fnc_shoreFind};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Throw ashore: looking at %1 | from %2 | lands at %3 (%4 m away, bearing %5) | %6",
    _aim, _hand, _land, round (_hand distance2D _land),
    if (count _land == 3) then {round (((_land select 0) - (_hand select 0)) atan2 ((_land select 1) - (_hand select 1)))} else {"-"},
    ["no aim given - nearest shore used", ["shore in the direction you looked", "no shore that way - into the water"] select _inWater] select (count _aim == 3)]};
if (count _land == 0) exitWith {"No shore within 20 m." call _fail};

// Made fast at the end chosen in the menu (bow or stern) - or, with no choice (AI, waypoints), whichever end is
// nearer to where it lands.
private _pt = switch (_end) do {
    case "bow":   {[_boat, "towBow"] call ANC_fnc_pointFor};
    case "stern": {[_boat, "towStern"] call ANC_fnc_pointFor};
    default {
        [[_boat, "towBow"] call ANC_fnc_pointFor, [_boat, "towStern"] call ANC_fnc_pointFor] select (((_boat worldToModel (ASLToAGL _land)) select 1) < 0)
    };
};
private _from = _boat modelToWorldWorld _pt;
// The bag leaves the thrower's hand; the line is made fast at the boat's nearer end.
private _pad = [_boat, _pt, _hand] call ANC_fnc_shoreStart;
_boat setVariable ["ANC_state", "flying"];
_boat setVariable ["ANC_owner", _player];
[_boat, "Throwing the line ashore...", _player] call ANC_fnc_tellBoat;
[_boat, _pad, _boat getVariable ["ANC_visual", objNull], _hand, _land vectorAdd [0, 0, 0.1]] call ANC_fnc_shoreThrowBag;
if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};

_boat setVariable ["ANC_state", "loose"];
// Ashore: the line as thrown. In the water: the whole 30 m line runs out, so the bag can sink to the bottom (it hangs
// at the end of the line where it's deeper - a guide rope).
[_boat, _pad, _pt, [(_from distance (getPosASL _pad)) + 2, 30] select _inWater, 0, "loose"] call ANC_fnc_setShore;
call ANC_fnc_shoreLists;
[_boat, ["Line ashore - anyone there can pick it up.", "The line is in the water - a guide rope down to the bottom. {tow} brings it back; {payout} / Down pay out / haul in."] select _inWater] call ANC_fnc_tellBoat;
[_boat] spawn ANC_fnc_shoreWatch;
