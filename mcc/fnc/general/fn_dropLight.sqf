params [["_plane", objNull, [objNull]], ["_state", "OFF", [""]]];
if (!hasInterface || {isNull _plane}) exitWith {};
["INFO", "dropLight", "%1: %2%3", [typeOf _plane, _state, ["", " (switched off - MCC_dropLightOff)"] select (missionNamespace getVariable ["MCC_dropLightOff", false])]] call MCC_fnc_log;
if (missionNamespace getVariable ["MCC_dropLightOff", false]) exitWith {};
private _light = _plane getVariable ["MCC_dropLightObj", objNull];
if (_state == "OFF") exitWith {
	if (!isNull _light) then {deleteVehicle _light};
	_plane setVariable ["MCC_dropLightObj", nil];
};
if (isNull _light) then {
	(boundingBoxReal _plane) params ["_b1"];
	_light = "#lightpoint" createVehicleLocal (getPos _plane);
	_light setLightDayLight true;
	private _off = if (((toUpper (typeOf _plane)) find "C130") >= 0) then {[0, -3, 3]} else {[0, (_b1 select 1) * 0.3, 1.5]};
	_light setLightUseFlare false;
	_light setLightFlareSize 0;
	_light setPosASL (_plane modelToWorldVisualWorld _off);
	MCC_dropLights = (missionNamespace getVariable ["MCC_dropLights", []]) select {!isNull (_x select 1)};
	MCC_dropLights pushBack [_plane, _light, _off];
	if ((missionNamespace getVariable ["MCC_dropLightEH", -1]) < 0) then {
		MCC_dropLightEH = addMissionEventHandler ["EachFrame", {
			{
				_x params ["_p", "_l", "_o"];
				if (!isNull _p && {!isNull _l}) then {_l setPosASL (_p modelToWorldVisualWorld _o)};
			} forEach (missionNamespace getVariable ["MCC_dropLights", []]);
			if ((count (MCC_dropLights select {!isNull (_x select 1)})) == 0) then {removeMissionEventHandler ["EachFrame", MCC_dropLightEH]; MCC_dropLightEH = -1; MCC_dropLights = []};
		}];
	};
	_plane setVariable ["MCC_dropLightObj", _light];
	[_plane, _light] spawn {
		params ["_p", "_l"];
		waitUntil {sleep 1; isNull _p || {!alive _p} || {isNull _l}};
		if (!isNull _l) then {deleteVehicle _l};
	};
};
_light setLightAttenuation [0, 1, 0, 1, 1.5, 3];
_light setLightIntensity ([300, 20000] select (daytime > 6 && {daytime < 19}));
if (_state == "GREEN") then {
	_light setLightAmbient [0, 0.2, 0.1];
	_light setLightColor [0, 0.4, 0.1];
} else {
	_light setLightAmbient [0.2, 0, 0];
	_light setLightColor [1, 0.1, 0];
};
