/*
    ANC_fnc_makeHelper  (server)
    Arma ropes can only be tied to vehicles, so each rope runs from a hidden quad bike attached to the anchor / dock
    fitting. Created for everyone, so the rope exists on every player's computer.
*/
private _helper = createVehicle ["B_Quadbike_01_F", [0, 0, 1000], [], 0, "CAN_COLLIDE"];
_helper allowDamage false;
_helper lock 2;
hideObjectGlobal _helper;
clearItemCargoGlobal _helper;
clearMagazineCargoGlobal _helper;
clearWeaponCargoGlobal _helper;
clearBackpackCargoGlobal _helper;
_helper setVariable ["ANC_isHelper", true, true];
_helper
