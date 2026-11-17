params [["_mkJobG", grpNull], ["_mkJobId", 0]];
if (!isServer || {isNull _mkJobG}) exitWith {};
private _mkOk = {!isNull _mkJobG && {(_mkJobG getVariable ["MCCMK_wpJobId", 0]) isEqualTo _mkJobId} && {((units _mkJobG) findIf {alive _x}) >= 0}};
private _mkCond = {!isNull _mkJobG && {(_mkJobG getVariable ["MCCMK_wpJobId", 0]) isEqualTo _mkJobId}};
private _mkSay = {
	params ["_m"];
	if (call _mkCond) then {[_m] remoteExec ["MCCMK_fnc_hint", _mkJobG getVariable ["MCCMK_wpOwner", 2]]};
	["INFO", "wpJob", "%1: %2", [groupId _mkJobG, _m]] call MCC_fnc_log;
};
while {call _mkOk} do {
	if ((_mkJobG getVariable ["MCCMK_wpQ", []]) isEqualTo []) exitWith {};
	waitUntil {
		sleep 1;
		!(call _mkOk) || {
			private _mkN = count (waypoints _mkJobG);
			private _mkC = currentWaypoint _mkJobG;
			(_mkC >= _mkN) || {_mkN == 1 && {_mkC == 0} && {((leader _mkJobG) distance2D (waypointPosition [_mkJobG, 0])) < 150}}
		}
	};
	if !(call _mkOk) exitWith {};
	private _mkQ = +(_mkJobG getVariable ["MCCMK_wpQ", []]);
	if (_mkQ isEqualTo []) exitWith {};
	private _mkO = _mkQ deleteAt 0;
	_mkO params ["_mkLoc", "_mkArr", "_mkShown", "_mkType", "_mkSpecial"];
	private _mkV = vehicle (leader _mkJobG);
	if (!_mkSpecial) then {
		private _mkBatch = [_mkO];
		while {(_mkQ isNotEqualTo []) && {!((_mkQ select 0) select 4)}} do {_mkBatch pushBack (_mkQ deleteAt 0)};
		_mkJobG setVariable ["MCCMK_wpQ", _mkQ];
		{[0, _x select 0, _x select 1, [_mkJobG], _x select 2, true] call MCC_fnc_manageWp} forEach _mkBatch;
		[_mkJobG] call MCCMK_fnc_wpPlan;
		sleep 2;
	} else {
		_mkJobG setVariable ["MCCMK_wpQ", _mkQ];
		_mkJobG setVariable ["MCCMK_wpNow", [_mkLoc, [_mkType] call MCCMK_fnc_wpLabel]];
		[_mkJobG] call MCCMK_fnc_wpPlan;
		private _mkFh = _mkArr param [8, 0];
		if (_mkFh > 0 && {_mkV isKindOf "Air"}) then {
			[_mkV, _mkFh] remoteExec ["flyInHeight", _mkV];
			_mkV setVariable ["MCCMK_flyH", _mkFh, true];
		};
		["INFO", "wpJob", "%1: %2 at %3 begins", [groupId _mkJobG, _mkType, mapGridPosition _mkLoc]] call MCC_fnc_log;
		switch (true) do {
			case (_mkType in ["Water landing (engine on)", "Water landing (engine off)"]): {
				if (_mkV isKindOf "Air") then {
					private _mkAfloat = [_mkV, _mkLoc, _mkType == "Water landing (engine on)", _mkCond] call MCCMK_fnc_heliWaterLandWp;
					if (_mkAfloat && {call _mkOk}) then {
						private _mkWid = _mkV getVariable ["MCCMK_waterId", 0];
						private _mkHad = !isNull ([_mkV] call MCCMK_fltAttached);
						_mkJobG setVariable ["MCCMK_wpGo", false];
						_mkJobG setVariable ["MCCMK_wpNow", nil];
						[_mkJobG] call MCCMK_fnc_wpPlan;
						private _mkWhy = "";
						waitUntil {
							sleep 1;
							if (!(call _mkOk) || {!alive _mkV}) then {_mkWhy = "stop"};
							if (_mkWhy == "" && {(_mkV getVariable ["MCCMK_waterId", 0]) != _mkWid}) then {_mkWhy = "lifted"};
							if (_mkWhy == "" && {_mkJobG getVariable ["MCCMK_wpGo", false]}) then {_mkWhy = "go"};
							if (_mkWhy == "") then {
								private _mkHas = !isNull ([_mkV] call MCCMK_fltAttached);
								if (!_mkHas) then {_mkHad = false};
								if (_mkHas && {!_mkHad} && {(_mkJobG getVariable ["MCCMK_wpQ", []]) isNotEqualTo []}) then {_mkWhy = "go"};
							};
							_mkWhy != ""
						};
						["INFO", "wpJob", "%1: afloat wait ended (%2), %3 queued", [groupId _mkJobG, _mkWhy, count (_mkJobG getVariable ["MCCMK_wpQ", []])]] call MCC_fnc_log;
						if (_mkWhy == "go") then {
							private _mkNext = (_mkJobG getVariable ["MCCMK_wpQ", []]) param [0, []];
							private _mkStay = _mkNext isNotEqualTo [] && {(_mkNext select 3) == "Boat drop (landed)"} && {(_mkV distance2D (_mkNext select 0)) < 50};
							if (!_mkStay) then {[_mkV, _mkV getVariable ["MCCMK_flyH", 50]] call MCCMK_fnc_heliWaterEnd};
						};
						if (_mkWhy == "lifted" && {call _mkOk}) then {_mkJobG setVariable ["MCCMK_wpQ", []]};
					};
				};
			};
			case (_mkType in ["Boat drop (landed)", "Boat drop (low hover)"]): {
				if (_mkV isKindOf "Air") then {
					[_mkV, _mkLoc, _mkType == "Boat drop (low hover)", _mkCond] call MCCMK_fnc_boatDrop;
					if ((call _mkOk) && {(_mkJobG getVariable ["MCCMK_wpQ", []]) isNotEqualTo []} && {!isNil {_mkV getVariable "MCCMK_waterState"}}) then {
						sleep 3;
						if (call _mkOk) then {[_mkV, _mkV getVariable ["MCCMK_flyH", 50]] call MCCMK_fnc_heliWaterEnd};
					};
				};
			};
			case (_mkType == "Boat load"): {
				if (_mkV isKindOf "Ship") then {
					private _mkPick = {
						params ["_c", "_r"];
						(nearestObjects [_c, ["Air"], _r]) select {alive _x && {[_x] call MCCMK_fnc_boatCarrier} && {(_x getVariable ["MCCMK_waterState", ""]) == "afloat"}}
					};
					private _mkCs = [_mkLoc, 300] call _mkPick;
					if (_mkCs isEqualTo []) then {_mkCs = [getPos _mkV, 600] call _mkPick};
					if (_mkCs isEqualTo []) then {
						["Boat load: no helicopter is on the water near that point"] call _mkSay;
					} else {
						[_mkV, _mkCs select 0, _mkCond, _mkJobG getVariable ["MCCMK_wpOwner", 2]] call MCCMK_fnc_aiBoatLoad;
					};
				};
			};
		};
		if (call _mkCond) then {
			_mkJobG setVariable ["MCCMK_wpNow", nil];
			[_mkJobG] call MCCMK_fnc_wpPlan;
		};
	};
};
if (isNull _mkJobG) exitWith {};
if ((_mkJobG getVariable ["MCCMK_wpJobId", 0]) isEqualTo _mkJobId) then {
	_mkJobG setVariable ["MCCMK_wpBusy", false];
	_mkJobG setVariable ["MCCMK_wpNow", nil];
	[_mkJobG] call MCCMK_fnc_wpPlan;
} else {
	if !(_mkJobG getVariable ["MCCMK_wpBusy", false]) then {
		private _mkV = vehicle (leader _mkJobG);
		if (_mkV isKindOf "Air" && {isNil {_mkV getVariable "MCCMK_waterState"}}) then {
			_mkV setVariable ["MCCMK_glideId", -1];
			[_mkV] remoteExec ["MCCMK_fnc_heliHold", _mkV];
			_mkV limitSpeed 1000;
		};
	};
};
