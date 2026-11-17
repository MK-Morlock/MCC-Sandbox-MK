/*
	MCCMK_fnc_evacLabel - an Evac helicopter's line in the Evac lists: [vehicle] -> "Alpha 2-3 - CH-67 Huron". Its own name
	if the mission gives it one, else its crew's callsign (the label of its icon on the map), then its type; "(no driver)"
	when it has no live pilot; "N/A" when it is gone. (MCC wrote the vehicle itself: with no name of its own, current Arma
	writes its internal reference - "1c1ee65a040# 1781531: heli_transport_03_f.p3d B_Heli_Transport_03_F".)
*/
params [["_v", objNull]];
if (isNull _v || {!alive _v}) exitWith {"N/A"};
private _type = getText (configFile >> "CfgVehicles" >> typeOf _v >> "displayName");
private _d = driver _v;
private _name = vehicleVarName _v;
if (_name == "") then {
	private _g = if (!isNull _d) then {group _d} else {group (effectiveCommander _v)};
	if (!isNull _g) then {_name = groupId _g};
};
format ["%1%2%3", if (_name == "") then {""} else {_name + " - "}, _type, ["", " (no driver)"] select !(alive _d)]
