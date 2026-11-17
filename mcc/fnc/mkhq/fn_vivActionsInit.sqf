/*
	MCCMK_fnc_vivActionsInit - every player, postInit: with ACE, vehicle-in-vehicle loading on foot in ACE's interaction
	menu. "Load onto vehicle" on any object Arma can carry that way (a crate, a box, a quad bike ...), one entry per
	vehicle within 10 m that can take it; "Unload cargo" on a vehicle, one entry per object it carries. ACE's own cargo
	is untouched. Without ACE the same options are in MCC's interaction menu.
*/
if (!hasInterface || {!isClass (configFile >> "CfgPatches" >> "ace_interact_menu")}) exitWith {};
private _load = ["MCCMK_vivLoad", "Load onto vehicle", "", {}, {
	(vehicle _player) isEqualTo _player && {([_target] call MCCMK_fnc_vivTargets) isNotEqualTo []}
}, {
	params ["_target"];
	([_target] call MCCMK_fnc_vivTargets) apply {
		[[format ["MCCMK_vivLoad_%1", netId _x], getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"), "", {
			params ["_target", "", "_veh"];
			[_target, _veh] call MCCMK_fnc_cargoViV;
		}, {true}, {}, _x] call ace_interact_menu_fnc_createAction, [], _target]
	}
}] call ace_interact_menu_fnc_createAction;
private _unload = ["MCCMK_vivUnload", "Unload cargo", "", {}, {
	(vehicle _player) isEqualTo _player && {(getVehicleCargo _target) isNotEqualTo []}
}, {
	params ["_target"];
	(getVehicleCargo _target) apply {
		[[format ["MCCMK_vivUnload_%1", netId _x], getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"), "", {
			params ["", "", "_o"];
			[_o] call MCCMK_fnc_cargoViVUnload;
		}, {true}, {}, _x] call ace_interact_menu_fnc_createAction, [], _target]
	}
}] call ace_interact_menu_fnc_createAction;
{["ThingX", 0, ["ACE_MainActions"], _x, true] call ace_interact_menu_fnc_addActionToClass} forEach [_load];
{["AllVehicles", 0, ["ACE_MainActions"], _x, true] call ace_interact_menu_fnc_addActionToClass} forEach [_load, _unload];
