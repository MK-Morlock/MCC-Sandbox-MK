/*==================================================================MCC_fnc_RSunitSelectedClicked===============================================================================
// Call from a listbox only
==============================================================================================================================================================================*/
disableSerialization;
params ["_ctrl","_index"];
private "_data";
private _unit = objNull;
private _str = "";

_data = _ctrl lbData _index;
_unit = player getVariable ["interactWith",objNull];

_ctrl ctrlShow false;
ctrlDelete _ctrl;

if (isNull _unit) exitWith {};

switch (toLower _data) do {
    case "kick": {
    	if (player == leader _unit && _unit != player) then {
			[format ["%1 kicked %2 from the squad",name player, name _unit], 5] remoteExec ["MCC_fnc_rsMessage", group _unit, false];
			[_unit] join grpNull;

            if ((missionNamespace getVariable ["CP_activated",false]) && isPlayer _unit) then {
                [] remoteExec ["MCC_fnc_setGear", _unit, false];
            };
		};
    };

    case "commander": {
    	if (player == leader _unit && _unit != player) then {
    		["selectLeader", [_unit]] remoteExec ["MCC_fnc_secAction", group _unit, false];
    	};
    };

    case "teleport": {
    	if ((missionNamespace getVariable ["MCC_teleportToTeam",false]) && _unit in (units player) && _unit != player) then {
    		[_unit] execVM format ["%1mcc\general_scripts\mcc_SpawnToPosition.sqf",MCC_path];
    	};
    };
};