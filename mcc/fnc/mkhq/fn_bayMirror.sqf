/*
	MCCMK_fnc_bayMirror - (client) while the camera is on the aircraft carrying the player's boat (third person - see
	MCCMK_fnc_boardingInit), MCC's own actions are copied onto that aircraft so they stay in the scroll menu (Arma shows the
	menu of whatever the camera is on): Unload watercraft, Scuttle, Scuttle helicopter, Repair helicopter, Plug the leak,
	and MCC's console entries (Commander - Console, Squad Leader - PDA, --= MCC =--). [aircraft, on?] - off takes them away.
	Arma's own boat entries (its seats, its engine) can't be copied.
*/
params [["_a", objNull], ["_on", true]];
if (isNull _a) exitWith {};
{_a removeAction _x} forEach (_a getVariable ["MCCMK_bayActs", []]);
_a setVariable ["MCCMK_bayActs", []];
if (!_on) exitWith {};
private _ids = [];
if (!isNil "MCCMK_boardingAdd") then {_ids append ([_a, ["MCCMK_fltUnload", "MCCMK_fltScuttle", "MCCMK_fltScuttleHeli", "MCCMK_fltRepair", "MCCMK_fltPlug"]] call MCCMK_boardingAdd)};
private _path = missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"];
_ids pushBack (_a addAction ["<img size='1.5' image='\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa'/><t color='#FFCC01'>Commander - Console</t>", _path + "mcc\dialogs\mcc_PopupMenu.sqf", [nil, nil, nil, nil, 1], -1, false, true, "",
	format ["((MCC_server getVariable ['CP_commander%1','']) == getPlayerUID _this) && (missionNamespace getVariable ['MCC_allowConsole',true]) && (missionNamespace getvariable ['MCC_showActionKey',true])", side player]]);
_ids pushBack (_a addAction ["<t color='#FFCC01'>Squad Leader - PDA</t>", _path + "mcc\dialogs\mcc_PopupMenu.sqf", [nil, nil, nil, nil, 3], -1, false, true, "",
	"((count units _this > 1) && (leader _this == _this)) && (missionNamespace getVariable ['MCC_allowsqlPDA',true]) && 'ItemGPS' in (assignedItems _this) && (missionNamespace getvariable ['MCC_showActionKey',true])"]);
_ids pushBack (_a addAction ["<t color='#99FF00'>--= MCC =--</t>", _path + "mcc\dialogs\mcc_PopupMenu.sqf", [nil, nil, nil, nil, 0], 0, false, false, "",
	"(getplayerUID player in (missionNamespace getvariable ['MCC_allowedPlayers',[]]) || 'all' in (missionNamespace getvariable ['MCC_allowedPlayers',['all']]) || (serverCommandAvailable '#kick' && missionNamespace getvariable ['MCC_allowAdmin',true]) || (isServer && missionNamespace getvariable ['MCC_allowAdmin',true]) || (player getvariable ['MCC_allowed',false])) && (missionNamespace getvariable ['MCC_showActionKey',true])"]);
_a setVariable ["MCCMK_bayActs", _ids];
