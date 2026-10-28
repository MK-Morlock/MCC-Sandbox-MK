params [["_anchor", objNull, [objNull]], ["_parts", [], [[]]]];
private _n = count _parts;
private _lift = [];
for "_i" from 0 to (_n - 1) do {
	((_parts select _i) params ["_o", "_off"]);
	private _bottom = ((boundingBoxReal _o) select 0) select 2;
	private _wc = _anchor modelToWorldWorld _off;
	_lift pushBack (((getTerrainHeightASL _wc) - ((_wc select 2) + _bottom)) max 0);
};
private _final = +_lift;
for "_i" from 0 to (_n - 1) do {
	if ((_lift select _i) == 0) then {
		private _p = _anchor modelToWorld ((_parts select _i) select 1);
		private _best = 0;
		for "_j" from 0 to (_n - 1) do {
			if ((_lift select _j) > 0 && {(_p distance2D (_anchor modelToWorld ((_parts select _j) select 1))) < 1.5}) then {
				_best = _best max (_lift select _j);
			};
		};
		_final set [_i, _best];
	};
};
private _out = [];
for "_i" from 0 to (_n - 1) do {
	_out pushBack (((_parts select _i) select 1) vectorAdd [0, 0, _final select _i]);
};
_out
