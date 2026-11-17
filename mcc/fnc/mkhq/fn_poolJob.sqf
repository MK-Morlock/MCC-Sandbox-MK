// MCCMK_fnc_poolJob - a faction's soldier for a job, from its jobs table (MCCMK_fnc_pools): Team Leader, Rifleman,
// Grenadier, Medic, AT, AA, Sniper, Autorifleman, Engineer, Explosive Specialist, UAV Operator, Officer, Crew, Pilot,
// Jet Pilot. Never a vanilla soldier. [faction, job] -> class ("" = none)
params [["_fac", "", [""]], ["_job", "Rifleman", [""]]];
(([_fac] call MCCMK_fnc_pools) getOrDefault ["jobs", createHashMap]) getOrDefault [_job, ""]
