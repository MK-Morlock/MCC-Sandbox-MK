/*
    ANC_fnc_boatPick  (client)
    "Board Boat" or "Boat Cargo" picked: with one boat within 10 m it's that boat; with several, a list to choose from
    first ("Combat Boat (HMG) - 3 m, port bow"), in the same style as the tow line list.
    ["board" / "cargo"]
*/
params [["_what", "", [""]]];
ANC_pickWhat = _what;
private _onFoot = isNull objectParent player;
// (MK) on foot: boats within 10 m of their hull; from a boat: Board Boat within 10 m, Boat Cargo within 20 m (hull to hull)
ANC_pickBoats = if (_what isEqualTo "board") then {if (_onFoot) then {+ANC_footBoats} else {+(missionNamespace getVariable ["ANC_nearBoardBoats", []])}} else {+ANC_nearBoats};
if (count ANC_pickBoats == 0) exitWith {};
ANC_pickGo = {
    params ["_b"];
    switch (ANC_pickWhat) do {
        case "board": {[_b] call ANC_fnc_boardMenu};
        case "cargo": {[_b] call ANC_fnc_cargoUI};
    };
};
if (count ANC_pickBoats == 1) exitWith {[ANC_pickBoats select 0] call ANC_pickGo};
private _v = vehicle player;
// on foot: the boat's name, its distance and which way it is from where you face
private _labels = if (_onFoot) then {
    ANC_pickBoats apply {
        private _rel = player getRelDir _x;
        private _where = switch (true) do {
            case (_rel < 30 || {_rel > 330}): {"ahead"};
            case (_rel < 150): {"to your right"};
            case (_rel < 210): {"behind you"};
            default {"to your left"};
        };
        format ["%1  -  %2 m, %3", getText (configOf _x >> "displayName"), round (([player, _x] call ANC_fnc_hullDist) max 0), _where]	// (MK) to its hull
    }
} else {ANC_pickBoats apply {[_v, _x] call ANC_fnc_boatLabel}};
[["Board which boat?", "Cargo - which boat?"] select (_what isEqualTo "cargo"), _labels, {
    params ["_i"];
    private _b = ANC_pickBoats param [_i, objNull];
    if (!isNull _b) then {[_b] call ANC_pickGo};
}] call ANC_fnc_listMenu;
