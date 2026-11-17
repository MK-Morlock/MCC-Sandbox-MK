/*
	MCCMK_fnc_crateRepack - packs what's left of a broken-down crate back into a crate. Only what came out of it counts:
	full magazines of those types, no more of each than came out. Anything else (other gear, part-used magazines) stays on
	the ground. The crate is worth the original value less what was taken, judged by the items' weight.
	[pile]
*/
params [["_h", objNull, [objNull]]];
private _rec = _h getVariable ["MCCMK_crate", []];
if (isNull _h || {_rec isEqualTo []}) exitWith {};
_rec params ["_type", "_frac", "_orig", "_mass"];
private _origMap = createHashMapFromArray _orig;
private _taken = createHashMap;
private _back = [];
private _keep = [];
{
	_x params ["_c", "_a"];
	private _n = _taken getOrDefault [toLower _c, 0];
	if (_n < (_origMap getOrDefault [toLower _c, 0]) && {_a >= getNumber (configFile >> "CfgMagazines" >> _c >> "count")}) then {
		_taken set [toLower _c, _n + 1];
		_back pushBack _c;
	} else {
		_keep pushBack _x;
	};
} forEach (magazinesAmmoCargo _h);
if (_back isEqualTo []) exitWith {["Nothing from the crate is left to repack."] call MCCMK_fnc_hint};
private _m = 0;
{_m = _m + ((getNumber (configFile >> "CfgMagazines" >> _x >> "mass")) max 1)} forEach _back;
private _newFrac = ((_frac * (_m / (_mass max 1))) min 1) max 0.01;
private _pos = getPosATL _h;
_h setVariable ["MCCMK_crate", nil, true];
clearMagazineCargoGlobal _h;
{_h addMagazineAmmoCargo [_x select 0, 1, _x select 1]} forEach _keep;
private _c = createVehicle [_type, _pos, [], 1, "NONE"];
_c setVariable ["MCCMK_crateFrac", _newFrac, true];
private _full = getNumber (configFile >> "CfgVehicles" >> _type >> "ammo");
if (_full <= 0) then {_full = 200};
_c setVariable ["ammoLeft", _full * _newFrac, true];
playSound "click";
[format ["Crate repacked: %1%% of a full crate.", round (_newFrac * 100)]] call MCCMK_fnc_hint;
