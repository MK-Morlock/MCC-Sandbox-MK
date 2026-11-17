/*
	MCCMK_fnc_airIcons - (every player, postInit) MCC's transport and drop aircraft on the main map as FRIENDLY: their crews
	are captives (so the enemy doesn't shoot at them), which Arma counts as civilian - purple, or not drawn at all where the
	difficulty shows only friendly units; and Arma never draws the vehicle a player is riding in, only his own marker. So
	every aircraft working for the player's side - Pickup, fast-rope, paradrop, pod drops, supply drops (tagged
	"MCC_dropFor"), and the side's Evac helicopters - gets its own map icon drawn over it in the side's colour, every frame
	the map is open, but only where Arma doesn't draw one itself: a captive
	(civilian-counted) crew, an empty one, or the one the player is riding in - never twice. On the GPS minimap too (over
	Arma's own purple icon there).
*/
if (!hasInterface) exitWith {};
[] spawn {
	waitUntil {sleep 1; !isNull player};
	MCCMK_airIconList = [];
	MCCMK_airIconCache = createHashMap;
	// the list, refreshed every 2 s (the drawing only reads it)
	[] spawn {
		while {true} do {
			private _sd = side group player;
			private _evac = missionNamespace getVariable [format ["MCC_evacVehicles_%1", _sd], []];
			// only where Arma doesn't draw it itself: a captive crew (counted as civilian), or the one the player is riding in
			// (Arma shows only his own marker then) - a normal NATO crew (an Evac) already has Arma's own icon
			MCCMK_airIconList = vehicles select {
				(_x isKindOf "Air") && {alive _x} && {!(_x isKindOf "ParachuteBase")} && {
					(_x in _evac) || {private _g = group (driver _x); !isNull _g && {(_g getVariable ["MCC_dropFor", sideUnknown]) isEqualTo _sd}}
				} && {
					private _d = driver _x;
					(vehicle player isEqualTo _x) || {isNull _d} || {captive _d} || {(side group _d) isEqualTo civilian}
				}
			};
			// the GPS minimap (rebuilt whenever its panel is toggled): the same icons drawn on it too
			private _mini = (uiNamespace getVariable ["RscCustomInfoMiniMap", displayNull]) displayCtrl 101;
			if (!isNull _mini && {!(_mini getVariable ["MCCMK_airIconsEH", false])}) then {
				_mini setVariable ["MCCMK_airIconsEH", true];
				_mini ctrlAddEventHandler ["Draw", {
					params ["_m"];
					if (MCCMK_airIconList isEqualTo []) exitWith {};
					private _col = (side group player) call BIS_fnc_sideColor;
					{
						if (alive _x) then {_m drawIcon [[typeOf _x] call MCCMK_airIconOf, _col, getPosASLVisual _x, 24, 24, getDirVisual _x, "", 0]};
					} forEach MCCMK_airIconList;
				}];
			};
			sleep 2;
		};
	};
	MCCMK_airIconOf = {
		params ["_t"];
		private _c = MCCMK_airIconCache getOrDefault [_t, ""];
		if (_c != "") exitWith {_c};
		private _raw = getText (configFile >> "CfgVehicles" >> _t >> "icon");
		private _map = getText (configFile >> "CfgVehicleIcons" >> _raw);
		_c = switch (true) do {
			case (_map != ""): {_map};
			case (_raw != "" && {((toLower _raw) find ".paa") > -1}): {_raw};
			default {["\A3\ui_f\data\Map\VehicleIcons\iconPlane_ca.paa", "\A3\ui_f\data\Map\VehicleIcons\iconHelicopter_ca.paa"] select (_t isKindOf "Helicopter")};
		};
		MCCMK_airIconCache set [_t, _c];
		_c
	};
	private _hook = {
		private _c = (findDisplay 12) displayCtrl 51;
		if (isNull _c || {_c getVariable ["MCCMK_airIconsEH", false]}) exitWith {};
		_c setVariable ["MCCMK_airIconsEH", true];
		_c ctrlAddEventHandler ["Draw", {
			params ["_m"];
			if (MCCMK_airIconList isEqualTo []) exitWith {};
			private _col = (side group player) call BIS_fnc_sideColor;
			{
				if (alive _x) then {_m drawIcon [[typeOf _x] call MCCMK_airIconOf, _col, getPosASLVisual _x, 24, 24, getDirVisual _x, "", 0]};
			} forEach MCCMK_airIconList;
		}];
	};
	call _hook;
	addMissionEventHandler ["Map", {params ["_open"]; if (_open) then {
		private _c = (findDisplay 12) displayCtrl 51;
		if (!isNull _c && {!(_c getVariable ["MCCMK_airIconsEH", false])}) then {
			_c setVariable ["MCCMK_airIconsEH", true];
			_c ctrlAddEventHandler ["Draw", {
				params ["_m"];
				if (MCCMK_airIconList isEqualTo []) exitWith {};
				private _col = (side group player) call BIS_fnc_sideColor;
				{
					if (alive _x) then {_m drawIcon [[typeOf _x] call MCCMK_airIconOf, _col, getPosASLVisual _x, 24, 24, getDirVisual _x, "", 0]};
				} forEach MCCMK_airIconList;
			}];
		};
	}}];
};
