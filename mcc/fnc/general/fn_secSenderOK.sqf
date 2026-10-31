if (!isRemoteExecuted) exitWith {true};
private _id = remoteExecutedOwner;
if (_id == 2) exitWith {true};
if (!isServer) exitWith {false};
if ((admin _id) > 0) exitWith {true};
private _mm = missionNamespace getVariable ["mcc_missionmaker", ""];
((allPlayers + (entities "HeadlessClient_F")) findIf {
	(owner _x == _id) && {(_x isKindOf "HeadlessClient_F") || {(_mm != "") && {name _x == _mm}} || {!isNull (getAssignedCuratorLogic _x)}}
}) >= 0
