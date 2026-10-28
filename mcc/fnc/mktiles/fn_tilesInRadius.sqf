params [["_pos", [0,0,0], [[]]], ["_radius", 200, [0]]];
if (isNil "MCCMK_tileCells" || {missionNamespace getVariable ["MCCMK_tileStep", 0] <= 0}) exitWith {[_pos, _radius, "MCCCampaignMarker_"] call MCC_fnc_findMarkers};
private _st = MCCMK_tileStep;
private _out = [];
for "_c" from floor (((_pos select 0) - _radius) / _st) to ceil (((_pos select 0) + _radius) / _st) do {
	for "_r" from floor (((_pos select 1) - _radius) / _st) to ceil (((_pos select 1) + _radius) / _st) do {
		private _m = MCCMK_tileCells getOrDefault [format ["%1_%2", _c, _r], ""];
		if (_m != "" && {(markerPos _m) distance2D _pos <= _radius}) then {_out pushBack _m};
	};
};
_out
