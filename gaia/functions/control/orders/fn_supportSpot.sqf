params [["_group", grpNull, [grpNull]], ["_zone", "", ["", 0]]];
if (isNull _group) exitWith {[]};
private _side = side _group;
private _anchors = allGroups select {
	(side _x == _side)
	&& {_x != _group}
	&& {count units _x > 0}
	&& {alive leader _x}
	&& {!isPlayer leader _x}
	&& {!(_x getVariable ["GAIA_CACHED_STAGE_1", false])}
	&& {(_x getVariable ["GAIA_class", ""]) != "Support"}
	&& {(behaviour leader _x) != "COMBAT"}
	&& {[getPosATL leader _x, _zone] call GAIA_fnc_isPositionInMarker}
	&& {count ((leader _x) targets [true, 400]) == 0}
};
if (_anchors isEqualTo []) exitWith {[]};
private _p = (getPosATL leader (selectRandom _anchors)) getPos [60 + random 60, random 360];
if (surfaceIsWater _p) exitWith {[]};
_p set [2, 0];
_p
