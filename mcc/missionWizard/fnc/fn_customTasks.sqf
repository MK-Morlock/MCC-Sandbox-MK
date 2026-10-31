/*================================================MCC_fnc_customTasks=====================================================================================================
	 Manage custom tasks
	 Example:[_logic] spawn MCC_fnc_customTasks;
	 Return - nothing
===================================================================================================================================================================*/
private _logic = objNull;
private _attachedUnit = objNull;
private _owners = [];
private _taskState = "";
private _taskStateDestination = 0;
private _taskDescription = [];
private _taskType = "";
private _desc = "";
private _missionDone = false;
private _taskName = "";
_logic = param [0, objNull, [objNull]];

waituntil {!alive _logic || _logic getvariable ["updated",false]};

if (!alive _logic) exitWith {};

_attachedUnit 			= _logic getvariable ["bis_fnc_curatorAttachObject_object",objnull];
_owners 				= _logic getvariable ["RscAttributeOwners",[]];
_taskState 				= _logic getvariable ["RscAttributeTaskState","created"];
_taskStateDestination 	= _logic getvariable ["RscAttributeTaskDestination",0];
_taskDescription 		= _logic getvariable ["RscAttributeTaskDescription",["","", ""]];
_taskType				= _logic getvariable ["taskType",""];
_taskName 				= _logic getvariable ["taskName",""];

_logic setVariable ["MCC_customTask",true,true];

//Not a custom task? exit
if (_taskType == "") exitWith {};

