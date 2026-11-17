params [["_side", west, [west]]];
private _key = format ["MCCMK_supplyAir_%1", _side];
private _cached = missionNamespace getVariable [_key, []];
if (count _cached > 0) exitWith {_cached};
private _sn = [east, west, resistance, civilian] find _side;
private _out = [];
isNil {	//(MK) aircraft only, in one go
{
	private _cl = configName _x;
	private _isPlane = _cl isKindOf "Plane";
	if ((_isPlane || {_cl isKindOf "Helicopter"}) && {getNumber (_x >> "isUav") == 0} && {((_cl select [0, 4]) != "MCC_") || {(_cl find "Heli_Transport_04") < 0}}) then {
		private _viv = isClass (_x >> "VehicleTransport" >> "Carrier");
		private _sling = !_isPlane && {getNumber (_x >> "slingLoadMaxCargoMass") > 0};
		if (_viv || {_sling}) then {
			private _fac = getText (configFile >> "CfgFactionClasses" >> getText (_x >> "faction") >> "displayName");
			_out pushBack [_cl, format ["%1 (%2)", getText (_x >> "displayName"), _fac], getText (_x >> "picture"), _isPlane, getText (_x >> "faction"), _sling];
		};
	};
} forEach (format ["getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') == %1} && {(configName _x) isKindOf 'Air'}", _sn] configClasses (configFile >> "CfgVehicles"));
};
// (MK) the side's Taru (the Taru Pod Mod's, in the livery set for that side) - part of its faction; not for CSAT, whose
// own vanilla Tarus are already listed. Its name without the livery (one livery per side).
if (_side in [west, resistance]) then {
	private _tc = ([_side, "box"] call MCCMK_fnc_podClasses) select 0;
	private _cfg = configFile >> "CfgVehicles" >> _tc;
	if (isClass _cfg && {(_out findIf {(_x select 0) == _tc}) < 0}) then {
		private _nm = getText (_cfg >> "displayName");
		{_nm = (_nm splitString "(") select 0} forEach [1];
		_out pushBack [_tc, format ["%1 (%2)", trim _nm, getText (configFile >> "CfgFactionClasses" >> getText (_cfg >> "faction") >> "displayName")], getText (_cfg >> "picture"), false, getText (_cfg >> "faction"), getNumber (_cfg >> "slingLoadMaxCargoMass") > 0];
	};
};
_out = [_out, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
missionNamespace setVariable [_key, _out];
_out
