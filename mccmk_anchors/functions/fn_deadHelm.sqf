/*
    ANC_fnc_deadHelm  (server, once)
    A boat whose driver is killed keeps its engine, throttle and rudder in Arma - it carries on, often circling or
    reversing round and round. Here: when a unit dies in a boat's driver seat and nobody living takes the wheel within
    a few seconds (AI often moves another crewman across), the boat's engine is switched off - it coasts to a stop and
    drifts with the wind (ANC_fnc_driftTick), as an abandoned boat would. Anyone getting into the driver's seat can
    start it again as normal.
*/
if (!isServer || {!isNil "ANC_deadHelmEH"}) exitWith {};
ANC_deadHelmEH = addMissionEventHandler ["EntityKilled", {
    params ["_unit"];
    private _boat = objectParent _unit;
    if (isNull _boat || {!(_boat isKindOf "Ship")} || {!((driver _boat) isEqualTo _unit)} || {unitIsUAV _boat}) exitWith {};
    [_boat] spawn {
        params ["_boat"];
        sleep 4;
        if (isNull _boat || {!alive _boat} || {alive (driver _boat)} || {!isEngineOn _boat}) exitWith {};
        // (through CBA events: works on servers that whitelist remote calls; only the boat's own computer acts on it)
        [[_boat], "engineOff", _boat] call ANC_fnc_remote;
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] %1 at %2: driver killed, nobody at the wheel - engine off, it drifts.", typeOf _boat, mapGridPosition _boat]};
    };
}];
