private _mkrName = "";
private "_mkr";

// ====================================================================================

params ["_plane", "_mkrType", "_mkrText", "_mkrColor", "_ammount"];
_mkrName = format ["mkr_%1",_plane];

_mkr = createMarker [_mkrName,[(getPos _plane select 0),(getPos _plane select 1)]];
_mkr setMarkerShape "ICON";
_mkrName setMarkerType _mkrType;
_mkrName setMarkerColor _mkrColor;
_mkrName setMarkerSize [0.8, 0.8];
_mkrName setMarkerText _mkrText;

// ====================================================================================

for [{_i=0}, {_i<=10000}, {_i=_i+1}] do
{
	if (alive _plane) then 
	{
		_mkrName setMarkerPos [(getPos _plane select 0),(getPos _plane select 1)];
		sleep 1;
	}
	else 
	{
		deleteMarker _mkrName;
		_i = 20000;
		if (true) exitWith {};
	};
};