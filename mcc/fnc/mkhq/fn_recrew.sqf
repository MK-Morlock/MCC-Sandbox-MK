// (where the vehicle is local) Swaps a vehicle's crew for another class, seat for seat (driver, turrets), in the same
// group - e.g. a Taru (a CSAT design) flown by the faction's own pilots. [vehicle, class]
params [["_v", objNull, [objNull]], ["_cls", "", [""]]];
if (isNull _v || {_cls == ""} || {!isClass (configFile >> "CfgVehicles" >> _cls)}) exitWith {};
{
	_x params ["_u", "_role", "", "_path"];
	if (!isNull _u && {!isPlayer _u} && {(typeOf _u) != _cls}) then {
		private _g = group _u;
		private _n = _g createUnit [_cls, [0, 0, 0], [], 0, "CAN_COLLIDE"];
		moveOut _u;
		deleteVehicle _u;
		switch (toLower _role) do {
			case "driver": {_n moveInDriver _v};
			case "commander": {_n moveInCommander _v};
			case "gunner": {_n moveInGunner _v};
			case "turret": {_n moveInTurret [_v, _path]};
			default {_n moveInAny _v};
		};
	};
} forEach (fullCrew _v);
