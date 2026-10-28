params ["_m", "_color", "_alpha"];
if (!isServer || {!isMultiplayer} || {missionNamespace getVariable ["MCCMK_tilesBuilding", false]}) exitWith {};
if (isNil "MCCMK_tileDelta") then {MCCMK_tileDelta = createHashMap};
private _cur = MCCMK_tileDelta getOrDefault [_m, ["", -1]];
if (_color != "") then {_cur set [0, _color]};
if (_alpha >= 0) then {_cur set [1, _alpha]};
MCCMK_tileDelta set [_m, _cur];
if (missionNamespace getVariable ["MCCMK_tileFlushPending", false]) exitWith {};
MCCMK_tileFlushPending = true;
[] spawn {
	sleep 0.2;
	private _list = [];
	{_list pushBack [_x, _y select 0, _y select 1]} forEach MCCMK_tileDelta;
	MCCMK_tileDelta = createHashMap;
	MCCMK_tileFlushPending = false;
	if (count _list > 0) then {[_list] remoteExec ["MCCMK_fnc_tileUpdateLocal", -2]};
};
