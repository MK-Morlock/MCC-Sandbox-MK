private _unitspawned = grpNull;
private _dummy = nil;
private _vehicleClass = "";
private "_tempInit";
params ["_pos", "_dir", "_class", "_type", "_faction", "_notEmpty", "_init", "_name", "_loc", ["_align", false, [false]], ["_beh", "hold", [""]], ["_cmd", false, [false]]];

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
					[[netid _dummy,_dummy], _init, false] remoteExec ["MCC_fnc_setVehicleInit", 0, true];

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
					[[netid _dummy,_dummy], _init, false] remoteExec ["MCC_fnc_setVehicleInit", 0, true];

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

						_veh = createvehicle [_class,_pos,[],0,"none"];
						_veh setpos _pos;
						_veh setdir _dir;
						if (_align) then {_veh setVectorUp (surfaceNormal _pos)};
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
						if (!_align) then
						{
							(_dummy select 0) setpos _pos;
							_tempInit= _tempInit +	FORMAT [";_this setpos %1;",_pos];
						};

						(_dummy select 0) setVariable ["vehicleinit", _tempInit, true];


						[[netid (_dummy select 0),(_dummy select 0)], _init] remoteExec ["MCC_fnc_setVehicleInit", 0, true];

						//Curator
						{_x addCuratorEditableObjects [[(_dummy select 0)],true]} forEach allCurators;
					}
					else
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
						[[netid _dummy,_dummy], _init] remoteExec ["MCC_fnc_setVehicleInit", 0, true];

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
					[[netid _dummy,_dummy], _init] remoteExec ["MCC_fnc_setVehicleInit", 0, true];

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
					[[netid _dummy,_dummy], _init] remoteExec ["MCC_fnc_setVehicleInit", 0, true];

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
