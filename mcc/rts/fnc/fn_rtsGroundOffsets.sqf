/*
	MCC_fnc_rtsGroundOffsets - a building's parts fitted to the ground: each part's attach offset with its height adjusted.
	  Free-standing parts are moved up OR down until their underside meets the terrain (on a slope the downhill ones would
	  otherwise hang in the air). A part resting on another (a lamp or map on a desk: higher than a part within 1.2 m of it)
	  moves with that part, so it stays on it. Camouflage nets are left to MCCMK_fnc_rtsNetTilt (they tilt with the slope).
	[anchor, [[object, offset], ...]] -> [offset, ...]
*/
params [["_anchor", objNull, [objNull]], ["_parts", [], [[]]]];
private _n = count _parts;
private _gap = [];
for "_i" from 0 to (_n - 1) do {
	((_parts select _i) params ["_o", "_off"]);
	private _bottom = ((boundingBoxReal _o) select 0) select 2;
	private _wc = _anchor modelToWorldWorld _off;
	_gap pushBack ((getTerrainHeightASL _wc) - ((_wc select 2) + _bottom));
};
// what each part rests on: the nearest lower part within 1.2 m (by its offset), or nothing (free-standing)
private _on = [];
for "_i" from 0 to (_n - 1) do {
	private _oi = (_parts select _i) select 1;
	private _best = -1;
	private _bd = 1e9;
	for "_j" from 0 to (_n - 1) do {
		private _oj = (_parts select _j) select 1;
		private _d = [_oi select 0, _oi select 1] distance2D [_oj select 0, _oj select 1];
		if (_j != _i && {(_oj select 2) < (_oi select 2) - 0.3} && {_d < 1.2} && {_d < _bd} && {((toLower typeOf ((_parts select _j) select 0)) find "camonet") < 0}) then {_best = _j; _bd = _d};
	};
	_on pushBack _best;
};
// free-standing parts first, then whatever rests on them (lowest offset first, so a stack follows its base)
private _order = [];
for "_i" from 0 to (_n - 1) do {_order pushBack [((_parts select _i) select 1) select 2, _i]};
_order sort true;
private _final = [];
_final resize _n;
{
	private _i = _x select 1;
	private _j = _on select _i;
	_final set [_i, if (_j >= 0 && {!isNil {_final select _j}}) then {_final select _j} else {_gap select _i}];
} forEach _order;
private _out = [];
for "_i" from 0 to (_n - 1) do {
	private _isNet = ((toLower typeOf ((_parts select _i) select 0)) find "camonet") >= 0;
	_out pushBack (((_parts select _i) select 1) vectorAdd [0, 0, [_final select _i, 0] select _isNet]);
};
_out
