params [["_unit", objNull, [objNull]], ["_chute", objNull, [objNull]]];
if (isNull _unit || {isPlayer _unit}) exitWith {};

if (alive _unit && {vehicle _unit != _unit} && {(vehicle _unit) isKindOf "ParachuteBase"}) then {
	_chute = vehicle _unit;
	if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by landing (paraOffRoof) | %1 from %2 at %3 m", [name _unit, typeOf (vehicle _unit), round ((getPosATL _unit) select 2)]] call MCC_fnc_log}; 
	moveOut _unit;
	sleep 0.2;
};
if (!isNull _chute && {_chute isKindOf "ParachuteBase"}) then {deleteVehicle _chute};

private _onRoof = {
	params ["_u"];
	(((getPosATL _u) select 2) > 1.5) && {[getPosATL _u, 0, _u] call MCC_fnc_posOnBuilding}
};
sleep 1;
if (!alive _unit || {!([_unit] call _onRoof)}) exitWith {};

private _ground = [];
{
	private _r = _x;
	{
		private _q = (getPosATL _unit) getPos [_r, _x];
		if (!(surfaceIsWater _q) && {!([_q, 2] call MCC_fnc_posOnBuilding)}) exitWith {_ground = _q};
	} forEach [0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330];
	if (count _ground > 0) exitWith {};
} forEach [6, 10, 15, 20, 30, 40];
if (count _ground == 0) exitWith {["WARN", "paraOffRoof", "%1 landed on a building at %2 - no open ground within 40 m, left there", [name _unit, mapGridPosition _unit]] call MCC_fnc_log};

["INFO", "paraOffRoof", "%1 landed on a building at %2 - moving him to the ground %3 m away when no player is near or watching", [name _unit, mapGridPosition _unit, round (_unit distance2D _ground)]] call MCC_fnc_log;

private _end = time + 600;
waitUntil {
	sleep 2;
	if (!alive _unit || {time > _end} || {!([_unit] call _onRoof)}) exitWith {true};
	(allPlayers - entities "HeadlessClient_F") findIf {
		alive _x && {(_x distance _unit < 100) || {(_x distance _unit < 1500) && {([objNull, "VIEW", _unit] checkVisibility [eyePos _x, eyePos _unit]) > 0.1}}}
	} < 0
};
if (!alive _unit || {!([_unit] call _onRoof)}) exitWith {};
if (time > _end) exitWith {["INFO", "paraOffRoof", "%1 still on the building after 10 minutes (players near or watching) - left there", [name _unit]] call MCC_fnc_log};

_unit setPosATL [_ground select 0, _ground select 1, 0];
["INFO", "paraOffRoof", "%1 moved off the building to the ground at %2", [name _unit, mapGridPosition _unit]] call MCC_fnc_log;