switch (true) do {
	case (_taskType in ["help"]): {
		private _startPositions = (allPlayers select {alive _x && {side group _x in _owners}}) apply {getPos _x};

		private _fnc_bases = {
			private _b = [];
			{
				private _side = _x;
				switch (_side) do {
					case west:       {_b pushBack (missionNamespace getvariable ["MCC_START_WEST",[0,0,0]]); _b pushBack (markerPos "respawn_west")};
					case east:       {_b pushBack (missionNamespace getvariable ["MCC_START_EAST",[0,0,0]]); _b pushBack (markerPos "respawn_east")};
					case resistance: {_b pushBack (missionNamespace getvariable ["MCC_START_GUER",[0,0,0]]); _b pushBack (markerPos "respawn_guerrila")};
				};
				{
					_b pushBack (switch (typeName _x) do {
						case "STRING": {markerPos _x};
						case "OBJECT": {if (_x isKindOf "AllVehicles") then {[0,0,0]} else {getPos _x}};	// not mobile respawns / squad leaders
						case "ARRAY": {_x};
						default {[0,0,0]};	// squads
					});
				} forEach ([_side] call BIS_fnc_getRespawnPositions);
			} forEach (_owners select {_x isEqualType west});
			_b select {(_x isEqualType []) && {count _x >= 2} && {!(_x isEqualTo [0,0,0])}}
		};

		private _fnc_inAO = {
			params ["_p"];
			private _hit = false;
			private _zPos = missionNamespace getVariable ["mcc_zone_pos", []];
			private _zSize = missionNamespace getVariable ["mcc_zone_size", []];
			private _zDir = missionNamespace getVariable ["mcc_zone_dir", []];
			{
				if (!isNil "_x" && {_x isEqualType 0}) then {
					private _zp = _zPos param [_x, []];
					if ((_zp isEqualType []) && {count _zp >= 2} && {!(_zp isEqualTo [-5000,-5000,0])}) then {
						private _zs = _zSize param [_x, [50,50]];
						if (_p inArea [_zp, (_zs select 0) + 300, (_zs select 1) + 300, _zDir param [_x, 0], true]) then {_hit = true};
					};
				};
				if (_hit) exitWith {};
			} forEach (missionNamespace getVariable ["MCC_zones_numbers",[]]);
			_hit
		};

		private _fnc_extraction = {
			params ["_hostagePos"];
			private _ok = {params ["_p"]; !(surfaceIsWater _p) && {(_p distance2D _hostagePos) >= 500} && {!([_p] call _fnc_inAO)}};
			private _anchor = [];
			private _cands = _startPositions select {[_x] call _ok};
			if (count _cands > 0) then {
				_cands = [_cands, [], {_x distance2D _hostagePos}, "DESCEND"] call BIS_fnc_sortBy;
				_anchor = _cands select 0;
			};
			if (_anchor isEqualTo []) then {
				private _dir0 = random 360;
				{
					private _d = _x;
					for "_i" from 0 to 11 do {
						private _p = _hostagePos getPos [_d, _dir0 + _i * 30];
						if ((_p select 0) > 0 && {(_p select 1) > 0} && {(_p select 0) < worldSize} && {(_p select 1) < worldSize} && {[_p] call _ok}) exitWith {_anchor = _p};
					};
					if !(_anchor isEqualTo []) exitWith {};
				} forEach [1000, 1500, 2000, 3000];
			};
			//Nothing outside the areas of operation (small island, zones everywhere): any land 1 km away
			if (_anchor isEqualTo []) then {
				for "_i" from 0 to 11 do {
					private _p = _hostagePos getPos [1000, _i * 30];
					if !(surfaceIsWater _p) exitWith {_anchor = _p};
				};
				if (_anchor isEqualTo []) then {_anchor = _hostagePos getPos [1000, random 360]};
				["WARN", "MCC_fnc_customTasks", "rescue task: no extraction position outside the areas of operation - using %1", [mapGridPosition _anchor]] call MCC_fnc_log;
			};

			//A landmark near the anchor: church / chapel, or a military building
			private _marks = nearestTerrainObjects [_anchor, ["CHURCH","CHAPEL"], 400, false];
			_marks append ((nearestObjects [_anchor, ["House"], 400]) select {
				private _c = toLower typeOf _x;
				(["cargo_hq","cargo_tower","cargo_patrol","barracks","miloffices","military","mil_","bunker"] findIf {(_c find _x) >= 0}) >= 0
			});
			_marks = _marks select {alive _x && {[getPos _x] call _ok}};
			if (count _marks > 0) exitWith {
				_marks = [_marks, [], {_x distance2D _anchor}, "ASCEND"] call BIS_fnc_sortBy;
				["INFO", "MCC_fnc_customTasks", "rescue task: extraction point at %1 (%2) at %3", [typeOf (_marks select 0), "existing building", mapGridPosition (_marks select 0)]] call MCC_fnc_log;
				[getPos (_marks select 0), []]
			};

			//None: a temporary extraction LZ on open, flat ground near the anchor (nothing on the map is hidden or removed for it)
			private _site = [_anchor, 0, 300, 20, 0, 0.15, 0, [], [[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
			if ((_site select 0) == -500 || {!([_site] call _ok)}) then {_site = +_anchor};
			_site = [_site select 0, _site select 1, 0];
			private _dir = random 360;
			private _netType = switch (_owners select 0) do {case east: {"CamoNet_OPFOR_big_F"}; case resistance: {"CamoNet_INDP_big_F"}; default {"CamoNet_BLUFOR_big_F"}};
			private _netPos = _site getPos [17, _dir];
			private _objects = [];
			{
				_x params ["_type", "_pos", "_odir"];
				if (isClass (configFile >> "CfgVehicles" >> _type)) then {
					private _o = createVehicle [_type, [_pos select 0, _pos select 1, 0], [], 0, "CAN_COLLIDE"];
					_o setDir _odir;
					_o setVectorUp (surfaceNormal _pos);
					_o allowDamage false;
					_objects pushBack _o;
				} else {
					["WARNING", "MCC_fnc_customTasks", "extraction LZ: %1 is not in this game's config - not created", [_type]] call MCC_fnc_log;
				};
			} forEach [
				["Land_HelipadSquare_F", _site, _dir],
				[_netType, _netPos, _dir],
				["Land_Pallet_MilBoxes_F", _netPos getPos [2.5, _dir + 90], _dir],
				["Land_PaperBox_closed_F", _netPos getPos [2.5, _dir - 90], _dir + 15]
			];
			{_x addCuratorEditableObjects [_objects, false]} forEach allCurators;
			["INFO", "MCC_fnc_customTasks", "rescue task: extraction point at %1 (extraction LZ set up: %2)", [mapGridPosition _site, _objects apply {typeOf _x}]] call MCC_fnc_log;
			[_site, _objects]
		};

		waituntil {!alive _attachedUnit || isPlayer leader _attachedUnit || !(isNull attachedTo _attachedUnit)};

		private _rescuer = if (isNull attachedTo _attachedUnit) then {leader _attachedUnit} else {attachedTo _attachedUnit};

		if (alive _attachedUnit && side group _rescuer in _owners) then {
			_desc 	= format ["Get %1 back to base alive.<br/><br/>Base is within 100 m of your side's start location or any of your respawn points (respawn markers, respawn modules, FOBs, tents - not mobile respawn vehicles).",name _attachedUnit];

			//No base for this side: extraction point with its own map marker (only for this side), and the task points there
			private _extraction = [];
			private _extractionObjects = [];
			private _extractionMarker = "";
			if (count (call _fnc_bases) == 0) then {
				([getPos _attachedUnit] call _fnc_extraction) params ["_ePos", "_eObjects"];
				_extraction = _ePos;
				_extractionObjects = _eObjects;
				if (count _extractionObjects > 0) then {["addObjects", [_logic, _extractionObjects]] call MCC_fnc_generatedMissions};
				["WARN", "MCC_fnc_customTasks", "rescue task: no start location or respawn position for %1 - extraction point at %2, %3 m from the hostage", [_owners, mapGridPosition _extraction, round (_extraction distance2D _attachedUnit)]] call MCC_fnc_log;
				_extractionMarker = format ["MCC_extraction_%1", ["MCC_extractionCounter",1] call BIS_fnc_counter];
				["call", [[_extractionMarker, _extraction, [_owners select 0, true] call BIS_fnc_sideColor], {
					params ["_mk", "_p", "_c"];
					private _m = createMarkerLocal [_mk, _p];
					_m setMarkerTypeLocal "mil_pickup";
					_m setMarkerColorLocal _c;
					_m setMarkerTextLocal "Extraction";
				}], _owners select 0, _extractionMarker] call MCC_fnc_secRemote;
				_desc = format ["Get %1 to the extraction point alive.<br/><br/>Your side has no base on this map (no start location or respawn point), so an extraction point is marked on the map. Get %1 within 100 m of it.", name _attachedUnit];
				_logic setvariable ["showMarker", _extraction, true];
			};

			sleep 1;
			_logic setvariable ["RscAttributeTaskDescription",[_desc, _desc, _desc],true];
			sleep 1;
			_logic setvariable ["RscAttributeTaskState","assigned", true];
			_logic setvariable ["updated",true];

			_missionDone = false;
			while {! _missionDone} do {
				private _bases = call _fnc_bases;
				if !(_extraction isEqualTo []) then {_bases pushBack _extraction};
				{
					if (_x distance2D _attachedUnit < 100) exitWith {
						_logic setvariable ["RscAttributeTaskState","Succeeded", true];
						_missionDone = true;
					};
				} forEach _bases;

				if (!alive _attachedUnit) then {
					_logic setvariable ["RscAttributeTaskState","Failed", true];
					_missionDone = true;
				};

				sleep 5;
			};

			//Extraction marker gone with the task (and from the join-in-progress queue)
			if (_extractionMarker != "") then {
				remoteExec ["", _extractionMarker];
				_extractionMarker remoteExec ["deleteMarkerLocal", _owners select 0];
			};

			if (count _extractionObjects > 0) then {
				[_extractionObjects] spawn {
					params ["_objects"];
					private _points = (_objects select {!isNull _x}) apply {(getPosASL _x) vectorAdd [0,0,2.5]};
					waitUntil {
						sleep 10;
						_objects = _objects select {!isNull _x};
						(count _objects == 0) || {
							(allPlayers findIf {
								private _p = _x;
								alive _p && {
									((_points findIf {(_p distance _x) < 600}) >= 0) ||
									{(_points findIf {((_p distance _x) < 4000) && {([vehicle _p, "VIEW"] checkVisibility [eyePos _p, _x]) > 0}}) >= 0}
								}
							}) < 0
						}
					};
					{deleteVehicle _x} forEach _objects;
					["INFO", "MCC_fnc_customTasks", "extraction LZ removed (no player within 600 m or in sight)", []] call MCC_fnc_log;
				};
			};
		} else {
			_logic setvariable ["RscAttributeTaskState","Failed", true];
		};

	};

	case (_taskType in ["kill","destroy"]): {
		waituntil {!alive _attachedUnit || isPlayer leader _attachedUnit};
		_logic setvariable ["RscAttributeTaskState","Succeeded", true];
	};

	case (_taskType in ["mine"]): {
		waituntil {!(alive _attachedUnit) || !(_attachedUnit getvariable ["armed",true])};
		sleep 1;
		if (alive _attachedUnit) then {
			_logic setvariable ["RscAttributeTaskState","Succeeded", true];
		} else {
			_logic setvariable ["RscAttributeTaskState","Failed", true];
		};
	};

	case (_taskType in ["search","download"]): {
		private _pickedSide = sideUnknown;
		waituntil {
			if (!isNull _attachedUnit) then {_pickedSide = _attachedUnit getVariable ["MCC_intelPickedSide", _pickedSide]};
			(isnull _attachedUnit || (_attachedUnit getVariable ["MCC_intelItemDone",false]) || {!alive _attachedUnit})
		};
		if (!isNull _attachedUnit && {!alive _attachedUnit} && {!(_attachedUnit getVariable ["MCC_intelItemDone",false])}) exitWith {
			["INFO", "MCC_fnc_customTasks", "intel task: %1 was destroyed - task failed", [typeOf _attachedUnit]] call MCC_fnc_log;
			_logic setvariable ["RscAttributeTaskState","Failed", true];
		};
		sleep 5;
		if (!isNull _attachedUnit) then {_pickedSide = _attachedUnit getVariable ["MCC_intelPickedSide", _pickedSide]};
		if (_pickedSide isEqualTo sideUnknown) then {_pickedSide = missionNamespace getVariable ["MCC_pickItem",sideLogic]};
		if ((isnull _attachedUnit || (_attachedUnit getVariable ["MCC_intelItemDone",false])) && (_pickedSide in _owners)) then {
			_logic setvariable ["RscAttributeTaskState","Succeeded", true];
		} else {
			_logic setvariable ["RscAttributeTaskState","Failed", true];
		};
	};

	case (_taskType in ["attack","defend"]): {
		if (_logic getVariable ["MCC_MWClearArea", false]) then {
			[_logic, _owners] spawn {
				params ["_logic", "_owners"];
				private _enemy = _logic getVariable ["MCC_MWClearEnemy", sideUnknown];
				private _radius = (_logic getvariable ["radius",200]) call bis_fnc_parsenumber;
				private _heldSince = -1;
				while {!isNull _logic && {simulationEnabled _logic}} do {
					sleep 2;
					private _inside = allUnits select {alive _x && {!(vehicle _x isKindOf "Air")} && {(_x distance2D _logic) < _radius}};
					private _enemies = {side group _x == _enemy} count _inside;
					private _best = [0, sideUnknown];
					{
						private _s = _x;
						private _n = {side group _x == _s} count _inside;
						if (_n > (_best select 0)) then {_best = [_n, _s]};
					} forEach _owners;
					if (_enemies <= 2 && {(_best select 0) > 0}) then {
						if (_heldSince < 0) then {_heldSince = time};
						if (time - _heldSince >= 60) exitWith {
							private _id = (_best select 1) call bis_fnc_sideID;
							private _score = [0,0,0,0,0,0];
							_score set [_id, 1];
							_logic setVariable ["sideScore", _score, true];
							_logic setVariable ["owner", _best select 1, true];
							["INFO", "MCC_fnc_customTasks", "Clear Area: %1 enemies left, %2 held it for 60 s - area cleared", [_enemies, _best select 1]] call MCC_fnc_log;
						};
					} else {
						_heldSince = -1;
					};
				};
			};
		};

		waitUntil {!simulationEnabled _logic};
		_logic setVariable ["SucceededSide",[(_logic getvariable ["owner",sideLogic])],true];


		//if capture area then capture it
		[position _logic,(_logic getvariable ["radius",200])*3,(_logic getvariable ["owner",sideLogic]),0.2,[]] spawn MCC_fnc_campaignPaintMarkers;

		_logic setvariable ["RscAttributeTaskState","Succeeded", true];
	};

	case (_taskType in ["logistic"]): {
		_missionDone = false;
		while {alive _attachedUnit && !_missionDone} do {
			if (_attachedUnit distance2D _logic < 50) then {
				_missionDone = true;
			};

			sleep 1;
		};

		if (_missionDone) then {
			_logic setvariable ["RscAttributeTaskState","Succeeded", true];
		} else {
			_logic setvariable ["RscAttributeTaskState","Failed", true];
		};

	};

	case (_taskType in ["parent"]): {
		private _fnc_open = {
			private _ch = _taskName call BIS_fnc_taskChildren;
			if (_ch isEqualType []) then {{!(_x call bis_fnc_taskCompleted)} count _ch} else {0}
		};
		waituntil {isNull _logic || (call _fnc_open > 0)};

		waituntil {isNull _logic || (call _fnc_open <= 0)};

		//If a perent task
		if (!isNull _logic && {call _fnc_open <= 0}) then {
			_logic setvariable ["RscAttributeTaskState","Succeeded", true];
		};
	};

	default
	{
		waituntil {isNull _logic || !(simulationEnabled _logic)};
	};
};

if (!isNull _logic) then {
	_logic setvariable ["updated",true];
};