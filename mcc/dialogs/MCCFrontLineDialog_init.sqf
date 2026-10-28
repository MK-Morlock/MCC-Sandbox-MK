#define MCC_MINIMAP 9000
#define MCCFrontLineDialog_IDD 29891

#define FACTIONCOMBO 1001
#define MCC_MWDifficultyIDC 6006
#define MCC_MWVehiclesIDC 6010
#define MCC_MWArmorIDC 6011
#define MCC_MWIEDIDC 6012
#define MCC_MWFortificationIDC 6016
#define MCC_MWDebugComboIDC 6019
#define MCC_MWArtilleryIDC 6021

private _comboBox = controlNull;
private _displayname = "";
private _missionTypeIcons = [];
disableSerialization;

uiNamespace setVariable ["MCC_FLDialog", _this select 0];
params ["_mccdialog"];


_missionTypeIcons = missionNamespace getVariable ["MCC_MWMissionTypeIcons",[]];

_comboBox = _mccdialog displayCtrl FACTIONCOMBO;		//fill combobox CFG factions
	lbClear _comboBox;
	{
		_displayname = format ["%1(%2)",_x select 0,_x select 1];
		_comboBox lbAdd _displayname;
	} foreach U_FACTIONS;
	_comboBox lbSetCurSel (((profileNamespace getVariable ["MCC_FLFactionIndex", MCC_faction_index]) min ((lbSize _comboBox) - 1)) max 0);


//General Markers
_comboBox = _mccdialog displayCtrl MCC_MWDebugComboIDC;
_comboBox ctrlSetChecked [(profileNamespace getVariable ["MCC_MWDebugIndex",0]),true];


//Difficulty
_comboBox = _mccdialog displayCtrl MCC_MWDifficultyIDC;
_comboBox ctrlSetChecked [(profileNamespace getVariable ["MCC_MWDifficultyIndex",0]),true];

//Vehicles
_comboBox = _mccdialog displayCtrl MCC_MWVehiclesIDC;
_comboBox ctrlSetChecked [(profileNamespace getVariable ["MCC_MWVehiclesIndex",2]),true];

//Armor
_comboBox = _mccdialog displayCtrl MCC_MWArmorIDC;
_comboBox ctrlSetChecked [(profileNamespace getVariable ["MCC_MWArmorIndex",2]),true];

//Artillery
_comboBox = _mccdialog displayCtrl MCC_MWArtilleryIDC;
lbClear _comboBox;
{
	_displayname = _x;
	_comboBox lbAdd _displayname;
} foreach ["No","Mortars","Self Propelled Artillery","Random"];
_comboBox lbSetCurSel (profileNamespace getVariable ["MCC_MWArtilleryIndex",3]);

//IED
_comboBox = _mccdialog displayCtrl MCC_MWIEDIDC;
_comboBox ctrlSetChecked [(profileNamespace getVariable ["MCC_MWIEDIndex",2]),true];

//Roadblocks
_comboBox = _mccdialog displayCtrl MCC_MWFortificationIDC;
_comboBox ctrlSetChecked [(profileNamespace getVariable ["MCC_MWFortificationIDC",2]),true];

//Minefield / fortification markers: show the saved choice (they always opened unticked)
(_mccdialog displayCtrl 6013) ctrlSetChecked [(profileNamespace getVariable ["MCC_FLIEDmarkersTittleIndex",0]), true];
(_mccdialog displayCtrl 6017) ctrlSetChecked [(profileNamespace getVariable ["MCC_FLFortificationsmarkersCombo",0]), true];

//Depth, task, attacker (Front Lines additions)
_comboBox = _mccdialog displayCtrl 6030;
lbClear _comboBox;
{_comboBox lbAdd _x} forEach ["Shallow (600 m)","Standard (1.5 km)","Deep (3 km)"];
_comboBox lbSetCurSel (profileNamespace getVariable ["MCC_FLDepthIndex",1]);

_comboBox = _mccdialog displayCtrl 6031;
lbClear _comboBox;
{_comboBox lbAdd _x} forEach ["No task","Break through"];
_comboBox lbSetCurSel (profileNamespace getVariable ["MCC_FLTaskIndex",1]);

_comboBox = _mccdialog displayCtrl 6032;
lbClear _comboBox;
_comboBox lbAdd "None";
{_comboBox lbAdd format ["%1(%2)",_x select 0,_x select 1]} forEach U_FACTIONS;
_comboBox lbSetCurSel 0;

_comboBox = _mccdialog displayCtrl 6033;
lbClear _comboBox;
{_comboBox lbAdd _x} forEach ["When a player is near (max 15 min)","Immediately","After 2 minutes","After 5 minutes","After 10 minutes","After 15 minutes","After 20 minutes","After 30 minutes"];
_comboBox lbSetCurSel (profileNamespace getVariable ["MCC_FLAttackStartIndex",0]);

_comboBox = _mccdialog displayCtrl 6034;
lbClear _comboBox;
{_comboBox lbAdd _x} forEach ["None","Aerial","Motorized","Random"];
_comboBox lbSetCurSel (profileNamespace getVariable ["MCC_FLReinforcementIndex",0]);

_comboBox = _mccdialog displayCtrl 6035;
lbClear _comboBox;
{_comboBox lbAdd _x} forEach ["Players are near","Always"];
_comboBox lbSetCurSel (profileNamespace getVariable ["MCC_FLReinforcementWaitIndex",0]);

((_mccdialog displayCtrl 0)) ctrlSetStructuredText parseText "<t size='0.85' color='#E2EEE0'>Choose the defending faction and options, press Generate Front Line, draw the line on the map, then click the side the attack comes from.</t>";


