/*
    ANC_fnc_xlAdd  (server)
    Registers an extra line - a tow line or a tether - between two vehicles in the line register (ANC_xLines), shares
    it with both, makes it the line the haul keys work on for the boat that threw it, and starts its watchdog.
    [kind ("tow" / "tether"), vehicle a (tower / maker), a's point, vehicle b (towed / other), b's point, length,
     rope, player, minimum length]  ->  id
*/
params ["_kind", "_a", "_aPt", "_b", "_bPt", "_len", "_rope", ["_player", objNull], ["_min", 2]];
if (isNil "ANC_xLines") then {ANC_xLines = createHashMap};
if (isNil "ANC_xNext") then {ANC_xNext = 0};
ANC_xNext = ANC_xNext + 1;
private _id = format ["xl%1", ANC_xNext];
ANC_xLines set [_id, createHashMapFromArray [
    ["kind", _kind], ["a", _a], ["aPt", _aPt], ["b", _b], ["bPt", _bPt], ["len", _len], ["goal", _len],
    ["rope", _rope], ["player", _player], ["min", _min], ["moving", false], ["lastPress", -10]
]];
{[_x] call ANC_fnc_addBoatHandlers; _x setVariable ["ANC_drift", true, true]; [_x] call ANC_fnc_xlSync} forEach [_a, _b];
_a setVariable ["ANC_activeLine", _id, true];
[_id] spawn ANC_fnc_xlWatch;
_id
