params [["_owner", 0, [0]]];
if (!isServer || {_owner <= 0}) exitWith {};
private _list = [];
{
	{
		if (_x != "") then {_list pushBack [_x, markerPos _x, markerSize _x, markerColor _x, markerAlpha _x]};
	} forEach _x;
} forEach (missionNamespace getVariable ["mcc_markersZonesExc", []]);
{
	private _a = MCC_consoleTilesShown getOrDefault [_x select 0, -1];
	if (_a >= 0) then {_x set [4, _a]};
} forEach (if (isNil "MCC_consoleTilesShown") then {[]} else {_list});
[_list] remoteExec ["MCCMK_fnc_tileBuildLocal", _owner];
