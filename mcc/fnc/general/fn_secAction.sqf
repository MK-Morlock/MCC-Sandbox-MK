params [["_action", "", [""]], ["_args", [], [[]]]];
switch (toLower _action) do {
	case "announce": {
		_args params [["_text", "", [""]], ["_style", 0, [0]]];
		if (!hasInterface) exitWith {};
		["MCC_woosh", true] spawn BIS_fnc_playSound;
		if (_style == 1) then {[_text, 0, 0.2, 5, 1, 0.0] spawn BIS_fnc_dynamicText} else {[_text, 5] spawn MCC_fnc_rsMessage};
	};
	case "zeusadd": {
		_args params [["_objs", [], [[]]], ["_children", true, [true]], ["_all", false, [true]]];
		if (!isServer) exitWith {};
		_objs = _objs select {_x isEqualType objNull && {!isNull _x}};
		if (_all) then {{_x addCuratorEditableObjects [_objs, _children]} forEach allCurators} else {
			if (!isNil "MCC_curator") then {MCC_curator addCuratorEditableObjects [_objs, _children]};
		};
	};
	case "deletemarker": {
		_args params [["_m", "", [""]]];
		if (_m != "") then {deleteMarker _m};
	};
	case "hideglobal": {
		_args params [["_o", objNull, [objNull]]];
		if (isServer && {!isNull _o}) then {_o hideObjectGlobal true};
	};
	case "eject": {
		_args params [["_u", objNull, [objNull]]];
		if (local _u) then {unassignVehicle _u; _u action ["eject", vehicle _u]};
	};
	case "podmoveout": {
		_args params [["_u", objNull, [objNull]], ["_src", "pods", [""]]];
		if (isNull _u) exitWith {};
		if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by pods (%4) | %1 from %2 at %3 m", [name _u, typeOf (vehicle _u), round ((getPosATL _u) select 2), _src]] call MCC_fnc_log};
		unassignVehicle _u;
		moveOut _u;
	};
	case "switchmove": {
		_args params [["_u", objNull, [objNull]], ["_anim", "", [""]]];
		if (!isNull _u) then {_u switchMove _anim};
	};
	case "enablemove": {
		_args params [["_u", objNull, [objNull]]];
		if (!isNull _u) then {_u enableAI "MOVE"};
	};
	case "haltai": {
		_args spawn {
			params [["_target", objNull, [objNull]], ["_men", objNull, [objNull]]];
			if (isNull _target || {isNull _men}) exitWith {};
			(group _target) setFormDir ([_target, _men] call BIS_fnc_dirTo);
			doStop _target;
			_target disableAI "MOVE";
			sleep 2;
			_target enableAI "MOVE";
		};
	};
	case "setdir": {
		_args params [["_o", objNull, [objNull]], ["_dir", 0, [0]]];
		if (!isNull _o) then {_o setDir _dir};
	};
	case "selectleader": {
		_args params [["_u", objNull, [objNull]]];
		if (!isNull _u) then {(group _u) selectLeader _u};
	};
	case "leavevehicle": {
		_args params [["_who", grpNull, [grpNull, objNull]], ["_veh", objNull, [objNull]]];
		if (!isNull _veh) then {_who leaveVehicle _veh};
	};
	case "setunitpos": {
		_args params [["_u", objNull, [objNull]], ["_mode", "AUTO", [""]]];
		if (!isNull _u && {(toUpper _mode) in ["AUTO", "UP", "DOWN", "MIDDLE"]}) then {_u setUnitPos _mode};
	};
	case "hostagefreed": {
		_args params [["_u", objNull, [objNull]]];
		if (isNull _u) exitWith {};
		_u setCaptive false;
		_u allowFleeing 1;
		_u enableAI "MOVE";
		_u setUnitPos "AUTO";
		_u playMoveNow "Acts_ExecutionVictim_Unbow";
	};
	case "buildrating": {
		_args params [["_side", sideUnknown, [sideUnknown]]];
		if (hasInterface) then {player addRating (if (playerSide != _side) then {500} else {-1000})};
	};
	case "leaveuav": {
		if (hasInterface) then {player action ["BackFromUAV", player]; player connectTerminalToUAV objNull; player switchCamera "INTERNAL"};
	};
	case "haloalign": {
		_args params [["_d", 0, [0]], ["_v", [0, 0, 0], [[]], 3]];
		if (!hasInterface) exitWith {};
		if ((vectorMagnitude _v) > 120) then {_v = (vectorNormalized _v) vectorMultiply 120};
		player setDir _d;
		player setVelocity _v;
	};
	case "intelrecord": {
		_args params [["_tittle", "", [""]], ["_text", "", [""]], ["_markers", [], [[]]]];
		if (!hasInterface) exitWith {};
		private _oldText = _text;
		{_text = _text + (format ["<marker name='%1'> Location</marker>", _x, _x])} forEach _markers;
		_text = "<t size='1.0' font='PuristaBold'>" + _text + "</t>";
		if !(player diarySubjectExists "MCC_intel") then {player createDiarySubject ["MCC_intel", "Intel"]};
		player createDiaryRecord ["MCC_intel", [_tittle, _text]];
		private _output = [
			[_tittle, "<t size='1.0' font='PuristaBold'>%1</t><br/>", 2],
			[_oldText, "<t size='1.0' font='PuristaMedium'>%1</t><br/>", 5]
		];
		[_output, safezoneX + 0.03 * safezoneW, 0, "<t color='#FFFFFFFF' align='left'>%1</t>"] spawn BIS_fnc_typeText;
	};
	case "unloadunconscious": {
		_args spawn {
			params [["_unit", objNull, [objNull]]];
			if (isNull _unit) exitWith {};
			_unit setUnconscious false;
			unassignVehicle _unit;
			[_unit] orderGetIn false;
			_unit action ["Eject", vehicle _unit];
			moveOut _unit;
			waitUntil {vehicle _unit == _unit};
			sleep 0.1;
			_unit setUnconscious true;
		};
	};
	case "dropoffmsg": {
		_args params [["_name", "", [""]], ["_x1", 0, [0]], ["_y1", 0, [0]]];
		if (hasInterface) then {titleText [format ["%1 Request Drop-off at X-ray: %2 Yankee: %3", _name, _x1, _y1], "PLAIN DOWN"]; titleFadeOut 60};
	};
	case "pubmutiny": {
		if (isServer) then {publicVariable "CP_mutiny"};
	};
	case "placesatchel": {
		_args spawn {
			params [["_pos", [], [[]]], ["_leader", objNull, [objNull]]];
			if (isNull _leader || {count _pos < 2}) exitWith {};
			private _prepos = getPos _leader;
			_leader doMove _pos;
			waitUntil {!(alive _leader) || _leader distance _pos < 6};
			if (!alive _leader) exitWith {};
			private _mine = createMine ["SatchelCharge_F", getPos _leader, [], 0];
			_leader doMove _prepos;
			_mine spawn {sleep 30; _this setDamage 1};
		};
	};
};
