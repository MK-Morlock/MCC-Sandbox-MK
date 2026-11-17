/*
	MCCMK_fnc_salvageInit  (every computer, postInit)
	Wreck salvage: every destroyed vehicle gets a "Salvage wreck" hold action (MCCMK_fnc_salvageAction) for every player,
	players joining later included; the sides that ever crewed a vehicle are recorded (MCCMK_usedBy), so a vehicle your
	side used never pays when salvaged. Wrecks inside an RTS base can be cleared automatically (MCCMK_salvageAutoBase).
*/
// the sides that crewed each vehicle - recorded where the unit getting in is local
{
	[_x, "GetIn", {
		params ["_v", "", "_u"];
		if (!local _u) exitWith {};
		private _s = side group _u;
		private _used = _v getVariable ["MCCMK_usedBy", []];
		if !(_s in _used) then {_v setVariable ["MCCMK_usedBy", _used + [_s], true]};
	}] call CBA_fnc_addClassEventHandler;
} forEach ["LandVehicle", "Air", "Ship"];
//(MK) a drone hit and unable to move (or 90% damaged): the server watches it come down and lets it be salvaged
// (MCCMK_fnc_droneDowned) - only when a drone is actually hit, no loop
{
	[_x, "Dammaged", {
		params ["_v"];
		if (!(unitIsUAV _v) || {_v getVariable ["MCCMK_droneChk", false]}) exitWith {};
		if ((canMove _v) && {(damage _v) < 0.9} && {((crew _v) findIf {alive _x}) >= 0}) exitWith {};	// still flying, crewed
		_v setVariable ["MCCMK_droneChk", true];
		[_v] remoteExec ["MCCMK_fnc_droneDowned", 2];
	}] call CBA_fnc_addClassEventHandler;
} forEach ["Air", "LandVehicle"];
//(MK) drones: "Salvage wreck" on the PLAYER, for the drone he's looking at (destroyed, or downed) - an action on the
// drone itself only shows to someone connected to it. Same rules: a toolkit or a repair source near; the server pays.
if (hasInterface) then {
	MCCMK_salvageDroneOk = {
		params ["_o", "_u"];
		!isNull _o && {getNumber (configOf _o >> "isUav") == 1} && {!alive _o || {_o getVariable ["MCCMK_downedDrone", false]}}
			&& {!(_o getVariable ["MCCMK_salvaged", false])} && {(_u distance _o) < 8} && {(vehicle _u) isEqualTo _u}
	};
	if ((call MCCMK_fnc_aceMenus)) then {
		private _act = ["MCCMK_salvageDrone", "Salvage wreck", "\a3\ui_f\data\IGUI\Cfg\Actions\repair_ca.paa", {
			params ["_target", "_player"];
			[5, [_target, _player], {(_this select 0) params ["_t", "_p"]; [_t, _p] remoteExec ["MCCMK_fnc_salvageDone", 2]}, {}, "Salvaging the wreck..."] call ace_common_fnc_progressBar;
		}, {[_target, _player] call MCCMK_salvageDroneOk && {call MCCMK_fnc_salvageCan}}] call ace_interact_menu_fnc_createAction;
		{[_x, 0, ["ACE_MainActions"], _act, true] call ace_interact_menu_fnc_addActionToClass} forEach ["Air", "LandVehicle"];
	};
	if (call MCCMK_fnc_scrollMenus) then {	//(MK) the scroll menu too with "ACE menu and scroll menu"
		[] spawn {
			waitUntil {sleep 1; !isNull player};
			private _add = {
				private _icon = "\a3\ui_f\data\IGUI\Cfg\Actions\repair_ca.paa";
				[
					player, "Salvage wreck", _icon, _icon,
					"[cursorObject, _this] call MCCMK_salvageDroneOk && {call MCCMK_fnc_salvageCan}",
					"!isNull (missionNamespace getVariable ['MCCMK_salvageDroneTgt', objNull]) && {(_this distance MCCMK_salvageDroneTgt) < 9}",
					{MCCMK_salvageDroneTgt = cursorObject}, {},
					{params ["", "_caller"]; if (!isNull MCCMK_salvageDroneTgt) then {[MCCMK_salvageDroneTgt, _caller] remoteExec ["MCCMK_fnc_salvageDone", 2]}},
					{},
					[], 5, 10, false, false
				] call BIS_fnc_holdActionAdd;
			};
			call _add;
			player addEventHandler ["Respawn", _add];
		};
	};
};
if (!isServer) exitWith {};
MCCMK_salvageOffer = {
	params ["_v"];
	if (isNull _v || {_v isKindOf "Man"} || {!(_v isKindOf "LandVehicle" || {_v isKindOf "Air"} || {_v isKindOf "Ship"} || {_v isKindOf "Pod_Heli_Transport_04_base_F"})}) exitWith {};	//(MK) Taru pods too
	if (_v getVariable ["MCC_isLHD", false] || {_v getVariable ["MCCMK_salvageOffered", false]}) exitWith {};
	_v setVariable ["MCCMK_salvageOffered", true];
	[_v] remoteExec ["MCCMK_fnc_salvageAction", 0, _v];
	// a wreck inside an RTS base: cleared after two minutes, if that option is on
	if (missionNamespace getVariable ["MCCMK_salvageAutoBase", false]) then {
		[_v] spawn {
			params ["_v"];
			sleep 120;
			if (isNull _v || {alive _v}) exitWith {};
			if ([["hq", 1], _v, 300] call MCC_fnc_CheckBuildings) then {{deleteVehicle _x} forEach (crew _v); deleteVehicle _v};
		};
	};
};
addMissionEventHandler ["EntityKilled", {params ["_v"]; [_v] call MCCMK_salvageOffer}];
{[_x] call MCCMK_salvageOffer} forEach (allDead select {!(_x isKindOf "Man")});
