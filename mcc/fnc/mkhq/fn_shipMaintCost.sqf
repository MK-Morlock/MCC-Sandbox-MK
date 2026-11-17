params [["_ship", objNull, [objNull]]];
private _full = createHashMapFromArray [["B_Ship_Gun_01_F", 100], ["B_Ship_MRLS_01_F", 300], ["B_AAA_System_01_F", 60], ["B_SAM_System_01_F", 120], ["B_SAM_System_02_F", 150]];
private _rep = 0; private _ammo = 0; private _dest = 0; private _nDam = 0; private _nEmpty = 0;
{
	_x params ["_w", "_name", "_st", "_dmg", "_frac", "_cls"];
	if (_st == "destroyed") then {_dest = _dest + 1} else {
		if (_dmg > 0.01) then {_rep = _rep + ceil (_dmg * 100); _nDam = _nDam + 1};
		if (_frac < 0.99) then {_ammo = _ammo + ceil ((1 - _frac) * (_full getOrDefault [_cls, 100])); _nEmpty = _nEmpty + 1};
	};
} forEach ([_ship] call MCCMK_fnc_shipWeaponInfo);
private _hullFull = [1000, 2000, 600, 1500] param [_ship getVariable ["MCC_ShipType", 0], 1000];
private _hull = ceil ((1 - (_ship getVariable ["MCCMK_hull", 1])) * _hullFull);
private _rc = ((missionNamespace getVariable ["MCCMK_shipReplaceCost", "200,100"]) splitString ", ") apply {parseNumber _x};
if (count _rc < 2) then {_rc = [200, 100]};
[_rep, _ammo, _dest * (_rc select 0), _dest * (_rc select 1), _nDam, _nEmpty, _dest, _hull]
