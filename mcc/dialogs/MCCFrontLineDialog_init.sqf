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

private ["_mccdialog","_comboBox","_displayname","_missionTypeIcons"];
disableSerialization;

uiNamespace setVariable ["MCC_FLDialog", _this select 0];
_mccdialog = _this select 0;


_missionTypeIcons = missionNamespace getVariable ["MCC_MWMissionTypeIcons",[]];

_comboBox = _mccdialog displayCtrl FACTIONCOMBO;		//fill combobox CFG factions
	lbClear _comboBox;
	{
		_displayname = format ["%1(%2)",_x select 0,_x select 1];
		_comboBox lbAdd _displayname;
	} foreach U_FACTIONS;
	_comboBox lbSetCurSel MCC_faction_index;


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