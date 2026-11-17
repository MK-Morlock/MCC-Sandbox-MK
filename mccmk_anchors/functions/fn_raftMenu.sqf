/*
    ANC_fnc_raftMenu  (client)
    Raft-Up / Tether with more than one boat within 10 m: a list to choose from, in the same style as the tow line
    list - "Combat Boat (HMG) - 2 m, port (Raft-Up)". Nearest first.
    [boat, [[other boat, gap], ...]]
*/
params [["_boat", objNull, [objNull]], ["_cands", [], [[]]], ["_choice", "raft", [""]]];
if (!hasInterface || {isNull _boat} || {count _cands == 0}) exitWith {};
ANC_raftMenuBoat = _boat;
private _labels = _cands apply {
    private _o = _x select 0;
    format ["%1  (%2)", [_boat, _o] call ANC_fnc_boatLabel, ["Raft-Up", "Tether"] select ((_choice isEqualTo "tether") || {_boat call ANC_fnc_isDinghy} || {_o call ANC_fnc_isDinghy})]
};
[[ "Raft-Up - which boat?", "Tether - which boat?"] select (_choice isEqualTo "tether"), _labels, {
    params ["_i"];
    [["raftPick", ANC_raftMenuBoat, player, _i], "server", 2] call ANC_fnc_remote;
}] call ANC_fnc_listMenu;
