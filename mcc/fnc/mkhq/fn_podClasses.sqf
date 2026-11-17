// The side's Taru and pod classes (the Taru Pod Mod's, in the livery set for that side; vanilla otherwise).
// [side, pod kind ("fuel", "covered", "bench", ...)]  ->  [taru class, pod class]
params [["_side", west, [west]], ["_kind", "box", [""]]];
private _sl = ["B", "O", "I"] param [[west, east, resistance] find _side, "B"];
private _black = (missionNamespace getVariable [format ["MCC_taruLivery%1", _sl], [1, 0, 0] select (((["B", "O", "I"] find _sl)) max 0)]) == 1;
private _b = ["", "_black"] select _black;
private _heli = format ["MCC_%1_Heli_Transport_04%2_F", _sl, _b];
if !(isClass (configFile >> "CfgVehicles" >> _heli)) then {_heli = format ["O_Heli_Transport_04%1_F", _b]};
private _pod = format ["MCC_%1_Pod_Heli_Transport_04_%2%3_F", _sl, _kind, _b];
if !(isClass (configFile >> "CfgVehicles" >> _pod)) then {_pod = format ["Land_Pod_Heli_Transport_04_%1%2_F", _kind, _b]};
[_heli, _pod]
