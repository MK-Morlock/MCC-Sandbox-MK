/*================================================================== MCC_fnc_hintBrief ==================================================================
	A hint that goes away by itself after a few seconds (Arma keeps a hint up for about 30 s). Used for the "click / drag on
	the map" instructions of CAS, Gunship, Supply Drop, Artillery, Evac and parachute drops, so the note does not stay when
	you decide not to draw.
	A newer hint is not removed: only the hint this call showed is cleared.
	<IN>	0: STRING or STRUCTURED TEXT
			1: NUMBER seconds (default 6)
==============================================================================================================================================================*/
params [["_text", ""], ["_secs", 6]];
if (_text isEqualType "") then {hint _text} else {hint _text};
private _token = (missionNamespace getVariable ["MCC_hintBriefToken", 0]) + 1;
missionNamespace setVariable ["MCC_hintBriefToken", _token];
[_token, _secs] spawn {
	params ["_token", "_secs"];
	uiSleep _secs;
	if ((missionNamespace getVariable ["MCC_hintBriefToken", 0]) == _token) then {hintSilent ""};
};
