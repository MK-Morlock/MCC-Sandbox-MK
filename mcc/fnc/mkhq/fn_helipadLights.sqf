/*
	MCCMK_fnc_helipadLights - green flush lights round a lit helipad, on while the side's base has power.
	  "build"  (server) [pad, side]: 8 lights at the pad's edge - corners and mid-sides of a square pad, evenly round a
	           circular one; removed with the pad. Then every computer sets them to the power state.
	  "update" (every computer, also for players joining later) [side]: the side's pad lights on or off with its power.
*/
params [["_mode", "update", [""]], ["_a", objNull], ["_b", sideUnknown]];
private _cls = "Land_Flush_Light_green_F";
if (_mode == "build") exitWith {
	private _pad = _a;
	private _side = _b;
	if (!isServer || {isNull _pad} || {!isClass (configFile >> "CfgVehicles" >> _cls)}) exitWith {};
	(boundingBoxReal _pad) params ["_lo", "_hi"];
	private _hx = (((_hi select 0) - (_lo select 0)) / 2) - 0.4;
	private _hy = (((_hi select 1) - (_lo select 1)) / 2) - 0.4;
	private _pts = [];
	if ((typeOf _pad) == "Land_HelipadSquare_F") then {
		_pts = [[-_hx, -_hy], [0, -_hy], [_hx, -_hy], [_hx, 0], [_hx, _hy], [0, _hy], [-_hx, _hy], [-_hx, 0]];
	} else {
		private _r = _hx min _hy;
		for "_i" from 0 to 7 do {_pts pushBack [_r * (sin (_i * 45)), _r * (cos (_i * 45))]};
	};
	private _lights = _pts apply {
		private _p = _pad modelToWorld [_x select 0, _x select 1, 0];
		private _l = createVehicle [_cls, _p, [], 0, "CAN_COLLIDE"];
		_l setPosATL [_p select 0, _p select 1, 0];
		_l setVariable ["MCCMK_padSide", _side, true];
		_l
	};
	_pad setVariable ["MCCMK_padLights", _lights, true];
	_pad addEventHandler ["Deleted", {{deleteVehicle _x} forEach ((_this select 0) getVariable ["MCCMK_padLights", []])}];
	["update", _side] remoteExec ["MCCMK_fnc_helipadLights", 0, format ["MCCMK_padLights_%1", _side]];
};
// "update": [side]
private _side = _a;
private _on = missionNamespace getVariable [format ["MCC_rtsElecOn_%1", _side], false];
{
	if ((_x getVariable ["MCCMK_padSide", sideUnknown]) isEqualTo _side) then {_x switchLight (["OFF", "ON"] select _on)};
} forEach (allMissionObjects _cls);
