params ["_mode", ["_a", []]];
switch (_mode) do {
	case "start": {
		_a params ["_cc", "_groups", "_arr"];
		_groups = _groups select {!isNull _x};
		if (_groups isEqualTo []) exitWith {uiNamespace setVariable ["MCCMK_wpChain", nil]};
		uiNamespace setVariable ["MCCMK_wpChain", [_cc, _groups, +_arr]];
	};
	case "end": {uiNamespace setVariable ["MCCMK_wpChain", nil]; uiNamespace setVariable ["MCCMK_wpChainPend", []]};
	case "pend": {
		private _p = uiNamespace getVariable ["MCCMK_wpChainPend", []];
		_p pushBack [[_a select 0, _a select 1], diag_tickTime];
		uiNamespace setVariable ["MCCMK_wpChainPend", _p];
	};
	case "unpend": {
		private _p = uiNamespace getVariable ["MCCMK_wpChainPend", []];
		if (_p isNotEqualTo []) then {_p deleteAt ((count _p) - 1)};
	};
	case "active": {!isNil {uiNamespace getVariable "MCCMK_wpChain"}};
	case "add": {
		private _ch = uiNamespace getVariable "MCCMK_wpChain";
		if (isNil "_ch") exitWith {false};
		_ch params ["_cc", "_groups", "_arr"];
		_groups = _groups select {!isNull _x && {alive (leader _x)}};
		if (_groups isEqualTo []) exitWith {uiNamespace setVariable ["MCCMK_wpChain", nil]; false};
		if (_cc) then {
			[0, _a, _arr, _groups, true] remoteExec ["MCC_fnc_manageWp", 2, false];
		} else {
			[0, _a, _arr, _groups] remoteExec ["MCC_fnc_manageWp", 2, false];
		};
		true
	};
	default {false};
};
