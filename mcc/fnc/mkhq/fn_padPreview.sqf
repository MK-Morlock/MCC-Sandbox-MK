/*
	MCCMK_fnc_padPreview - while placing an invisible helipad in the RTS: a flat, light green see-through square the size of
	a standard helipad (the invisible pad has no size of its own), on the preview object, so its position and facing show.
	It moves and turns with the preview and goes when the preview does. [preview object]
*/
params [["_ph", objNull, [objNull]]];
if (isNull _ph || {!hasInterface}) exitWith {};
private _size = missionNamespace getVariable "MCCMK_padSize";
if (isNil "_size") then {
	private _t = "Land_HelipadSquare_F" createVehicleLocal [0, 0, 1000];
	(boundingBoxReal _t) params ["_lo", "_hi"];
	_size = (((_hi select 0) - (_lo select 0)) max ((_hi select 1) - (_lo select 1))) max 6;
	deleteVehicle _t;
	MCCMK_padSize = _size;
};
private _tex = "#(argb,8,8,3)color(0.55,1,0.55,0.35,ca)";
private _planes = [];
// two flat 10 m planes, one facing up and one down (each is seen from one side only), scaled to the pad's size
{
	private _p = "UserTexture10m_F" createVehicleLocal [0, 0, 1000];
	_p setObjectTexture [0, _tex];
	_p attachTo [_ph, [0, 0, 0.08]];
	_p setVectorDirAndUp [[0, 0, _x], [0, 1, 0]];
	_p setObjectScale (_size / 10);
	_planes pushBack _p;
} forEach [1, -1];
_ph setVariable ["MCCMK_padPlanes", _planes];
_ph addEventHandler ["Deleted", {{deleteVehicle _x} forEach ((_this select 0) getVariable ["MCCMK_padPlanes", []])}];
