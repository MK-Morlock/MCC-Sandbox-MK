/*
    ANC_fnc_shoreActions  (client; at mission start and after respawn)
    Actions for someone on foot (scroll menu, or ACE's self menu - ANC_fnc_act):
      Throw heaving line to ... - carrying a Heaving line, looking at a boat within 20 m
      Pick up the line               - a loose line end within 2.5 m
      Take hold of the line          - someone within 3 m is holding a line (pull together)
      Make the line fast             - holding the end, a tree / post / rock within 3 m
      Drop the line                  - holding a line
      Throw the bag                  - carrying one: just throws it the way you look - into the sea (or onto the ground)
      Haul in the heaving line       - at the end of one thrown into the sea, within 2.5 m
    The searches run twice a second in the background, so the actions cost nothing while you're not near a boat or a
    line.
*/
if (!hasInterface) exitWith {};
if (isNil "ANC_shoreLoop") then {
    ANC_shoreLoop = [] spawn {
        while {true} do {
            private _u = player;
            ANC_actBoat = objNull;
            ANC_actPick = "";
            ANC_actPost = false;
            ANC_actTakeBack = false;
            ANC_actHaulSea = false; // the end of a heaving line thrown into the sea, within 2.5 m
            if (alive _u && {vehicle _u isEqualTo _u}) then {
                private _held = _u getVariable ["ANC_holdingBoat", objNull];
                if (isNull _held) then {
                    if ("ANC_HeavingLine" in (items _u)) then {
                        // The boat you're looking at: within 20 m and within 45 degrees of your view.
                        private _boats = (nearestObjects [_u, ["Ship"], 35]) select {alive _x && {(_x getVariable ["ANC_mode", ""]) isEqualTo ""}};
                        private _view = getCameraViewDirection _u;
                        _view set [2, 0];
                        _view = vectorNormalized _view;
                        private _bestAngle = 45;
                        {
                            private _b = _x;
                            private _ends = [[_b, "towBow"] call ANC_fnc_pointFor, [_b, "towStern"] call ANC_fnc_pointFor] apply {_b modelToWorldWorld _x};
                            private _near = _ends apply {_x distance (getPosASL _u)};
                            if ((selectMin _near) <= 20) then {
                                private _to = (getPosASL _b) vectorDiff (getPosASL _u);
                                _to set [2, 0];
                                private _angle = acos ((((vectorNormalized _to) vectorDotProduct _view) max -1) min 1);
                                if (_angle < _bestAngle) then {_bestAngle = _angle; ANC_actBoat = _b};
                            };
                        } forEach _boats;
                    };
                    ANC_actHaulSea = ((missionNamespace getVariable ["ANC_seaLines", []]) findIf {!isNull (_x select 0) && {(_x select 7) isEqualTo "out"} && {(_u distance (_x select 0)) <= 2.5}}) != -1;
                    private _endI = (missionNamespace getVariable ["ANC_lineEnds", []]) findIf {!isNull (_x select 0) && {(_u distance (_x select 0)) <= 2.5}};
                    if (_endI != -1) then {
                        ANC_actPick = "pick";
                        // A heaving line thrown from the shore can be taken back into the inventory.
                        private _lb = (ANC_lineEnds select _endI) select 1;
                        ANC_actTakeBack = !isNull (_lb getVariable ["ANC_shoreFromLandPub", objNull]);
                    } else {
                        if (((missionNamespace getVariable ["ANC_heldLines", []]) findIf {!isNull (_x select 1) && {(_x select 1) != _u} && {(_u distance (_x select 1)) <= 3}}) != -1) then {ANC_actPick = "help"};
                    };
                } else {
                    ANC_actPost = !isNull ([_u] call ANC_fnc_shorePost);
                };
            };
            private _idle = !("ANC_HeavingLine" in (items _u))
                && {isNull (_u getVariable ["ANC_holdingBoat", objNull])}
                && {count (missionNamespace getVariable ["ANC_lineEnds", []]) == 0}
                && {count (missionNamespace getVariable ["ANC_heldLines", []]) == 0}
                && {count (missionNamespace getVariable ["ANC_seaLines", []]) == 0};
            sleep ([0.5, 3] select _idle);
        };
    };
};

