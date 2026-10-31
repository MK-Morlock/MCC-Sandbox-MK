params [["_h", objNull, [objNull]], ["_mode", "", [""]], ["_pos", [], [[]]]];
private _fnc_done = {
	_h setVariable ["MCC_taruHold", nil];
	_h setVariable ["MCC_taruTask", 2, true];
	["INFO", "taruAI", "%1: %2 %3", [typeOf _h, _mode, _this]] call MCC_fnc_log;
};
if (isNull _h || {!alive _h} || {!(_h isKindOf "Heli_Transport_04_base_F")} || {count _pos < 2}) exitWith {"not possible (not a living Taru, or no place)" call _fnc_done};
if (!local _h) exitWith {[_h, _mode, _pos] remoteExec ["MCC_fnc_taruAI", _h]};
_pos = [_pos select 0, _pos select 1, 0];
private _types = ["Pod_Heli_Transport_04_crewed_base_F", "Pod_Heli_Transport_04_base_F", "Cargo_base_F", "Slingload_01_Base_F"];
private _fnc_docked = {
	private _p = _h getVariable ["MCC_attachedPod", objNull];
	if (isNull _p || {(attachedTo _p) != _h}) then {
		private _i = (attachedObjects _h) findIf {private _o = _x; (_types findIf {_o isKindOf _x}) >= 0};
		_p = if (_i >= 0) then {(attachedObjects _h) select _i} else {objNull};
		if (!isNull _p) then {_h setVariable ["MCC_attachedPod", _p, true]};
	};
	_p
};
private _fnc_hold = {
	params ["_at", "_hAGL"];
	_h setVariable ["MCC_taruHold", [_at, _hAGL]];
	if (_h getVariable ["MCC_taruHoldOn", false]) exitWith {};
	_h setVariable ["MCC_taruHoldOn", true];
	_h spawn {
		private _hh = _this;
		while {alive _hh && {!isNil {_hh getVariable "MCC_taruHold"}}} do {
			(_hh getVariable "MCC_taruHold") params ["_tg", "_ht"];
			private _tgP = if (_tg isEqualType objNull) then {getPosASL _tg} else {AGLToASL _tg};
			private _goal = [_tgP select 0, _tgP select 1, (if (_tg isEqualType objNull) then {_tgP select 2} else {getTerrainHeightASL _tgP}) + _ht];
			private _d = _goal vectorDiff (getPosASL _hh);
			private _dh = vectorMagnitude [_d select 0, _d select 1, 0];
			private _want = if (_dh > 0.5) then {(vectorNormalized [_d select 0, _d select 1, 0]) vectorMultiply ((_dh * 0.35) min 25)} else {[0, 0, 0]};
			_want set [2, ((_d select 2) * 0.5) max -5 min 5];
			private _cur = velocity _hh;
			private _dv = _want vectorDiff _cur;
			if ((vectorMagnitude _dv) > 0.8) then {_dv = (vectorNormalized _dv) vectorMultiply 0.8};
			_hh setVelocity (_cur vectorAdd _dv);
			sleep 0.1;
		};
		_hh setVariable ["MCC_taruHoldOn", false];
	};
};
private _fnc_inPlace = {
	params ["_at", "_side", "_lo", "_hi", "_t"];
	waitUntil {
		sleep 0.25;
		private _ap = if (_at isEqualType objNull) then {getPosASL _at} else {AGLToASL _at};
		private _up = if (_at isEqualType objNull) then {((getPosASL _h) select 2) - (_ap select 2)} else {(getPosATL _h) select 2};
		!alive _h || {time > _t} || {((_h distance2D _ap) < _side) && {_up > _lo} && {_up < _hi} && {(vectorMagnitude (velocity _h)) < 3}}
	};
	alive _h && {time <= _t}
};
_h setVariable ["MCC_taruTask", 1, true];
(group _h) setBehaviour "CARELESS";
switch (_mode) do {
	case "pickup": {
		private _cand = (nearestObjects [_pos, _types, 200]) select {alive _x && {isNull (attachedTo _x)} && {_x != _h}};
		if (count _cand == 0) exitWith {"no pod within 200 m" call _fnc_done};
		if (!isNull ([] call _fnc_docked)) exitWith {"it already has a pod docked" call _fnc_done};
		private _pod = _cand select 0;
		_h flyInHeight 30;
		[_pod, 13] call _fnc_hold;
		if !([_pod, 4, 9, 18, time + 120] call _fnc_inPlace) exitWith {"could not get over the pod in 2 minutes" call _fnc_done};
		_h enableRopeAttach true;
		_pod enableRopeAttach true;
		private _sling = _h setSlingLoad _pod;
		if (!_sling || {count (ropes _h) == 0}) then {
			(boundingBoxReal _pod) params ["_b1", "_b2"];
			private _z = _b2 select 2;
			{ropeCreate [_h, [0, 0, -1], _pod, [_x select 0, _x select 1, _z], ((_h modelToWorld [0, 0, -1]) distance (_pod modelToWorld [_x select 0, _x select 1, _z])) + 0.5]} forEach [[(_b1 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b1 select 0) * 0.6, (_b2 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b2 select 1) * 0.6]];
		};
		private _ht = 13;
		private _tl = time + 12;
		while {alive _h && {time < _tl} && {((getPosATL _pod) select 2) < 2}} do {_ht = _ht + 0.1; [_pod, _ht] call _fnc_hold; sleep 0.1};
		_h setVariable ["MCC_taruHold", nil];
		_h flyInHeight 35;
		[_h] spawn {sleep 8; if (alive (_this select 0)) then {(_this select 0) flyInHeight 60}; sleep 17; if (alive (_this select 0)) then {(_this select 0) flyInHeight 100}};
		[_h, _pod, _sling] spawn {
			params ["_h", "_pod", "_sling"];
			private _dock = if (_sling) then {[_h, 1, false, false] spawn MCC_fnc_podDock} else {[_h, 1] spawn MCC_fnc_attachPod};
			private _t = time + 40;
			waitUntil {sleep 0.5; scriptDone _dock || {!alive _h} || {time > _t}};
			if (!scriptDone _dock && {alive _h} && {alive _pod}) then {
				terminate _dock;
				{ropeDestroy _x} forEach (ropes _h);
				_pod attachTo [_h, [0, 0, -1.2]];
				_h setVariable ["MCC_attachedPod", _pod, true];
			};
		};
		format ["picked up %1", typeOf _pod] call _fnc_done;
	};
	case "winch": {
		if (isNull ([] call _fnc_docked)) exitWith {"no pod docked" call _fnc_done};
		_h flyInHeight 30;
		[_pos, 30] call _fnc_hold;
		if !([_pos, 6, 20, 45, time + 120] call _fnc_inPlace) exitWith {"could not get over the place in 2 minutes" call _fnc_done};
		private _ok = [_h, _pos] call MCC_fnc_podAssault;
		_h flyInHeight 35;
		[_h] spawn {sleep 8; if (alive (_this select 0)) then {(_this select 0) flyInHeight 60}; sleep 17; if (alive (_this select 0)) then {(_this select 0) flyInHeight 100}};
		(["the winch drop failed", "winch drop done"] select _ok) call _fnc_done;
	};
	case "parachute";
	case "release": {
		private _pod = [] call _fnc_docked;
		if (isNull _pod) exitWith {"no pod docked" call _fnc_done};
		private _hAGL = [6, 170] select (_mode == "parachute");
		_h flyInHeight _hAGL;
		[_pos, _hAGL] call _fnc_hold;
		if !([_pos, 8, _hAGL - ([4, 12] select (_mode == "parachute")), _hAGL + ([6, 15] select (_mode == "parachute")), time + 150] call _fnc_inPlace) exitWith {"could not get over the place in 2.5 minutes" call _fnc_done};
		_pod setVariable ["MCC_podTarget", _pos, true];
		if (_mode == "parachute") then {
			_h call MCC_fnc_releasePod;
		} else {
			_h disableCollisionWith _pod;
			if ((getSlingLoad _h) isEqualTo _pod) then {_h setSlingLoad objNull};
			detach _pod;
			_pod setVelocity [0, 0, 0];
			_h setCustomWeightRTD 0;
			_h setMass ((getMass _h) - (_h getVariable ["MCC_attachedPodMass", 0]));
			_h setVariable ["MCC_attachedPod", objNull, true];
			_h setVariable ["MCC_attachedPodMass", 0, true];
			[_h, _pod] spawn {
				params ["_hh", "_p"];
				sleep 2;
				_hh enableCollisionWith _p;
				private _t = time + 15;
				waitUntil {sleep 0.5; !alive _p || {(getPos _p select 2) < 1 && {vectorMagnitude (velocity _p) < 1}} || {time > _t}};
				{["podMoveOut", [_x, "taruAI"]] remoteExec ["MCC_fnc_secAction", _x, false]} forEach (crew _p);
			};
		};
		_h setVariable ["MCC_taruHold", nil];
		_h flyInHeight 100;
		format ["%1 done", _mode] call _fnc_done;
	};
	default {format ["unknown job '%1'", _mode] call _fnc_done};
};
