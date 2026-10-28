/*===========================================================MCC_fnc_addToZeus=====================================================================================
// find nearest civilian house
// In:
//	_pos:	ARRAY
//	_RADIUS: INTEGER
//
//<OUT>
//	_nearhouses ARRAY of objects - good houses found
//=================================================================================================================================================================*/
private "_pos";
private _module = objNull;
private _object = objNull;
private _resualt = [];
private "_unit";
_module = _this param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_pos = getpos _module;
_object = missionNamespace getVariable ["MCC_curatorMouseOver",objNull];

 _resualt = ["Add Units/Objects in radius to Zeus",[
 						["Radius",100],
 						["Action",["Add to Zeus","Remove from Zeus"]]
 					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

private _action = (_resualt select 1);

{
	_unit = _x;
	switch _action do
	{
		//Add
		case 0:
		{
			{[_x,[[_unit],true]] remoteExec ["addCuratorEditableObjects",2]} foreach allCurators;
		};

		//Remove
		case 1:
		{
			{[_x,[[_unit],true]] remoteExec ["removeCuratorEditableObjects",2]} foreach allCurators;
		};
	};
} forEach (nearestObjects [_pos, ["All"], (_resualt select 0)]);

deleteVehicle _module;