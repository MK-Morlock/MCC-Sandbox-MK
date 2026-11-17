params [["_list", [], [[]]]];
if (isServer) exitWith {};
if (isNil "MCCMK_tilePending") then {MCCMK_tilePending = createHashMap};
{
	_x params ["_name", "_color", "_alpha"];
	if (markerShape _name == "") then {
		private _p = MCCMK_tilePending getOrDefault [_name, ["", -1]];
		if (_color != "") then {_p set [0, _color]};
		if (_alpha >= 0) then {_p set [1, _alpha]};
		MCCMK_tilePending set [_name, _p];
	} else {
		if (_color != "") then {_name setMarkerColorLocal _color};
		if (_alpha >= 0) then {
			[_name, _alpha] call MCCMK_fnc_tileDraw;
		};
	};
} forEach _list;
