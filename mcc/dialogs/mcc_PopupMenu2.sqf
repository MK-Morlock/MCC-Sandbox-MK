private _ok = false;
disableSerialization;
MCC_mcc_screen = _this select 0;


closeDialog 0;
waituntil {!dialog};

MCC_GUIInitDone = false; 
switch (MCC_mcc_screen) do
{
    case 0:
   {_ok = createDialog "MCC_Sandbox";
 	if !(_ok) exitWith { ["createDialog failed"] call MCCMK_fnc_hint };};
   case 1:
   { _ok = createDialog "MCC_Sandbox2";
	 if !(_ok) exitWith { ["createDialog failed"] call MCCMK_fnc_hint };};
   case 2:
   { _ok = createDialog "MCC_Sandbox3";
	 if !(_ok) exitWith { ["createDialog failed"] call MCCMK_fnc_hint };};
   case 3:
   { _ok = createDialog "MCC_Sandbox4";
	 if !(_ok) exitWith { ["createDialog failed"] call MCCMK_fnc_hint };};
   case 4:
   { _ok = createDialog ("MCC3D_Dialog" call MCC_fnc_dialogName);
	 if !(_ok) exitWith { ["createDialog failed"] call MCCMK_fnc_hint };};
   case 5:
   { _ok = createDialog (['mcc_groupGen', 'mcc_groupGenButtons'] select (profileNamespace getVariable ['MCC_consoleButtons', false]));
	 if !(_ok) exitWith { ["createDialog failed"] call MCCMK_fnc_hint };};
   case 6:
   { _ok = createDialog "MCC_Sandbox5";
	 if !(_ok) exitWith { ["createDialog failed"] call MCCMK_fnc_hint };};
};
