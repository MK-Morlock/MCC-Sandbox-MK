params [["_side", west, [west]]];
private _key = format ["MCCMK_supplyAir_%1", _side];
private _cached = missionNamespace getVariable [_key, []];
if (count _cached > 0) exitWith {_cached};
private _sn = [east, west, resistance, civilian] find _side;
private _out = [];
{
	private _cl = configName _x;
	private _isPlane = _cl isKindOf "Plane";
	if ((_isPlane || {_cl isKindOf "Helicopter"}) && {getNumber (_x >> "isUav") == 0} && {getText (_x >> "editorSubcategory") != "MCC_EdSubcat_TaruPodMod"}) then {
		private _viv = isClass (_x >> "VehicleTransport" >> "Carrier");
		private _sling = !_isPlane && {getNumber (_x >> "slingLoadMaxCargoMass") > 0};
		if (_viv || {_sling}) then {
			private _fac = getText (configFile >> "CfgFactionClasses" >> getText (_x >> "faction") >> "displayName");
			_out pushBack [_cl, format ["%1 (%2)", getText (_x >> "displayName"), _fac], getText (_x >> "picture"), _isPlane, getText (_x >> "faction"), _sling];
		};
	};
} forEach (format ["getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') == %1}", _sn] configClasses (configFile >> "CfgVehicles"));
_out = [_out, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
missionNamespace setVariable [_key, _out];
_out
