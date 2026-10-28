//MCC_fnc_loginDialog

private _ar = [];
private _null = scriptNull;
private _isAdmin = false;
private _t = 0;
private _missionMaker = "";

//update request number
mcc_request= (missionNamespace getVariable ["mcc_request",0])+1;

_isAdmin = serverCommandAvailable "#kick" || isServer;
_ar = [
	player
	, name (player)
	, mcc_request
	, _isAdmin
	];

// Send data over the network, or when on server, execute directly
_null = _ar remoteExec ["mcc_fnc_login", 2, false];

//Close dialog
_t = time + 5;
_missionMaker = missionNamespace getVariable ["mcc_missionmaker",""];

while {dialog} do {closeDialog 0; sleep 0.1};

while {(missionNamespace getVariable ["mcc_missionmaker",""]) == _missionMaker && time < _t} do {sleep 0.1};
_null = [nil,nil,nil,nil,0] execVM MCC_path + "mcc\dialogs\mcc_PopupMenu.sqf";



