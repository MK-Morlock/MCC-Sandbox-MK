if (!hasInterface) exitWith {};
// Runs only while the player is in a plane: started when he gets into one (CBA's player vehicle event), it stops when he
// gets out - nothing checks in the background otherwise.
MCCMK_planeRevLoop = {
	if (missionNamespace getVariable ["MCCMK_planeRevRunning", false]) exitWith {};
	MCCMK_planeRevRunning = true;
	[] spawn {
		while {(vehicle player) isKindOf "Plane"} do {
			private _v = vehicle player;
			if (_v isKindOf "Plane" && {driver _v == player} && {isEngineOn _v} && {isTouchingGround _v}) then {
				private _mode = missionNamespace getVariable ["MCCMK_planeReverse", 0];
				private _ok = switch (_mode) do {
					case 0: {true};
					case 1: {((missionNamespace getVariable ["MCC_staticShips", []]) findIf {!isNull _x && {(_x distance2D _v) < 200}}) >= 0 && {((getPosASL _v) select 2) > 3}};
					default {false};
				};
				if (_ok && {(inputAction "AirPlaneBrake") > 0}) then {
					private _vm = velocityModelSpace _v;
					if ((_vm select 1) < 1) then {_v setVelocityModelSpace [0, -0.9, _vm select 2]};
				};
				sleep 0.05;
			} else {sleep 0.5};
		};
		MCCMK_planeRevRunning = false;
	};
};
["vehicle", {params ["", "_veh"]; if (_veh isKindOf "Plane") then {call MCCMK_planeRevLoop}}, true] call CBA_fnc_addPlayerEventHandler;
