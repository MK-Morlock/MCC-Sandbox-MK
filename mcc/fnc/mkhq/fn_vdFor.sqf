/*
	MCCMK_fnc_vdFor - the view distance for whoever is being watched (the MCC console's unit feed, the 3D View). With TAW
	View Distance loaded: TAW's own distance for what that unit is in - on foot, a ground vehicle or boat, or an aircraft -
	set as the game's view distance while he is watched (followed once a second, so a man who boards a helicopter gets the
	air distance), and TAW's own for the player put back after (TAW itself only changes it when the player gets in or out
	of something). Without TAW: the player's own view distance, untouched.
	["full", unit] -> metres; ["start", key, {target}] - key "feed" or "3d"; ["stop", key]
*/
params [["_mode", "full", [""]], ["_a", objNull], ["_code", {objNull}]];
private _taw = !isNil "tawvd_foot" && {!isNil "tawvd_car"} && {!isNil "tawvd_air"};
switch (_mode) do {
	case "full": {
		private _u = _a;
		if (!(_u isEqualType objNull) || {isNull _u} || {!_taw}) exitWith {missionNamespace getVariable ["MCCMK_vd0", viewDistance]};
		private _v = vehicle _u;
		switch (true) do {
			case (_v isKindOf "Air"): {tawvd_air};
			case (_v isKindOf "LandVehicle" || {_v isKindOf "Ship"}): {tawvd_car};
			default {tawvd_foot};
		}
	};
	case "start": {
		private _key = _a;
		if (isNil "MCCMK_vd0") then {MCCMK_vd0 = viewDistance};
		if (isNil "MCCMK_vdOwners") then {MCCMK_vdOwners = []};
		if (_key in MCCMK_vdOwners) exitWith {};
		MCCMK_vdOwners pushBack _key;
		[_key, _code] spawn {
			params ["_key", "_code"];
			private _last = -1;
			while {_key in (missionNamespace getVariable ["MCCMK_vdOwners", []])} do {
				private _u = call _code;
				if (_u isEqualType objNull && {!isNull _u}) then {
					private _f = ["full", _u] call MCCMK_fnc_vdFor;
					if (_f != _last) then {
						_last = _f;
						if (!isNil "tawvd_foot") then {setViewDistance _f};
						if (_key == "feed") then {["apply"] call MCCMK_fnc_feedDist};
					};
				};
				uiSleep 1;
			};
		};
	};
	case "stop": {
		private _key = _a;
		if (isNil "MCCMK_vdOwners") exitWith {};
		MCCMK_vdOwners = MCCMK_vdOwners - [_key];
		if (MCCMK_vdOwners isEqualTo []) then {
			if (_taw && {!isNil "TAWVD_fnc_updateViewDistance"}) then {[] call TAWVD_fnc_updateViewDistance} else {
				if (!isNil "MCCMK_vd0" && {_taw}) then {setViewDistance MCCMK_vd0};
			};
			MCCMK_vd0 = nil;
		};
	};
};
