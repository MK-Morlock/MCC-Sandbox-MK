/*
	MCCMK_fnc_heliHoverAt - (server; waits) a helicopter brought to a hover exactly over a spot:
	[helicopter, the spot (a position, or an object it follows - a boat), hover height,
	{still wanted?}] -> true only once it is HELD over it (false if it couldn't settle in 30 s - the caller may try again).
	  1. The pilot flies his own approach to a real waypoint, moved with the spot if it's an object that drifts - nothing is
	     touched (held back while he still has somewhere to go, he fights it).
	  2. Once he has come to rest near the spot (all but still for 2 s within 300 m, or within 60 m and slow), his
	     waypoints are taken away - he has nowhere left to go.
	  3. The helicopter is carried gently over the spot and held there (MCCMK_fnc_heliHold) until [helicopter] remoteExec
	     ["MCCMK_fnc_heliHold", helicopter] lets it go.
	The height is measured from the ground - or from the top of whatever stands on the spot (a roof, trees), so a low
	choice can't put it into something; from the sea; or from an object's deck. 5 m at the lowest (3 m asked for: 3 m).
*/
params [["_h", objNull], ["_spot", [0, 0, 0]], ["_hover", 20], ["_cond", {true}]];
if (isNull _h || {!alive _h}) exitWith {false};
private _isObj = _spot isEqualType objNull;
_hover = _hover max 3;
private _t = time + 420;
private _t0 = time;
private _still = -1;
private _flown = false;
private _n = 0;
// (MK) a REAL waypoint on the spot, where the pilot flies his own approach; the hold follows the object itself
// at the end, so the waypoint isn't moved. A fresh move order to the same spot (below) replaces any order already standing
// (the rescue gives a plain move order to the boat on its way in, and an order outranks a waypoint). NOT a stop order:
// it halts the pilot well short (his stopping reads as "arrived", so the carry has all of that distance to do), and a
// pilot ordered to stop holds position against the carry.
private _g0 = group (driver _h);
for "_w" from ((count (waypoints _g0)) - 1) to 0 step -1 do {deleteWaypoint [_g0, _w]};
private _tp0 = if (_isObj) then {getPos _spot} else {_spot};
private _wpos = [_tp0 select 0, _tp0 select 1, 0];
private _wpt = _g0 addWaypoint [_wpos, 0];
_wpt setWaypointType "MOVE";
_wpt setWaypointCompletionRadius 8;
_g0 setCurrentWaypoint _wpt;
_h doMove _wpos;
while {alive _h && {alive (driver _h)} && {call _cond} && {time < _t}} do {
	private _tp = if (_isObj) then {getPos _spot} else {_spot};
	private _d = _h distance2D _tp;
	private _v = vectorMagnitude (velocity _h);
	_n = _n + 1;
	if (_v > 5) then {_flown = true};
	if (_d < 300 && {_v < 2} && {((getPos _h) select 2) > 3} && {_flown || {(time - _t0) > 20}}) then {
		if (_still < 0) then {_still = time};
	} else {_still = -1};
	if ((_still > 0 && {(time - _still) > 2}) || {_d < 45 && {_v < 6}}) exitWith {};	// (MK) 45 m
	sleep 1;
};
if (!alive _h || {!(call _cond)}) exitWith {false};
private _g = group (driver _h);
for "_w" from ((count (waypoints _g)) - 1) to 0 step -1 do {deleteWaypoint [_g, _w]};
// (MK) and the order still standing replaced by one to where he is - done at once, so the pilot has nowhere left to go
// without a stop order
_h doMove (getPos _h);
private _hold = _spot;
if (!_isObj) then {
	private _gz = (getTerrainHeightASL _spot) max 0;
	private _hits = lineIntersectsSurfaces [[_spot select 0, _spot select 1, _gz + 150], [_spot select 0, _spot select 1, _gz - 1], _h, objNull, true, 1, "GEOM", "NONE"];
	private _base = if (_hits isEqualTo []) then {_gz} else {_gz max (((_hits select 0) select 0) select 2)};
	_hold = [_spot select 0, _spot select 1, _base];
	_h setVariable ["MCCMK_hoverBase", _base];
};
_h flyInHeight (_hover max 5);
[_h, _hold, _hover] remoteExec ["MCCMK_fnc_heliHold", _h];
private _th = time + 30;
waitUntil {sleep 0.5; !alive _h || {!(call _cond)} || {time > _th} || {(_h getVariable ["MCCMK_holdState", ""]) isEqualTo "hold"}};
["INFO", "heliHoverAt", "%1 over %2 at %3 m: %4 (%5 m off, %6 s)", [typeOf _h, if (_isObj) then {typeOf _spot} else {mapGridPosition _spot}, _hover, ["not settled", "held"] select ((_h getVariable ["MCCMK_holdState", ""]) isEqualTo "hold"), (_h distance2D (if (_isObj) then {getPos _spot} else {_spot})) toFixed 1, round (time - _t0)]] call MCC_fnc_log;
// (MK) true only once it's HELD over the spot - not just "still wanted"
alive _h && {call _cond} && {(_h getVariable ["MCCMK_holdState", ""]) isEqualTo "hold"}
