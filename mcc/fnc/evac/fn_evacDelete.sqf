//===================================================================MCC_fnc_evacDelete======================================================================================
// Delete the given vehicle or it's driver
// Example:[option, evac] remoteExec ["MCC_fnc_evacDelete", true, false];
// Params:
// 	option number, 0- delete driver, 1 - spawn driver, 2- delete vehicle, driver and gunners.
// 	evac: object, the evac vehicle
//==============================================================================================================================================================================
private _option = _this param [0, 0, [0]];
private _evac = _this param [1, objNull, [objNull]];
if (isNull _evac || {!isServer}) exitWith {};
private _crewClass = getText (configFile >> "CfgVehicles" >> typeOf _evac >> "crew");
switch (_option) do {
	case 0: {
		private _p = driver _evac;
		if (isNull _p || {isPlayer _p}) exitWith {};
		private _g = group _p;
		moveOut _p;
		deleteVehicle _p;
		if (count (units _g) == 0) then {deleteGroup _g};
	};
	case 1: {
		if (alive (driver _evac)) exitWith {};
		if (!isNull (driver _evac)) then {private _dp = driver _evac; moveOut _dp; deleteVehicle _dp};
		private _side = _evac getVariable ["MCC_evacSide", (getNumber (configFile >> "CfgVehicles" >> typeOf _evac >> "side")) call BIS_fnc_sideType];
		private _g = createGroup _side;
		private _p = _g createUnit [_crewClass, getPos _evac, [], 0, "NONE"];
		_p assignAsDriver _evac;
		_p moveInDriver _evac;
		_g setBehaviour "CARELESS";
		_g setCombatMode "YELLOW";
		_p setSkill 1;
	};
	case 2: {
		{if (isPlayer _x) then {moveOut _x} else {private _g = group _x; deleteVehicle _x; if (count (units _g) == 0) then {deleteGroup _g}}} forEach (crew _evac);
		deleteVehicle _evac;
	};
};
