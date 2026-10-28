/*================================================================== MCC_fnc_consoleFolderClose ==================================================================
	Commander console: slide a side folder (CAS 2010, Supply Drop 2020, Evac 2030) back in, as its close tab does, so the
	map can be clicked after Call.
	<IN>	0: NUMBER folder group idc
==============================================================================================================================================================*/
disableSerialization;
params [["_idc", 2010]];
private _d = findDisplay 2993;
if (isNull _d) exitWith {};
private _grp = _d displayCtrl _idc;
private _pos = ctrlPosition _grp;
_pos set [2, 0];
_grp ctrlSetPosition _pos;
_grp ctrlCommit 0.1;
private _tab = _d displayCtrl (_idc - 999);	//the tab that opens it again
_pos = ctrlPosition _tab;
_pos set [2, 0.02 * safezoneW];
_tab ctrlSetPosition _pos;
_tab ctrlCommit 0;
