/*
    ANC_fnc_boatLabel  (any computer)
    "Combat Boat (HMG) - 3 m, port" - the other boat's name, the gap between the hulls and which side it's on, as seen
    from this boat. The same wording everywhere a boat is chosen (tow line, Board Boat, Boat Cargo, Raft-Up / Tether).
    [this boat, other boat]
*/
params ["_from", "_to"];
private _rel = _from getRelDir _to;
private _where = switch (true) do {
    case (_rel < 30 || {_rel > 330}): {"ahead"};
    case (_rel < 150): {"starboard"};
    case (_rel < 210): {"astern"};
    default {"port"};
};
format ["%1  -  %2 m, %3", getText (configOf _to >> "displayName"), round ((([_from, _to] call ANC_fnc_hullGap) select 0) max 0), _where]
