params [["_cfgName", "", [""]]];
[] call MCC_fnc_rtsPreviewClear;
private _cfg = (if (MCC_isMode) then {configFile} else {missionConfigFile}) >> "cfgRtsBuildings" >> _cfgName;
if (!isClass _cfg) exitWith {};
private _anchorType = getText (_cfg >> "anchorType");
if (_anchorType == "") exitWith {};
private _anchor = _anchorType createVehicleLocal [0, 0, 5000];
_anchor allowDamage false;
_anchor enableSimulation false;
private _parts = [];
{
	_x params [["_cls", "", [""]], ["_off", [0, 0, 0], [[]]], ["_vdu", [], [[]]]];
	if (_cls != "") then {
		private _o = _cls createVehicleLocal [0, 0, 5000];
		_o allowDamage false;
		_o enableSimulation false;
		_parts pushBack [_o, _off, _vdu];
	};
} forEach getArray (_cfg >> "objectsArray");
missionNamespace setVariable ["MCC_rtsPreviewAnchor", _anchor];
missionNamespace setVariable ["MCC_rtsPreviewParts", _parts];
missionNamespace setVariable ["MCC_rtsPreviewObjs", _parts apply {_x select 0}];
if (!isNull MCC_CONST_PLACEHOLDER) then {MCC_CONST_PLACEHOLDER hideObject true};
if (!isNil "MCC_CONST_CAM") then {MCC_CONST_CAM camCommand "manual off"};
[true] call MCC_fnc_rtsPreviewMove;
[getText (_cfg >> "displayName"), true] call MCC_fnc_rtsPlacePrompt;
