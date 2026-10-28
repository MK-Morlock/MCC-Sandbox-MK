/*===================================  MCC_fnc_MWGetStartLocation ==================================================
		Find a start location based on MCC HQ if non present then BI respawn position if non present then players position

		<IN>
			0:		SIDE - side player
			1:		STRING - vehicle class to find empty position for it

	*/

	params [
		["_sidePlayer",sideLogic,[sideLogic]],
		["_vehicleClass","",[""]]
	];

	private _startPos = nil;
	private _fnc_startPos = {};
	private "_unit";

	_fnc_startPos = {
		params ["_sidePlayer","_vehicleClass","_startPos"];

		if (isNil "_startPos") exitWith {nil};

		private _found = [];
		{
			_found = if (_vehicleClass == "") then {_startPos findEmptyPosition [5,_x]} else {_startPos findEmptyPosition [5,_x,_vehicleClass]};
			if (count _found > 0) exitWith {};
		} forEach [50, 150, 300, 600];
		if (count _found == 0) then {["WARN", "MCC_fnc_MWGetStartLocation", "no free spot for %1 within 600 m of %2", [_vehicleClass, mapGridPosition _startPos]] call MCC_fnc_log};

		_found
	};

	//Find mission start position
	//First look for MCC HQ
	_startPos = missionNameSpace getvariable [(switch (_sidePlayer) do {case west: {"MCC_START_WEST"}; case east: {"MCC_START_EAST"}; case resistance: {"MCC_START_GUER"}; default {"MCC_START_NONE"}}),[]];

	if (!isNil "_startPos") then {
		if (count _startPos <=0) then {
			_startPos = nil;
		} else {
			_startPos = [_sidePlayer, _vehicleClass, _startPos] call _fnc_startPos;
			if (count _startPos == 0) then {_startPos = nil};
		};
	};

	//Second look for BI respawn pos
	if (isNil "_startPos") then {
		{
			private _rp = switch (typeName _x) do {
				case "STRING": {markerPos _x};
				case "ARRAY": {_x};
				case "OBJECT": {if (isNull _x) then {[0,0,0]} else {getPos _x}};
				default {[0,0,0]};
			};
			if !(_rp isEqualTo [0,0,0]) then {
				_startPos = [_sidePlayer, _vehicleClass, _rp] call _fnc_startPos;
			};
			if (!isNil "_startPos" && {count _startPos > 0}) exitWith {};
		} forEach (_sidePlayer call BIS_fnc_getRespawnPositions);
		if (!isNil "_startPos" && {count _startPos == 0}) then {_startPos = nil};
	};

	if (isNil "_startPos") then {
		{
			_unit = leader _x;
			if (isPlayer _unit && side _unit == _sidePlayer && isTouchingGround _unit && alive _unit) exitWith {
				_startPos = [_sidePlayer, _vehicleClass, (position _unit)] call _fnc_startPos;
				if (count _startPos >0) exitWith {};
			};
		} forEach allGroups;
	};

	if (!isNil "_startPos") then {_startPos} else {[]};