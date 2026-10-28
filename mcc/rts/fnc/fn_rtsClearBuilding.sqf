//=================================================================MCC_fnc_rtsClearBuilding==============================================================================
//	Remove resources
//  Parameter(s):
//     _module: OBJECT the building to delete
//     _deleteModule: BOOLEAN should we delete the attached module
//==============================================================================================================================================================================
private _module = _this param [0, objNull, [objNull]];
private _deleteModule = _this param [1, true, [true]];
private _anchor = _module getVariable ["mcc_construction_anchor",objNull];
private _side = _anchor getVariable ["mcc_side",sideLogic];

{deletevehicle _x} foreach (attachedObjects _anchor);
deletevehicle _anchor;


if (_deleteModule) then {
	//Delete Marker
	[[], compile format ['deleteMarker "%1";',(_module getVariable ["mcc_markerName",""])]] remoteExec ["call", _side, false];

	//Delete module
	deletevehicle _module;
};

//Remove old marker
if (!isnil "MCC_fnc_rtsMakeMarkersGroups") then {
	[] spawn MCC_fnc_rtsMakeMarkersGroups;
};
MCC_ConsoleGroupSelected = [];