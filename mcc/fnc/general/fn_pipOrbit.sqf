#define MCC_UM_PIC 3070
disableSerialization;
params [["_mode", "", [""]], ["_args", []]];
switch (_mode) do {
	case "over": {
		private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
		if (isNull _d) exitWith {false};
		private _c = _d displayCtrl MCC_UM_PIC;
		if (isNull _c || {!ctrlShown _c}) exitWith {false};
		(ctrlPosition _c) params ["_x0", "_y0", "_w", "_h"];
		private _g = ctrlParentControlsGroup _c;
		if (!isNull _g) then {(ctrlPosition _g) params ["_gx", "_gy"]; _x0 = _x0 + _gx; _y0 = _y0 + _gy};
		getMousePosition params ["_mx", "_my"];
		_mx >= _x0 && {_mx <= _x0 + _w} && {_my >= _y0} && {_my <= _y0 + _h}
	};
	case "attach": {
		_args params [["_d", displayNull]];
		if (isNull _d) exitWith {};
		if (isNil "MCC_pipOrbit") then {MCC_pipOrbit = +(profileNamespace getVariable ["MCC_pipOrbit", [0, 0, 0.75]])};	//where it was left last time
		MCC_pipOrbit params [["_y", 0], ["_p", 0], ["_z", 0.75]];
		MCC_pipOrbit = [_y mod 360, (_p max -45) min 70, (_z max 0.2) min 3];
		MCC_pipOrbitDrag = -1;	//1 while the right mouse button is dragged, -1 otherwise
		_d displayAddEventHandler ["MouseButtonDown", {
			params ["", "_b"];
			if (_b == 1 && {["over"] call MCC_fnc_pipOrbit}) then {MCC_pipOrbitDrag = _b};
		}];
		_d displayAddEventHandler ["MouseButtonUp", {
			params ["", "_b"];
			if (_b == (missionNamespace getVariable ["MCC_pipOrbitDrag", -1])) then {
				MCC_pipOrbitDrag = -1;
				profileNamespace setVariable ["MCC_pipOrbit", +MCC_pipOrbit];	//kept for next time
			};
		}];
		_d displayAddEventHandler ["MouseMoving", {
			params ["", "_dx", "_dy"];
			switch (missionNamespace getVariable ["MCC_pipOrbitDrag", -1]) do {
				case 1: {	//swing all the way round (no limit left / right), and down to looking up at the unit
					MCC_pipOrbit set [0, ((MCC_pipOrbit select 0) + _dx * 4) mod 360];
					MCC_pipOrbit set [1, (((MCC_pipOrbit select 1) - _dy * 3) max -45) min 70];
				};
			};
		}];
		_d displayAddEventHandler ["MouseZChanged", {
			params ["", "_z"];
			if (["over"] call MCC_fnc_pipOrbit) then {
				MCC_pipOrbit set [2, (((MCC_pipOrbit select 2) * (1 - _z * 0.1)) max 0.2) min 3];
				profileNamespace setVariable ["MCC_pipOrbit", +MCC_pipOrbit];
			};
		}];
	};
};
