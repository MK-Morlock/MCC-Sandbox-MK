private _used = missionNamespace getVariable ["MCC_zones_numbers", []];
private _n = 1;
while {_n in _used} do {_n = _n + 1};
_n
