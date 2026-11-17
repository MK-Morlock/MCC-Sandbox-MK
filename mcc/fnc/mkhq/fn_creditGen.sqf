/*
	MCCMK_fnc_creditGen - the key for Valor in a mission without a campaign: map + mission + a generation that "Delete
	data" moves on. [] -> key
*/
private _g = [format ["MCC_campaign_%1_%2", worldName, missionName], "CREDITS", "GEN", "read", 0, true] call MCC_fnc_handleDB;
if !(_g isEqualType 0) then {_g = 0};
format ["%1_%2_g%3", worldName, missionName, _g]
