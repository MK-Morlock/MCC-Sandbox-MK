params [["_veh", objNull, [objNull]], ["_grp", grpNull, [grpNull]]];
if (isNull _veh || {isNull _grp}) exitWith {};
{
	private _u = _veh turretUnit _x;
	if (!isNull _u && {alive _u} && {!isPlayer _u} && {group _u != _grp} && {count (_veh weaponsTurret _x) > 0} && {getNumber (([_veh, _x] call BIS_fnc_turretConfig) >> "isCopilot") == 0}) then {
		[_u] joinSilent _grp;
	};
} forEach (allTurrets [_veh, false]);
