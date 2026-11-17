params [["_faction", "", [""]], ["_side", west, [west]], ["_men", 8, [0]]];
private _set = missionNamespace getVariable ["MCC_haloAircraft", ""];
if (_set == "MCC_ORIGINAL") exitWith {"MCC original (Auto)"};
private _cls = if (_set != "" && {isClass (configFile >> "CfgVehicles" >> _set)}) then {_set} else {[_faction, _side, ((16 min _men) max 1)] call MCC_fnc_haloAutoAircraft};
if (_cls == "") exitWith {"Automatic"};
format ["%1 (Auto)", getText (configFile >> "CfgVehicles" >> _cls >> "displayName")]
