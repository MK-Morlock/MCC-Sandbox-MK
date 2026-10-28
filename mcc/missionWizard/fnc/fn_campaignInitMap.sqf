/*========================================MCC_fnc_campaignInitMap=========================================================================================================
// init the campaign map and create hostile markers
// Example:[_side,_size._alpha] call MCC_fnc_campaignInitMap;
// _side: SIDE the default side holding the island
// _size: INTEGER, the island will be divided to many boxes this is the default box size.
// _alpha: INTEGER, defual box alpha marker
// _locations : ARRAY of locations to mark the area around them as hot ex [[_pos1,"name1"],[_pos2,"name2"]]
// _hotAlpha : INTGER Alpha intensity of the hot area marker
//====================================================================================================================================================================*/
private _mapSize = 0;
private _markersArray = [];
private _size = 0;
private "_marker";
private _tempArray = [];
private _markerName = "";
private "_side";
private "_markerColor";
private _alpha = 0;
private _xCounter = 0;
private _yCounter = 0;
private _locations = [];
private _markerPos = [];
private _hotAlpha = 0;
private _hotDistance = 0;
private "_markerSelected";
private _markerCenter = [];
private _loadDb = false; private _tc = 0;
_side = param [0,sideLogic,[west]];
_size = param [1,250,[0]];;
_alpha = param [2,0.3,[0]];
_locations = param [3,[],[[]]];
_hotDistance = param [4,500,[0]];;
_hotAlpha = param [5,0.5,[0]];
_loadDb = param [6,false,[false]];

_tempArray = [];
_markersArray = [];
private _perfT0 = diag_tickTime;

MCCMK_tileCells = createHashMap; MCCMK_tilesBuilding = true;
private _fnc_tile = {
	params ["_name", "_pos", "_msize", "_color", "_a"];
	private _m = createMarkerLocal [_name, _pos];
	_m setMarkerShapeLocal "RECTANGLE";
	_m setMarkerBrushLocal "SolidFull";
	_m setMarkerSizeLocal _msize;
	_m setMarkerColorLocal _color;
	[_m, _a] call MCC_fnc_campaignTileSetAlpha;
	MCCMK_tileCells set [format ["%1_%2", round ((_pos select 0) / MCCMK_tileStep), round ((_pos select 1) / MCCMK_tileStep)], _m];
	_tc = _tc + 1; if (_tc % 50 == 0) then {sleep 0.001};
	_m
};

_allTiles = if (_loadDb) then {[format ["MCC_campaign_%1_%2",worldname,missionName], "CAMPAIGN_MARKERS", "row_0", "read",[],true] call MCC_fnc_handleDB} else {[]};

if (count _allTiles > 0) then {
	MCCMK_tileStep = 0;
	for "_y" from 0 to 100 step 1 do {
		_allTiles = [format ["MCC_campaign_%1_%2",worldname,missionName], "CAMPAIGN_MARKERS", format ["row_%1", _y], "read",[],true] call MCC_fnc_handleDB;
		for "_x" from 0 to (count _allTiles)-1 step 1 do {
			_markerSelected = _allTiles select _x;
			if (count _markerSelected > 0) then {
				if (MCCMK_tileStep <= 0) then {MCCMK_tileStep = ((_markerSelected select 1) select 0) * 2};
				_markerName = format ["MCCCampaignMarker_%1_%2", _x,_y];
				[_markerName, _markerSelected select 0, _markerSelected select 1, _markerSelected select 2, _markerSelected select 3] call _fnc_tile;
				_tempArray pushBack _markerName;
			} else {
				_tempArray pushBack "";
			};
		};
		if (count _tempArray > 0) then {
			_markersArray pushBack _tempArray;
			_tempArray = [];
		};
	};
} else {

	_mapSize = getnumber (( configfile >> "cfgworlds" >> worldname) >> "mapSize");
	if (_mapSize == 0) then {_mapSize = worldSize};
	_size = _size max floor (_mapSize / 100);
	MCCMK_tileStep = _size * 2;
	_xCounter = 0;
	_yCounter = 0;

	_markerColor = switch (_side) do
					{
						case west: {"ColorWEST"};
						case resistance: {"ColorGUER"};
						default	{"ColorEAST"};
					};
	for "_y" from 0 to _mapSize step _size*2 do {
		for "_x" from 0 to _mapSize step _size*2 do {
			if (!surfaceIsWater [_x,_y] ||
			    !surfaceIsWater [_x+_size,_y] ||
				!surfaceIsWater [_x,_y +_size] ||
				!surfaceIsWater [_x+_size,_y+_size]) then {

				_markerPos = [_x,_y,0];
				_markerName = format ["MCCCampaignMarker_%1_%2", _xCounter,_yCounter];
				_markerCenter = [(_markerPos select 0) + _size, (_markerPos select 1) + _size,0];
				private _a = if ({(_x select 0) distance _markerCenter < _hotDistance || {(abs (((_x select 0) select 0) - (_markerPos select 0)) <= _size) && {abs (((_x select 0) select 1) - (_markerPos select 1)) <= _size}}} count _locations > 0) then {_hotAlpha} else {_alpha};
				[_markerName, _markerPos, [_size,_size], _markerColor, _a] call _fnc_tile;
				_tempArray pushBack _markerName;
			} else {
				_tempArray pushBack "";
			};

			_xCounter = _xCounter + 1;
		};

		if (count _tempArray > 0) then {
			_markersArray pushBack _tempArray;
			_tempArray = [];
		};

		_yCounter = _yCounter + 1;
	};
};

missionNamespace setVariable ["mcc_markersZonesExc",_markersArray]; MCCMK_tilesBuilding = false;
if (isMultiplayer) then {[] remoteExec ["MCCMK_fnc_tileRequest", -2, "MCCMK_tilesJIP"]};

private _perfCount = 0;
{_perfCount = _perfCount + ({_x != ""} count _x)} forEach _markersArray;
private _perfMsg = format ["campaign tiles: %1 tiles (size %2 m) created in %3 s%4", _perfCount, _size * 2, (diag_tickTime - _perfT0) toFixed 2, ["", " (loaded from DB)"] select _loadDb];
if (isNil "MCC_perfWrite") then {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text ("MCC [PERF] " + _perfMsg)}} else {["campaign", _perfMsg] call MCC_perfWrite};
