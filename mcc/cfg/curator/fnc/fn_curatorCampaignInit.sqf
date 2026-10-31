//============================================================MCC_fnc_curatorCampaignInit=============================================================================
// Starts MCC Campaign
//=======================================================================================================================================================================
private "_pos";
private _module = objNull;
private _factionArray = [];
private _resualt = [];
private _difficulty = 0;
private _missionMax = 0;
private _factionCiv = "";
private _factionPlayer = "";
private _sidePlayer = [];
private _factionEnemy = "";
private _sideEnemy = [];
private _sidePlayer2 = [];
private _tickets = 0;
private _missionRotation = 0;
private "_tileSize";
private _loadDb = false;
private _playMusic = 0;
private _preciseMarkers = false;
private _tileTransparency = 0;
private _keepOverStorage = false;
_module = _this param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

if (missionNamespace getVariable ["MCC_isCampaignRuning",false]) exitWith {systemChat "Campaign already running"};

//did we get here from the 2d editor?
if (typeName (_module getVariable ["factionPlayer",true]) == typeName "") exitWith {

	_factionPlayer = _module getVariable ["factionPlayer","BLU_F"];
	_sidePlayer = [([_factionPlayer] call MCC_fnc_factionSide)] call BIS_fnc_sideType;
	_factionEnemy = _module getVariable ["factionEnemy","OPF_F"];
	_sideEnemy = [([_factionEnemy] call MCC_fnc_factionSide)] call BIS_fnc_sideType;
	_factionCiv	= _module getVariable ["factionCiv","CIV_F"];
	//Eden can hand these over as text; make them numbers (a text value stopped the campaign from starting)
	private _num = {
		params ["_v", "_d"];
		if (_v isEqualType "") then {_v = parseNumber _v};
		if (_v isEqualType 0) then {_v} else {_d}
	};
	_missionMax = [_module getVariable ["missionMax",10], 10] call _num;
	_difficulty = [_module getVariable ["difficulty",20], 20] call _num;
	//Rival players side: 0 OPFOR, 1 BLUFOR, 2 Independent, 3 Civilian, 7 none (BIS_fnc_sideType has no side for 7)
	_sidePlayer2 = [east, west, resistance, civilian] param [[_module getVariable ["factionRivalPlayer",7], 7] call _num, sideLogic];
	_tickets = [_module getVariable ["tickets",100], 100] call _num;
	_missionRotation = [_module getVariable ["missionRotation",1], 1] call _num;
	_tileSize = ([_module getVariable ["tileSize",250], 250] call _num) max 200;
	_loadDb = _module getVariable ["loadDB",false];
	if !(_loadDb isEqualType true) then {_loadDb = ([_loadDb, 0] call _num) == 1};
	_playMusic = [_module getVariable ["playMusic",1], 1] call _num;
	// Objective markers: 0 = Area (classic, offset up to ~400 m), 1 = Precise. Accept number, text or bool.
	_preciseMarkers = _module getVariable ["objectiveMarkers",1];
	if (_preciseMarkers isEqualType "") then {_preciseMarkers = parseNumber _preciseMarkers};
	if (_preciseMarkers isEqualType 0) then {_preciseMarkers = _preciseMarkers == 1};
	if !(_preciseMarkers isEqualType true) then {_preciseMarkers = false};
	_tileTransparency = _module getVariable ["tileTransparency",0];
	if (_tileTransparency isEqualType "") then {_tileTransparency = parseNumber _tileTransparency};
	if !(_tileTransparency isEqualType 0) then {_tileTransparency = 0};
	// percentages typed as 0-100 are accepted too
	if (_tileTransparency > 1) then {_tileTransparency = _tileTransparency / 100};
	_tileTransparency = (_tileTransparency max 0) min 1;
	// module placed with the older "Hide Map Overlay" checkbox
	if ((_module getVariable ["hideTiles",false]) isEqualTo true) then {_tileTransparency = 1};
	_keepOverStorage = _module getVariable ["overStorage",0];
	if (_keepOverStorage isEqualType "") then {_keepOverStorage = parseNumber _keepOverStorage};
	_keepOverStorage = (_keepOverStorage isEqualTo 1) || {_keepOverStorage isEqualTo true};
	private _playersOverride = _module getVariable ["playersCount", 0];
	if (_playersOverride isEqualType "") then {_playersOverride = parseNumber _playersOverride};
	if !(_playersOverride isEqualType 0) then {_playersOverride = 0};
	if (isNil "MCC_MWContentModes") then {MCC_MWContentModes = createHashMap};
	MCC_MWContentModes set [toLower _factionPlayer, (([_module getVariable ["playerContent", 1], 1] call _num) max 0) min 2];
	MCC_MWContentModes set [toLower _factionCiv, (([_module getVariable ["civContent", 1], 1] call _num) max 0) min 2];
	MCC_MWContentModes set [toLower _factionEnemy, (([_module getVariable ["enemyContent", 1], 1] call _num) max 0) min 2];
	MCC_campaignSpreadIndex = (([_module getVariable ["forceSpread", 1], 1] call _num) max 0) min 2;

	//Start ambient civilians
	[_sidePlayer,_factionPlayer,_sideEnemy,_factionEnemy,_factionCiv,_missionMax,_difficulty,_sidePlayer2,_tickets,_missionRotation,_tileSize,_loadDb,_playMusic,_preciseMarkers,_tileTransparency,_keepOverStorage,round (_playersOverride max 0)] remoteExec ["MCC_fnc_campaignInit",2];


	//Start day/night cycle
	[_sidePlayer,_sidePlayer2] remoteExec ["MCC_fnc_dayCycle", 2, false];
};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_pos = getpos _module;

