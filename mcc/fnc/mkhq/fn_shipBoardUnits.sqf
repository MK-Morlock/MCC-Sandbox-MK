params [["_who", [], [[]]], ["_ship", objNull, [objNull]]];
if (isNull _ship || {_who isEqualTo []}) exitWith {};
private _type = _ship getVariable ["MCC_ShipType", 0];
private _fade = hasInterface && {player in _who};
if (_fade) then {cutText ["", "BLACK OUT", 0.2]; sleep 0.2};
{
	if (vehicle _x != _x) then {
		if (local _x) then {unassignVehicle _x; moveOut _x} else {[_x] remoteExec ["unassignVehicle", _x]; [_x] remoteExec ["moveOut", _x]};
	};
	if (!isPlayer _x) then {[_x] orderGetIn false};
} forEach _who;
sleep 0.4;
if (_type == 3 && {!isNil "CUP_fnc_moveInCargo"}) then {{[_ship, _x] call CUP_fnc_moveInCargo} forEach _who} else {
	private _off = [[0, 45, 10], [0, 0, 24], [15, 0, 1], [0, 45, 10]] param [_type, [0, 45, 10]];
	{
		_x setPosASLW (_ship modelToWorld (_off vectorAdd [(_forEachIndex mod 4) * 1.5 - 2.25, -(floor (_forEachIndex / 4)) * 1.5, 0]));
	} forEach _who;
};
if (_fade) then {cutText ["", "BLACK IN", 0.3]};
private _mode = missionNamespace getVariable ["MCCMK_deckAI", 0];
{
	private _u = _x;
	if (!isPlayer _u && {local _u}) then {
		if (_mode == 0) then {doStop _u};
		if (_mode == 2 && {!(_u getVariable ["MCCMK_deckWatch", false])}) then {
			_u setVariable ["MCCMK_deckWatch", true];
			[_u, _ship] spawn {
				params ["_u", "_ship"];
				sleep 3;
				private _away = 0;
				while {alive _u && {!isPlayer _u} && {_away < 20}} do {
					sleep 1;
					([_u] call MCCMK_fnc_boardState) params ["_st", "_on"];
					switch (true) do {
						case (_st == "deck"): {_away = 0; _ship = _on};
						case (_st == "climb" && {vehicle _u == _u} && {_on == _ship}): {
							sleep 4;
							if (alive _u && {vehicle _u == _u} && {(([_u] call MCCMK_fnc_boardState) select 0) == "climb"}) then {
								[[_u], _ship] call MCCMK_fnc_shipBoardUnits;
								["INFO", "boarding", "%1 fell overboard from %2 - put back on deck", [name _u, _ship getVariable ["MCC_LHDDisplayName", "ship"]]] call MCC_fnc_log;
							};
						};
						default {_away = _away + 1};
					};
				};
				_u setVariable ["MCCMK_deckWatch", false];
			};
		};
	};
} forEach _who;
