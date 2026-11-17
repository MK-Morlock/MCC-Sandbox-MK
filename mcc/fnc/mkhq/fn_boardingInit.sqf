if (!hasInterface) exitWith {};
//(MK) DRIVE-IN LOADING ("Floatary: drive-in loading", on by default): the driver of a small boat drives it INTO the bay of a
// carrier sitting on the water.
//  - THE LANE: behind the ramp, within 2 m of the centreline, pointing within 15 degrees of the helicopter, within about 10 m
//    of the ramp, moving in: collisions between that boat and that helicopter are switched OFF, so it can drive in through
//    the ramp (outside the lane they are on - miss, and you hit it; leave the lane, backing out included, and they are on again).
//  - THE LOCK: once the middle of the boat is within 0.5 m of where it sits when loaded (or past it), within 1 m sideways and
//    10 degrees, it is fixed where it is and settled into its place over a third of a second.
//  "Load watercraft" from behind it stays as well. (Carriers on the water take no damage from boats: MCCMK_fnc_boatDmgGuard.)
[] spawn {
	private _off = objNull;	// (the carrier collisions are off with)
	private _offB = objNull;
	private _restore = {
		if (!isNull _off && {!isNull _offB}) then {
			[_offB, _off] remoteExecCall ["enableCollisionWith", _offB];
			[_off, _offB] remoteExecCall ["enableCollisionWith", _off];
		};
		_off = objNull; _offB = objNull;
	};
	//(MK) idle (once a second) unless he is DRIVING A BOAT; then a carrier is looked for once a second, and only with
	// one within 50 m is the approach checked ten times a second
	private _c = objNull;
	private _scanT = 0;
	while {true} do {
		private _b = vehicle player;
		private _go = (missionNamespace getVariable ["MCCMK_driveInLoad", true]) && {_b isKindOf "Ship"} && {(driver _b) isEqualTo player} && {isNull (attachedTo _b)} && {!isNil "MCCMK_fltCarrierOffset"};
		if (!_go) then {call _restore; _c = objNull; sleep 1; continue};
		if (time >= _scanT) then {
			_scanT = time + 1;
			private _cs = (nearestObjects [_b, ["Air"], 50]) select {alive _x && {([_x] call MCCMK_fltCarrierOffset) isNotEqualTo []} && {isNull ([_x] call MCCMK_fltAttached)} && {[_x] call MCCMK_fltAfloat}};
			_c = if (_cs isEqualTo []) then {objNull} else {_cs select 0};
			if (!isNull _c && {(sizeOf (typeOf _b)) > ([10, 15] select (_c isKindOf "Plane"))}) then {_c = objNull};
		};
		if (isNull _c || {!alive _c}) then {call _restore; _c = objNull; sleep 1; continue};
		private _o = [_c] call MCCMK_fltCarrierOffset;
		private _m = _c worldToModel (ASLToAGL (getPosASL _b));
		private _rearY = ((boundingBoxReal _c) select 0) select 1;
		private _hd = abs ((((getDir _b) - (getDir _c)) + 540) mod 360 - 180);
		private _vin = ((_c vectorWorldToModel (velocity _b)) select 1);
		private _dx = abs ((_m select 0) - (_o select 0));
		private _inside = (_m select 1) > _rearY;
		private _lane = _dx < 2 && {_hd < 15} && {(_m select 1) > (_rearY - 10 - (((boundingBoxReal _b) select 1) select 1))} && {(_m select 1) < ((_o select 1) + 3)} && {_vin > 0.3 || {_inside}};
		if (!_lane) then {call _restore; sleep 0.1; continue};
		if (!(_off isEqualTo _c) || {!(_offB isEqualTo _b)}) then {
			call _restore;
			[_b, _c] remoteExecCall ["disableCollisionWith", _b];
			[_c, _b] remoteExecCall ["disableCollisionWith", _c];
			_off = _c; _offB = _b;
		};
		if (_dx < 1 && {_hd < 10} && {(_m select 1) >= ((_o select 1) - 0.5)} && {isNull ([_c] call MCCMK_fltAttached)}) then {
			[_b, _c, true, true] remoteExec ["MCCMK_fnc_floatLoad", 2];
			_off = objNull; _offB = objNull;	// (attached now - collisions are put back when it's unloaded)
			_c = objNull;
			sleep 2;
		};
		sleep 0.1;
	};
};
//(MK) leaving Zeus: the group icons it turned on IN 3D (they float over vehicles until the map is opened and closed)
//off again
[] spawn {
	while {true} do {
		waitUntil {sleep 1; !isNull (findDisplay 312)};
		waitUntil {sleep 0.5; isNull (findDisplay 312)};
		sleep 0.3;
		setGroupIconsVisible [(groupIconsVisible) param [0, true], false];
	};
};
[] spawn {
	waitUntil {sleep 0.5; !isNull player};
	private _menu = (call MCCMK_fnc_aceMode)	/*(MK) "MCC actions with ACE": 2 ACE only, 0 both, 1 scroll only*/;
	private _ace = !isNil "ace_interact_menu_fnc_createAction";
	if (_ace && {_menu in [0, 2]}) then {
		private _root = ["MCCMK_ship", "Ship", "", {}, {(count (missionNamespace getVariable ['MCC_staticShips', []]) > 0) && {((missionNamespace getVariable ['MCC_staticShips', []]) findIf {!isNull _x && {(_x distance2D _player) < 450}}) >= 0}}] call ace_interact_menu_fnc_createAction;
		["CAManBase", 1, ["ACE_SelfActions"], _root, true] call ace_interact_menu_fnc_addActionToClass;
		{
			_x params ["_id", "_txt", "_code", "_cond", ["_boat", []]];
			private _kids = if (_boat isEqualTo []) then {{}} else {compile format ["['%1', %2] call MCCMK_fnc_boatChildren", _boat select 0, _boat select 1]};
			private _a = [_id, _txt, "", _code, compile _cond, _kids] call ace_interact_menu_fnc_createAction;
			//(MK) the rescue and water actions at the top level (the "Ship" group only shows near a ship)
			private _path = if ((_id in ["MCCMK_sell", "MCCMK_naval"]) || {(_id find "MCCMK_sar") == 0} || {(_id find "MCCMK_flt") == 0} || {(_id find "MCCMK_rope") == 0}) then {["ACE_SelfActions"]} else {["ACE_SelfActions", "MCCMK_ship"]};
			["CAManBase", 1, _path, _a, true] call ace_interact_menu_fnc_addActionToClass;
		} forEach (call MCCMK_fnc_boardingActions);
	};
	if (!_ace || {_menu in [0, 1]}) then {
		MCCMK_boardingAdd = {
			params ["_u", ["_only", []]];
			private _ids = [];
			{
				_x params ["_id", "_txt", "_code", "_cond"];
				if (_only isNotEqualTo [] && {!(_id in _only)}) then {continue};
				// (MK) priority -8.7: the scroll menu is in descending order of priority, so Arma's own seat and light
				// actions come first, then these - Scuttle, Request rescue... (and, being low, they are never the action
				// the action key picks by itself). (MK) Scuttle (a
				// boat, a floating aircraft, a helicopter from its bay) in orange and HELD for 2 s - it can't be undone
				// without a toolkit; Plug the leak in green
				if (_id in ["MCCMK_fltScuttle", "MCCMK_fltScuttleHeli"]) then {
					// (MK) TWO STEPS: "Scuttle" is an ordinary scroll entry, in orange, with nothing on screen; choosing it brings up
					// the hold prompt ("Hold ... to scuttle", 2 s). A right-click, or 10 s without holding, takes the prompt away.
					_ids pushBack (_u addAction [format ["<t color='#ff9933'>%1</t>", _txt], {
						params ["_u", "", "", "_args"];
						_args params ["_code", "_txt"];
						// (the hold prompt on the same object the entry is on - the player, or the aircraft his boat is in while
						// the camera is on it)
						if (!isNil "MCCMK_scuttleHold") then {[missionNamespace getVariable ["MCCMK_scuttleHoldOn", player], MCCMK_scuttleHold] call BIS_fnc_holdActionRemove; MCCMK_scuttleHold = nil};
						MCCMK_scuttleHoldOn = _u;
						MCCMK_scuttleHold = [_u, _txt, "", "", "true", "true", {}, {}, {
							MCCMK_scuttleHold = nil;
							call ((_this select 3) select 0);
						}, {}, [_code], 2, 1000, true, false] call BIS_fnc_holdActionAdd;
						// gone again: a right-click, or 10 s
						[] spawn {
							private _id = MCCMK_scuttleHold;
							private _t = time + 10;
							private _rc = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {if ((_this select 1) == 1) then {MCCMK_scuttleCancel = true}}];
							MCCMK_scuttleCancel = false;
							waitUntil {sleep 0.1; time > _t || {MCCMK_scuttleCancel} || {isNil "MCCMK_scuttleHold"} || {!(MCCMK_scuttleHold isEqualTo _id)}};
							(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", _rc];
							if (!isNil "MCCMK_scuttleHold" && {MCCMK_scuttleHold isEqualTo _id}) then {[missionNamespace getVariable ["MCCMK_scuttleHoldOn", player], _id] call BIS_fnc_holdActionRemove; MCCMK_scuttleHold = nil};
						};
					}, [_code, _txt], -8.7, false, true, "", format ["_this call {private _player = _this; %1}", _cond]]);
				} else {
					// (Load / Unload watercraft just above Scuttle and Request rescue)
					_ids pushBack (_u addAction [format ["<t color='%2'>%1</t>", _txt, ["#7fd4ff", "#66dd66"] select (_id == "MCCMK_fltPlug")], _code, [], [-8.7, -8.6] select (_id in ["MCCMK_fltLoad", "MCCMK_fltUnload"]), false, true, "", format ["_this call {private _player = _this; %1}", _cond]]);
				};
			} forEach (call MCCMK_fnc_boardingActions);
			_ids
		};
		[player] call MCCMK_boardingAdd;
		player addEventHandler ["Respawn", {params ["_u"]; [_u] call MCCMK_boardingAdd}];
	};
};
