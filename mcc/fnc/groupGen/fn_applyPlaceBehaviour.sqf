params [["_grp", grpNull, [grpNull]], ["_beh", "hold", [""]], ["_cmd", false, [false]]];
if (isNull _grp) exitWith {};
if (_cmd) then {_grp setVariable ["MCC_canbecontrolled", true, true]};
switch (toLower _beh) do {
	case "hold": {
		private _units = units _grp;
		{_x disableAI "PATH"} forEach _units;
		{
			private _v = vehicle _x;
			if (!(_v isEqualTo _x) && {(driver _v) isEqualTo _x}) then {
				_x disableAI "MOVE";
				if (_v isKindOf "Air") then {_v engineOn false};
			};
		} forEach _units;
		[_grp, _units] spawn {
			params ["_grp", "_units"];
			private _wp = count waypoints _grp;
			private _cur = currentWaypoint _grp;
			waitUntil {
				sleep 2;
				isNull _grp || {({alive _x} count _units) == 0} || {(count waypoints _grp) != _wp} || {(currentWaypoint _grp) != _cur}
			};
			{_x enableAI "PATH"; _x enableAI "MOVE"} forEach _units;
		};
	};
	case "bisd": {[_grp, getPos (leader _grp)] call BIS_fnc_taskDefend};
	case "bisp": {[_grp, getPos (leader _grp), 100] call BIS_fnc_taskPatrol};
	default {};
};
