/*
    ANC_fnc_moorWatchdog  (server, spawned)
    While moored: keeps each visible line running from the boat to the dock with a small sag (resized only when
    clearly off, so it doesn't jump); cleans up if the boat is destroyed or deleted; casts off if a submarine / SDV
    dives.
*/
params ["_boat"];
private _lines = [];
while {true} do {
    sleep 0.25;
    if (isNull _boat) exitWith {
        {
            _x params ["_rope", "_helper", "_pad"];
            if (!isNull _rope) then {ropeDestroy _rope};
            if (!isNull _helper) then {detach _helper; deleteVehicle _helper};
            if (!isNull _pad) then {deleteVehicle _pad};
        } forEach _lines;
    };
    if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};
    if !((_boat getVariable ["ANC_state", ""]) in ["moored", "mooring"]) exitWith {};
    _lines = _boat getVariable ["ANC_lines", []];

    if !(_boat call ANC_fnc_isSurfaced) exitWith {
        [_boat] call ANC_fnc_cleanup;
        [_boat, "Diving - lines cast off."] call ANC_fnc_tellBoat;
    };

    if ((missionNamespace getVariable ["ANC_moorPhysics", 0]) == 1 && {isMultiplayer} && {(count crew _boat) == 0} && {!local _boat}) then {
        _boat setOwner 2;
    };

    private _data = _boat getVariable ["ANC_moorData", []];
    {
        _x params ["_rope", "_helper", "_pad", "_boatPoint"];
        if (!isNull _rope && {!isNull _pad}) then {
            private _gap = (_boat modelToWorldWorld _boatPoint) distance (getPosASL _pad);
            private _len = ((_data param [_forEachIndex, []]) param [2, _gap]);
            private _cur = ropeLength _rope;
            if ((missionNamespace getVariable ["ANC_moorPhysics", 0]) == 1) then {
                // Arma rope physics: the rope is the line - set to its length, Arma pulls.
                if (abs (_cur - _len) > 0.05) then {ropeUnwind [_rope, 1, _len]};
            } else {
                // Anchors model: the rope only shows the line. Taut lines run nearly straight (5 cm over the gap);
                // slack ones hang with a natural sag. Resized gently (2 m/s) and only when clearly off, so it moves
                // smoothly. never drawn tight: an Arma rope pulls hard on what it's tied to once taut, and can fling
                // a boat. A taut line hangs with a slight sag (20 cm more than the gap); a slack one with its natural
                // sag.
                private _visual = if (_gap >= _len - 0.1) then {(_gap * 1.02) + 0.2} else {(_len min ((_gap * 1.04) + 0.3)) max ((_gap * 1.02) + 0.2)};
                if ((_cur < _gap + 0.12) || {abs (_cur - _visual) > 0.25}) then {ropeUnwind [_rope, 2, _visual]};
            };
        };
    } forEach _lines;
};
