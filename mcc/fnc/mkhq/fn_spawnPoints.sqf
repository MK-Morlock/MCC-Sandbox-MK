params [["_side", sideUnknown, [west]]];
private _all = (missionNamespace getVariable ["MCCMK_spawnPointList", []]) select {!isNull _x && {alive _x} && {!(_x getVariable ["dead", false])}};
if (_side isEqualTo sideUnknown) exitWith {_all};
_all select {(_x getVariable ["side", _x getVariable ["MCC_side", sideUnknown]]) isEqualTo _side}
