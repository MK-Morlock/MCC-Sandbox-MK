params [["_ship", objNull, [objNull]]];
private _names = createHashMapFromArray [["B_Ship_Gun_01_F", "Gun"], ["B_Ship_MRLS_01_F", "VLS"], ["B_AAA_System_01_F", "AAA"], ["B_SAM_System_01_F", "SAM (short)"], ["B_SAM_System_02_F", "SAM"]];
private _specs = _ship getVariable ["MCCMK_weaponSpecs", []];
private _ws = _ship getVariable ["MCCMK_weapons", []];
private _out = [];
{
	private _cls = _x select 0;
	private _w = _ws param [_forEachIndex, objNull];
	private _dead = isNull _w || {!alive _w};
	private _frac = 1;
	if (!_dead) then {
		private _cur = 0;
		private _max = 0;
		{
			_cur = _cur + (_x select 2);
			_max = _max + (getNumber (configFile >> "CfgMagazines" >> (_x select 0) >> "count"));
		} forEach (magazinesAllTurrets _w);
		_frac = if (_max > 0) then {(_cur / _max) min 1} else {1};
	};
	_out pushBack [_w, _names getOrDefault [_cls, getText (configFile >> "CfgVehicles" >> _cls >> "displayName")], ["", "destroyed"] select _dead, if (_dead) then {1} else {damage _w}, if (_dead) then {0} else {_frac}, _cls, _forEachIndex];
} forEach _specs;
_out
