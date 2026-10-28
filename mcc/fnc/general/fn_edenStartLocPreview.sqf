if (!is3DEN) exitWith {};
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text "MCC [INFO] fn_edenStartLocPreview | started"};
private _token = (uiNamespace getVariable ["MCC_slPrevToken", 0]) + 1;
uiNamespace setVariable ["MCC_slPrevToken", _token];
missionNamespace setVariable ["MCC_slPrevData", createHashMap];	//entity id -> [signature, objects, posASL, dir]

private _clear = {
	params ["_objs"];
	{deleteVehicle _x} forEach _objs;
};
private _build = {
	params ["_pos", "_dir", "_size", "_construct", ["_cls", "MCC_rts_hq1"]];
	private _objs = [];
	private _mk = {
		params ["_class"];
		if (_class == "" || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {
			if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC [INFO] fn_edenStartLocPreview | no such object class '%1'", _class]}; objNull
		};
		private _o = createSimpleObject [_class, [0, 0, 0], true];
		if (isNull _o) then {
			_o = _class createVehicleLocal [0, 0, 0];
			if (!isNull _o) then {_o enableSimulation false; _o allowDamage false};
		};
		if (!isNull _o) then {_objs pushBack _o} else {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC [INFO] fn_edenStartLocPreview | could not create %1", _class]}};
		_o
	};
	private _ground = {	//stand the model on the ground at _pos (simple objects are placed by their centre)
		params ["_o", "_p"];
		private _bb = boundingBoxReal _o;
		_o setPosWorld (_p vectorAdd [0, 0, -((_bb select 0) select 2)]);
	};
	if (_construct) then {
		//HQ as MCC_fnc_construct_base places it: anchor at the module, objects attached with their offsets
		private _root = configFile >> "cfgRtsBuildings" >> _cls;
		if (isClass (missionConfigFile >> "cfgRtsBuildings" >> _cls)) then {_root = missionConfigFile >> "cfgRtsBuildings" >> _cls};
		private _parts = [];
		private _anchorClass = getText (_root >> "anchorType");
		if (_anchorClass == "" || {!isClass (configFile >> "CfgVehicles" >> _anchorClass)}) exitWith {};
		private _anchor = _anchorClass createVehicleLocal [0, 0, 0];
		if (isNull _anchor) exitWith {};
		_anchor enableSimulation false;
		_anchor allowDamage false;
		_objs pushBack _anchor;
		_anchor setDir _dir;
		_anchor setPosATL [_pos select 0, _pos select 1, 0];
		{
			_x params ["_class", "_off", ["_vec", []]];
			private _o = [_class] call _mk;
			if (!isNull _o) then {
				_parts pushBack [_o, _off];
				_o setPosWorld (_anchor modelToWorldWorld _off);
				if (count _vec == 2) then {
					_o setVectorDirAndUp [_anchor vectorModelToWorld (_vec select 0), _anchor vectorModelToWorld (_vec select 1)];
				} else {_o setDir _dir};
			};
		} forEach getArray (_root >> "objectsArray");
		private _offs = [_anchor, _parts] call (uiNamespace getVariable ["MCC_fnc_rtsGroundOffsets", {[]}]);
		if (_offs isEqualType [] && {count _offs == count _parts}) then {
			{(_x select 0) setPosWorld (_anchor modelToWorldWorld (_offs select _forEachIndex))} forEach _parts;
		};
	} else {
		private _base = [["UserTexture10m_F", "Land_TBox_F"] select (_size == "FOB")] call _mk;
		if (isNull _base) exitWith {};
		_base setDir _dir;
		[_base, _pos] call _ground;
		private _flag = ["FlagPole_F"] call _mk;
		if (!isNull _flag) then {
			_flag setDir _dir;
			if (_size == "FOB") then {_flag setPosWorld (_base modelToWorldWorld [2.5, 0, 2])} else {[_flag, _pos] call _ground};
		};
	};
	_objs
};

while {is3DEN && {(uiNamespace getVariable ["MCC_slPrevToken", 0]) == _token}} do {
	private _data = missionNamespace getVariable ["MCC_slPrevData", createHashMap];
	private _seen = [];
	{
		if (typeOf _x == "mcc_sandbox_moduleStartLocations") then {
			private _id = get3DENEntityID _x;
			_seen pushBack _id;
			private _pos = getPosASL _x;
			private _dir = getDir _x;
			private _size = toUpper str ((_x get3DENAttribute "size") param [0, "FOB"]);
			_size = ["MAIN", "FOB"] select ("FOB" in _size);
			private _con = (_x get3DENAttribute "construct") param [0, 1];
			_con = _con isEqualTo 1 || {_con isEqualTo true} || {_con isEqualTo "1"};
			private _sig = [(_pos apply {round (_x * 10)}), round _dir, _size, _con];
			private _old = _data getOrDefault [_id, []];
			if (count _old == 0 || {!((_old select 0) isEqualTo _sig)}) then {
				if (count _old > 0) then {[_old select 1] call _clear};
				private _objs = [_pos, _dir, _size, _con] call _build;
				_data set [_id, [_sig, _objs, _pos, _dir]];
				if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC [INFO] fn_edenStartLocPreview | module %1: %2, construct %3, %4 preview objects at %5", _id, _size, _con, count _objs, mapGridPosition (ASLToAGL _pos)]};
			};
		};
		if (typeOf _x == "MCC_Module_RTSBuildingsCurator") then {
			private _id = get3DENEntityID _x;
			_seen pushBack _id;
			private _pos = getPosASL _x;
			private _dir = getDir _x;
			private _cls = (_x get3DENAttribute "MCC_Module_RTSBuildingsCurator_building") param [0, ""];
			if (!(_cls isEqualType "") || {_cls == ""}) then {_cls = (_x get3DENAttribute "building") param [0, ""]};
			if (!(_cls isEqualType "") || {_cls == ""}) then {_cls = "MCC_rts_storage1"};
			if !(_cls isEqualType "") then {_cls = "MCC_rts_storage1"};
			private _sig = [(_pos apply {round (_x * 10)}), round _dir, _cls];
			private _old = _data getOrDefault [_id, []];
			if (count _old == 0 || {!((_old select 0) isEqualTo _sig)}) then {
				if (count _old > 0) then {[_old select 1] call _clear};
				private _objs = [_pos, _dir, "", true, _cls] call _build;
				_data set [_id, [_sig, _objs, _pos, _dir]];
			};
		};
	} forEach ((all3DENEntities) select 3);
	//Modules that were deleted
	{
		if !(_x in _seen) then {[(_data get _x) select 1] call _clear; _data deleteAt _x};
	} forEach (keys _data);
	uiSleep 0.15;
};

//Eden left or restarted: remove everything
{[_y select 1] call _clear} forEach (missionNamespace getVariable ["MCC_slPrevData", createHashMap]);
missionNamespace setVariable ["MCC_slPrevData", createHashMap];
