params [["_mode", "", [""]], ["_ctrl", controlNull, [controlNull]], ["_sx", 0, [0]], ["_sy", 0, [0]], ["_style", "para", [""]]];
switch (_mode) do {
	case "down": {
		MCC_evacParaA = _ctrl ctrlMapScreenToWorld [_sx, _sy];
		MCC_evacParaDrag = true;
	};
	case "move": {
		private _a = missionNamespace getVariable ["MCC_evacParaA", []];
		if (count _a < 2) exitWith {};
		private _b = _ctrl ctrlMapScreenToWorld [_sx, _sy];
		MCCMK_evacParaMarks = [missionNamespace getVariable ["MCC_evacParaStyle", "para"], [_a select 0, _a select 1, 0], [_b select 0, _b select 1, 0], missionNamespace getVariable ["MCCMK_evacParaMarks", []]] call MCCMK_fnc_supportLine;
	};
	case "up": {
		MCC_evacParaDrag = false;
		MCC_evacParaB = _ctrl ctrlMapScreenToWorld [_sx, _sy];
		MCC_evacParaWait = false;
	};
	case "wait": {
		MCC_evacParaA = nil;
		MCC_evacParaB = nil;
		MCC_evacParaDrag = false;
		MCC_evacParaWait = true;
		MCC_evacParaStyle = _style;
		[if ((missionNamespace getVariable ["MCCMK_lineLabel", ""]) != "") then {missionNamespace getVariable ["MCCMK_lineLabel", ""]} else {(["Paradrop: click and drag on the map to draw the drop line", "HALO: click and drag on the map to draw the drop line - the green dot is the target"] select (_style == "drop"))}] call MCCMK_fnc_hint;
		private _t = diag_tickTime + 120;
		waitUntil {sleep 0.1; !(missionNamespace getVariable ["MCC_evacParaWait", false]) || {diag_tickTime > _t}};
		MCC_evacParaWait = false;
		{deleteMarkerLocal _x} forEach (missionNamespace getVariable ["MCCMK_evacParaMarks", []]);
		MCCMK_evacParaMarks = [];
		hintSilent "";
		if (isNil "MCC_evacParaA" || {isNil "MCC_evacParaB"}) exitWith {[]};
		[+MCC_evacParaA, +MCC_evacParaB]
	};
};
