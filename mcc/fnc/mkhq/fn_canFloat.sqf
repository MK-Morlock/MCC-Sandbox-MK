/*
	MCCMK_fnc_canFloat - would Floatary keep an aircraft of this class afloat? [class] -> true / false. The same rule as
	Floatary's own (MCCMK_fltAir): "Floating aircraft" on (MCCMK Commander Console > Water), a helicopter of size 24 or
	more, a plane of 24.75 or more. Used to offer Start: On water only where it floats (a smaller one sank).
	The size is measured once per class (a plain local model of it, deleted again) and kept in the profile.
*/
params [["_cls", "", [""]]];
if (_cls == "" || {!(missionNamespace getVariable ["MCCMK_floatAircraft", true])} || {!(_cls isKindOf "Air")}) exitWith {false};
private _store = profileNamespace getVariable ["MCCMK_floatSizes", []];
if !(_store isEqualType createHashMap) then {_store = createHashMap; profileNamespace setVariable ["MCCMK_floatSizes", _store]};
private _key = format ["%1|%2", toLower _cls, toLower (getText (configFile >> "CfgVehicles" >> _cls >> "model"))];
private _s = _store getOrDefault [_key, -1];
if (_s < 0) then {
	_s = sizeOf _cls;
	if (_s <= 0) then {
		private _o = createSimpleObject [_cls, [0, 0, 0], true];
		if (!isNull _o) then {
			_s = sizeOf _cls;
			if (_s <= 0) then {_s = 2 * ((0 boundingBoxReal _o) select 2)};
			deleteVehicle _o;
		};
	};
	if (_s > 0) then {_store set [_key, _s]; saveProfileNamespace};
};
// (MK) and only a boat carrier (MCCMK_fnc_boatCarrier) whose engine stands 3 m of water (maxFordingDepth - MCC MK raises
// the carriers' to 3 m; a mod variant with its own lower value is left out)
(_s >= ([24, 24.75] select (_cls isKindOf "Plane"))) && {[_cls] call MCCMK_fnc_boatCarrier} && {(getNumber (configFile >> "CfgVehicles" >> _cls >> "maxFordingDepth")) >= 3}
