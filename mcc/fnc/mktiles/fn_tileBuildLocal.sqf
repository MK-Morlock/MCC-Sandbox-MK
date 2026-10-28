params [["_list", [], [[]]]];
if (isServer) exitWith {};
_list spawn {
	private _n = 0;
	{
		_x params ["_name", "_pos", "_size", "_color", "_alpha"];
		if (!isNil "MCCMK_tilePending") then {private _p = MCCMK_tilePending getOrDefault [_name, []]; if (count _p > 0) then {if ((_p select 0) != "") then {_color = _p select 0}; if ((_p select 1) >= 0) then {_alpha = _p select 1}; MCCMK_tilePending deleteAt _name}};
		if (markerShape _name == "") then {createMarkerLocal [_name, _pos]};
		_name setMarkerShapeLocal "RECTANGLE";
		_name setMarkerBrushLocal "SolidFull";
		_name setMarkerSizeLocal _size;
		_name setMarkerColorLocal _color;
		if (missionNamespace getVariable ["MCC_consoleTilesHidden", false]) then {MCC_consoleTilesShown set [_name, _alpha]; _name setMarkerAlphaLocal 0} else {_name setMarkerAlphaLocal _alpha};
		_n = _n + 1;
		if (_n % 50 == 0) then {sleep 0.001};
	} forEach _this;
};
