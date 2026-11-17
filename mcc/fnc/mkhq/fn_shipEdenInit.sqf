if (!is3DEN) exitWith {};
{if (isNil {missionNamespace getVariable _x}) then {missionNamespace setVariable [_x, uiNamespace getVariable [_x, {}]]}} forEach ["MCCMK_fnc_shipCfg", "MCCMK_fnc_shipWeapons", "MCCMK_fnc_shipTraverse", "MCCMK_fnc_shipShape", "MCCMK_fnc_shipDraw", "MCCMK_fnc_shipDraw3D"];
private _token = (uiNamespace getVariable ["MCCMK_shipPrevToken", 0]) + 1;
uiNamespace setVariable ["MCCMK_shipPrevToken", _token];
missionNamespace setVariable ["MCCMK_shipPrevList", []];
private _old3 = missionNamespace getVariable ["MCCMK_shipDrawEH", -1];
if (_old3 >= 0) then {removeMissionEventHandler ["Draw3D", _old3]};
missionNamespace setVariable ["MCCMK_shipDrawEH", addMissionEventHandler ["Draw3D", {
	if (!is3DEN) exitWith {};
	{
		_x params ["_m", "_dir", "_t"];
		if (!isNull _m && {(_m distance2D (getPos get3DENCamera)) < 3000}) then {[getPosWorld _m, _dir, _t, [0.4, 1, 0.4, 1]] call MCCMK_fnc_shipDraw3D};
	} forEach (missionNamespace getVariable ["MCCMK_shipPrevList", []]);
}]];
[_token] spawn {
	params ["_token"];
	private _t0 = diag_tickTime;
	waitUntil {uiSleep 0.3; !isNull ((findDisplay 313) displayCtrl 51) || {(diag_tickTime - _t0) > 20} || {!is3DEN}};
	private _map = (findDisplay 313) displayCtrl 51;
	if (isNull _map) exitWith {};
	private _old = uiNamespace getVariable ["MCCMK_shipMapEH", -1];
	if (_old >= 0) then {_map ctrlRemoveEventHandler ["Draw", _old]};
	uiNamespace setVariable ["MCCMK_shipMapEH", _map ctrlAddEventHandler ["Draw", {
		params ["_c"];
		{
			_x params ["_m", "_dir", "_t"];
			if (!isNull _m) then {[_c, getPosWorld _m, _dir, _t, [0.4, 1, 0.4, 1]] call MCCMK_fnc_shipDraw};
		} forEach (missionNamespace getVariable ["MCCMK_shipPrevList", []]);
	}]];
};
private _build = {
	params ["_p", "_dir", "_t"];
	private _objs = [];
	private _sea = [_p select 0, _p select 1, 0];
	private _mk = {
		params ["_cls"];
		if !(isClass (configFile >> "CfgVehicles" >> _cls)) exitWith {objNull};
		private _o = createSimpleObject [_cls, _sea, true];
		if (!isNull _o) then {_objs pushBack _o};
		_o
	};
	switch (_t) do {
		case 2: {
			private _o = ["Submarine_01_F"] call _mk;
			if (!isNull _o) then {_o setDir _dir; _o setPosASL _sea};
		};
		case 3: {
			private _base = ["CUP_LHD_BASE"] call _mk;
			if (!isNull _base) then {
				_base setPosASLW _sea;
				_base setDir (_dir - 180);
				private _bp = getPosASL _base;
				private _n = 0;
				{
					if (isClass (configFile >> "CfgVehicles" >> _x)) then {
						private _o = _x createVehicleLocal [0, 0, 0];
						if (!isNull _o) then {
							_o enableSimulation false;
							_o allowDamage false;
							_o setDir (_dir - 180);
							_o setPos _bp;
							_objs pushBack _o;
							_n = _n + 1;
						};
					};
				} forEach getArray (configFile >> "CfgVehicles" >> "CUP_LHD_BASE" >> "shipParts");
			};
		};
		default {
			private _bc = ["Land_Destroyer_01_base_F", "Land_Carrier_01_base_F"] select (_t == 1);
			private _base = [_bc] call _mk;
			if (!isNull _base) then {
				_base setDir _dir;
				_base setPosASL _sea;
				private _placed = 0;
				{
					_x params ["_pc", "_mem"];
					private _o = [_pc] call _mk;
					if (!isNull _o) then {
						private _sp = _base selectionPosition _mem;
						if !(_sp isEqualTo [0, 0, 0]) then {_placed = _placed + 1};
						_o setPosWorld (_base modelToWorldWorld _sp);
						_o setDir _dir;
					};
				} forEach getArray (configFile >> "CfgVehicles" >> _bc >> "multiStructureParts");
			};
		};
	};
	_objs
};
private _data = createHashMap;
while {is3DEN && {(uiNamespace getVariable ["MCCMK_shipPrevToken", 0]) == _token}} do {
	private _list = [];
	private _seen = [];
	{
		if (typeOf _x == "MCC_Module_LHDSpawnCurator") then {
			private _id = get3DENEntityID _x;
			_seen pushBack _id;
			private _v = (_x get3DENAttribute "MCC_Module_LHDSpawnCurator_lhdType") param [0, 0];
			private _t = if (_v isEqualType "") then {parseNumber _v} else {_v};
			private _p = getPosASL _x;
			private _dir = getDir _x;
			_list pushBack [_x, _dir, _t];
			private _sig = [[round (_p select 0), round (_p select 1)], round _dir, _t];
			private _old = _data getOrDefault [_id, []];
			if (count _old == 0 || {!((_old select 0) isEqualTo _sig)}) then {
				if (count _old > 0) then {{deleteVehicle _x} forEach (_old select 1)};
				_data set [_id, [_sig, [_p, _dir, _t] call _build]];
			};
		};
	} forEach ((all3DENEntities) select 3);
	{
		if !(_x in _seen) then {{deleteVehicle _x} forEach ((_data get _x) select 1); _data deleteAt _x};
	} forEach (keys _data);
	missionNamespace setVariable ["MCCMK_shipPrevList", _list];
	uiSleep 0.2;
};
{{deleteVehicle _x} forEach (_y select 1)} forEach _data;
missionNamespace setVariable ["MCCMK_shipPrevList", []];
