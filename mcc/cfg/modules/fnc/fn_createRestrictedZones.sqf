//==================================================================MCC_fnc_createRestrictedZones=================================================================
/************************************************************
Author:	Shay_gman

Parameters: [ _sides<Array>,_time <Integer>,_air <boolean>,createMarker<boolean>]

_logic:	if called by a function always leave objNull
_sides: array containg the sides that will be punished.
_time: time need to ellapsed before punishment
_air: Should air unis be punished
_createMarker: Should we delete the marker after placment if not then the trigger will move with the marker if the marker is moved
Create a restriction zone on a marker defined in mission sqf init.sqf

Example:[_logic, [east,west,resistance,civilian],10,false,false,false] remoteExec ["MCC_fnc_createRestrictedZones", 2, false];

************************************************************/
private "_sides";
private "_time";
private "_air";
private "_createMarker";
private _trgs = [];
private "_location";
private "_mName";
private _keepAI = false;
private _aiInside = 0;
private _exemptTxt = "";

params ["_logic"];

//Did we got here by  a function call or by module
if (isNull _logic) then {
	_sides     	 	= _this select 1;
	_time       	= _this select 2;
	_air        	= _this select 3;
	_createMarker   = _this select 4;
} else {
	_sides 	= _logic getvariable ["sides",-1];
	_time 	= _logic getvariable ["time",10];
	_air 	= _logic getvariable ["air",true];
	_createMarker = _logic getvariable ["createMarker",true];
	_keepAI = _logic getvariable ["keepAIOut",false];
	_aiInside = _logic getvariable ["aiInside",0];
	_exemptTxt = _logic getvariable ["exemptions",""];

	_sides = if (_sides == -1) then {[east,west,resistance,civilian]} else {[_sides call bis_fnc_sideType]};
};

if (isNil "_keepAI") then {_keepAI = false};
if (isNil "_aiInside") then {_aiInside = 0};
if (isNil "_exemptTxt") then {_exemptTxt = ""};
private _exemptNames = (_exemptTxt splitString ", ;") select {_x != ""};
private _fnc_exempt = {
	params ["_u", "_names"];
	if (count _names == 0) exitWith {false};
	private _hit = false;
	{
		private _o = missionNamespace getVariable [_x, objNull];
		if (_o isEqualType grpNull) then {if (_u in units _o) exitWith {_hit = true}} else {
			if (_o isEqualType objNull && {!isNull _o} && {_o == _u || {_o == vehicle _u}}) exitWith {_hit = true};
		};
		if (_hit) exitWith {};
	} forEach _names;
	_hit
};
_trgs = [];
_markers = [];

