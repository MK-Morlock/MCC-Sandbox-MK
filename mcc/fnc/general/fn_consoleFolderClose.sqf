/*================================================================== MCC_fnc_consoleFolderClose ==================================================================
	Commander console: slide a side folder (CAS 2010, Supply Drop 2020, Evac 2030) back in, as its close tab does, so the
	map can be clicked after Call.
	<IN>	0: NUMBER folder group idc
==============================================================================================================================================================*/
params [["_idc", 2010]];
["close", _idc] call MCCMK_fnc_consoleFolder;	//(MK) back to its slot and its own size (it may have been opened downwards)
