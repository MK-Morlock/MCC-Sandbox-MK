/*================================================================== MCC_fnc_consoleModeButtons ==================================================================
	Commander console UAV / Gunship screens: rows of rounded buttons that replace the old switch bars (Regular / N/V / Thermal,
	25mm / 40mm / 105mm). Shows which one is in use: its text orange, the others light.
	<IN>	0: DISPLAY
			1: NUMBER idc of the first button of the row (three buttons: idc, idc+1, idc+2)
			2: NUMBER the one in use (0..2)
==============================================================================================================================================================*/
disableSerialization;
params [["_d", displayNull, [displayNull]], ["_base", 0, [0]], ["_sel", 0, [0]]];
if (isNull _d) exitWith {};
for "_i" from 0 to 2 do {
	(_d displayCtrl (_base + _i)) ctrlSetTextColor ([[0.88,0.89,0.90,1], [0.77,0.51,0.08,1]] select (_i == _sel));
};
