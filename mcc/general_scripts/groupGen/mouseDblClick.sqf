//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private _ctrl = controlNull;
private _button = 0;
private _posX = 0;
private _posY = 0;
private _shift = false;
private _ctrlKey = false;
private _alt = false;
private _mccdialog = displayNull;
private _comboBox = controlNull;
private _displayname = "";
private _index = 0;
#define MCC_MINIMAP 9000

#define MCC_GroupGenWPCombo_IDC 9015
#define MCC_GroupGenWPformationCombo_IDC 9016
#define MCC_GroupGenWPspeedCombo_IDC 9017
#define MCC_GroupGenWPbehaviorCombo_IDC 9018

disableSerialization;
MCC_doubleClicked = true;
MCC_mapDblClickTime = diag_tickTime;
["end"] call MCCMK_fnc_wpChain;
params ["_params"];

_ctrl = _params select 0;
_button = _params select 1;
_posX = _params select 2;
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;

//Define which control
_mccdialog = (uiNamespace getVariable "MCC_groupGen_Dialog");
if (isnil "MCC_GroupGenGroupSelected") then {MCC_GroupGenGroupSelected = []};
if ((_button == 0) && (count MCC_GroupGenGroupSelected > 0) && !_ctrlKey)  then 								//Close Group info control
{
	//worldPos
	MCC_ConsoleWPpos = _ctrl ctrlMapScreenToWorld [_posX,_posY];
	ctrlShow [510,false];

	private _mkAir = (MCC_GroupGenGroupSelected findIf {!isNull _x && {(vehicle (leader _x)) isKindOf "Air"}}) >= 0;
	private _mkH = ([0.219914, 0.252901] select _mkAir) * safezoneH;
	private _mkBy = ([0.175932, 0.208919] select _mkAir) * safezoneH;
	{
		private _mkC = _mccdialog displayCtrl _x;
		private _mkP = ctrlPosition _mkC;
		_mkC ctrlSetPosition [_mkP select 0, _mkBy, _mkP select 2, _mkP select 3];
		_mkC ctrlCommit 0;
	} forEach [9021, 9022, 9023, 9024];
	(_mccdialog displayCtrl 9025) ctrlSetPosition [0, 0, 0.189063 * safezoneW, _mkH];
	(_mccdialog displayCtrl 9025) ctrlCommit 0;
	{(_mccdialog displayCtrl _x) ctrlShow _mkAir} forEach [9019, 9020];
	_comboBox = _mccdialog displayCtrl 9019;
	["fill", [_comboBox, "fly", MCC_GroupGenGroupSelected]] call MCCMK_fnc_wpCombos;

	(ctrlPosition (_mccdialog displayCtrl MCC_MINIMAP)) params ["_mkMx", "_mkMy", "_mkMw", "_mkMh"];
	_posX = (_posX min (_mkMx + _mkMw - (0.189063 * safezoneW))) max _mkMx;
	_posY = (_posY min (_mkMy + _mkMh - _mkH)) max _mkMy;
	(uiNamespace getVariable ["MCCMK_miBoxMCC", controlNull]) ctrlShow false;

	//Reveal WP  Bckgr
	(_mccdialog displayctrl 510) ctrlSetPosition [_posX,_posY,0,0];
	((findDisplay 2994) displayCtrl 9026) cbSetChecked (profileNamespace getVariable ["MCCMK_wpChainOn", false]);
	ctrlShow [510,true];
	(_mccdialog displayctrl 510) ctrlCommit 0;
	(_mccdialog displayctrl 510) ctrlSetPosition [_posX, _posY,0.189063 * safezoneW,_mkH];
	(_mccdialog displayctrl 510) ctrlCommit 0.1;
	waituntil {ctrlCommitted (_mccdialog displayctrl 510)};
	{(_mccdialog displayCtrl _x) ctrlShow _mkAir} forEach [9019, 9020];

	//Fill WP types
	_comboBox = _mccdialog displayCtrl MCC_GroupGenWPCombo_IDC;
	lbClear _comboBox;
	private _mkNames = ["Move", "Destroy", "Get In", "Search & Destroy", "Join Group", "Join Group As Leader", "Get Out", "Cycle Waypoints", "Load", "Unload", "Troops Unload", "Hold", "Sentry", "Guard", "Support", "Get In Nearest", "Dismiss", "Helicopter - Land", "Helicopter - Get in", "Artillery - Fire Mission", "Loiter", "Taru - Pick up pod", "Taru - Winch drop pod", "Taru - Parachute pod", "Taru - Release pod", "", "", "", "", "", "", "", "Helicopter - Water landing (engine on)", "Helicopter - Water landing (engine off)", "", "Helicopter - Boat drop (landed)", "Helicopter - Boat drop (low hover)", "Boat - Load into helicopter"];
	private _mkRules = ["all", "all", "foot", "all", "all", "all", "veh", "all", "cargo", "pass", "pass", "all", "all", "all", "support", "foot", "all", "heli", "heli", "arty", "air", "taru", "taru", "taru", "taru", "all", "all", "all", "all", "all", "all", "all", "carrier", "carrier", "all", "carrierboat", "carrierboat", "boat"];
	{
		if ([_mkRules select _x, MCC_GroupGenGroupSelected select {!isNull _x}] call MCCMK_fnc_wpCan) then {
			_index = _comboBox lbAdd (_mkNames select _x);
			_comboBox lbSetValue [_index, _x];
		};
	} forEach [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,32,33,35,36,37];
	_comboBox lbSetCurSel 0;


	//Fill WP  Formation
	_comboBox = _mccdialog displayCtrl MCC_GroupGenWPformationCombo_IDC;
	["fill", [_comboBox, "formation", MCC_GroupGenGroupSelected]] call MCCMK_fnc_wpCombos;


	//Fill WP  Speed
	_comboBox = _mccdialog displayCtrl MCC_GroupGenWPspeedCombo_IDC;
	["fill", [_comboBox, "speed", MCC_GroupGenGroupSelected]] call MCCMK_fnc_wpCombos;


	//Fill WP  Behavior
	_comboBox = _mccdialog displayCtrl MCC_GroupGenWPbehaviorCombo_IDC;
	["fill", [_comboBox, "behaviour", MCC_GroupGenGroupSelected]] call MCCMK_fnc_wpCombos;
};

//Quick WP
if (_button == 0 && _ctrlKey && (count MCC_GroupGenGroupSelected > 0)) then
{
	private _pos = [];

	_pos = _ctrl ctrlmapscreentoworld [_posX,_posY];

	//Call the server to handle WP
	[1,_pos,[0,"NO CHANGE","NO CHANGE","UNCHANGED","UNCHANGED","true","",0],MCC_GroupGenGroupSelected] remoteExec ["MCC_fnc_manageWp", 2, false];
};

MCC_doubleClicked = false;
