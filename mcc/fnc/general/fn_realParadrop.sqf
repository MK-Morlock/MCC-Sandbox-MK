private _spawn = [];
private _away = [];
private _plane = [];
private _pilot = objNull;
private _wp = [];
private _isHalo = 0;
private _flightHight = 0;
private _unitsArray = [];
private _unit = objNull;
private _chockArray = [];
private _heliClass = configNull;
private _pod = "";
private _fnc_findVehicles = {};
params ["_pos", "_units", "_UMUnit"];
_isHalo		= param [3,0,[0]];
_spawn		= _this select 4;
_away		= _this select 5;
(param [6, [], [[]]]) params [["_pdPara", "", [""]], ["_pdHalo", "", [""]], ["_pdH", 300, [0]], ["_pdOpenP", [0, 120], [[]]], ["_pdOpenH", [0, 120], [[]]], ["_pdForm", true, [true]], ["_pdLead", true, [true]]];
// Drop pods (MK): the method (0 = parachuted, 1 = winch drop) and the pod ("bench" - 8 seats, open; "covered" - the
// transport pod, 16 seats, enclosed) come with the drop; older callers fall back to the shared settings.
(param [7, [], [[]]]) params [["_podMethodP", -1, [0]], ["_podTypeP", "", [""]]];
//(MK) Pickup (MCCMK_fnc_taruPickup): Tarus already loaded at an LZ - [[Taru, pod, the men aboard], ...] - used instead of
// new ones (no boarding, no cut-scene), and a route flown first (round the mission areas, to the line-up point)
private _preset = param [8, [], [[]]];
private _preRoute = param [9, [], [[]]];
private _dd = param [10, [], [[]]];	//(MK) the drop id [id, owner] - its green dot goes when the men are all on the ground
private _podType = if (_podTypeP != "") then {_podTypeP} else {missionNamespace getVariable ["MCC_podType", "bench"]};
if !(_podType in ["bench", "covered"]) then {_podType = "bench"};

if (count _units == 0) exitWith {};

//Drop line: [start, end] from the MCC console (older callers pass one position)
private _lineA = [];
private _lineB = [];
if ((_pos param [0, 0]) isEqualType []) then {
	_lineA = +(_pos select 0); _lineB = +(_pos param [1, _pos select 0]);
} else {
	_lineA = +_pos; _lineB = +_pos;
};
_lineA = [_lineA select 0, _lineA select 1, 0];
_lineB = [_lineB select 0, _lineB select 1, 0];
private _lineLen = _lineA distance2D _lineB;
private _lineDir = if (_lineLen > 5) then {_lineA getDir _lineB} else {_spawn getDir _away};
if (_lineLen <= 5) then {_lineB = _lineA getPos [1, _lineDir]; _lineB set [2, 0]};
_pos = _lineA;
private _relA = +_lineA;
private _relB = +_lineB;
private _windV = [(wind select 0), (wind select 1), 0];
if (_isHalo == 2) then {
	private _carry = missionNamespace getVariable ["MCC_haloCarry", 550];
	private _wTime = missionNamespace getVariable ["MCC_haloWindTime", 60];
	private _shift = ([sin _lineDir, cos _lineDir, 0] vectorMultiply (-_carry)) vectorAdd (_windV vectorMultiply (-_wTime));
	_relA = _lineA vectorAdd _shift; _relA set [2, 0];
	_relB = _lineB vectorAdd _shift; _relB set [2, 0];
	private _r = _relA vectorDiff _lineA;
	["INFO", "paradrop", "HALO plan | wind %1 m/s from %2 | carry %3 m, wind time %4 s | release point: along %5 m side %6 m from the line start",
		[round ((vectorMagnitude _windV) * 10) / 10, round (((_windV select 0) atan2 (_windV select 1)) + 180) mod 360, _carry, _wTime,
		 round ((_r select 0) * (sin _lineDir) + (_r select 1) * (cos _lineDir)), round ((_r select 0) * (cos _lineDir) - (_r select 1) * (sin _lineDir))]] call MCC_fnc_log;
};
if (_isHalo == 0) then {
	private _carry = missionNamespace getVariable ["MCC_paraCarry", 350];
	private _shift = [sin _lineDir, cos _lineDir, 0] vectorMultiply (-_carry);
	_relA = (_lineA getPos [(_lineA distance2D _lineB) / 2, _lineDir]) vectorAdd _shift; _relA set [2, 0];
	_relB = _lineB vectorAdd _shift; _relB set [2, 0];
	["INFO", "paradrop", "PARA plan | release point moved back %1 m from the middle of the line, so the leaders land on it", [_carry]] call MCC_fnc_log;
};
_spawn = _relA getPos [[5000, 8000] select (_isHalo == 2), _lineDir + 180]; _spawn set [2, 0];
_away = _relB getPos [2500, _lineDir]; _away set [2, 0];
if (_isHalo == 2) then {_away = _relA getPos [5500, _lineDir]; _away set [2, 0]};


private _haloPlayer = false;
{if (isPlayer _x) then {_haloPlayer = true}} forEach (if (_UMUnit == 0) then {_units} else {private _all = []; {_all append (units _x)} forEach _units; _all});
private _podAssault = (_isHalo == 1) && {(if (_podMethodP >= 0) then {_podMethodP} else {missionNamespace getVariable ["MCC_podMethod", 0]}) == 1};
_flightHight = switch (_isHalo) do
				{
					case 1:{[400, 30] select _podAssault};
					case 2:{[4000, 4950] select _haloPlayer};
					default{_pdH max 50};
				};

_spawn set [2,(_spawn select 2) + _flightHight];
_away set [2,(_away select 2) + _flightHight];
_unitsArray	= [];
_chockArray = [];
private _load = if (_isHalo == 1) then {private _n = [["MCC_podBench", "MCC_podCovered"] select (_podType == "covered"), "allCargo"] call MCC_fnc_crewCount; [[8, 16] select (_podType == "covered"), _n] select (_n > 0)} else {16};
private _pdCl = [_pdPara, "", _pdHalo] param [_isHalo, ""];
if (_pdCl != "" && {!isClass (configFile >> "CfgVehicles" >> _pdCl)}) then {_pdCl = ""};
if (_pdCl != "") then {_load = ((([_pdCl, "allCargo"] call MCC_fnc_crewCount) min _load) max 1)};

