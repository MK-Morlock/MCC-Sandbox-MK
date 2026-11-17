/*
    ANC_fnc_itemName  (any computer)
    The display name of a weapon, magazine, item, backpack or glasses class (the class itself if it has none). [class]
*/
params ["_c"];
private _n = getText (configFile >> "CfgWeapons" >> _c >> "displayName");
if (_n isEqualTo "") then {_n = getText (configFile >> "CfgMagazines" >> _c >> "displayName")};
if (_n isEqualTo "") then {_n = getText (configFile >> "CfgVehicles" >> _c >> "displayName")};
if (_n isEqualTo "") then {_n = getText (configFile >> "CfgGlasses" >> _c >> "displayName")};
[_n, _c] select (_n isEqualTo "")