_factionArray = [];
{
	_factionArray pushBack (format ["%1(%2)",_x select 0,_x select 1]);
} forEach U_FACTIONS;

 _resualt = ["Starts MCC Campaign - Need: MCC Start Location",[
 						["Players Faction",_factionArray,"",(U_FACTIONS findIf {toUpper (_x select 2) == "BLU_F"}) max 0],
 						["Players Content",["Faction only","Faction + Creator DLC","All loaded mods"],"Which units and vehicles the players' faction may use: its own, plus Creator DLC, or every loaded mod",1],
 						["Rival Players Side",["East","West","Resistance","None"],"",3],
 						["Enemy Faction",_factionArray,"",(U_FACTIONS findIf {toUpper (_x select 2) == "OPF_F"}) max 0],
 						["Enemy Content",["Faction only","Faction + Creator DLC","All loaded mods"],"Which units and vehicles the enemy faction may use: its own, plus Creator DLC, or every loaded mod",1],
 						["Civilians Faction",_factionArray,"",(U_FACTIONS findIf {toUpper (_x select 2) == "CIV_F"}) max 0],
 						["Civilian Content",["Faction only","Faction + Creator DLC","All loaded mods"],"Which units and vehicles the civilian faction may use: its own, plus Creator DLC, or every loaded mod",1],
 						["Force Spread",["Tight","Normal","Wide"],"Where enemy forces start: Tight = near the centre, Normal = original MCC, Wide = evenly over the zone",1],
 						["Missions Before Campaign Ends",50],
 						["Difficulty",["Easy","Medium","Hard"]],
 						["Intro",["Cinematic","Pop-Up","None"]],
 						["Tickets",200],
 						["Players (enemy scaling)",32,"Enemy numbers are sized for at least this many players (0 = count the real players). Enemies per mission: about 5, 10 or 20 per player (Easy / Medium / Hard), rising 10% after each mission.",0],
 						["Missions Rotation",10,"How many missions are played in the same area before the campaign moves on (1 = a new area for every mission)",1],
 						["Tile Size",500],
 						["Map Overlay Transparency",["0% (normal)","25%","50%","75%","90%","100% (hidden)"],"Makes the red/blue territory squares more see-through. Shading differences are kept; 100% hides them. Territory, enemy spawns and saving are unaffected."],
 						["Objective Markers",["Area (search)","Precise"],"Area: task markers are placed up to ~400 m from the objective and must be searched for (classic MCC campaign). Precise: markers sit on the objective with a 3D icon.",1],
 						["Resources Over Storage Limit",["Cut at mission end (original)","Keep (lose 10% per hour)"],"What happens to resources above your storage limit when a campaign mission ends."],
 						["Load From DB",false]
 					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

_factionPlayer = (U_FACTIONS select (_resualt select 0)) select 2;
_sidePlayer = [([_factionPlayer] call MCC_fnc_factionSide)] call BIS_fnc_sideType;
_sidePlayer2 = [east,west,resistance,sideLogic] select (_resualt select 2);
_factionEnemy = (U_FACTIONS select (_resualt select 3)) select 2;
_sideEnemy = [([_factionEnemy] call MCC_fnc_factionSide)] call BIS_fnc_sideType;
_factionCiv	= (U_FACTIONS select (_resualt select 5)) select 2;
_missionMax = _resualt select 8;
_difficulty = ((_resualt select 9)+1)*10;
_playMusic = _resualt select 10;
_tickets = _resualt select 11;
private _playersOverride = round (_resualt select 12);
_missionRotation = _resualt select 13;
_tileSize = _resualt select 14;
_tileTransparency = [0, 0.25, 0.5, 0.75, 0.9, 1] select ((_resualt select 15) max 0);
_preciseMarkers = (_resualt select 16) == 1;
_keepOverStorage = (_resualt select 17) == 1;
_loadDb = _resualt select 18;
if (isNil "MCC_MWContentModes") then {MCC_MWContentModes = createHashMap};
MCC_MWContentModes set [toLower _factionPlayer, ((_resualt select 1) max 0) min 2];
MCC_MWContentModes set [toLower _factionCiv, ((_resualt select 6) max 0) min 2];
MCC_MWContentModes set [toLower _factionEnemy, ((_resualt select 4) max 0) min 2];
MCC_campaignSpreadIndex = ((_resualt select 7) max 0) min 2;
publicVariableServer "MCC_MWContentModes";
publicVariableServer "MCC_campaignSpreadIndex";

//Start ambient civilians
[_sidePlayer,_factionPlayer,_sideEnemy,_factionEnemy,_factionCiv,_missionMax,_difficulty,_sidePlayer2,_tickets,_missionRotation,_tileSize,_loadDb, _playMusic,_preciseMarkers,_tileTransparency,_keepOverStorage,_playersOverride] remoteExec ["MCC_fnc_campaignInit",2];

//Start day/night cycle
[_sidePlayer,_sidePlayer2] remoteExec ["MCC_fnc_dayCycle", 2, false];

deleteVehicle _module;