params [["_job", "Rifleman", [""]], ["_what", "chain", [""]]];
private _info = [
	// job, the related jobs to try next, jobs table, name
	["Officer", ["SquadLeader", "TeamLeader"], "Team Leader", "Officer"],
	["SquadLeader", ["TeamLeader", "Officer"], "Team Leader", "Squad Leader"],
	["TeamLeader", ["SquadLeader", "Officer"], "Team Leader", "Team Leader"],
	["Rifleman", [], "Rifleman", "Rifleman"],
	["RiflemanLight", ["Rifleman"], "Rifleman", "Rifleman (Light)"],
	["RiflemanAT", ["ATSpecialist"], "AT", "Rifleman (AT)"],
	["Grenadier", [], "Grenadier", "Grenadier"],
	["Autorifleman", ["MachineGunner"], "Autorifleman", "Autorifleman"],
	["MachineGunner", ["Autorifleman"], "Autorifleman", "Machine Gunner"],
	["AsstAutorifleman", ["AsstMachineGunner", "AmmoBearer"], "Rifleman", "Asst. Autorifleman"],
	["AsstMachineGunner", ["AsstAutorifleman", "AmmoBearer"], "Rifleman", "Asst. Machine Gunner"],
	["AsstAT", ["AsstAA", "AmmoBearer"], "Rifleman", "Asst. AT"],
	["AsstAA", ["AsstAT", "AmmoBearer"], "Rifleman", "Asst. AA"],
	["AmmoBearer", ["AsstAutorifleman", "AsstMachineGunner", "AsstAT"], "Rifleman", "Ammo Bearer"],
	["Marksman", ["Sniper"], "Sniper", "Marksman"],
	["Sniper", ["Marksman"], "Sniper", "Sniper"],
	["Spotter", ["RadioOperator"], "Spotter", "Spotter / Observer"],
	["RadioOperator", ["Spotter"], "Rifleman", "Radio Operator"],
	["ATSpecialist", ["RiflemanAT"], "AT", "AT Specialist"],
	["AASpecialist", [], "AA", "AA Specialist"],
	["Medic", [], "Medic", "Medic"],
	["Engineer", ["RepairSpecialist", "ExplosiveSpecialist"], "Engineer", "Engineer"],
	["RepairSpecialist", ["Engineer"], "Engineer", "Repair Specialist"],
	["ExplosiveSpecialist", ["Engineer"], "Explosive Specialist", "Explosive Specialist"],
	["UAVOperator", [], "UAV Operator", "UAV Operator"],
	["Breacher", [], "Rifleman", "Breacher"],
	["HeliPilot", ["Pilot", "HeliCrew"], "Pilot", "Helicopter Pilot"],
	["Pilot", ["HeliPilot"], "Pilot", "Pilot"],
	["HeliCrew", ["HeliPilot", "Crewman"], "Pilot", "Helicopter Crew"],
	["Crewman", ["Driver"], "Crew", "Crewman"],
	["Driver", ["Crewman"], "Crew", "Driver"],
	["Diver", [], "Rifleman", "Diver"],
	["Unarmed", [], "Rifleman", "Unarmed"]
];
private _row = _info param [_info findIf {(_x select 0) == _job}, ["Rifleman", [], "Rifleman", "Rifleman"]];
switch (_what) do {
	case "table": {_row select 2};
	case "name": {_row select 3};
	default {([_job] + (_row select 1) + ["Rifleman"]) arrayIntersect ([_job] + (_row select 1) + ["Rifleman"])};
}
