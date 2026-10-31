/*=================================================MCC_fnc_MWSpawnStatic=========================================================================================================
	Spawn infantry groups in the zone.
	Example:[_totalEnemyUnits,_missionCenter,_radius,_arrayUnits,_priceGroup,_priceUnit,_side,_artillery] call MCC_fnc_MWSpawnStatic;
	Return - handler
================================================================================================================================================================================*/
private _unitPlaced = 0;
private _group = grpNull;
private _perSpawn = 0;
private _spawnPos = [];
private _marker = "";
private _pos = [];
private _availablePos = [];
private _vehicleClass = "";
private _vehicle = [];
private _time = 0;
params [
	["_totalEnemyUnits", 0, [0]],
	["_missionCenter", [0,0,0], [[]]],
	["_radius", 0, [0]],
	["_arrayUnits", [], [[]]],
	["_priceGroup", 0, [0]],
	["_priceUnit", 0, [0]],
	["_side", sideUnknown, [sideUnknown]],
	["_artillery", 0, [0]],	///0 - none, 1 - mortar, 2 - self propelled artillery, 3 - Random, 999 - not artillery piece
	["_zone", 0, [0, ""]],
	["_enableMarkers", false, [false]]
];

_unitPlaced = 0;

//We have an artillery piece
if (_artillery != 999) then	{
	private _facMortars = ((_arrayUnits select {_x isEqualType [] && {count _x > 1}}) apply {_x select 1}) select {_x isKindOf "StaticMortar"};
	switch (_side) do  {
		case west: {_arrayUnits = ["B_Mortar_01_F","B_MBT_01_arty_F"]};
		case east: {_arrayUnits = ["O_Mortar_01_F","O_MBT_02_arty_F"]};
		case resistance: {_arrayUnits = ["I_Mortar_01_F","I_Mortar_01_F"]};
		default {_arrayUnits = ["B_Mortar_01_F","B_MBT_01_arty_F"]};
	};

	_vehicleClass = if (_artillery != 3) then {_arrayUnits select (_artillery-1)} else {_arrayUnits call BIS_fnc_selectRandom};
	if ((_vehicleClass isKindOf "StaticMortar") && {count _facMortars > 0}) then {_vehicleClass = selectRandom _facMortars};
	_perSpawn = 2;
} else {
	_arrayUnits = _arrayUnits select {
		private _c = _x select 1;
		(getNumber (configFile >> "CfgVehicles" >> _c >> "artilleryScanner") == 0)
		&& {(["StaticMGWeapon", "StaticGrenadeLauncher", "StaticATWeapon", "StaticAAWeapon"] findIf {_c isKindOf _x}) >= 0}
		&& {(["SAM_System_01_base_F", "SAM_System_02_base_F", "SAM_System_03_base_F", "SAM_System_04_base_F", "Radar_System_01_base_F", "Radar_System_02_base_F"] findIf {_c isKindOf _x}) < 0}
		&& {((toLower getText (configFile >> "CfgVehicles" >> _c >> "displayName")) find "radar") < 0}
		&& {(["sam_system", "radar_system"] findIf {((toLower getText (configFile >> "CfgVehicles" >> _c >> "model")) find _x) >= 0}) < 0}
	};
	_vehicleClass = if (count _arrayUnits > 0) then {(selectRandom _arrayUnits) select 1} else {""};
	_perSpawn = 1;
};

_availablePos = (selectBestPlaces [_missionCenter, _radius, "meadow * (2*hills)", 10, 40]) call BIS_fnc_arrayShuffle;
if (isNil "MCC_MWStaticUsed") then {MCC_MWStaticUsed = []};

if (count _arrayUnits > 0) then {

	_time = time + 15;

	while {(_unitPlaced < (_totalEnemyUnits)) && (count _availablePos > 0) && (time < _time)} do {

		_pos = [((_availablePos select 0) select 0) select 0, ((_availablePos select 0) select 0) select 1,0];
		_availablePos set [0, -1];
		_availablePos = _availablePos - [-1];
		MCC_MWStaticUsed = MCC_MWStaticUsed select {(_x isEqualType []) && {!isNull (_x select 1)} && {alive (_x select 1)}};
		if ((MCC_MWStaticUsed findIf {((_x select 0) distance2D _pos) < 35}) >= 0) then {continue};
		if (_artillery == 999) then {_vehicleClass = (selectRandom _arrayUnits) select 1};
		_group = createGroup _side;

		//Spawn the static pieces
		for "_x" from 1 to _perSpawn step 1 do {
			_radius = 40;
			_spawnPos = [_pos, _vehicleClass, 60] call MCC_fnc_clearVehicleSpot;
			if (count _spawnPos == 0) then {_spawnPos = _pos findEmptyPosition [20,_radius,_vehicleClass]};

			while {count _spawnPos == 0} do {
				_radius = _radius +40;
				_spawnPos = _pos findEmptyPosition [20,_radius,_vehicleClass];
				sleep 0.1;
			};

			_vehicle = [_spawnPos, (random 360), _vehicleClass, _group] call MCC_fnc_spawnVehicle;
			MCC_MWStaticUsed pushBack [_spawnPos, _vehicle select 0];
			{_x addCuratorEditableObjects [[_vehicle select 0],true]} forEach allCurators;
			(_vehicle select 2) setVariable ["GAIA_ZONE_INTEND",[str _zone,"NOFOLLOW"], true];
		};

		//Add a markers to artiilery
		if (getNumber (configfile >> "CfgVehicles" >> _vehicleClass >> "artilleryScanner") > 0 && _enableMarkers) then {

			private _markers = [];
			private _range = 50 + (random 200);
			_pos = (_pos getPos [_range,random 360]);
			_marker = createMarker [format ["MCC_MWArtillery_%1",(["MCC_MWArtilleryMarkerCounter",1] call BIS_fnc_counter)],_pos];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "mil_warning";
			_marker setMarkerColor "ColorRed";
			_marker setMarkerText "Artillery";

			_markers pushBack _marker;

			_marker = createMarker [format ["MCC_MWArtillery_%1",(["MCC_MWArtilleryMarkerCounter",1] call BIS_fnc_counter)],_pos];
			_marker setMarkerShape "ELLIPSE";
			_marker setMarkerType "hd_marker";
			_marker setMarkerColor "ColorRed";
			_marker setMarkerBrush  "DiagGrid";
			_marker setMarkerSize [_range, _range];

			_markers pushBack _marker;

			[_group,_markers] spawn {
				params ["_group","_markers"];

				while {(alive leader _group) && (vehicle leader _group != leader _group)} do {sleep 60};

				{deleteMarker _x} foreach _markers;
			};
		};

		_unitPlaced = _unitPlaced + (_priceUnit*_perSpawn);
	};
} else {
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC: Mission Wizard Error: No vehicles available in the selected enemy faction"};
};
_unitPlaced;





