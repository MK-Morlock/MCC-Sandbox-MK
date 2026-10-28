//===================================================================MCC_fnc_saveToComp=========================================================================================
// Save MCC's 3D editor placments in a composition's format to clipboard and RPT file
// Example: [] call MCC_fnc_saveToComp
// Params:
// 	<_anchorPos = referance position>
// Returns:
//     <Nothing>
//==============================================================================================================================================================================	
 private "_obj";
 private "_type";
 private _mission = "";
 private "_objPos";
 private "_dX";
 private "_dY";
 private "_z";
 private "_azimuth";
 private "_fuel";
 private "_damage";
 private "_vehicleinit";
 private _sim = "";
 private "_br";
 private _start = false;
 
params ["_anchorPos"];
_br = toString [0x0D, 0x0A];
_start = true; 

if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "###########################################"};
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "# Log: MCC_fnc_saveToComp : StartGrabbing #"};
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "###########################################"};

_mission = "[" + _br; 

if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text "["};
private _saveObjs = [];
{
	if (_x isEqualType []) then {
		_saveObjs pushBack (_x select 0);
		_saveObjs append ((_x param [1, []]) select {_x isEqualType objNull});
	} else {
		_saveObjs pushBack _x;
	};
} forEach MCC_lastSpawn;
{
	_obj = _x;
	

	_type = typeOf _obj;
     
	//Exclude human objects.
	_sim = getText (configFile >> "CfgVehicles" >> _type >> "simulation");
	if (!(_sim in ["soldier"]) && (_obj distance _anchorPos < 200)) then
	{
		_objPos = position _obj;
		_dX = (_objPos select 0) - (_anchorPos select 0);
		_dY = (_objPos select 1) - (_anchorPos select 1);
		_z = _objPos select 2;
		_azimuth = direction _obj;
		_fuel = fuel _obj;
		_damage = damage _obj;
		_vehicleinit = if (isnil {_obj getvariable "vehicleinit"}) then {{}} else {_obj getvariable "vehicleinit";};
		if (_start) then
		{
			if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text(format ["    %1", [_type, [_dX, _dY, _z], _azimuth, _fuel, _damage, _vehicleinit]])};
			_mission = _mission + (format ["    %1", [_type, [_dX, _dY, _z], _azimuth, _fuel, _damage, _vehicleinit]]) + _br;
			_start = false; 
		}
		else
		{
			if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text(format ["    ,%1", [_type, [_dX, _dY, _z], _azimuth, _fuel, _damage, _vehicleinit]])};
			_mission = _mission + (format ["    ,%1", [_type, [_dX, _dY, _z], _azimuth, _fuel, _damage, _vehicleinit]]) + _br;
		};
	};
} foreach _saveObjs;

_mission = _mission + "]";

if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text "];"};

if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "###########################################"};
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "# Log: MCC_fnc_saveToComp : EndGrabbing   #"};
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "###########################################"};

copyToClipboard _mission;
systemchat "Objects saved to the clipboard and written to the RPT file in composition format";
_mission;