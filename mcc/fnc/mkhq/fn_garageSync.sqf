/*
	MCCMK_fnc_garageSync - (server) garage choices from a mission maker's profile: [[[class, [textures, animations]], ...]]
	- an empty choice drops that class's. Kept in MCCMK_garageLooks for MCCMK_fnc_garageApply.
*/
params [["_pairs", []]];
if (!isServer) exitWith {};
if (isNil "MCCMK_garageLooks") then {MCCMK_garageLooks = createHashMap};
{
	_x params [["_c", ""], ["_look", []]];
	if (_c != "") then {if (_look isEqualTo []) then {MCCMK_garageLooks deleteAt (toLower _c)} else {MCCMK_garageLooks set [toLower _c, _look]}};
} forEach _pairs;
