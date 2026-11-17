if (!hasInterface) exitWith {};
[] spawn {
	waitUntil {sleep 1; !isNull ((findDisplay 12) displayCtrl 51)};
	((findDisplay 12) displayCtrl 51) ctrlAddEventHandler ["Draw", {
		params ["_c"];
		private _mp = getMousePosition;
		private _tex = ["\A3\ui_f\data\map\markers\nato\o_naval.paa", "\A3\ui_f\data\map\markers\nato\b_naval.paa", "\A3\ui_f\data\map\markers\nato\n_naval.paa"] param [[east, west, independent] find playerSide, "\A3\ui_f\data\map\markers\nato\b_naval.paa"];
		private _col = [playerSide] call BIS_fnc_sideColor;
		{
			if (!isNull _x && {(_x getVariable ["MCC_side", sideUnknown]) isEqualTo playerSide} && {_x getVariable ["MCCMK_radarOn", false]} && {_x getVariable ["MCCMK_radarMap", false]}) then {
				private _r = _x getVariable ["MCCMK_radarRange", 8000];
				_c drawEllipse [getPosWorld _x, _r, _r, 0, [_col select 0, _col select 1, _col select 2, 0.7], ""];
				_c drawEllipse [getPosWorld _x, _r, _r, 0, [_col select 0, _col select 1, _col select 2, 0.05], "#(rgb,8,8,3)color(1,1,1,1)"];
			};
		} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
		{
			if (!isNull _x && {_x getVariable ["MCCMK_showMarker", false]} && {(_x getVariable ["MCC_side", sideUnknown]) isEqualTo playerSide} && {((_x getVariable ["MCCMK_repositionUntil", 0]) - serverTime) <= 0}) then {
				private _p = getPosWorld _x;
				private _hover = ((_c ctrlMapWorldToScreen _p) distance2D _mp) < 0.02;
				_c drawIcon [_tex, _col, _p, 24, 24, 0, ["", _x getVariable ["MCC_LHDDisplayName", "Ship"]] select _hover, 0, 0.032, "RobotoCondensedLight", "right"];
			};
		} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
	}];
};
