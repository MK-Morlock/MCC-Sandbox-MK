/*
	MCCMK_fnc_armedBoatFallback - the side's vanilla armed speedboat, used when the enemy faction has boats but none of
	them is armed (a mission's boat should be dangerous). [side] -> class
*/
params [["_side", east, [east]]];
if !(missionNamespace getVariable ["MCCMK_vanillaFallback", true]) exitWith {""};	//(MK) the "Vanilla vehicle fallback" setting off: none
switch (true) do {
	case (_side isEqualTo west): {"B_Boat_Armed_01_minigun_F"};
	case (_side isEqualTo resistance): {"I_Boat_Armed_01_minigun_F"};
	default {"O_Boat_Armed_01_hmg_F"};
}
