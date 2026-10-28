params [["_recs", [], [[]]], ["_kind", "single", [""]]];
if (!isServer) exitWith {};
private _made = [];
private _men = grpNull;
private _crewAll = [];
private _crewGrp = grpNull;
{
	_x params [["_cls", "", [""]], ["_posASL", [0, 0, 0], [[]]], ["_vd", [0, 1, 0], [[]]], ["_vu", [0, 0, 1], [[]]], ["_isMan", false, [false]], ["_sideStr", "CIV", [""]], ["_hasCrew", false, [false]]];
	if (_cls != "" && {isClass (configFile >> "CfgVehicles" >> _cls)}) then {
		private _o = objNull;
		if (_isMan) then {
			if (isNull _men) then {_men = createGroup ([west, east, resistance, civilian] select ((["WEST", "EAST", "GUER", "CIV"] find _sideStr) max 0))};
			_o = _men createUnit [_cls, ASLToAGL _posASL, [], 0, "CAN_COLLIDE"];
		} else {
			_o = createVehicle [_cls, ASLToAGL _posASL, [], 0, "CAN_COLLIDE"];
		};
		if (!isNull _o) then {
			_o setPosASL _posASL;
			_o setVectorDirAndUp [_vd, _vu];
			if (!_isMan && {_hasCrew}) then {
				createVehicleCrew _o;
				_crewAll append (crew _o);
				_crewGrp = group (effectiveCommander _o);
			};
			{_x addCuratorEditableObjects [[_o], true]} forEach allCurators;
			_made pushBack _o;
		};
	};
} forEach _recs;
if (!isNull _men) then {_men deleteGroupWhenEmpty true};
if (count _made == 0) exitWith {};
switch (_kind) do {
	case "veh": {MCC_lastSpawn pushBack [_made select 0, _crewAll, _crewGrp]};
	case "comp": {MCC_lastSpawn pushBack [_made select 0, _made select [1, (count _made) - 1]]};
	default {{MCC_lastSpawn pushBack _x} forEach _made};
};
publicVariable "MCC_lastSpawn";
