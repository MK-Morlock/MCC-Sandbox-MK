//==================================================================MCC_fnc_globalHint======================================================================================
// Broadcast a meesege on all clients
// Example: [_hint] remoteExec ['MCC_fnc_globalHint', true, true];
// Params:
//	_hint: string, messege to broadcast
//==============================================================================================================================================================================
private _string = _this param [0, "", [""]];
private _richText = _this param [1, false, [false]];

private _secs = _this param [2, 30, [0]];	//it goes away by itself after this many seconds (RTS mission notices stayed up)
private _consoleOpen = ([2993, 5000, 5010] findIf {!isNull (findDisplay _x)}) >= 0;
if (_consoleOpen) exitWith {
	private _plain = ((_string regexReplace ["<br\s*/?>", " "]) regexReplace ["<[^>]*>", ""]) select [0, 60];
	["MCCNotifications", [_plain, "", "Full report when you leave the console"]] call BIS_fnc_showNotification;
	[_string, _richText, _secs] spawn {
		params ["_string", "_richText", "_secs"];
		waitUntil {sleep 1; ([2993, 5000, 5010] findIf {!isNull (findDisplay _x)}) < 0};
		sleep 0.5;
		if (_richText) then {[parseText _string, _secs] call MCC_fnc_hintBrief} else {[_string, _secs] call MCC_fnc_hintBrief};
	};
};
if (_richText) then {[parseText _string, _secs] call MCC_fnc_hintBrief} else {[_string, _secs] call MCC_fnc_hintBrief};