params [["_p", objNull, [objNull]]];
if (!isServer || {isNull _p}) exitWith {};
private _uid = getPlayerUID _p;
if (_uid == "") exitWith {};
private _v = [_uid, name _p] call MCCMK_fnc_creditGet;
if (_v >= 0) then {
	_p setVariable ["MCC_valorPoints", _v, true];
	["INFO", "credits", "%1: %2 credits restored", [name _p, _v]] call MCC_fnc_log;
} else {
	[_uid, name _p, _p getVariable ["MCC_valorPoints", 50]] call MCCMK_fnc_creditStore;
};
MCCMK_creditRestored pushBackUnique _uid;
