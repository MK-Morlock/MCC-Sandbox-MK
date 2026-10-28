/*================================================================ MCC_fnc_pipCycleView ================================================================
	Right-click on the unit video feed in the MCC console: switch to the next camera view
	(Chase, Over the shoulder, Overhead). The choice lasts for the session; the CBA setting is the starting view.
=======================================================================================================================================================*/
private _names = ["Chase", "Over the shoulder", "Overhead"];
private _state = missionNamespace getVariable ["MCC_pipState", []];
private _current = missionNamespace getVariable ["MCC_pipView", 0];
private _next = if (_current >= 2) then {0} else {_current + 1};
missionNamespace setVariable ["MCC_pipView", _next];

if (count _state > 3 && {!isNull (_state select 0)} && {(missionNamespace getVariable ["MCC_pipFollowEH", -1]) >= 0}) then {
	_state set [3, _next];
	(_state select 0) camSetFov ([0.75, 0.7, 0.9] select _next);
	MCC_pipState = _state;
	hintSilent format ["Video feed: %1 view (right-click to change)", _names select _next];
} else {
	hintSilent format ["Video feed: %1 view - select the unit again to apply", _names select _next];
};
