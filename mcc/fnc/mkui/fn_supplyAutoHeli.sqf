params [["_planeType", "west", [""]]];
private _isHeliDLC = isClass (configFile >> "CfgPatches" >> "A3_Air_F_Heli_Heli_Transport_03");
private _cls = if (_isHeliDLC) then {
	switch (toLower _planeType) do {
		case "east": {"O_Heli_Transport_04_F"};
		case "west": {"B_Heli_Transport_03_unarmed_F"};
		default {"I_Heli_Transport_02_F"};
	};
} else {"I_Heli_Transport_02_F"};
private _dropSide = switch (toLower _planeType) do {case "west": {west}; case "east": {east}; case "guer": {resistance}; default {civilian}};
private _dropFaction = faction (((allPlayers - entities "HeadlessClient_F") select {side group _x == _dropSide}) param [0, objNull]);
private _lifters = if (_dropFaction == "") then {[]} else {[_dropFaction, "cargoHeli"] call MCC_fnc_factionVehicles};
_lifters = _lifters select {getText (configFile >> "CfgVehicles" >> _x >> "editorSubcategory") != "MCC_EdSubcat_TaruPodMod"};
if (count _lifters > 0) then {_cls = _lifters select 0} else {
	if (_dropFaction != "") then {_cls = [_cls, _dropFaction] call MCCMK_fnc_factionVehicle};
};
if (missionNamespace getVariable ["MCC_assetCustom_MCC_assetSupplyHeli", false]) then {_cls = selectRandom (missionNamespace getVariable ["MCC_assetSupplyHeli", [_cls]])};
_cls
