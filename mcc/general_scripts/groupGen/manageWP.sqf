//Made by Shay_Gman (c) 09.10
#define MCC_GroupGenWPCombo_IDC 9015
#define MCC_GroupGenWPformationCombo_IDC 9016
#define MCC_GroupGenWPspeedCombo_IDC 9017
#define MCC_GroupGenWPbehaviorCombo_IDC 9018


private _wpType = 0;
private _groups = [];
private _wpFormation = [];
private _wpSpeed = [];
private _wpBehavior = [];

params ["_action"]; 
_wpType 	= lbValue [MCC_GroupGenWPCombo_IDC, lbCurSel MCC_GroupGenWPCombo_IDC];
private _mkFh = if (ctrlShown ((uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) displayCtrl 9019)) then {["readFly", [(uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) displayCtrl 9019]] call MCCMK_fnc_wpCombos} else {0};
//(MK) the water landings go by their own numbers (32 / 33 - MCC_fnc_manageWp)
private _wpTxt = lbText [MCC_GroupGenWPCombo_IDC, lbCurSel MCC_GroupGenWPCombo_IDC];
if (_wpTxt == "Helicopter - Water landing (engine on)") then {_wpType = 32};
if (_wpTxt == "Helicopter - Water landing (engine off)") then {_wpType = 33};
if (_wpTxt == "Helicopter - Boat drop (landed)") then {_wpType = 35};
if (_wpTxt == "Helicopter - Boat drop (low hover)") then {_wpType = 36};
_groups		= []; 
private _mkD = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
_wpFormation = ["read", [_mkD displayCtrl MCC_GroupGenWPformationCombo_IDC, "NO CHANGE"]] call MCCMK_fnc_wpCombos;
_wpSpeed = ["read", [_mkD displayCtrl MCC_GroupGenWPspeedCombo_IDC, "UNCHANGED"]] call MCCMK_fnc_wpCombos;
_wpBehavior = ["read", [_mkD displayCtrl MCC_GroupGenWPbehaviorCombo_IDC, "UNCHANGED"]] call MCCMK_fnc_wpCombos;

{
	_groups set [count _groups, _x];
	//_x setVariable ["MCC_disableUPSMON",true,true];
	_x setVariable ["GAIA_ZONE_INTEND",[], true];
	//(MK) as MCC: a waypoint from this console takes the group off the commander - unless "MCC console waypoints keep groups
	// commandable" is on (MCCMK Commander Console > Tracking)
	if !(missionNamespace getVariable ["MCCMK_wpKeepCommandable", false]) then {
		if ((_x getVariable ["MCC_canbecontrolled", false]) && {missionNamespace getVariable ["MCC_debug", false]}) then {["INFO", "commandable", "%1 set NOT commandable by a waypoint from the MCC console (option 'MCC console waypoints keep groups commandable' is off)", [groupId _x]] call MCC_fnc_log};
		_x setVariable ["MCC_canbecontrolled",false, true];
	};
} foreach MCC_GroupGenGroupSelected;

//Call the server to handle WP
[_action,MCC_ConsoleWPpos,[_wpType,"NO CHANGE",_wpFormation,_wpSpeed,_wpBehavior,"true","",0,_mkFh],_groups] remoteExec ["MCC_fnc_manageWp", 2, false];
if (_wpType == 0 && {_action in [0, 1]} && {profileNamespace getVariable ["MCCMK_wpChainOn", false]}) then {["start", [false, _groups, [0,"NO CHANGE",_wpFormation,_wpSpeed,_wpBehavior,"true","",0,_mkFh]]] call MCCMK_fnc_wpChain} else {["end"] call MCCMK_fnc_wpChain};	
	
ctrlShow [510,false];

