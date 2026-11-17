/*============================== MCC_fnc_halt ===========================================
	Stops a Mission Wizard run and tells the player why.

	Shows a hint + chat line, writes the reason to the RPT and leaves every dialog closable (a message box can end up
	under MCC's own dialogs with nothing able to close it).
*/

params [
	["_msg","",[""]]
];

missionNamespace setVariable ["MCC_MWisGenerating", false];

if (_msg != "") then {
	["ERROR", "fn_halt", "%1", [_msg]] call MCC_fnc_log;
	if (hasInterface) then {
		[parseText format ["<t color='#C48214' size='1.2'>MCC</t><br/>%1", _msg]] call MCCMK_fnc_hint;
		systemChat _msg;
	};
};

endLoadingScreen;