// GET OUT OF A ZODIAC still moving slowly - up to 5 km/h, any direction (the game only lets you out when it has all
// but stopped). You step out into the water beside it. At the top of the menu, where Get out always is - in the
// action menu only, not shown on screen, as the game's own is. never twice on the same soldier (added again after a
// respawn / team switch), and only above 2 km/h - below that the game shows its own Get out
if ((player getVariable ["ANC_getOutAct", -1]) >= 0) then {player removeAction (player getVariable ["ANC_getOutAct", -1])};
private _goAct = [player, "ANC_getOut",
    "Get out",
    {
        private _v = vehicle player;
        if (_v isEqualTo player) exitWith {};
        unassignVehicle player;
        moveOut player;
    },
    "(vehicle player) isKindOf 'Rubber_duck_base_F' && {abs (speed (vehicle player)) > 2} && {abs (speed (vehicle player)) <= 5}", 99
] call ANC_fnc_act;
player setVariable ["ANC_getOutAct", _goAct];
[player, "ANC_throwLine",
    "Throw heaving line to the boat you're looking at",
    {[["shoreThrowLand", ANC_actBoat, player, 0], "server", 2] call ANC_fnc_remote},
    "!isNull ANC_actBoat && {isNull (player getVariable ['ANC_holdingBoat', objNull])}", 1.5, false, true
] call ANC_fnc_act;
// THROW THE BAG: just throws it, the way you're looking - into the sea (or onto the ground) - ANC_fnc_shoreThrowSea.
// Always offered with a Heaving line; looking at a boat in reach, it is there beside the throw to that boat.
[player, "ANC_throwBag",
    "Throw the bag",
    {[["shoreThrowSea", objNull, player, 0, getCameraViewDirection player], "server", 2] call ANC_fnc_remote},
    "('ANC_HeavingLine' in (items player)) && {isNull (player getVariable ['ANC_holdingBoat', objNull])} && {vehicle player isEqualTo player}", 1.49, false, true
] call ANC_fnc_act;
[player, "ANC_haul",
    "Haul in the heaving line",
    {[["shoreHaulSea", objNull, player, 0], "server", 2] call ANC_fnc_remote},
    "ANC_actHaulSea", 6, true, true
] call ANC_fnc_act;
[player, "ANC_pick",
    "Pick up the line",
    {[["shorePick", objNull, player, 0], "server", 2] call ANC_fnc_remote},
    "ANC_actPick isEqualTo 'pick'", 6, true, true
] call ANC_fnc_act;
[player, "ANC_takeBack",
    "Take back the heaving line",
    {[["shoreTakeBack", objNull, player, 0], "server", 2] call ANC_fnc_remote},
    "ANC_actTakeBack", 5.9, true, true
] call ANC_fnc_act;
[player, "ANC_help",
    "Take hold of the line (help haul)",
    {[["shorePick", objNull, player, 0], "server", 2] call ANC_fnc_remote},
    "ANC_actPick isEqualTo 'help'", 6, true, true
] call ANC_fnc_act;
[player, "ANC_fast",
    "Make the line fast",
    {[["shoreTie", objNull, player, 0], "server", 2] call ANC_fnc_remote},
    "ANC_actPost && {!isNull (player getVariable ['ANC_holdingBoat', objNull])}", 1.5, false, true
] call ANC_fnc_act;
[player, "ANC_drop",
    "Drop the line",
    {[["shoreDrop", objNull, player, 0], "server", 2] call ANC_fnc_remote},
    "!isNull (player getVariable ['ANC_holdingBoat', objNull])", 1.5, false, true
] call ANC_fnc_act;
