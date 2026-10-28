/*======================================================== MCC_fnc_respawnObjects ========================================================
	BIS_fnc_getRespawnPositions, but every entry is an OBJECT or GROUP.

	MCC's respawn/deploy panel only understood respawn positions that are objects (FOBs, tents, vehicles) or groups.
	A respawn position added as a marker ("respawn_west", BIS_fnc_addRespawnPosition with a marker name) or as a plain
	position made the panel throw errors, so nothing could be selected or deployed and the player was stuck on the
	panel's map in MP. Markers and positions are now turned into an invisible local helper at that spot.

	<IN>	0: OBJECT/SIDE/... - target for BIS_fnc_getRespawnPositions (default player)
	<OUT>	ARRAY of OBJECT/GROUP
==========================================================================================================================================*/
params [["_target", player]];

private _helpers = missionNamespace getVariable ["MCC_respawnHelpers", createHashMap];
missionNamespace setVariable ["MCC_respawnHelpers", _helpers];

private _out = [];
{
	private _entry = _x;
	switch (typeName _entry) do {
		case "OBJECT";
		case "GROUP": {if (!isNull _entry) then {_out pushBack _entry}};
		case "STRING";
		case "ARRAY": {
			private _pos = if (_entry isEqualType "") then {getMarkerPos _entry} else {_entry};
			if (_pos isEqualType [] && {count _pos >= 2} && {!(_pos isEqualTo [0,0,0])}) then {
				_pos = [_pos select 0, _pos select 1, 0];
				private _key = str _entry;
				private _helper = _helpers getOrDefault [_key, objNull];
				if (isNull _helper) then {
					_helper = "Land_HelipadEmpty_F" createVehicleLocal _pos;
					_helper setPosATL _pos;
					private _name = if (_entry isEqualType "") then {markerText _entry} else {""};
					_helper setVariable ["type", ["Respawn", _name] select (_name != "")];
					_helpers set [_key, _helper];
					["INFO", "MCC_fnc_respawnObjects", "respawn position %1 is a %2 - using a helper at %3", [_entry, typeName _entry, mapGridPosition _pos]] call MCC_fnc_log;
				} else {
					if ((getPosATL _helper) distance2D _pos > 1) then {_helper setPosATL _pos};
				};
				_out pushBack _helper;
			};
		};
	};
} forEach ([_target] call BIS_fnc_getRespawnPositions);

_out
