params [["_cl", "", [""]]];
if (isNil "MCCMK_massCache") then {MCCMK_massCache = createHashMap};
private _m = MCCMK_massCache getOrDefault [_cl, -1];
if (_m < 0) then {
	_m = 0;
	if (isClass (configFile >> "CfgVehicles" >> _cl)) then {
		isNil {
			private _o = _cl createVehicleLocal [-2000, -2800, 3000];
			_o enableSimulation false;
			_m = getMass _o;
			deleteVehicle _o;
		};
	};
	MCCMK_massCache set [_cl, _m];
};
_m
