/*
	MCCMK_fnc_salvageCan  (player) - can this player salvage a wreck? A toolkit, or a repair source within 15 m: anything
	Arma treats as one (repair trucks, the Taru repair pod, MCC's Supply Crate) or ACE's repair vehicles and facilities.
	Checked at most once a second (it's an action condition).
*/
if (time < (missionNamespace getVariable ["MCCMK_salvageCanT", -1])) exitWith {missionNamespace getVariable ["MCCMK_salvageCanV", false]};
MCCMK_salvageCanT = time + 1;
MCCMK_salvageCanV = ("ToolKit" in (items player)) || {((nearestObjects [player, ["AllVehicles", "ReammoBox_F", "Pod_Heli_Transport_04_base_F"], 15]) findIf {
	alive _x && {(getRepairCargo _x) > 0 || {getNumber (configOf _x >> "ace_repair_canRepair") > 0} || {_x getVariable ["ACE_isRepairVehicle", false]} || {_x getVariable ["ACE_isRepairFacility", false]}}
}) >= 0};
MCCMK_salvageCanV
