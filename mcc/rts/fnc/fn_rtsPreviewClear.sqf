disableSerialization;
if (!isNil "MCC_CONST_CAM") then {MCC_CONST_CAM camCommand "manual on"};
{deleteVehicle _x} forEach (missionNamespace getVariable ["MCC_rtsPreviewObjs", []]);
deleteVehicle (missionNamespace getVariable ["MCC_rtsPreviewAnchor", objNull]);
missionNamespace setVariable ["MCC_rtsPreviewAnchor", objNull];
missionNamespace setVariable ["MCC_rtsPreviewObjs", []];
missionNamespace setVariable ["MCC_rtsPreviewParts", []];
private _disp = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
if (!isNull _disp) then {(_disp displayCtrl 9137) ctrlShow false};
