/*
	MCCMK_fnc_hint - MCC's hints: shown as normal, then cleared after a real-time delay (8 s, longer for a long message, up
	to 20 s) if a dialog is open by then - Arma's own hint timer stops while a dialog such as the MCC console is open,
	so the hint would stay until it is closed. With no dialog open, Arma fades it as usual. A newer hint is never
	cleared by an
	older one's timer. [text or structured text]
*/
params [["_t", ""]];
hint _t;
MCCMK_hintToken = (missionNamespace getVariable ["MCCMK_hintToken", 0]) + 1;
private _len = count (if (_t isEqualType "") then {_t} else {str _t});
[MCCMK_hintToken, (8 + _len / 25) min 20] spawn {
	params ["_tok", "_wait"];
	uiSleep _wait;
	if ((missionNamespace getVariable ["MCCMK_hintToken", 0]) == _tok && {dialog || {!isNull findDisplay 2994}}) then {hintSilent ""};
};
