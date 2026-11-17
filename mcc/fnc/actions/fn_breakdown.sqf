//==================================================================MCC_fnc_breakdown=========================================================================================
//Breakdown MCC crate into supplies
// Example:[_object] spawn MCC_fnc_breakdown;
// <IN>
//	_object:					Object- object.
//
// <OUT>
//		<nothing>
//===========================================================================================================================================================================
#define MCC_fuelItems [["MCC_fuelCan"],["MCC_fuelbot"]]
#define MCC_repairItems [["MCC_ductTape"],["MCC_butanetorch"],["MCC_oilcan"],["MCC_metalwire"],["MCC_carBat"],["MCC_canOpener"],["MCC_screwdriver"],["MCC_matches"]]

// (MK) An ammo crate gives a resupply for the soldiers around it (MCCMK_fnc_crateAmmoSet) What comes out is scaled to
// what the crate still holds (after Resupply, or when it was repacked), is created for everyone, and is remembered so it
// can be repacked.
params [["_object", objNull, [objNull]]];
if (isNull _object) exitWith {};
private _type = typeOf _object;
private _pos = getPosATL _object;
private _frac = _object getVariable ["MCCMK_crateFrac", 1];
private _items = [];
switch (_type) do {
	case "MCC_crateSupply": {for "_i" from 1 to 4 do {_items pushBack ((selectRandom MCC_repairItems) select 0)}};
	case "MCC_crateFuel": {for "_i" from 1 to 4 do {_items pushBack ((selectRandom MCC_fuelItems) select 0)}};
	default {
		private _full = getNumber (configFile >> "CfgVehicles" >> _type >> "ammo");
		if (_full <= 0) then {_full = 200};
		_frac = _frac min ((_object getVariable ["ammoLeft", _full]) / _full);
		_items = [_object] call MCCMK_fnc_crateAmmoSet;
	};
};
_items = _items call BIS_fnc_arrayShuffle;
_items resize (round ((count _items) * (_frac max 0)));
if (_items isEqualTo []) exitWith {["The crate is empty."] call MCCMK_fnc_hint};
deleteVehicle _object;
private _h = createVehicle ["GroundWeaponHolder", _pos, [], 0, "CAN_COLLIDE"];
_h setPosATL _pos;
private _counts = createHashMap;
{_counts set [toLower _x, (_counts getOrDefault [toLower _x, 0]) + 1]} forEach _items;
{_h addMagazineCargoGlobal [_x, _y]} forEach _counts;
private _mass = 0;
{_mass = _mass + ((getNumber (configFile >> "CfgMagazines" >> _x >> "mass")) max 1)} forEach _items;
_h setVariable ["MCCMK_crate", [_type, _frac, (keys _counts) apply {[_x, _counts get _x]}, _mass], true];
[_h] remoteExec ["MCCMK_fnc_pileAction", 0, _h];
