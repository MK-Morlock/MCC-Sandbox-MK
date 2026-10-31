params [["_group", grpNull, [grpNull]]];
if (isNull _group) exitWith {};
private _job = [];
private _hideUntil = 0;
private _relocateAt = time + 300 + random 300;
private _fnc_service = {
	params ["_kind", "_target", "_truck", "_side"];
	switch (_kind) do {
		case "repair": {if (local _target) then {_target setDamage 0}};
		case "fuel": {if (local _target) then {_target setFuel 1}};
		case "ammo": {if (local _target) then {_target setVehicleAmmo 1}};
		case "medical": {
			{
				if (local _x) then {
					if (!isNil "ace_medical_treatment_fnc_fullHealLocal") then {[_x] call ace_medical_treatment_fnc_fullHealLocal} else {_x setDamage 0};
				};
			} forEach ((_truck nearEntities [["CAManBase"], 40]) select {alive _x && {!isPlayer _x} && {side group _x == _side} && {!isPlayer leader group _x}});
		};
	};
};
while {!isNull _group && {count units _group > 0}} do {
	sleep 30;
	if (isNull _group || {count units _group == 0}) exitWith {};
	if (_group getVariable ["GAIA_CACHED_STAGE_1", false]) then {continue};
	private _lead = leader _group;
	if (!alive _lead || {isPlayer _lead}) then {continue};
	private _truck = vehicle _lead;
	if (_truck == _lead || {!alive _truck} || {!canMove _truck}) then {continue};
	private _side = side _group;

	if (count (_lead targets [true, 300]) > 0) then {
		_job = [];
		_hideUntil = time + 120;
		if ((_group getVariable ["GAIA_Order", ""]) != "DoHide") then {[_group] call GAIA_fnc_doHide};
		continue;
	};
	if ((_group getVariable ["GAIA_Order", ""]) == "DoHide") then {
		if (time > _hideUntil) then {[_group] call GAIA_fnc_removeWaypoints};
		continue;
	};

	if !(_job isEqualTo []) then {
		_job params ["_kind", "_target", "_jobEnd"];
		if (time > _jobEnd || {isNull _target} || {!alive _target}) then {
			_job = [];
		} else {
			if ((_truck distance2D _target) < 30 && {speed _truck < 3}) then {
				[_kind, _target, _truck, _side] call _fnc_service;
				_job = [];
			};
		};
		continue;
	};

	private _wpType = waypointType [_group, currentWaypoint _group];
	if (_wpType != "SUPPORT" || {speed _truck > 2}) then {continue};

	private _cfg = configOf _truck;
	private _kinds = [];
	if (getNumber (_cfg >> "transportRepair") > 0) then {_kinds pushBack "repair"};
	if (getNumber (_cfg >> "transportFuel") > 0) then {_kinds pushBack "fuel"};
	if (getNumber (_cfg >> "transportAmmo") > 0) then {_kinds pushBack "ammo"};
	if (getNumber (_cfg >> "attendant") > 0) then {_kinds pushBack "medical"};

	private _cands = [];
	if (count (_kinds - ["medical"]) > 0) then {
		{
			private _v = _x;
			if (alive _v && {_v != _truck} && {local _v} && {side _v == _side} && {count crew _v > 0} && {((crew _v) findIf {isPlayer _x}) < 0}) then {
				if ("repair" in _kinds && {damage _v > 0.3}) then {_cands pushBack ["repair", _v]};
				if ("fuel" in _kinds && {fuel _v < 0.3}) then {_cands pushBack ["fuel", _v]};
				if ("ammo" in _kinds && {!someAmmo _v} && {count (magazinesAllTurrets _v) > 0}) then {_cands pushBack ["ammo", _v]};
			};
		} forEach (_truck nearEntities [["LandVehicle"], 800]);
	};
	if ("medical" in _kinds) then {
		{
			_cands pushBack ["medical", _x];
		} forEach ((_truck nearEntities [["CAManBase"], 800]) select {alive _x && {local _x} && {!isPlayer _x} && {vehicle _x == _x} && {side group _x == _side} && {!isPlayer leader group _x} && {damage _x > 0.3}});
	};
	_cands = _cands select {count (_lead targets [true, 300, [], 0, getPosATL (_x select 1)]) == 0};

	if (count _cands > 0) then {
		_cands = _cands apply {[_truck distance2D (_x select 1), _x]};
		_cands sort true;
		private _pick = (_cands select 0) select 1;
		[_group] call GAIA_fnc_removeWaypoints;
		private _wp = _group addWaypoint [getPosATL (_pick select 1), 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointCompletionRadius 25;
		_wp setWaypointTimeout [60, 90, 120];
		_group setVariable ["GAIA_Order", "DoSupport", false];
		_group setVariable ["GAIA_OrderTime", time, false];
		_group setVariable ["GAIA_OrderPosition", getPosATL _lead, false];
		_job = [_pick select 0, _pick select 1, time + 300];
		_relocateAt = time + 300 + random 300;
		if (missionNamespace getVariable ["MCC_debug", false]) then {
			["DEBUG", "GAIA_fnc_supportLoop", "%1 (%2) service run: %3 at %4", [groupId _group, typeOf _truck, _pick select 0, mapGridPosition (_pick select 1)]] call MCC_fnc_log;
		};
		continue;
	};

	if (time > _relocateAt) then {
		_relocateAt = time + 300 + random 300;
		[_group] call GAIA_fnc_removeWaypoints;
	};
};
