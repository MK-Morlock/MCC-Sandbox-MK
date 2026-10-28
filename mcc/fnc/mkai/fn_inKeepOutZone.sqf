params [["_pos", [], [[], objNull]], ["_side", civilian, [civilian]]];
if (_pos isEqualType objNull) then {_pos = getPosATL _pos};
private _zones = missionNamespace getVariable ["MCCMK_aiKeepOutZones", []];
if (count _zones == 0 || {count _pos < 2}) exitWith {false};
private _in = false;
{
	_x params ["_logic", "_trgs", "_sides"];
	if (!isNull _logic && {_side in _sides}) then {
		if ((_trgs findIf {!isNull _x && {_pos inArea _x}}) >= 0) exitWith {_in = true};
	};
	if (_in) exitWith {};
} forEach _zones;
_in
