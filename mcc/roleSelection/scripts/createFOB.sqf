private "_pos";
private "_dir";
private _side = "";
// Who activated the action?
params ["_item", "_caller", "_index"]; 

_pos 	= getpos _item;
_dir 	= getdir _item;
_side	= str (side _caller);
{
	 [[], compile format ["unassignVehicle objectFromNetID '%1'; objectFromNetID '%1' action ['eject', vehicle objectFromNetID '%1'];", netID _x]] remoteExec ["call", _x, false];
	 sleep 0.1;
} foreach crew _item;

deleteVehicle _item;
waituntil {isnull _item};

[_pos,_dir, _side, "FOB" ,true, true] remoteExec ["MCC_fnc_buildSpawnPoint", 2, false];  