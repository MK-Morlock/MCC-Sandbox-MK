params [["_fac", "", [""]]];
if (_fac == "") exitWith {[]};
private _key = "MCCMK_facGroups_" + toUpper _fac;
if (!isNil _key) exitWith {missionNamespace getVariable _key};
private _F = toUpper _fac;
private _out = [];
{
	{
		{
			private _cat = configName _x;
			{
				private _units = (("true" configClasses _x) apply {getText (_x >> "vehicle")}) select {_x != ""};
				if (count _units > 0 && {(_units findIf {!isClass (configFile >> "CfgVehicles" >> _x) || {!(_x isKindOf "CAManBase")}}) < 0}) then {
					private _gf = toUpper (getText (_x >> "faction"));
					private _mine = if (_gf != "") then {_gf == _F} else {
						({(toUpper (getText (configFile >> "CfgVehicles" >> _x >> "faction"))) == _F} count _units) > ((count _units) / 2)
					};
					if (_mine) then {
						private _type = [_x, _cat] call MCCMK_fnc_groupType;
						if !(_type in ["Motorized", "Mechanized", "Armored", "Air", "Naval", "Support"]) then {_out pushBack [_type, _units]};
					};
				};
			} forEach ("isClass _x" configClasses _x);
		} forEach ("isClass _x" configClasses _x);
	} forEach ("isClass _x" configClasses _x);
} forEach ("isClass _x" configClasses (configFile >> "CfgGroups"));
missionNamespace setVariable [_key, _out];
_out
