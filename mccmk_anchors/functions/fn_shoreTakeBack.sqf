/*
    ANC_fnc_shoreTakeBack  (server)
    Scroll action "Take back the heaving line": at the loose end of a line thrown from the shore (or holding it), the
    line is untied from the boat and the Heaving line goes back into your inventory.
*/
params ["_player"];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
private _boat = _player getVariable ["ANC_holdingBoat", objNull];
if (isNull _boat) then {
    private _i = ANC_lineEnds findIf {!isNull (_x select 0) && {(_player distance (_x select 0)) <= 2.5}};
    if (_i != -1) then {_boat = (ANC_lineEnds select _i) select 1};
};
if (isNull _boat || {isNull (_boat getVariable ["ANC_shoreFromLand", objNull])}) exitWith {"There's no heaving line of yours here to take back." call _say};
private _flyer = _boat getVariable ["ANC_flyer", objNull];
if (!isNull _flyer) then {detach _flyer; deleteVehicle _flyer};
_boat setVariable ["ANC_flyer", nil];
_boat setVariable ["ANC_shoreFromLand", nil];
[_boat] call ANC_fnc_cleanup;
call ANC_fnc_shoreLists;
if (_player canAdd "ANC_HeavingLine") then {_player addItem "ANC_HeavingLine"; "Heaving line taken back." call _say} else {
    private _holder = createVehicle ["GroundWeaponHolder", getPosATL _player, [], 0, "CAN_COLLIDE"];
    _holder addItemCargoGlobal ["ANC_HeavingLine", 1];
    "No room for the Heaving line - it's on the ground at your feet." call _say;
};