//units
if (_UMUnit==0) then {
	{
		_unitsArray pushBack _x;
		if (count _unitsArray >= _load) then {
			_chockArray pushBack _unitsArray;
			_unitsArray	= [];
		};
	} foreach _units;
} else {
	{
		{
			_unitsArray pushBack _x;
			if (count _unitsArray >= _load) then {
				_chockArray  pushBack _unitsArray;
				_unitsArray	= [];
			};
		} foreach (units _x);
	} foreach _units;
};

//Drop pods need a Taru-family helicopter: the faction own one first, the CSAT Taru otherwise
private _podFaction = if ((_units select 0) isEqualType grpNull) then {faction leader (_units select 0)} else {faction (_units select 0)};
private _podCarriers = [_podFaction, "podCarrier"] call MCC_fnc_factionVehicles;
private _sideL = ["O", "B", "I", "B"] select (([east, west, independent, civilian] find (side (_units select 0))) max 0);
private _black = (missionNamespace getVariable [format ["MCC_taruLivery%1", _sideL], 0]) == 1;
private _podCarrierPick = {
	private _m = _podCarriers select {(((toUpper _x) find "BLACK") >= 0) isEqualTo _black};
	if (count _m > 0) exitWith {selectRandom _m};
	if (count _podCarriers > 0) exitWith {selectRandom _podCarriers};
	private _own = format ["MCC_%1_Heli_Transport_04%2_F", _sideL, ["", "_black"] select _black];
	if (isClass (configFile >> "CfgVehicles" >> _own)) exitWith {_own};
	["O_Heli_Transport_04_F", "O_Heli_Transport_04_black_F"] select _black
};
_heliClass = if (_isHalo == 1) then  {call _podCarrierPick} else {
				switch (true) do
				{
					case (side (_units select 0) == east && (isClass(configFile >> "CfgVehicles" >> "O_T_VTOL_02_infantry_F"))):{"O_T_VTOL_02_infantry_F"};

					case (side (_units select 0) == west && (isClass(configFile >> "CfgVehicles" >> "B_T_VTOL_01_infantry_F"))):{"B_T_VTOL_01_infantry_F"};

					default{"I_Heli_Transport_02_F"};
				};
			};

if (_isHalo == 2 && {(missionNamespace getVariable ["MCC_haloAircraft", ""]) != "MCC_ORIGINAL"}) then {
	private _sideN = [east, west, independent, civilian] find (side (_units select 0));
	private _nMen = if (_UMUnit == 0) then {count _units} else {private _c = 0; {_c = _c + count (units _x)} forEach _units; _c};
	private _need = (_load min _nMen) max 1;
	private _best = [_podFaction, side (_units select 0), _need] call MCC_fnc_haloAutoAircraft;
	if (_best != "") then {
		_heliClass = _best;
		["INFO", "paradrop", "HALO aircraft: %1 (%2, faction %3)", [_best, getText (configFile >> "CfgVehicles" >> _best >> "displayName"), getText (configFile >> "CfgVehicles" >> _best >> "faction")]] call MCC_fnc_log;
	};
};

//Add the last chock even if it isn't full
if (count _unitsArray > 0) then {_chockArray pushBack _unitsArray};
if (_isHalo == 2 && {!_pdLead} && {!(_pdForm && {missionNamespace getVariable ["MCC_haloFormation", true]})}) then {
	_chockArray = _chockArray apply {
		private _s = +_x;
		private _li = _s findIf {isPlayer _x && {leader group _x == _x}};
		if (_li >= 0 && {count _s > 1}) then {
			private _p = _s deleteAt _li;
			private _ni = floor random ((count _s) + 1);
			_s = (_s select [0, _ni]) + [_p] + (_s select [_ni]);
			["INFO", "paradrop", "HALO lead first off: %1 jumps %2 of %3", [name _p, _ni + 1, count _s]] call MCC_fnc_log;
		};
		_s
	};
};
private _stickMids = [];
if (_isHalo == 0) then {
	_chockArray = _chockArray apply {
		private _stick = _x;
		private _grps = [];
		{_grps pushBackUnique (group _x)} forEach _stick;
		private _info = _grps apply {
			private _g = _x;
			private _mem = _stick select {group _x == _g};
			private _ld = if ((leader _g) in _mem) then {leader _g} else {_mem select 0};
			[count _mem, _ld, _mem - [_ld]]
		};
		_info = [_info, [], {_x select 0}, "DESCEND"] call BIS_fnc_sortBy;
		private _left = [];
		private _right = [];
		private _leaders = [];
		{
			_x params ["_n", "_ld", "_rest"];
			private _h = floor ((count _rest) / 2);
			_left append (_rest select [0, _h]);
			_right = (_rest select [_h]) + _right;
			_leaders pushBack _ld;
		} forEach _info;
		_stickMids pushBack ((count _left) + ((count _leaders) - 1) / 2);
		["DEBUG", "paradrop", "PARA stick order: %1 (leaders %2 in the middle)", [(_left + _leaders + _right) apply {name _x}, _leaders apply {name _x}]] call MCC_fnc_log;
		_left + _leaders + _right
	};
};

