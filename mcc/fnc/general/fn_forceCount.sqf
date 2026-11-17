params [["_side", west, [west]]];
private _humans = playersNumber _side;
if !(missionNamespace getVariable ["MCC_aiCountAsPlayers", true]) exitWith {_humans};
private _squad = 0;
private _ctrl = 0;
{
	private _g = _x;
	if ((side _g == _side) && {count units _g > 0} && {!(_g getVariable ["MCC_droneGroup", false])}) then {
		private _ai = {alive _x && {!isPlayer _x} && {!(unitIsUAV (vehicle _x))}} count (units _g);
		if (isPlayer leader _g) then {
			_squad = _squad + _ai;
		} else {
			if (_g getVariable ["MCC_canbecontrolled", false]) then {_ctrl = _ctrl + _ai};
		};
	};
} forEach allGroups;
_humans + (_squad * (missionNamespace getVariable ["MCC_aiSquadmateValue", 0.5])) + (_ctrl * 0.25)
