params [["_ship", objNull, [objNull]], ["_text", "", [""]], ["_warn", false, [true]]];
if (!isServer || {isNull _ship} || {!(_ship getVariable ["MCCMK_radarOn", false])}) exitWith {false};
private _log = +(_ship getVariable ["MCCMK_contactLog", []]);
_log pushBack [serverTime, _text];
if (count _log > 6) then {_log deleteAt 0};
_ship setVariable ["MCCMK_contactLog", _log, true];
if (_warn) then {[format ["%1: %2", _ship getVariable ["MCC_LHDDisplayName", "Ship"], _text]] remoteExec ["systemChat", _ship getVariable ["MCC_side", sideUnknown]]};
true