_fnc_findVehicles = {
	params ["_choke","_classA","_classB"];
	//Try to find an helicopter from the faction
	private _minSpaces = 0;
	private _vehiclesTypesArray = [];
	private _availableSpaces = [];
	private _newHeliClassesArray = [];
	private _faction = "";
	private _return = "";
	_minSpaces = count (_chockArray select 0);
	_faction = faction ((_chockArray select 0) select 0);
	_return = "";
	//The units own faction first, then the other factions of the same mod and side (vanilla aircraft only as the last resort)
	{
		private _f = _x;
		_vehiclesTypesArray = [_f,"helicopterrtd","air"] call MCC_fnc_makeUnitsArray;
		if (count _vehiclesTypesArray < 2) then {
			_vehiclesTypesArray = [_f,"helicopterrtd"] call MCC_fnc_makeUnitsArray;
		};
		_vehiclesTypesArray = _vehiclesTypesArray + ([_f,"helicopterX"] call MCC_fnc_makeUnitsArray);
		if ((_vehiclesTypesArray findIf {([_x select 0, "allCargo"] call MCC_fnc_crewCount) >= _minSpaces}) >= 0) exitWith {};
	} forEach ([_faction] + ([_faction] call MCC_fnc_factionSiblings));

	_newHeliClassesArray = [];

	for "_i" from 0 to (count _vehiclesTypesArray)-1 step 1 do {
		_vehicleClass = (_vehiclesTypesArray select _i) select 0;
	    _availableSpaces = [_vehicleClass, "allCargo"] call MCC_fnc_crewCount;

		//if enogh cargo space add it
		if ( _availableSpaces >= _minSpaces) then {
			_newHeliClassesArray pushBack [_availableSpaces, _vehicleClass]
		};
	};

	if (count _newHeliClassesArray > 0) then {
		_newHeliClassesArray sort true;
		_return = (_newHeliClassesArray select 0) select 1;
	};

	_return
};

if (_isHalo == 0) then  {
	_heliClass = [faction ((_chockArray select 0) select 0), side ((_chockArray select 0) select 0), count (_chockArray select 0)] call MCC_fnc_paraAutoAircraft;
};

//Landing spot for each jumper: spread along the drawn line (parachute), or close around the start point (HALO)
private _fnc_targets = {
	params ["_n"];
	private _t = [];
	for "_i" from 0 to (_n - 1) do {
		if (_isHalo == 2 || {_lineLen < 30}) then {
			_t pushBack (if (_i == 0) then {_lineA} else {_lineA getPos [6 + 4 * floor (_i / 6), _i * 60]});
		} else {
			_t pushBack (_lineA getPos [_lineLen * ((_i + 0.5) / _n), _lineDir]);
		};
	};
	_t
};

//Aircraft chosen on the console Assets page win (drop pods / paradrops)
if (_isHalo == 1 && {missionNamespace getVariable ["MCC_assetCustom_MCC_assetPodCarrier", false]}) then {_heliClass = selectRandom (missionNamespace getVariable ["MCC_assetPodCarrier", [_heliClass]])};
if (_isHalo != 1 && {missionNamespace getVariable ["MCC_assetCustom_MCC_assetParadrop", false]}) then {_heliClass = selectRandom (missionNamespace getVariable ["MCC_assetParadrop", [_heliClass]])};
if (_isHalo == 2) then {
	private _hc = missionNamespace getVariable ["MCC_haloAircraft", ""];
	if (_hc != "" && {_hc != "MCC_ORIGINAL"}) then {
		private _nMen = if (_UMUnit == 0) then {count _units} else {private _c = 0; {_c = _c + count (units _x)} forEach _units; _c};
		if (isClass (configFile >> "CfgVehicles" >> _hc) && {([_hc, "allCargo"] call MCC_fnc_crewCount) >= ((_load min _nMen) max 1)}) then {
			_heliClass = _hc;
			["INFO", "paradrop", "HALO aircraft from the MCC options: %1 (%2)", [_hc, getText (configFile >> "CfgVehicles" >> _hc >> "displayName")]] call MCC_fnc_log;
		} else {
			["WARN", "paradrop", "HALO aircraft in the MCC options (%1) is not installed or has too few seats for the stick - automatic choice used", [_hc]] call MCC_fnc_log;
		};
	};
};
if (_pdCl != "") then {
	_heliClass = _pdCl;
	["DEBUG", "paradrop", "aircraft chosen in the Paradrop panel: %1 (%2 seats, sticks of %3)", [_pdCl, [_pdCl, "allCargo"] call MCC_fnc_crewCount, _load]] call MCC_fnc_log;
};

