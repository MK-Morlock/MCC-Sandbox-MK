params [["_carrier", "", [""]], ["_classes", [], [[]]]];
private _cfgC = configFile >> "CfgVehicles" >> _carrier >> "VehicleTransport" >> "Carrier";
if (!isClass _cfgC || {count _classes == 0}) exitWith {[true, "", 0, 0]};
private _max = getNumber (_cfgC >> "maxLoadMass");
private _n = count _classes;
private _used = 0;
for "_i" from 0 to (_n - 2) do {_used = _used + ([_classes select _i] call MCCMK_fnc_classMass)};
private _total = _used + ([_classes select (_n - 1)] call MCCMK_fnc_classMass);
private _why = "";
if (_max > 0 && {_total > _max}) then {_why = "too heavy"};
if (_why == "") then {
	isNil {
		private _cv = _carrier createVehicleLocal [-2000, -2000, 0];
		private _objs = [];
		{
			if (_why == "" && {_x isKindOf "AllVehicles"}) then {
				private _o = _x createVehicleLocal [-2000 - 40 * (_forEachIndex + 1), -2400, 0];
				_objs pushBack _o;
				if !(_cv setVehicleCargo _o) then {_why = "bay full"};
			};
		} forEach _classes;
		{deleteVehicle _x} forEach _objs;
		deleteVehicle _cv;
	};
};
["DEBUG", "supplyDrop", "fit check %1 | %2 item(s) | %3 of %4 kg with the new item | %5", [_carrier, _n, round _total, _max, ["fits", _why] select (_why != "")]] call MCC_fnc_log;
[_why == "", _why, _used, _max]
