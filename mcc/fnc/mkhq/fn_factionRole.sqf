// A faction's own soldier for a job: "heli" (helicopter pilot), "plane" (jet pilot), "crew" (vehicle crewman) - from the
// faction's jobs table (MCCMK_fnc_pools: the framework's matching, with its fallback - crewman, engineer, rifleman; a
// faction with no soldiers takes a sibling faction's). Never the side's vanilla soldier: "" when there's none, and the
// vehicle keeps its own crew. [faction, side, job]
params [["_fac", "", [""]], ["_side", west, [west]], ["_job", "crew", [""]]];
if (_fac == "" || {!isClass (configFile >> "CfgFactionClasses" >> _fac)}) exitWith {""};
[_fac, switch (_job) do {case "heli": {"Pilot"}; case "plane": {"Jet Pilot"}; default {"Crew"}}] call MCCMK_fnc_poolJob