if (_preset isNotEqualTo []) then {_chockArray = _preset apply {_x select 2}};	//(MK) Pickup: the men as they boarded
if (count _dd == 2) then {missionNamespace setVariable [format ["MCCMK_ddN_%1", _dd select 0], count _chockArray]};
{
	_unitsArray = _x;
	private _pre = _preset param [_forEachIndex, []];	//(MK) Pickup: this stick's loaded Taru and pod
	private _podOff = if (_isHalo == 1 && {count _chockArray > 1}) then {
		_forEachIndex * ((_lineLen max 30) / ((count _chockArray) - 1))
	} else {0};

	//Spawn plane 1
	_plane = if (_pre isNotEqualTo []) then {_pre select 0} else {[_heliClass, _spawn, _pos, _flightHight,true,civilian] call MCC_fnc_createPlane};

	// The aircraft (drop pod Taru, paradrop or HALO plane): flown by the troops' faction's own pilots (the side's vanilla
	// ones as a last resort), in the same group as created.
	if (_pre isEqualTo []) then {
		[_plane, _podFaction] call MCCMK_fnc_factionCrew;
		//(MK) the "Support aircraft" options (the side of the faction it flies for)
		[_plane, (getNumber (configFile >> "CfgFactionClasses" >> _podFaction >> "side")) call BIS_fnc_sideType, "Paradrop aircraft"] call MCCMK_fnc_supportAir;
	};
	_pilot = driver _plane;
	(group _pilot) setVariable ["MCC_dropFor", side group (_unitsArray select 0), true];
	_plane allowCrewInImmobile true;

	if (_isHalo == 1 && {_pre isNotEqualTo []}) then {	//(MK) Pickup: its pod is already slung
		_pod = _pre select 1;
		_plane setVariable ["MCC_attachedPod", _pod, true];
	};
	if (_isHalo == 1 && {_pre isEqualTo []}) then {
		if (side (_units select 0) != east) then {
			_null = _plane execVM "\a3\Air_F_Heli\Heli_Transport_04\Scripts\Heli_Transport_04_basic_black.sqf";
		};

		_pod = (([["MCC_podBench", "MCC_podBench_black"], ["MCC_podCovered", "MCC_podCovered_black"]] select (_podType == "covered")) select (((toUpper _heliClass) find "BLACK") >= 0)) createVehicle [0,0,0];
		_pod setPosASL ((getPosASL _plane) vectorAdd [0, 0, -6]);
		if (false) then {
			["INFO", "paradrop", "drop pod docked on the sling of %1", [typeOf _plane]] call MCC_fnc_log;
		} else {
			_pod attachto [_plane,[0,0,-1.2]];
			[_pod, _plane] remoteExecCall ["disableCollisionWith", 0, _pod];	//(MK) the pod can't bump the Taru while attached
			_plane setVariable ["MCC_attachedPod",_pod,true];
			[_pod,_plane] spawn {
				private _pod = _this select 0;
				private _vehicle = _this select 1;
				while {!(isNull attachedTo _pod) && alive _pod} do {if !(alive _vehicle) then {_pod setDamage 1;detach _pod};sleep 0.5};
			};
		};
	} else {
		if (_heliClass == "I_Heli_Transport_02_F") then {
			switch (side (_units select 0)) do
			{
				case east:
				{
					_plane setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
					_plane setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
					_plane setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
				};

				case west:
				{
					_plane setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
					_plane setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
					_plane setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
				};
			};
		};

		_plane lock true;
	};


	if (_pre isEqualTo []) then {
		_plane setDir _lineDir;
		private _v0 = if (_plane isKindOf "Helicopter") then {60} else {120};
		_plane setVelocity [(sin _lineDir) * _v0, (cos _lineDir) * _v0, 0];
	} else {
		// Pickup: off the LZ - its landing order and the waypoints that brought it there cleared
		_plane setVariable ["MCCMK_pickupDrop", true, true];	// (MCC_fnc_realParadropPlayer: no fade, no cut-scene)
		_plane land "NONE";
		for "_w" from (count waypoints (group _plane)) - 1 to 0 step -1 do {deleteWaypoint [group _plane, _w]};
	};
	//Set plane variables
	_plane flyInHeight _flightHight;
	_plane setVariable ["MCCJumperNumber",-1,true];																		//Number of unit to jump
	_plane setVariable ["MCCisHALO",_isHalo,true];
	_plane setVariable ["MCC_haloFormOn", _pdForm, true];
	_plane setVariable ["MCCjumpReady",false,true];
	_plane setVariable ["MCC_dropTargets", [count _unitsArray] call _fnc_targets, true];
	_plane setVariable ["MCC_stickMid", _stickMids param [_forEachIndex, 0]];
	_plane setVariable ["MCC_dropLine", [_lineA, _lineDir, _isHalo], true];
	_plane setVariable ["MCC_haloStick", +_unitsArray, true];
	//HALO formation followers (every AI but the first, up to 12 in all): they are flown to the ring, so they skip the
	{_x setVariable ["MCC_haloFollower", false, true]; _x setVariable ["MCC_haloFormMember", false, true]; _x setVariable ["MCC_haloChuteAlt", nil, true]} forEach _unitsArray;
	if (_isHalo == 2 && {_pdForm} && {missionNamespace getVariable ["MCC_haloFormation", true]}) then {
		private _ais = _unitsArray select {!isPlayer _x};
		if ((_unitsArray findIf {isPlayer _x}) >= 0) then {
			{_x setVariable ["MCC_haloFollower", true, true]; _x setVariable ["MCC_haloFormMember", true, true]} forEach (_ais select [0, 11]);
		} else {
			if (count _ais >= 2) then {{_x setVariable ["MCC_haloFollower", true, true]} forEach (_ais select [1, 11]); {_x setVariable ["MCC_haloFormMember", true, true]} forEach (_ais select [0, 12])};
		};
	};
	//HALO: each jumping group gets a MOVE waypoint at the start of the red line (the aim point), behaviour AWARE,
	//speed FULL, formation unchanged; its old waypoints are removed so this is the one they follow after landing
	if (_isHalo in [0, 1, 2]) then {
		private _wpPos = if (_isHalo == 1) then {
			private _ll = _lineA distance2D _lineB;
			private _mine = _podOff;
			private _wpAlong = _mine;
			if (_podAssault) then {
				private _nA = count _chockArray;
				private _alongs = [];
				for "_i" from 0 to (_nA - 1) do {
					_alongs pushBack (if (_nA == 1) then {0} else {_i * ((_ll max 30) / (_nA - 1))});
				};
				private _prev = 0;
				{if (_x < _mine - 0.5 && {_x > _prev}) then {_prev = _x}} forEach _alongs;
				_wpAlong = if ((_mine - _prev) < 20) then {_mine - 25} else {(_mine + _prev) / 2};
			};
			_lineA getPos [_wpAlong, _lineDir]
		} else {if (_isHalo == 0) then {_lineA getPos [(_lineA distance2D _lineB) / 2, _lineDir]} else {_lineA}};
		_wpPos = [_wpPos select 0, _wpPos select 1, 0];
		private _grps = [];
		{_grps pushBackUnique (group _x)} forEach _unitsArray;
		_grps = _grps select {(units _x) findIf {isPlayer _x} < 0};
		{
			private _g = _x;
			private _gi = _g getVariable ["GAIA_ZONE_INTEND", []];
			if (count _gi > 0) then {
				_g setVariable ["MCC_dropGaia", _gi, true];
				_g setVariable ["GAIA_ZONE_INTEND", [], true];
			};
			for "_w" from (count waypoints _g - 1) to 0 step -1 do {deleteWaypoint [_g, _w]};
			private _gw = _g addWaypoint [_wpPos, 0];
			_gw setWaypointType "MOVE";
			_gw setWaypointBehaviour "AWARE";
			_gw setWaypointSpeed "FULL";
			_gw setWaypointStatements ["true", "private _gg = group this; private _back = _gg getVariable ['MCC_dropGaia', []]; if (count _back > 0) then {_gg setVariable ['GAIA_ZONE_INTEND', _back, true]; _gg setVariable ['MCC_dropGaia', nil, true]};"];
			_g setCurrentWaypoint _gw;
			[_g, _gw, _wpPos] spawn {
				params ["_g", "_gw", "_wp"];
				private _st = waypointStatements _gw;
				private _t = time + 600;
				waitUntil {sleep 2; isNull _g || {time > _t} || {((units _g) select {alive _x}) findIf {vehicle _x != _x || {((getPosATL _x) select 2) > 2}} < 0}};
				if (isNull _g || {({alive _x} count units _g) == 0}) exitWith {};
				sleep 1;
				private _l = leader _g;
				if ((currentWaypoint _g) >= (count waypoints _g) && {(_l distance2D _wp) > 10}) then {
					private _nw = _g addWaypoint [_wp, 0];
					_nw setWaypointType "MOVE";
					_nw setWaypointBehaviour "AWARE";
					_nw setWaypointSpeed "FULL";
					_nw setWaypointCompletionRadius 5;
					_nw setWaypointStatements _st;
					_g setCurrentWaypoint _nw;
					["DEBUG", "paradrop", "WAYPOINT re-issued | %1 | completed early with leader %2 m away - sent on to it again", [groupId _g, round (_l distance2D _wp)]] call MCC_fnc_log;
				};
			};
			if (missionNamespace getVariable ["MCC_debug", false]) then {
				[_g, _gw, _wpPos] spawn {
					params ["_g", "_gw", "_wp"];
					private _fnc_state = {
						params ["_g", "_wp", "_when"];
						private _l = leader _g;
						private _ci = currentWaypoint _g;
						private _cp = if (_ci < count waypoints _g) then {(waypointPosition [_g, _ci]) apply {round _x}} else {"none"};
						private _ed = expectedDestination _l;
						["DEBUG", "paradrop", "WAYPOINT %1 | %2 | leader %3 is %4 m from the move waypoint (bearing %5 from it) | current waypoint %6 of %7 at %8 | move waypoint now at %9 | leader heading for %10 (%11) | behaviour %12 | leader at %13, %14 km/h, stance %15, anim %16, command %17 | combat mode %18 | AI path %19 move %20 | members over 50 m from the leader: %21",
							[_when, groupId _g, name _l, round (_l distance2D _wp), round ((_wp getDir _l)), _ci, count waypoints _g, _cp, (waypointPosition [_g, _gw select 1]) apply {round _x}, (_ed param [0, [0,0,0]]) apply {round _x}, _ed param [1, "?"], behaviour _l, (getPosATL _l) apply {round _x}, round (speed _l), stance _l, animationState _l, currentCommand _l, combatMode _g, _l checkAIFeature "PATH", _l checkAIFeature "MOVE", ((units _g) select {alive _x && {(_x distance2D _l) > 50}}) apply {[name _x, round (_x distance2D _l), (getPosATL _x) apply {round _x}, behaviour _x, vehicle _x != _x]}]] call MCC_fnc_log;
					};
					["DEBUG", "paradrop", "WAYPOINT created | %1 | move waypoint %2 at %3", [groupId _g, _gw select 1, _wp apply {round _x}]] call MCC_fnc_log;
					private _t = time + 600;
					waitUntil {sleep 2; isNull _g || {time > _t} || {((units _g) select {alive _x}) findIf {vehicle _x != _x || {((getPosATL _x) select 2) > 2}} < 0}};
					if (isNull _g) exitWith {};
					for "_i" from 0 to 12 do {
						if (isNull _g || {({alive _x} count units _g) == 0}) exitWith {};
						[_g, _wp, if (_i == 0) then {"all landed"} else {format ["+%1 s", _i * 10]}] call _fnc_state;
						sleep 10;
					};
				};
			};
			["INFO", "paradrop", "%1 move waypoint for %2 at %4%3", [["PARA", "PODS", "HALO"] select _isHalo, groupId _g, ["", " (GAIA paused until it gets there)"] select (count _gi > 0), ["the line start", "its pod spot", "the middle of the line"] select ([[2, 1] select (_isHalo == 1), 0] select (_isHalo == 2))]] call MCC_fnc_log;
			if (count _gi > 0) then {
				[_g] spawn {
					params ["_g"];
					private _back = {
						params ["_g", "_why"];
						private _gi = _g getVariable ["MCC_dropGaia", []];
						if (count _gi == 0) exitWith {};
						_g setVariable ["GAIA_ZONE_INTEND", _gi, true];
						_g setVariable ["MCC_dropGaia", nil, true];
						["INFO", "paradrop", "%1 handed back to GAIA (%2)", [groupId _g, _why]] call MCC_fnc_log;
					};
					private _t = time + 600;
					waitUntil {
						sleep 2;
						isNull _g || {count (_g getVariable ["MCC_dropGaia", []]) == 0} || {time > _t} ||
						{((units _g) select {alive _x}) findIf {vehicle _x != _x || {((getPosATL _x) select 2) > 2}} < 0}
					};
					if (isNull _g || {count (_g getVariable ["MCC_dropGaia", []]) == 0}) exitWith {};
					private _tLand = time;
					waitUntil {
						sleep 2;
						isNull _g || {count (_g getVariable ["MCC_dropGaia", []]) == 0} || {behaviour (leader _g) == "COMBAT"} || {time > _tLand + 180}
					};
					if (isNull _g || {count (_g getVariable ["MCC_dropGaia", []]) == 0}) exitWith {};
					[_g, ["3 minutes after landing", "under fire"] select (behaviour (leader _g) == "COMBAT")] call _back;
				};
			};
		} forEach _grps;
	};
	MCC_planeNameCount = MCC_planeNameCount + 1;


	for "_x" from 0 to (count _unitsArray -1) step 1 do {
		_unit = _unitsArray select _x;
		_unit setVariable ["MCC_paraOpen", [_pdOpenP, [0, 0], _pdOpenH] param [_isHalo, [0, 0]], true];
		if (_pre isNotEqualTo [] && {_isHalo == 1}) then {continue};	//(MK) Pickup by Taru: already in the pod - nothing more (a paradrop's men still get their jump script - no fade or cut-scene)
		_null = [_plane, _unit,_x] remoteExec ["MCC_fnc_realParadropPlayer", _unit];
		private _tb = time + 20;
		waitUntil {sleep 0.1; (_unit in crew _plane) || {_unit in crew (_plane getVariable ["MCC_attachedPod", objNull])} || {!alive _unit} || {time > _tb}};
		if (time > _tb) then {["WARN", "paradrop", "%1 did not board %2 within 20 s - the drop goes on without him", [name _unit, typeOf _plane]] call MCC_fnc_log};
	};



	//(MK) this stick done when its men are all out and on the ground (or dead): the last stick takes the green dot away
	if (count _dd == 2) then {
		[+_unitsArray, _dd] spawn {
			params ["_men", "_dd"];
			private _t = time + 900;
			sleep 5;
			waitUntil {sleep 3; time > _t || {(_men findIf {alive _x && {(vehicle _x != _x) || {((getPosATL _x) select 2) > 2}}}) < 0}};
			private _k = format ["MCCMK_ddN_%1", _dd select 0];
			private _n = (missionNamespace getVariable [_k, 1]) - 1;
			missionNamespace setVariable [_k, _n];
			if (_n <= 0) then {[_dd, -1] call MCCMK_fnc_dropDone};
		};
	};
	if (_isHalo != 1) then {
		[_plane, _lineA] spawn {
			params ["_pl", "_at"];
			waitUntil {sleep 0.5; !alive _pl || {_pl getVariable ["MCC_haloReleased", false]} || {(_pl distance2D _at) < (((vectorMagnitude [(velocity _pl) select 0, (velocity _pl) select 1, 0]) * 30) max 1500)}};
			if (alive _pl) then {if (_pl isKindOf "Plane") then {[_pl, true] call MCCMK_fnc_aircraftRamp} else {[_pl, true] call MCCMK_fnc_rampOrDoors}};	//(MK) a helicopter: its ramp (side doors if it has none)
		};
	};
	_plane setVariable ["MCC_podOff", _podOff];
	private _podCarry = 0;
	_plane setVariable ["MCC_podCarry", _podCarry];
	_plane setVariable ["MCC_podAssault", _podAssault];

	//Waypoints along the drop line: start, end, then away, so the run-in follows the line
	{
		_wp = (group _plane) addWaypoint [_x, 0];
		//HALO: the release waypoint (at the release point) sets the release when Arma completes it: the release no
		_wp setWaypointStatements ["true", if (_isHalo != 0 && {if (_isHalo == 2) then {(_x distance2D _lineA) < 1} else {_forEachIndex == 0}}) then {"(vehicle this) setVariable ['MCC_haloReleaseWP', true, true];"} else {""}];
		_wp setWaypointType "MOVE";
		_wp setWaypointSpeed (["NORMAL", "FULL"] select (_podAssault || {((toUpper (typeOf _plane)) find "VTOL") >= 0}));
		_wp setWaypointCombatMode "BLUE";
		_wp setWaypointBehaviour "CARELESS";
		_wp setWaypointCompletionRadius (switch (_isHalo) do {case 2: {if ((_x distance2D _lineA) < 1) then {400} else {if ((((_x select 0) - (_lineA select 0)) * (sin _lineDir) + ((_x select 1) - (_lineA select 1)) * (cos _lineDir)) < 0) then {200} else {300}}}; case 1: {[300, 60] select (_forEachIndex == 0)}; default {[60, 100, 200] select ((2 - _forEachIndex) max 0)}});
	} forEach (((if (_pre isNotEqualTo []) then {_preRoute} else {[]}) apply {[_x select 0, _x select 1, 0]}) + (if (_isHalo == 2) then {
		//HALO: only two waypoints on the drop line, 2.5 km before the release point and 3 km past it, so the aircraft
		//Plain MOVE waypoints, Arma's own flying.
		private _pts = [];
		_pts = [_lineA, _lineA getPos [3000, _lineDir]];
		if (((toUpper (typeOf _plane)) find "VTOL_01") >= 0) then {
			private _mid = [];
			for "_k" from 1500 to ((_plane distance2D _lineA) - 1000) step 1500 do {_mid pushBack (_lineA getPos [_k, _lineDir + 180])};
			reverse _mid;
			_pts = _mid + _pts;
		};
		_pts apply {[_x select 0, _x select 1, 0]}
	} else {
		private _rp = if (_isHalo == 1) then {_lineA getPos [70 + _podOff - _podCarry, _lineDir]} else {_relA};
		private _pts = [];
		{_pts pushBack (_rp getPos [_x, _lineDir])} forEach ([[-1500, 0, 2000], [0, 2000]] select (_isHalo == 1));
		_pts apply {[_x select 0, _x select 1, 0]}
	}) + [_away]);
	_plane flyInHeight _flightHight;
	[_plane, _lineA, _lineDir] spawn {
		params ["_pl", "_la", "_ld"]; if !(missionNamespace getVariable ["MCC_debug", false]) exitWith {};
		private _fw = [sin _ld, cos _ld, 0]; private _rt = [cos _ld, -(sin _ld), 0];
		private _t = time + 240;
		while {alive _pl && {time < _t} && {(_pl getVariable ["MCCJumperNumber", -1]) < 0} && {!(_pl getVariable ["MCC_podReleased", false])}} do {
			private _o = (getPosASL _pl) vectorDiff (AGLToASL _la);
			private _v = velocity _pl;
			private _g = group _pl;
			private _ci = currentWaypoint _g;
			private _wo = (waypointPosition [_g, _ci]) vectorDiff _la;
			["INFO", "paradrop", "run-in | %1 | along %2 m side %3 m | height %4 m | heading %5 track %6 (line %7) | %8 km/h | to waypoint %9 of %10 (along %11 m side %12 m, %13 m away) | %14, %15",
				[typeOf _pl, round (_o vectorDotProduct _fw), round (_o vectorDotProduct _rt), round ((getPosATL _pl) select 2), round getDir _pl,
				 round (((_v select 0) atan2 (_v select 1) + 360) mod 360), round _ld, round (speed _pl), _ci, count waypoints _g,
				 round (_wo vectorDotProduct _fw), round (_wo vectorDotProduct _rt), round (_pl distance2D (waypointPosition [_g, _ci])), behaviour (driver _pl), combatMode _g]] call MCC_fnc_log;
			sleep 5;
		};
	};

	[_plane, _pos, _flightHight, _pilot, _away, _isHalo, _lineA, _lineB, _lineDir, _relA, _windV, +_unitsArray, +_pdOpenP] spawn {
		params ["_plane","_pos","_flightHight","_pilot","_away","_isHalo","_lineA","_lineB","_lineDir","_relA","_windV","_stick",["_pdOpenP", [0, 100]]];

		//Make them stand on the deck
		while {((_plane distance2d _relA) > 800) && (alive _plane)} do {sleep 1};

		//Ready for the jump
		_plane setVariable ["MCCjumpReady",true,true];
		if (_isHalo != 1) then {[_plane, true] call MCCMK_fnc_rampOrDoors};	//(MK) the ramp (side doors for a helicopter with none)

		//Go when the aircraft reaches the start of the line (or has just passed it); pods at the middle of the line
		private _podTgt = _lineA getPos [_plane getVariable ["MCC_podOff", 0], _lineDir];
		private _mark = if (_isHalo == 1) then {_podTgt getPos [-(_plane getVariable ["MCC_podCarry", 0]), _lineDir]} else {_relA};
		if (_isHalo == 1 && {_plane getVariable ["MCC_podAssault", false]}) exitWith {
			_plane setVariable ["MCC_podReleased", true];
			private _t0 = time;
			waitUntil {sleep 0.5; !alive _plane || {(_plane distance2D _podTgt) < 1000} || {time - _t0 > 240}};
			private _pod = _plane getVariable ["MCC_attachedPod", objNull];
			["INFO", "paradrop", "PODS assault | %1 | %2 m out - the Taru's own winch drop takes over (MCC_fnc_taruAI)", [typeOf _plane, round (_plane distance2D _podTgt)]] call MCC_fnc_log;
			// (MK) exactly as an AI Taru does it (MCC_fnc_taruAI "winch"): its approach and hover, the pod lowered on its
			// ropes (a clear spot found first), the troops out, the pod winched back up
			// the drop-line waypoints (full speed, on past the drop) cleared first, so the pilot isn't flying on to them while the
			// winch drop holds the Taru over the spot; he's sent to the spot instead, as an AI Taru on its own winch drop is
			// (the exit gets its own waypoint afterwards - MCC_fnc_haloPlaneExit).
			private _gp = group _plane;
			for "_w" from ((count waypoints _gp) - 1) to 0 step -1 do {deleteWaypoint [_gp, _w]};
			_plane doMove [_podTgt select 0, _podTgt select 1, 0];
			if (alive _plane) then {[_plane, "winch", _podTgt, false, true] call MCC_fnc_taruAI};	// the pilot's own hover
			_plane setVariable ["MCC_exitFull", true];
			[_plane, _pod] spawn {params ["_pl", "_pd"]; [_pl] spawn {sleep 8; if (alive (_this select 0)) then {(_this select 0) flyInHeight 60}; sleep 17; if (alive (_this select 0)) then {(_this select 0) flyInHeight 150}}; [_pl, 35] call MCC_fnc_haloPlaneExit; if (!isNull _pd && {(count crew _pd) == 0} && {isNull (attachedTo _pd)} && {((getPosATL _pd) select 2) > 5}) then {deleteVehicle _pd}};
		};
		if (_isHalo == 0 || {_isHalo == 2 && {_plane isKindOf "Plane"}}) then {
			[_plane, _mark, _lineDir, [1500, 3000] select (_plane isKindOf "Plane")] spawn {
				params ["_pl", "_mk", "_ld", "_st"];
				private _fw = [sin _ld, cos _ld, 0];
				private _rt = [cos _ld, -(sin _ld), 0];
				while {alive _pl && {!(_pl getVariable ["MCC_haloReleased", false])}} do {
					private _o = (getPosASL _pl) vectorDiff (AGLToASL _mk);
					private _along = _o vectorDotProduct _fw;
					if (_along > 50) exitWith {};
					if (_along > -_st) then {
						private _v = velocity _pl;
						private _want = ((-(_o vectorDotProduct _rt)) * 0.12) max -8 min 8;
						private _dv = ((_want - (_v vectorDotProduct _rt)) max -0.6) min 0.6;
						_pl setVelocity (_v vectorAdd (_rt vectorMultiply _dv));
					};
					sleep 0.1;
				};
			};
		};
		private _start = time;
		private _haloCarry = 0;
		private _carryRel = _isHalo in [0, 2];
		private _jumpGap = missionNamespace getVariable ["MCC_paraJumpGap", 0.3];
		private _aim = if (_isHalo == 0) then {_lineA getPos [(_lineA distance2D _lineB) / 2, _lineDir]} else {_lineA};
		_aim set [2, 0];
		private _carryTime = if (_isHalo == 2) then {missionNamespace getVariable ["MCC_haloCarryTime", 3.9]} else {missionNamespace getVariable ["MCC_paraCarryTimePlane", 2.9]};
		private _isParaPlane = _isHalo == 0 && {_plane isKindOf "Plane"};
		waitUntil {
			sleep ([0.1, 0.05] select _carryRel);
			if (_carryRel) exitWith {
				private _v = velocity _plane;
				private _vh = [_v select 0, _v select 1, 0];
				private _sp = vectorMagnitude _vh;
				private _ahead = if (_sp > 1) then {((AGLToASL _aim) vectorDiff (getPosASL _plane)) vectorDotProduct (vectorNormalized _vh)} else {1000000};
				private _hRel = ((getPosASL _plane) select 2) - (getTerrainHeightASL _aim);
				if (_isHalo == 0 && {(_pdOpenP select 1) > 0}) then {_hRel = _hRel - ((((_pdOpenP select 1) + 25) - 125) max 0)};
				_haloCarry = if (_isHalo == 0 && {!(_plane isKindOf "Plane")}) then {_sp * ((((missionNamespace getVariable ["MCC_paraCarryTimeHeli", 1.7]) + 0.012 * (_hRel - 100)) max 0.5) min 4.6)} else {
					if (_isParaPlane) then {_sp * (((missionNamespace getVariable ["MCC_paraCarryTimePlane", 1.5]) + 0.00785 * ((_hRel - 100) max 0)) min 3.7)} else {_sp * _carryTime}
				};
				if (_isHalo == 0) then {
					_jumpGap = ((missionNamespace getVariable ["MCC_paraJumpSpacing", 22.5]) / (_sp max 1)) max 0.1 min 0.6;
					_haloCarry = _haloCarry + (_plane getVariable ["MCC_stickMid", 0]) * _jumpGap * _sp;
				};
				!alive _plane || {time - _start > 240} || {_ahead <= _haloCarry}
			};
			!alive _plane || {time - _start > 120} || {_isHalo != 1 && {(_plane distance2D _mark) < 80}} ||
			{_isHalo == 1 && {((((getPosASL _plane) vectorDiff (AGLToASL _mark)) vectorDotProduct [sin _lineDir, cos _lineDir, 0]) >= 0) && {(_plane distance2D _mark) < 150}}} ||
			{_isHalo != 1 && {((((getPosASL _plane) vectorDiff (AGLToASL _mark)) vectorDotProduct [sin _lineDir, cos _lineDir, 0]) > 0)} && {(_plane distance2D _mark) < 400}} ||
			{_plane getVariable ["MCC_haloReleaseWP", false]}
		};

		if (_isHalo ==1) then {
			_plane setVariable ["MCC_droppedPod", _plane getVariable ["MCC_attachedPod", objNull]];
			_plane setVariable ["MCC_podReleased", true];
			(_plane getVariable ["MCC_attachedPod", objNull]) setVariable ["MCC_podTarget", _podTgt, true];
			private _ro = (getPosASL _plane) vectorDiff (AGLToASL _mark);
			["INFO", "paradrop", "PODS release | %1 | by %6 | along %2 m side %3 m from the middle of the line | height %4 m | speed %5 km/h", [typeOf _plane, round (_ro vectorDotProduct [sin _lineDir, cos _lineDir, 0]), round (_ro vectorDotProduct [cos _lineDir, -(sin _lineDir), 0]), round ((getPosATL _plane) select 2), round (speed _plane), ["the distance check / time limit", "the release waypoint"] select (_plane getVariable ["MCC_haloReleaseWP", false])]] call MCC_fnc_log;
			_plane call MCC_fnc_releasePod;
		} else {
			_plane lock false;
			if (_isHalo == 0) then {
				_plane setVariable ["MCC_jumpGap", _jumpGap, true];
				["DEBUG", "paradrop", "jump spacing %1 s (about %2 m between jumpers at %3 m/s)", [round (_jumpGap * 100) / 100, round (_jumpGap * (vectorMagnitude [(velocity _plane) select 0, (velocity _plane) select 1, 0])), round (vectorMagnitude [(velocity _plane) select 0, (velocity _plane) select 1, 0])]] call MCC_fnc_log;
			};
			_plane setVariable ["MCC_releaseTime", time, true];
			_plane setVariable ["MCCJumperNumber",0,true];
			[_plane, count _stick] spawn {
				params ["_pl", "_n"];
				private _t = time + (_n * 0.6) + 8;
				waitUntil {sleep 0.2; !alive _pl || {time > _t} || {(_pl getVariable ["MCCJumperNumber", 0]) >= _n}};
				private _p = getPosATL _pl;
				waitUntil {sleep 0.2; !alive _pl || {(_pl distance2D _p) > 150}};
				if (alive _pl) then {
					[_pl, false] call MCCMK_fnc_aircraftRamp;
					if (_pl isKindOf "Helicopter") then {[_pl, false] call MCCMK_fnc_aircraftDoors};
				};
			};
			_plane setVariable ["MCC_haloReleased", true];
			["INFO", "paradrop", "release by %1", [if (_carryRel) then {format ["the carry formula (ground speed %1 m/s, %2 m before the %3)", round ((vectorMagnitude [(velocity _plane) select 0, (velocity _plane) select 1, 0])), round _haloCarry, ["line start", "middle of the line"] select (_isHalo == 0)]} else {if (_plane getVariable ["MCC_haloReleaseWP", false]) then {"the release waypoint"} else {"distance check / time limit"}}]] call MCC_fnc_log;
			//Where the aircraft is when the first jumper goes (summary line; the details only with MCC debug on)
			private _rel = [((getPosATL _plane) select 0) - (_lineA select 0), ((getPosATL _plane) select 1) - (_lineA select 1)];
			["DEBUG", "paradrop", "wind at release %1 m/s from %2", [round ((vectorMagnitude [(wind select 0), (wind select 1), 0]) * 10) / 10, round (((wind select 0) atan2 (wind select 1)) + 180) mod 360]] call MCC_fnc_log;
			private _pv = velocity _plane;
			["DEBUG", "paradrop", "aircraft track %1 (heading %2, line %3) | ground speed %4 m/s", [round (((_pv select 0) atan2 (_pv select 1)) + 360) mod 360, round (getDir _plane), round _lineDir, round (vectorMagnitude [_pv select 0, _pv select 1, 0])]] call MCC_fnc_log;
			["INFO", "paradrop", "%1 aircraft release | %2 | along %3 m side %4 m | height %5 m | speed %6 km/h | heading %7 (line %8, %9 m long) | t=%10",
				[["PARA", "PODS", "HALO"] param [_isHalo, "?"], typeOf _plane, round ((_rel select 0) * (sin _lineDir) + (_rel select 1) * (cos _lineDir)),
				 round ((_rel select 0) * (cos _lineDir) - (_rel select 1) * (sin _lineDir)), round ((getPosATL _plane) select 2), round (speed _plane),
				 round (getDir _plane), round _lineDir, round (_lineA distance2D _lineB), round (time * 10) / 10]] call MCC_fnc_log;
		};

		if (_isHalo == 1 && {!isNull (_plane getVariable ["MCC_droppedPod", objNull])}) then {[_plane, _plane getVariable ["MCC_droppedPod", objNull], _flightHight] spawn MCC_fnc_podTaruReturn} else {
		[_plane, _flightHight, _flightHight < 1000] spawn MCC_fnc_haloPlaneExit;
		};
	};

	sleep 5;
} foreach _chockArray;