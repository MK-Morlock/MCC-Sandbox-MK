/*================================================================== MCC_fnc_rsMessage ==================================================================
	Short message for the squad panel (P), the commander and the QRF notice: white, PuristaLight, centred, upper part of the screen.
	<IN>	0: STRING text
			1: NUMBER seconds (default 4)
==============================================================================================================================================================*/
params [["_text", "", [""]], ["_secs", 4]];
if (_text == "") exitWith {};
//Font of the original MCC notices (PuristaLight, as the QRF message had), a bit smaller than their size 1, at the squad
//panel position (top centre). Change the size here to change all these messages.
[format ["<t size='0.75' font='PuristaLight' color='#FFFFFF' align='center'>%1</t>", _text], 0, 0.05, _secs, 0.5, 0] spawn BIS_fnc_dynamicText;
