/*
    ANC_fnc_boatInitLine  (server, every boat as it's created)
    Puts one Heaving line in every boat's inventory (setting "Heaving line in every boat"), so a crew can always throw
    a line ashore - or take it ashore to throw back.
*/
params [["_boat", objNull, [objNull]]];
if (!isServer || {isNull _boat} || {call ANC_fnc_builtIn}) exitWith {};
[_boat] spawn {
    params ["_boat"];
    sleep 0.5; // let a just-created boat finish spawning
    if (isNull _boat || {!(missionNamespace getVariable ["ANC_lineInBoats", true])}) exitWith {};
    if (_boat getVariable ["ANC_lineAdded", false]) exitWith {};
    _boat setVariable ["ANC_lineAdded", true, true];
    if !("ANC_HeavingLine" in (itemCargo _boat)) then {_boat addItemCargoGlobal ["ANC_HeavingLine", 1]};
    // Check it actually went in (a full inventory, for instance, can refuse it).
    [_boat] spawn {
        params ["_boat"];
        sleep 1;
        if (!isNull _boat && {!("ANC_HeavingLine" in (itemCargo _boat))}) then {
            if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Couldn't put a Heaving line in %1's inventory (cargo now: %2).", typeOf _boat, itemCargo _boat]};
            _boat setVariable ["ANC_lineAdded", false, true];
        };
    };
};
