/*
	MCCMK_fnc_crateFrac - how much of a full crate a resource crate still holds (0-1): less after Resupply has been used,
	or for a repacked crate. [crate] -> number
*/
params [["_c", objNull, [objNull]]];
if (isNull _c) exitWith {1};
private _fr = _c getVariable ["MCCMK_crateFrac", 1];
if !((typeOf _c) in ["MCC_crateSupply", "MCC_crateFuel"]) then {
	private _full = getNumber (configFile >> "CfgVehicles" >> typeOf _c >> "ammo");
	if (_full <= 0) then {_full = 200};
	_fr = _fr min ((_c getVariable ["ammoLeft", _full]) / _full);
};
(_fr min 1) max 0
