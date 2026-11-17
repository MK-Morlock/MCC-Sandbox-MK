/*
    ANC_fnc_raftWatchdog  (server, spawned)
    While rafted up or tethered: keeps each visible line running between the boats with a small sag, and lets go if
    either boat is destroyed or deleted, a submarine dives, or the boats are somehow torn more than 30 m apart.
    [boat]
*/
params ["_boat"];
while {true} do {
    sleep 0.25;
    if (isNull _boat || {!alive _boat}) exitWith {[_boat] call ANC_fnc_cleanup};
    if !((_boat getVariable ["ANC_mode", ""]) in ["raft", "tether"]) exitWith {};
    private _link = _boat getVariable ["ANC_raftLink", []];
    if (count _link < 5) exitWith {};
    private _other = _link select 0;
    if (isNull _other || {!alive _other} || {!(_boat call ANC_fnc_isSurfaced)} || {!(_other call ANC_fnc_isSurfaced)} || {(_boat distance _other) > 30}) exitWith {
        [_boat] call ANC_fnc_cleanup;
        [_boat, "The lines to the other boat are gone."] call ANC_fnc_tellBoat;
    };
    // Raft-up: the ropes (boat to boat) always hang slack, a little longer than the gap - only seen, never pulling;
    // the boat is kept in place by ANC_fnc_raftHold. A tether's rope is left at its length - it's what holds the
    // boats.
    if ((_boat getVariable ["ANC_mode", ""]) isEqualTo "raft") then {
        {
            _x params ["_rope", "", "", "_myPt", ["_thPt", []]];
            if (!isNull _rope && {count _thPt == 3}) then {
                private _gap = (_boat modelToWorldWorld _myPt) distance (_other modelToWorldWorld _thPt);
                private _cur = ropeLength _rope;
                private _visual = (_gap * 1.04) + 0.4;
                if ((_cur < _gap + 0.25) || {abs (_cur - _visual) > 0.2}) then {ropeUnwind [_rope, 3, _visual]};
            };
        } forEach (_boat getVariable ["ANC_lines", []]);
    };
};
