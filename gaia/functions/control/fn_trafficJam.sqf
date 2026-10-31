if (!isServer) exitWith {};
while {true} do {
	sleep 10;
	{
		private _g = _x;
		private _l = leader _g;
		private _veh = vehicle _l;
		if (_veh != _l && {alive _veh} && {_veh isKindOf "LandVehicle"} && {!isPlayer (driver _veh)} && {count (_g getVariable ["GAIA_zone_intend", []]) > 0} && {(count (waypoints _g)) > (currentWaypoint _g)} && {behaviour _l != "COMBAT"}) then {
			private _hist = (_g getVariable ["MCC_jamHist", []]) + [[time, getPosATL _veh]];
			_hist = _hist select {(time - (_x select 0)) <= 35};
			_g setVariable ["MCC_jamHist", _hist];
			private _old = _hist select 0;
			if ((time - (_old select 0)) >= 30 && {((_old select 1) distance2D (getPosATL _veh)) < 3}) then {
				private _wpPos = waypointPosition [_g, currentWaypoint _g];
				private _blockers = (_veh nearEntities [["LandVehicle"], 15]) select {
					_x != _veh && {private _rd = _veh getRelDir _x; _rd < 60 || {_rd > 300}}
				};
				if ((_veh distance2D _wpPos) > 40 && {count _blockers > 0}) then {
					if (missionNamespace getVariable ["MCC_debug", false]) then {
						["DEBUG", "GAIA", "%1 (%2) jammed behind %3 at %4 - new destination", [groupId _g, typeOf _veh, typeOf (_blockers select 0), mapGridPosition _veh]] call MCC_fnc_log;
					};
					[_g] call GAIA_fnc_removeWaypoints;
					_g setVariable ["MCC_jamHist", []];
				};
			};
		} else {
			if (count (_g getVariable ["MCC_jamHist", []]) > 0) then {_g setVariable ["MCC_jamHist", []]};
		};
	} forEach allGroups;
};
