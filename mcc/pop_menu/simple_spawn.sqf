private _unitspawned = grpNull;
private _dummy = nil;
private _vehicleClass = "";
private "_tempInit";
params ["_pos", "_dir", "_class", "_type", "_faction", "_notEmpty", "_init", "_name", "_loc", ["_align", false, [false]], ["_beh", "hold", [""]], ["_cmd", false, [false]], ["_landed", true, [true, 0]]];
//(MK) Start as a number too: 0 flying, 1 landed, 2 on the water (afloat)
private _start3D = if (_landed isEqualType 0) then {_landed} else {[0, 1] select _landed};
_landed = _start3D > 0;
//(MK) _landed: the 3D Editor's Start (aircraft) - true: on the ground where it was put, engine off, crew aboard, held until
// its first order (MCCMK_fnc_airLandedHold); false: in the air there (at least 50 m up), engine running

if ( ( (isServer) && ( (_loc == 0) || !(MCC_isHC) ) ) || ( (MCC_isLocalHC) && (_loc == 1) ) ) then
{
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["%1 - spawning 3D Editor object [%2]", time, _class]};

	switch (_type) do		//Which type do we want
			{
				case "MAN":
				{
					_unitspawned = createGroup (((getNumber (configFile >> "CfgVehicles" >> _class >> "side")) call BIS_fnc_sideType));
					_dummy = _unitspawned createUnit [_class, _pos, [], 0, "NONE"];
					_dummy setpos _pos;
					_dummy setdir _dir;
					sleep 0.01;

					_tempInit = _init;
					if (!_align) then
					{
						_dummy setpos _pos;
						_tempInit= _tempInit +	FORMAT [";_this setpos %1;",_pos];
					};

					_dummy setVariable ["vehicleinit", _tempInit, true];

					//setskill
					_unitspawned setformdir _dir;

					_dummy setSkill ["aimingspeed", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
					_dummy setSkill ["spotdistance", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
					_dummy setSkill ["aimingaccuracy", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
					_dummy setSkill ["aimingshake", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
					_dummy setSkill ["spottime", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
					_dummy setSkill ["commanding", (missionNamespace getVariable ["MCC_AI_Command",0.5])];
					_dummy setSkill ["general", (missionNamespace getVariable ["MCC_AI_Skill",0.5])];

					if (_name != "") then
					{
						[[netid _dummy,_dummy], _name] remoteExec ["MCC_fnc_setVehicleName", 0, true];
					};
					["MCC_fnc_setVehicleInit", [[netid _dummy,_dummy], _init, false], 0, true] call MCC_fnc_secRemote;

					//Curator
					{_x addCuratorEditableObjects [[_dummy],false]} forEach allCurators;
				};

				case "ANIMAL":
				{
					_unitspawned = createGroup sidelogic;
					_dummy = _unitspawned createUnit [_class, _pos, [], 0, "NONE"];
					_dummy setpos _pos;
					_dummy setdir _dir;
					sleep 0.01;

					_tempInit = _init;
					if (!_align) then
					{
						_dummy setpos _pos;
						_tempInit= _tempInit +	FORMAT [";_this setpos %1;",_pos];
					};

					_dummy setVariable ["vehicleinit", _tempInit, true];

					_unitspawned setformdir _dir;
					if (_name != "") then
					{
						[[netid _dummy,_dummy], _name] remoteExec ["MCC_fnc_setVehicleName", 0, true];
					};
					["MCC_fnc_setVehicleInit", [[netid _dummy,_dummy], _init, false], 0, true] call MCC_fnc_secRemote;

					//Curator
					{_x addCuratorEditableObjects [[_dummy],false]} forEach allCurators;
				};

				case "VEHICLE":
				{
					if (_notEmpty) then
					{
						private _side = configNull;
						private _veh = objNull;
						private _crew = [];
						_side = (((getNumber (configFile >> "CfgVehicles" >> _class >> "side")) call BIS_fnc_sideType));

						private _fly = (_class isKindOf "Air") && {!_landed};
						if (_fly) then {
							private _fp = [_pos select 0, _pos select 1, (_pos param [2, 0]) max 50];
							_veh = createVehicle [_class, _fp, [], 0, "FLY"];
							_veh setDir _dir;
							_veh setPos _fp;
							_veh engineOn true;
							if (_class isKindOf "Plane") then {_veh setVelocity [100 * (sin _dir), 100 * (cos _dir), 0]};
						} else {
							_veh = createvehicle [_class,_pos,[],0,"none"];
							_veh setpos _pos;
							_veh setdir _dir;
							if (_align) then {_veh setVectorUp (surfaceNormal _pos)};
							//(MK) On water: afloat on the sea there (Floatary floats it), marked watertight until it is 5 m up
							if ((_class isKindOf "Air") && {_start3D == 2} && {surfaceIsWater _pos} && {[_class] call MCCMK_fnc_canFloat}) then {
								_veh setVariable ["MCCMK_waterLanding", true, true];
								_veh setPosASL [_pos select 0, _pos select 1, 0.3];
								_align = true;	// (not put back at the placed height below)
								[_veh] spawn {params ["_v"]; waitUntil {sleep 2; !alive _v || {((getPosATL _v) select 2) > 5}}; if (alive _v) then {_v setVariable ["MCCMK_waterLanding", nil, true]}};
								["INFO", "waterLand", "%1 placed afloat at %2, engine off", [_class, mapGridPosition _veh]] call MCC_fnc_log;
								[_veh] spawn {sleep 1; [_this select 0] call MCCMK_fnc_heliWaterCrew};	// (after its crew is in)
							};
						};
						_grp = createGroup _side;

						//If autonomous
						_vehicleClass 	=  getText (configFile >> "CfgVehicles" >> _class >> "vehicleClass");
						if (_vehicleClass == "autonomous") then
						{
							createVehicleCrew _veh;
						};

						_crew = [_veh, _grp] call BIS_fnc_spawnCrew;
						_dummy = [_veh,_crew,_grp];

						(_dummy select 0) setSkill ["aimingspeed", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
						(_dummy select 0) setSkill ["spotdistance", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
						(_dummy select 0) setSkill ["aimingaccuracy", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
						(_dummy select 0) setSkill ["aimingshake", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
						(_dummy select 0) setSkill ["spottime", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
						(_dummy select 0) setSkill ["commanding", (missionNamespace getVariable ["MCC_AI_Command",0.5])];
						(_dummy select 0) setSkill ["general", (missionNamespace getVariable ["MCC_AI_Skill",0.5])];

						if (_name != "") then
						{
							[[netid (_dummy select 0),(_dummy select 0)], _name] remoteExec ["MCC_fnc_setVehicleName", 0, true];
						};

						_tempInit = _init +	FORMAT [";group _this setFormDir %1;",_dir];
						if (!_align && {!_fly}) then
						{
							(_dummy select 0) setpos _pos;
							_tempInit= _tempInit +	FORMAT [";_this setpos %1;",_pos];
						};

						(_dummy select 0) setVariable ["vehicleinit", _tempInit, true];


						["MCC_fnc_setVehicleInit", [[netid (_dummy select 0),(_dummy select 0)], _init], 0, true] call MCC_fnc_secRemote;

						//Curator
						{_x addCuratorEditableObjects [[(_dummy select 0)],true]} forEach allCurators;
						if ((_class isKindOf "Air") && {_landed}) then {[_dummy select 0] call MCCMK_fnc_airLandedHold};
						[_dummy select 0] call MCCMK_fnc_spawnAnchor;
						[_dummy select 0] call MCCMK_fnc_garageApply;	//(MK) its class's garage paint and parts, if any
					}
					else
					{
						_dummy = _class createvehicle _pos;
						_dummy setpos _pos;
						_dummy setdir _dir;
						if (_dummy isKindOf "AllVehicles" && {!(_dummy isKindOf "CAManBase")}) then {[_dummy] call MCCMK_fnc_garageApply; [_dummy] call MCCMK_fnc_spawnAnchor};	//(MK) garage paint and parts
						if (_align) then {_dummy setVectorUp (surfaceNormal _pos)};
						sleep 0.01;

						_tempInit = _init;
						if (!_align) then
						{
							_dummy setpos _pos;
							_tempInit= _tempInit +	FORMAT [";_this setpos %1;",_pos];
						};

						_dummy setVariable ["vehicleinit", _tempInit, true];

						if (_name != "") then
						{
							[[netid _dummy,_dummy], _name] remoteExec ["MCC_fnc_setVehicleName", 0, true];
						};
						["MCC_fnc_setVehicleInit", [[netid _dummy,_dummy], _init], 0, true] call MCC_fnc_secRemote;

						//Curator
						{_x addCuratorEditableObjects [[_dummy],false]} forEach allCurators;
					};
				};

				case "AMMO":
				{
					_dummy = _class createvehicle _pos;
					_dummy setpos _pos;
					_dummy setdir _dir;
					if (_align) then {_dummy setVectorUp (surfaceNormal _pos)};
					sleep 0.01;

					_tempInit = _init;
					if (!_align) then
					{
						_dummy setpos _pos;
						_tempInit= _tempInit +	FORMAT [";_this setpos %1;",_pos];
					};

					_dummy setVariable ["vehicleinit", _tempInit, true];

					if (_name != "") then
					{
						[[netid _dummy,_dummy], _name] remoteExec ["MCC_fnc_setVehicleName", 0, true];
					};
					["MCC_fnc_setVehicleInit", [[netid _dummy,_dummy], _init], 0, true] call MCC_fnc_secRemote;

					//Curator
					{_x addCuratorEditableObjects [[_dummy],false]} forEach allCurators;
				};

				case "MINES":
				{
					_dummy = createMine [_class, _pos, [], 0];
					_dummy setpos _pos;
					_init = format ["%1;_this setdir %2;",_init,_dir];
					sleep 0.01;
					if (_name != "") then
					{
						[[netid _dummy,_dummy], _name] remoteExec ["MCC_fnc_setVehicleName", 0, true];
					};
					["MCC_fnc_setVehicleInit", [[netid _dummy,_dummy], _init], 0, true] call MCC_fnc_secRemote;

					//Curator
					{_x addCuratorEditableObjects [[_dummy],false]} forEach allCurators;
				};

				case "DOC":
				{
					_unitspawned =[ _pos, _dir, _class] call MCC_fnc_objectMapper;
				};
			};
	if (!isnil "_dummy") then
	{
		private _placeGrp = grpNull;
		if (_type == "MAN" && {!isNil "_unitspawned"} && {_unitspawned isEqualType grpNull}) then {_placeGrp = _unitspawned};
		if (_type == "VEHICLE" && {_notEmpty} && {!isNil "_grp"} && {_grp isEqualType grpNull}) then {_placeGrp = _grp};
		if (!isNull _placeGrp) then {[_placeGrp, _beh, _cmd] call MCC_fnc_applyPlaceBehaviour};
		MCC_lastSpawn set [count MCC_lastSpawn,_dummy];
		publicVariable "MCC_lastSpawn";
	};
};

MCC_mccFunctionDone = true;
publicvariable "MCC_mccFunctionDone";