if (isServer) then {
	private _cands = [];
	{
		if (_x isKindOf "EmptyDetector") then {_cands pushBackUnique _x};
		if (typeOf _x == "LocationArea_F") then {
			_location = _x;
			{if (_x isKindOf "EmptyDetector") then {_cands pushBackUnique _x}} forEach synchronizedObjects _location;
		};
	} forEach synchronizedObjects _logic;
	{
		_x setTriggerActivation["ANY","PRESENT",true];
		//Should we create markers for the trigger
		if (_createMarker) then {
			_mName = createMarker [str _x, getpos _x];
			_mName setMarkerColor "colorRed";
			_mName setMarkerShape (if ((triggerArea _x) select 3) then {"RECTANGLE"} else {"ELLIPSE"});
			_mName setMarkerSize [(triggerArea _x) select 0,(triggerArea _x) select 1];
			_mName setMarkerDir ((triggerArea _x) select 2);
			_mName setMarkerBrush "DIAGGRID";
			_markers pushBack _mName;
		};
		_trgs pushBack _x;
	} forEach _cands;
	if (count _trgs == 0) then {["WARN", "createRestrictedZones", "restricted zones module: no trigger synced to it (or to a Location / Area synced to it) - no zone"] call MCC_fnc_log};
	["INFO", "createRestrictedZones", "%1 zone(s) | restricted sides %2 | keep AI out %3 | AI already inside: %4 | markers %5", [count _trgs, _sides, _keepAI, ["moved out", "left alone"] select (_aiInside == 1), _createMarker]] call MCC_fnc_log;

	sleep 1;
	_logic setVariable ["triggers", _trgs, true];

	if (_keepAI && {count _trgs > 0}) then {
		MCCMK_aiKeepOutZones = (missionNamespace getVariable ["MCCMK_aiKeepOutZones", []]) + [[_logic, _trgs, _sides]];
		[_logic, _trgs, _sides, _aiInside, _exemptNames, _fnc_exempt] spawn {
			params ["_logic", "_trgs", "_sides", "_aiInside", "_names", "_fnc_exempt"];
			private _fnc_outside = {
				params ["_t", "_p"];
				private _c = getPosATL _t;
				private _dir = _c getDir _p;
				private _r = ((triggerArea _t) select 0) max ((triggerArea _t) select 1);
				private _d = (_c distance2D _p) max 1;
				while {_d < (_r * 1.5 + 50) && {(_c getPos [_d, _dir]) inArea _t}} do {_d = _d + 5};
				_c getPos [_d + 15, _dir]
			};
			private _fnc_aiIn = {
				params ["_t"];
				private _out = [];
				{
					private _v = _x;
					private _crew = if (_v isKindOf "CAManBase") then {[_v]} else {crew _v};
					if (alive _v && {!(_v isKindOf "Animal")} && {count _crew > 0} && {({isPlayer _x} count _crew) == 0}) then {
						private _cmd = if (_v isKindOf "CAManBase") then {_v} else {effectiveCommander _v};
						if (isNull _cmd) then {_cmd = _crew select 0};
						private _sd = if (isNull (group _cmd)) then {side _cmd} else {side (group _cmd)};
						if (_sd in _sides && {!([_cmd, _names] call _fnc_exempt)}) then {_out pushBack _cmd};
					};
				} forEach (list _t);
				_out
			};
			private _leftAlone = [];
			sleep 3;
			if (_aiInside == 1) then {{_leftAlone append ([_x] call _fnc_aiIn)} forEach _trgs};
			while {!isNull _logic} do {
				private _inNow = [];
				{
					private _t = _x;
					{
						private _u = _x;
						_inNow pushBackUnique _u;
						if !(_u in _leftAlone) then {
							private _g = group _u;
							private _key = if (isNull _g) then {_u} else {_g};
							if (time >= (_key getVariable ["MCC_rzTurnedAt", -100]) + 6) then {
								_key setVariable ["MCC_rzTurnedAt", time];
								private _veh = vehicle _u;
								private _leaving = !isNull _g && {(currentWaypoint _g) < (count (waypoints _g))} && {((waypointPosition [_g, currentWaypoint _g]) distance2D (_g getVariable ["MCC_rzExit", [0, 0, 0]])) < 5};
								if (_leaving) exitWith {};
								private _exit = if (_veh != _u) then {
									private _p0 = getPosATL _veh;
									private _bd = (getDir _veh) + 180;
									private _q = _p0;
									for "_s" from 10 to 3000 step 10 do {_q = _p0 getPos [_s, _bd]; if !(_q inArea _t) exitWith {}};
									_q = _q getPos [30, _bd];
									private _rd = (_q nearRoads 150) select {!((getPosATL _x) inArea _t)};
									if (count _rd > 0) then {getPosATL (([_rd, [], {_x distance2D _q}, "ASCEND"] call BIS_fnc_sortBy) select 0)} else {_q}
								} else {[_t, getPosATL _u] call _fnc_outside};
								if (isNull _g || {isAgent teamMember _u}) then {if (local _u) then {_u moveTo _exit} else {[_u, _exit] remoteExec ["moveTo", _u]}} else {
									{
										private _wp = _x;
										private _wpos = waypointPosition _wp;
										{if (_wpos inArea _x) exitWith {_wp waypointAttachObject objNull; _wp setWaypointPosition [[_x, _wpos] call _fnc_outside, 0]}} forEach _trgs;
									} forEach (waypoints _g);
									private _ci = currentWaypoint _g;
									private _hasNext = _ci < (count (waypoints _g));
									private _w = _g addWaypoint [_exit, 0, _ci];
									_w setWaypointType "MOVE";
									_g setVariable ["MCC_rzExit", _exit];
									private _next = _ci + 1;
									if (_hasNext) then {
										if (_veh != _u) then {
											while {_next < (count (waypoints _g)) && {(waypointType [_g, _next]) != "CYCLE"} && {[_exit, waypointPosition [_g, _next], side _g] call MCCMK_fnc_crossesKeepOut}} do {deleteWaypoint [_g, _next]};
										} else {
											if (_next < (count (waypoints _g)) && {[_exit, waypointPosition [_g, _next], side _g] call MCCMK_fnc_crossesKeepOut}) then {
												private _c = getPosATL _t;
												_c set [2, 0];
												private _r = (((triggerArea _t) select 0) max ((triggerArea _t) select 1)) + 30;
												private _np = waypointPosition [_g, _next];
												private _dv = _np vectorDiff _exit;
												_dv set [2, 0];
												private _l2 = _dv vectorDotProduct _dv;
												private _tt = if (_l2 > 0) then {((((_c vectorDiff _exit) vectorDotProduct _dv) / _l2) max 0) min 1} else {0};
												private _near = _exit vectorAdd (_dv vectorMultiply _tt);
												private _out = _near vectorDiff _c;
												_out set [2, 0];
												if ((vectorMagnitude _out) < 1) then {_out = [-(_dv select 1), _dv select 0, 0]};
												private _det = _c vectorAdd ((vectorNormalized _out) vectorMultiply (_r * 1.15));
												_det set [2, 0];
												private _dw = _g addWaypoint [_det, 0, _next];
												_dw setWaypointType "MOVE";
											};
										};
									};
									_g setCurrentWaypoint [_g, _ci];
								};
								["INFO", "restrictedZones", "turned away %1 (%2) at %3 - leaving by %4", [typeOf _veh, _key, mapGridPosition _u, mapGridPosition _exit]] call MCC_fnc_log;
							};
						};
					} forEach ([_t] call _fnc_aiIn);
				} forEach _trgs;
				_leftAlone = _leftAlone select {_x in _inNow};
				_logic setVariable ["MCC_rzScan", !(_logic getVariable ["MCC_rzScan", false])];
				if (_logic getVariable ["MCC_rzScan", false]) then {
					{
						private _g = _x;
						private _ld = leader _g;
						if ((side _g) in _sides && {!isNull _ld} && {({isPlayer _x} count (units _g)) == 0} && {!(_ld in _leftAlone)} && {!([_ld, _names] call _fnc_exempt)}) then {
							private _wps = waypoints _g;
							for "_i" from (currentWaypoint _g) to ((count _wps) - 1) do {
								private _wp = _wps select _i;
								private _wpos = waypointPosition _wp;
								{
									if (_wpos inArea _x) exitWith {
										_wp waypointAttachObject objNull;
										_wp setWaypointPosition [[_x, _wpos] call _fnc_outside, 0];
									};
								} forEach _trgs;
							};
						};
					} forEach allGroups;
				};
				sleep 2;
			};
		};
	};
};


if (!isdedicated) then {
	sleep 10;
	while {isNil {_logic getVariable "triggers"}} do {sleep 0.5};
	//waituntil {!(isNil {_logic getVariable "triggers"})};

	_trgs = _logic getVariable "triggers";

	//set Activation for all
	{
		_x setTriggerActivation ["ANY","PRESENT",true];
		sleep 0.1;
	} foreach _trgs;


	//Main loop
	while {!isnull _logic} do {
		{
			_myList = list _x;
			if ((vehicle player in _myList) && (((player getVariable ["CP_side", playerside])) in _sides) && {!([player, _exemptNames] call _fnc_exempt)}) then {
				[_x,_time,false,_air] spawn MCC_fnc_RestrictZoneEffect};
		} foreach _trgs;
		sleep 1;
	};
};

//if the logic have beeen deleted delete triggers
if (isServer) exitWith {
	waituntil {isnull _logic};
	{
		deleteVehicle _x;
	} foreach _trgs;

	{
		deleteMarker _x;
	} forEach _markers;
};