/*
	MCCMK_fnc_sarClimbReq - (server) a player's "Climb rope": [player] - onto the nearest free rope within 3 m of its end
	in the water, or any free rope from the deck of the crippled boat it's come down to.
*/
params [["_u", objNull]];
if (!isServer || {isNull _u} || {!alive _u}) exitWith {};
private _heli = _u getVariable ["MCCMK_sarRopeHeli", objNull];
private _st = _heli getVariable ["MCCMK_sarRope", []];
if (isNull _heli || {_st isEqualTo []} || {isNil "MCCMK_sarStartClimb"}) exitWith {};
private _deck = _u getVariable ["MCCMK_sarRopeDeck", objNull];
private _free = _st select 1;
if (!isNull _deck && {(vehicle _u) isEqualTo _deck}) exitWith {
	private _fi = _free find true;
	if (_fi >= 0) then {[_heli, _u, _fi] call MCCMK_sarStartClimb};
};
private _bot = (_st select 0) apply {private _w = _heli modelToWorld _x; [_w select 0, _w select 1, 0]};
private _best = -1;
private _bd = 3.5;
{if ((_free select _forEachIndex) && {(_u distance2D _x) < _bd}) then {_bd = _u distance2D _x; _best = _forEachIndex}} forEach _bot;
if (_best >= 0) then {[_heli, _u, _best] call MCCMK_sarStartClimb};
