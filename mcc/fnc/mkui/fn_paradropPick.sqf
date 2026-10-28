params ["_which", "_c", "_i"];
if (_i < 0) exitWith {};
if (isNil "MCCMK_pdMem") then {MCCMK_pdMem = createHashMap};
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
private _cl = _c lbData _i;
(_d displayCtrl ([1056, 1057] select _which)) ctrlSetText (if (_cl == "") then {"Seats: as needed"} else {format ["Seats: %1", _c lbValue _i]});
if (_cl != (MCCMK_pdMem getOrDefault [["para", "halo"] select _which, ""])) then {
	MCCMK_pdMem set [["para", "halo"] select _which, _cl];
	["DEBUG", "paradrop", "%1 aircraft in the Paradrop panel: %2", [["Paratrooper", "HALO"] select _which, if (_cl == "") then {"Automatic"} else {_cl}]] call MCC_fnc_log;
};
missionNamespace setVariable [["MCCMK_pdAirPara", "MCCMK_pdAirHalo"] select _which, _cl];
