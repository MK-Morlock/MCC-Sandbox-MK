//==================================================================MCC_fnc_spotEnemy
// Example:[_type]  call MCC_fnc_spotEnemy;
// <IN>
//	_type:					string - type of enemy to spot
//
// <OUT>
//		<Nothing>
//===========================================================================================================================================================================
private _type = "";
private "_markerName";
private _path = "";
private "_pos";
private _markerClass = "";
private _text = "";
_type = _this param [0, "", [""]];

if (_type == "") exitWith {};
private _radioSelf = "";
private _radioGlobal = "";
private "_type";

_markerName = (getplayerUID player) + str floor time;
_path = "";

 private _ins = lineIntersectsSurfaces [
                                AGLToASL positionCameraToWorld [0,0,0],
                                AGLToASL positionCameraToWorld [0,0,3000],
                                player,
                                objNull,
                                true,
                                1,
                                "GEOM",
                                "NONE"
                              ];
_pos = if (count _ins == 0) then {screenToWorld [0.5,0.5]} else {ASLToATL (_ins select 0 select 0)};

switch (_type) do {
    case "cas": {
      _markerClass = "mil_destroy";
      _text = "Need CAS";
      _radioSelf = "SentSupportRequestRGCASBombing";
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_casrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_casrequested_IHQ_%1",floor random 3]};
    };

    case "transport": {
      _markerClass = "mil_pickup";
      _text = "Need Transport";
      _radioSelf = "SentSupportRequestRGTransport";
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_transportrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_transportrequested_IHQ_%1",floor random 3]};
    };

    case "areaAttack": {
      _markerClass = "mil_objective";
      _text = "Need Area Attack";
      _radioSelf = "SentSupportRequestRGArty";
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_casrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_casrequested_IHQ_%1",floor random 3]};
    };

    case "medic": {
      _markerClass = "mil_warning";
      _text = "Need Medic";
      _radioSelf = "SentSupportAskHeal";
      _pos = getpos player;
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_slingloadrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_slingloadrequested_IHQ_%1",floor random 3]};
    };

    case "ammo": {
      _markerClass = "mil_warning";
      _text = "Need Ammo";
      _radioSelf = "SentSupportAskRearm";
      _pos = getpos player;
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_slingloadrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_slingloadrequested_IHQ_%1",floor random 3]};
    };

    case "repair": {
      _markerClass = "mil_warning";
      _text = "Need Repairs";
      _radioSelf = "SentSupportAskRepair";
      _pos = getpos player;
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_slingloadrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_slingloadrequested_IHQ_%1",floor random 3]};
    };

    case "fuel": {
      _markerClass = "mil_warning";
      _text = "Need Fuel";
      _radioSelf = "SentSupportAskRefuel";
      _pos = getpos player;
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_slingloadrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_slingloadrequested_IHQ_%1",floor random 3]};
    };

    default {
      _markerClass = "mil_marker";
      _text = "Need Support";
      _radioSelf = "SentSupportRequestRGSupplyDrop";
      _radioGlobal = if (side player == west) then {format["mp_groundsupport_01_slingloadrequested_BHQ_%1",floor random 3]} else {format["mp_groundsupport_01_slingloadrequested_IHQ_%1",floor random 3]};
    };
};

player globalRadio "CuratorWaypointPlacedAttack";
[_markerName, _path, _pos, _markerClass, _text, time, "default"] remoteExec ["MCC_fnc_PDAcreatemarker", playerside, false];

titleText ["Marker Added","PLAIN DOWN"];
titleFadeOut 10;