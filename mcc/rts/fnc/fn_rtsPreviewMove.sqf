params [["_show", true, [true]]];
private _a = missionNamespace getVariable ["MCC_rtsPreviewAnchor", objNull];
if (isNull _a) exitWith {};
private _parts = missionNamespace getVariable ["MCC_rtsPreviewParts", []];
if (_show && {!isNull MCC_CONST_PLACEHOLDER}) then {
	_a setPos (getPos MCC_CONST_PLACEHOLDER);
	_a setDir (getDir MCC_CONST_PLACEHOLDER);
	private _offs = [_a, _parts apply {[_x select 0, _x select 1]}] call MCC_fnc_rtsGroundOffsets;
	{
		_x params ["_o", "_off", "_vdu"];
		_o setPosWorld (_a modelToWorldWorld (_offs select _forEachIndex));
		if (count _vdu == 2) then {
			_o setVectorDirAndUp [_a vectorModelToWorld (_vdu select 0), _a vectorModelToWorld (_vdu select 1)];
		} else {
			_o setDir (getDir _a);
		};
	} forEach _parts;
} else {
	_a setPosASL [0, 0, 5000];
	{(_x select 0) setPosASL [0, 0, 5000]} forEach _parts;
};
