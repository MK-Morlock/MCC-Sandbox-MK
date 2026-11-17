// MCCMK_fnc_classSearch - the Spawn panel's class search: the Class list narrowed to names containing the text, a moment
// after typing stops (MCC_fnc_spawnLists refills it and applies MCCMK_classFilter). [text]
params [["_txt", "", [""]]];
uiNamespace setVariable ["MCCMK_classFilter", toLower _txt];
private _stamp = diag_tickTime;
uiNamespace setVariable ["MCCMK_classFilterStamp", _stamp];
[_stamp] spawn {
	params ["_stamp"];
	uiSleep 0.4;
	if ((uiNamespace getVariable ["MCCMK_classFilterStamp", -1]) != _stamp) exitWith {};
	if (isNull (findDisplay 2994)) exitWith {};
	isNil {["branch"] call MCC_fnc_spawnLists};
};
