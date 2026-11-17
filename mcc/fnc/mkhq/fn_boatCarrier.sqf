/*
	MCCMK_fnc_boatCarrier - can this aircraft carry a boat in its cargo bay (Floatary's "Load Watercraft")? [class or
	vehicle] -> true / false. The original Simple Floatary's carriers, by family (a mod's variant of one counts): the Huron,
	the Mohawk, the Blackfish and Xi'an transports (not the Blackfish gunship), and of the Taru only the covered one (Taru
	Transport) - or a plain Taru carrying an MCC transport pod (a vehicle given). The other Tarus (bench, ammo, cargo, fuel,
	medical, repair, no pod) have no cargo bay for a boat.
*/
params [["_t", ""]];
private _isObj = _t isEqualType objNull;
private _cls = if (_isObj) then {typeOf _t} else {_t};
if !(_cls isEqualType "") exitWith {false};
if (_cls == "") exitWith {false};
if (((["Heli_Transport_04_base_F", "Heli_Transport_02_base_F", "Heli_Transport_03_base_F", "VTOL_01_base_F", "VTOL_02_base_F"]) findIf {_cls isKindOf _x}) < 0) exitWith {false};
// (the Blackfish gunship by its class - "armed" in a name also matches "unarmed")
if (_cls isKindOf "VTOL_01_armed_base_F") exitWith {false};
if (_cls isKindOf "Heli_Transport_04_base_F") exitWith {
	(_cls isKindOf "O_Heli_Transport_04_covered_F")
	|| {_isObj && {private _p = _t getVariable ["MCC_attachedPod", objNull]; !isNull _p && {_p isKindOf "Land_Pod_Heli_Transport_04_covered_F"}}}
};
true
