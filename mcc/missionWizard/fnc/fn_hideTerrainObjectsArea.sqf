/*===================================== MCC_fnc_hideTerrainObjectsArea ===================================================================================================
Hide all terrain objects in given area

	<IN>
		0:		ARRAY - position
		1:		INTEGER	 - Radius
		2:		BOOLEAN - hide/unhide

	<OUT>
		NOTHING
=========================================================================================================================================================================*/
private _hidingCode = {};
private _found = objNull;
params [
	["_pos",[0,0,0],[[],objNull]],
	["_radius",50,[0]],
	["_hide",true,[true]]
];

_hidingCode = if (_hide) then {
		{_x hideObjectGlobal true;_x allowDamage false;}
	} else {
		{_x hideObjectGlobal false;_x allowDamage true;}
	};

_found = nearestTerrainObjects [_pos,[],_radius,false,true];

if (_hide) then {
	private _items = (missionNamespace getVariable ["MCC_MWObjectiveItems", []]) select {!isNull _x && {(_x distance2D _pos) < (_radius + 60)}};
	if (count _items > 0) then {
		private _kept = _found select {
			private _t = _x;
			private _r = ((boundingBoxReal _t) select 2) max 3;
			(_items findIf {(_x distance2D _t) < _r}) >= 0
		};
		if (count _kept > 0) then {
			_found = _found - _kept;
			["INFO", "MCC_fnc_hideTerrainObjectsArea", "kept %1 terrain objects that hold an objective near %2", [count _kept, mapGridPosition _pos]] call MCC_fnc_log;
		};
	};
};

_hidingCode forEach (_found inAreaArray [_pos, _radius, _radius, 0, false]);
