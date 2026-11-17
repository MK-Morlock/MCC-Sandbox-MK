// (where the vehicle's crew is local) Every crew member not from the chosen faction is replaced, seat for seat in the
// same group, by the faction's own soldier for the job: helicopter pilot, jet pilot, or vehicle crewman (rifleman /
// any soldier as fallbacks; the side's vanilla one last). Drones and UGVs keep their AI crew; players are never
// touched. [vehicle, faction]
params [["_v", objNull, [objNull]], ["_fac", "", [""]]];
if (isNull _v || {_fac == ""} || {!isClass (configFile >> "CfgFactionClasses" >> _fac)}) exitWith {};
if (unitIsUAV _v || {getNumber (configOf _v >> "isUav") == 1}) exitWith {};
private _side = [east, west, resistance, civilian] param [getNumber (configFile >> "CfgFactionClasses" >> _fac >> "side"), west];
private _job = switch (true) do {case (_v isKindOf "Helicopter"): {"heli"}; case (_v isKindOf "Plane"): {"plane"}; default {"crew"}};
private _cls = [_fac, _side, _job] call MCCMK_fnc_factionRole;
if (!isClass (configFile >> "CfgVehicles" >> _cls)) exitWith {};
{
	_x params ["_u", "_role", "", "_path"];
	if (!isNull _u && {alive _u} && {!isPlayer _u} && {(faction _u) != _fac} && {local _u} && {(toLower _role) != "cargo"}) then {
		private _g = group _u;
		private _skill = skill _u;
		private _n = _g createUnit [_cls, [0, 0, 0], [], 0, "CAN_COLLIDE"]; [_n] call MCCMK_fnc_genTag;
		_n setSkill _skill;
		private _lead = (leader _g) isEqualTo _u;
		moveOut _u;
		deleteVehicle _u;
		switch (toLower _role) do {
			case "driver": {_n moveInDriver _v};
			case "commander": {_n moveInCommander _v};
			case "gunner": {_n moveInGunner _v};
			case "turret": {_n moveInTurret [_v, _path]};
			default {_n moveInAny _v};
		};
		if (_lead) then {_g selectLeader _n};
		{_x addCuratorEditableObjects [[_n], false]} forEach allCurators;
	};
} forEach (fullCrew _v);
