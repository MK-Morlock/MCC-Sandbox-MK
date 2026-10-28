/*============================== MCC_fnc_halt ===========================================
	Stops a Mission Wizard run and tells the player why.

	It used to open a BIS_fnc_guiMessage box and then run `breakout "#all"`. The message box
	could end up behind/under MCC's own dialogs with nothing able to close it (Esc included),
	which forced players to Alt+F4 (e.g. "Faction doesn't have any units in it"). It now shows
	a hint + chat line, writes the reason to the RPT and leaves every dialog closable.
*/

params [
	["_msg","",[""]]
];

missionNamespace setVariable ["MCC_MWisGenerating", false];

if (_msg != "") then {
	["ERROR", "fn_halt", "%1", [_msg]] call MCC_fnc_log;
	if (hasInterface) then {
		hint parseText format ["<t color='#C48214' size='1.2'>MCC</t><br/>%1", _msg];
		systemChat _msg;
	};
};

endLoadingScreen;
