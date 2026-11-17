params [["_mode", "start", [""]], ["_a", false], ["_b", 0]];
if (_mode == "start") exitWith {
	MCCMK_makeHQPick = true;
	MCCMK_makeHQPickFree = _a;
	["Make HQ: click one of your F.O.B.s (or a ship) on the map.\nRight-click to cancel."] call MCCMK_fnc_hint;
};
MCCMK_makeHQPick = false;
if (_b == 1) exitWith {["Make HQ cancelled."] call MCCMK_fnc_hint};
private _free = missionNamespace getVariable ["MCCMK_makeHQPickFree", false];
private _cands = ([[playerSide, sideUnknown] select _free] call MCCMK_fnc_spawnPoints) select {!([_x] call MCCMK_fnc_isHQ)};
if (_cands isEqualTo []) exitWith {["Make HQ: there is no F.O.B. or ship that could become the HQ."] call MCCMK_fnc_hint};
_cands = _cands apply {[_x distance2D _a, _x]};
_cands sort true;
(_cands select 0) params ["_d", "_t"];
if (_d > 500) exitWith {["Make HQ: no F.O.B. or ship near there - click closer to one."] call MCCMK_fnc_hint};
if (!_free && {!([_t, player] call MCCMK_fnc_makeHQCan)}) exitWith {[(["Make HQ: only the commander can do this.", "Make HQ: only the commander or a squad leader can do this."] select ((missionNamespace getVariable ["MCC_makeHQWho", 0]) == 1))] call MCCMK_fnc_hint};
[_t, _free] call MCCMK_fnc_makeHQConfirm;
