params [["_side", west, [west]]];
if (isNil "MCCMK_casMem") then {MCCMK_casMem = createHashMap};
private _key = "list|" + str _side;
private _have = MCCMK_casMem getOrDefault [_key, []];
if (count _have > 0) exitWith {_have};
private _sn = [_side] call BIS_fnc_sideID;
private _out = [];
{
	private _cl = configName _x;
	private _armed = "S&D" in ([_cl] call MCC_fnc_casAllowedTypes);
	private _recon = !_armed && {getNumber (_x >> "isUav") == 1};
	if ((_cl isKindOf "Plane" || {_cl isKindOf "Helicopter"}) && {_armed || _recon}) then {
		private _f = getText (_x >> "faction");
		_out pushBack [_cl, format ["%1%2 (%3)", getText (_x >> "displayName"), ["", " (Recon)"] select _recon, getText (configFile >> "CfgFactionClasses" >> _f >> "displayName")], getText (_x >> "picture"), _cl isKindOf "Plane", _f];
	};
} forEach (format ["getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') == %1}", _sn] configClasses (configFile >> "CfgVehicles"));
_out = [_out, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
MCCMK_casMem set [_key, _out];
_out
