/*==================================================================MCC_fnc_clearPersistentData=========================================================================
	Clear all data from saved files

	EXAMPLE
		[] spawn MCC_fnc_clearPersistentData;

	<IN>
		Nothing


	<OUT>

		Nothing

//==============================================================================================================================================*/
private "_side";
private _fileName = "";
_fileName = "MCC_campaign";

//Clear Save stuff for each side
{
	_side = _x;

	//Tiles
	0 spawn {
		for "_y" from 0 to 100 step 1 do {
			[format ["MCC_campaign_%1_%2",worldname,missionName], "CAMPAIGN_MARKERS", format ["row_%1", _y], "write",[],true] call MCC_fnc_handleDB;
		};
	};

	//tickets
	[format ["%1_%2_%3",_fileName, worldname,missionName], "TICKETS", str _side, "write",([_side] call BIS_fnc_respawnTickets),true] call MCC_fnc_handleDB;

	//resources
	[format ["%1_%2_%3",_fileName, worldname,missionName], "RESOURCES", str _side, "write",[1500,500,200,200,200],true] call MCC_fnc_handleDB;

	//civilian relation
	[format ["%1_%2_%3",_fileName, worldname,missionName], "CIV_RELATION", str _side, "write",0.5,true] call MCC_fnc_handleDB;


	//CAS
	[format ["%1_%2_%3",_fileName, worldname,missionName], "CAS", str _side, "write",[],true] call MCC_fnc_handleDB;

	//air drop
	[format ["%1_%2_%3",_fileName, worldname,missionName], "AIR_DROP", str _side, "write",[],true] call MCC_fnc_handleDB;

	//artillery
	[format ["%1_%2_%3",_fileName, worldname,missionName], "ARTILLERY", str _side, "write",0,true] call MCC_fnc_handleDB;

	//start locations
	[format ["%1_%2_%3",_fileName, worldname,missionName], "SPAWN_POINTS", str _side, "write",[],true] call MCC_fnc_handleDB;

} forEach [east,west,resistance];

//Arty type
[format ["%1_%2_%3",_fileName, worldname,missionName], "ARTILLERY", "TYPE", "write",[],true] call MCC_fnc_handleDB;

//(MK) Valor: the campaign ID cleared (the next campaign gets a new one) and the generation moved on; everyone online
// back to 50, kept from now on under the new key
private _cdb = format ["MCC_campaign_%1_%2", worldName, missionName];
private _gen = [_cdb, "CREDITS", "GEN", "read", 0, true] call MCC_fnc_handleDB;
if !(_gen isEqualType 0) then {_gen = 0};
[_cdb, "CREDITS", "GEN", "write", _gen + 1, true] call MCC_fnc_handleDB;
[_cdb, "CAMPAIGN", "ID", "write", "", true] call MCC_fnc_handleDB;
{_x setVariable ["MCC_valorPoints", 50, true]} forEach (allPlayers - (entities "HeadlessClient_F"));
if ((missionNamespace getVariable ["MCCMK_creditKey", ""]) != "") then {
	private _newKey = if (missionNamespace getVariable ["MCCMK_campaignSetupDone", false]) then {
		private _cid = format ["c%1%2", (systemTime apply {str _x}) joinString "", floor random 1000];
		[_cdb, "CAMPAIGN", "ID", "write", _cid, true] call MCC_fnc_handleDB;
		format ["%1_%2_%3", worldName, missionName, _cid]
	} else {[] call MCCMK_fnc_creditGen};
	[_newKey] call MCCMK_fnc_creditKeySet;
};
["INFO", "credits", "Delete data: Valor cleared", []] call MCC_fnc_log;

//Save RTS constuct - every few minutes heavy on resources
[format ["%1_%2_%3",_fileName, worldname,missionName], "BUILDINGS", "BUILDINGS", "write",[],true] call MCC_fnc_handleDB;

//Clear survival stuff
//resources
[format ["%1_%2_%3","MCC_SERVER_SURVIVAL", worldname,missionName], "RESOURCES", str _side, "write",[1500,500,200,200,200],true] call MCC_fnc_handleDB;