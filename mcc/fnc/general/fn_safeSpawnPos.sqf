params [["_pos", [], [[]]], ["_class", "", [""]]];
if (count _pos < 2) exitWith {_pos};
private _p = [_pos select 0, _pos select 1, 0];
if (isNil "MCC_MWRecentSpawns") then {MCC_MWRecentSpawns = []};
MCC_MWRecentSpawns = MCC_MWRecentSpawns select {(time - (_x select 1)) < 300};
private _isVeh = (_class != "") && {isClass (configFile >> "CfgVehicles" >> _class)} && {!(_class isKindOf "CAManBase")};
private _res = [];
if (_isVeh) then {
	_res = [_p, _class, 56] call MCC_fnc_clearVehicleSpot;
	if (count _res == 0) then {_res = [_p, _class] call MCC_fnc_roadsideSpot};
	if (count _res > 0 && {!(_class isKindOf "StaticWeapon")} && {!([_res, _class] call MCC_fnc_vehicleCanDriveOut)}) then {
		private _road = [_res, _class] call MCC_fnc_roadsideSpot;
		if (count _road > 0) then {_res = _road};
	};
} else {
	{
		private _d = _x;
		private _angles = if (_d == 0) then {[0]} else {[0, 45, 90, 135, 180, 225, 270, 315]};
		{
			private _q = if (_d == 0) then {_p} else {_p getPos [_d, _x]};
			if (!(surfaceIsWater _q) && {!([_q] call MCC_fnc_posOnBuilding)} && {(MCC_MWRecentSpawns findIf {((_x select 0) distance2D _q) < 20}) < 0} && {count ([_q, 0, 1] call MCC_fnc_landSpot) > 0}) exitWith {_res = _q};
		} forEach _angles;
		if (count _res > 0) exitWith {};
	} forEach [0, 10, 20, 30, 45, 60];
};
if (count _res == 0) then {_res = _p};
MCC_MWRecentSpawns pushBack [_res, time];
_res
