/*============================================================MCC_fnc_ambientFireExtinguish=======================================================================
	Puts out MCC ambient fires and stops the ones still spreading.

	Fire objects are not Zeus-editable, so they could not be deleted from Zeus and kept spreading. This deletes them
	(the server-side fire objects; each client's light, smoke and sound end by themselves when their fire is gone)
	and bumps MCC_ambientFireEpoch, which every running spread script checks before lighting anything new.

	<IN>
		0:	ARRAY/OBJECT  centre (position, object, or the Zeus/Eden module that called it); [] = whole map
		1:	NUMBER        radius in metres; -1 = whole map (default: 300 when called by a module, otherwise whole map)

	EXAMPLES:
		[] call MCC_fnc_ambientFireExtinguish;                    // all fires
		[getPos player, 200] call MCC_fnc_ambientFireExtinguish;  // fires within 200 m
==================================================================================================================================================================*/
#define	FIRE_OBJECTSMALL	"IncinerateShell"
#define	FIRE_OBJECTBIG	"test_EmptyObjectForFireBig"
#define	PLACE_HOLDER	"Land_HelipadEmpty_F"

params [["_center", [], [[], objNull]], ["_radius", -2, [0]]];

private _module = objNull;
if (_center isEqualType objNull) then {
	if (_center isKindOf "Logic") then {_module = _center; if (_radius == -2) then {_radius = 300}};
	_center = if (isNull _center) then {[]} else {getPosATL _center};
};
if (_radius == -2) then {_radius = -1};

// Zeus modules run on the curator's machine; the fires live on the server
if (!isServer) exitWith {
	[_center, _radius] remoteExec ["MCC_fnc_ambientFireExtinguish", 2];
	if (!isNull _module) then {
		[objNull, "Fires extinguished"] call bis_fnc_showCuratorFeedbackMessage;
		deleteVehicle _module;
	};
};

// stop every spread script that is still sleeping
missionNamespace setVariable ["MCC_ambientFireEpoch", (missionNamespace getVariable ["MCC_ambientFireEpoch", 0]) + 1, true];

private _fires = if (_radius < 0 || {_center isEqualTo []}) then {
	(allMissionObjects FIRE_OBJECTBIG) + (allMissionObjects FIRE_OBJECTSMALL)
} else {
	_center nearObjects [FIRE_OBJECTBIG, _radius] + (_center nearObjects [FIRE_OBJECTSMALL, _radius])
};

private _count = 0;
{
	private _parent = attachedTo _x;
	if (!isNull _parent && {typeOf _parent == PLACE_HOLDER}) then {deleteVehicle _parent};
	deleteVehicle _x;
	_count = _count + 1;
} forEach _fires;

["INFO", "fn_ambientFireExtinguish", "%1 fire objects removed (%2)", [_count, if (_radius < 0) then {"whole map"} else {format ["%1 m radius", _radius]}]] call MCC_fnc_log;

if (!isNull _module) then {
	if (hasInterface) then {[objNull, format ["%1 fires extinguished", _count]] call bis_fnc_showCuratorFeedbackMessage};
	deleteVehicle _module;
};

_count
