#define MCC_TRIGGERS_ACTIVATE 3064
#define MCC_TRIGGERS_CONDITION 3065
#define MCC_TRIGGERS_SHAPE 3066
#define MCC_TRIGGERS_LIST 3067
#define MCC_TRIGGERS_NAME 3068

#define MCC_TRIGGERS_TIME_MIN 3071
#define MCC_TRIGGERS_TIME_MAX 3072
#define MCC_TRIGGERS_STAT_COND 3073
#define MCC_TRIGGERS_STAT_ACTIVE 3074
#define MCC_TRIGGERS_STAT_DEACTIVE 3075

disableSerialization;
private "_dlg";
private "_size";
private "_activate";
private "_cond";
private "_shape";
private _text = controlNull;
private "_pos";
private _nul = [];
private "_triggerSelected";
private _timeMin = controlNull;
private _timeMax = controlNull;
private _stateCond = controlNull;
private _stateDiac = controlNull;

_dlg = (uiNamespace getVariable "MCC_groupGen_Dialog");
params ["_type"];

switch (_type) do
{
   case 0:	//Mapclick Generate
	{ 
		MCC_capture_state = true;
		MCC_drawTriggers = true;
		Mshape = (MCC_shapeMarker select (lbCurSel MCC_TRIGGERS_SHAPE));
		Mcolor = "ColorOrange";
		Mtype = "SOLID";
		hint "Left click on and drag a box on the map to create a trigger";
	};
	
	case 1:	//Generate
	{ 
		ctrlEnable [1014,true];
		_pos 		= _this select 1;	
		_size 		= _this select 2; 
		_activate 	= MCC_musicActivateby_array select (lbCurSel MCC_TRIGGERS_ACTIVATE);
		_cond 		= MCC_musicCond_array select (lbCurSel MCC_TRIGGERS_CONDITION);
		_text 		= ctrlText (_dlg displayCtrl MCC_TRIGGERS_NAME);
		_timeMin	= call compile (ctrlText (_dlg displayCtrl MCC_TRIGGERS_TIME_MIN));
		_timeMax	= call compile (ctrlText (_dlg displayCtrl MCC_TRIGGERS_TIME_MAX));
		_stateCond	= (ctrlText (_dlg displayCtrl MCC_TRIGGERS_STAT_COND));
		_stateDiac	= (ctrlText (_dlg displayCtrl MCC_TRIGGERS_STAT_DEACTIVE));
		MCC_capture_var = "";
		hint "Trigger created: capture MCC actions that you want to link to that trigger, press Stop Capturing to finish";
		waituntil {(!MCC_capture_state)};
		mcc_safe = mcc_safe + FORMAT ['
							MCC_capture_var = %7;
							script_handler = [0, %1, %2, "%3", "%4", "%5", "%6", MCC_capture_var,%8,%9,"%10","%11"] execVM "%12mcc\general_scripts\triggers\triggers_execute.sqf";
							waitUntil {scriptDone script_handler};'								 
							,_pos
							,_size
							,_activate
							,_cond
							,Mshape
							,_text
							,toArray MCC_capture_var  
							,_timeMin
							,_timeMax
							,_stateCond
							,_stateDiac
							,MCC_path
							];
		[0, _pos, _size, _activate, _cond, Mshape, _text, toArray MCC_capture_var,_timeMin,_timeMax,_stateCond,_stateDiac] execVM MCC_path + "mcc\general_scripts\triggers\triggers_execute.sqf";

		while {dialog} do {closedialog 0};
		_ok = createDialog (['mcc_groupGen', 'mcc_groupGenButtons'] select (profileNamespace getVariable ['MCC_consoleButtons', false]));
	};
	   
   case 2:	//Mapclick Move trigger
	{
		hint "Left click on the map to move a trigger";
			onMapSingleClick  format[" 	hint 'Trigger moved.'; 
								_nul=[3,_pos] execVM '%1mcc\general_scripts\triggers\triggers.sqf';
								onMapSingleClick """";",MCC_path];
	};
	
   case 3:	// Move trigger
	{
		_pos = _this select 1;
		_text = MCC_triggers select (lbCurSel MCC_TRIGGERS_LIST) select 0;
		_triggerSelected = MCC_triggers select (lbCurSel MCC_TRIGGERS_LIST) select 1;
		[1,_pos, _text, _triggerSelected] execVM MCC_path + 'mcc\general_scripts\triggers\triggers_execute.sqf';
								
	};
};