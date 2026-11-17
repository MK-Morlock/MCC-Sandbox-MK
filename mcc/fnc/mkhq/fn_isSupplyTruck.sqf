/*
	MCCMK_fnc_isSupplyTruck - can this vehicle take logistics crates (the Logistics crate screen)? Any vehicle that can
	carry cargo with Arma's vehicle-in-vehicle (HEMTT Flatbed, Blackfish, landing craft ...), and cargo trucks
	(MCCMK_fnc_isCargoTruck), where MCC places the crates itself. Troop transports, fuel, ammo, repair and medical trucks
	can't. [vehicle] -> boolean
*/
params [["_v", objNull, [objNull]]];
if (isNull _v) exitWith {false};
(isClass (configFile >> "CfgVehicles" >> typeOf _v >> "VehicleTransport" >> "Carrier")) || {[_v] call MCCMK_fnc_isCargoTruck}
