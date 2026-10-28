//==================================================================MCC_fnc_releasePod===============================================================================================
//Release a pod from Taru helicopter
// Example: [_object] call MCC_fnc_releasePod;
//===========================================================================================================================================================================
private _vehicle = _this;
private _pod = _vehicle getVariable ["MCC_attachedPod",objnull];
private _attachPos = switch (typeof _pod) do
	{
		case "Land_Pod_Heli_Transport_04_ammo_F" : {[0,-1,-1.2]};
		case "Land_Pod_Heli_Transport_04_covered_F" : {[0,-1.1,-0.85]};
		case "Land_Pod_Heli_Transport_04_bench_F" : {[0,0,-1.2]};
		case "MCC_podBench" : {[0,0,-1.2]};
		case "MCC_podBench_black" : {[0,0,-1.2]};
		case "Land_Pod_Heli_Transport_04_box_F" : {[0,-1.1,-1.1]};
		case "Land_Pod_Heli_Transport_04_fuel_F" : {[0,-0.5,-1.3]};
		case "Land_Pod_Heli_Transport_04_medevac_F" : {[0,-1,-1.05]};
		case "Land_Pod_Heli_Transport_04_repair_F" : {[0,-1.2,-1.05]};
		default {[0,-1,-1.2]};
	};

if (!isNull _pod && {(getSlingLoad _vehicle) isEqualTo _pod}) then {
	_vehicle disableCollisionWith _pod;
	_vehicle setSlingLoad objNull;
	detach _pod;
	_pod setVelocity ((velocity _vehicle) vectorAdd [0, 0, -2]);
	_vehicle setCustomWeightRTD 0;
	_vehicle setVariable ["MCC_podSling", false, true];
	[_vehicle, _pod] spawn {sleep 2; (_this select 0) enableCollisionWith (_this select 1)};
	[[netid _pod,_pod], "missileLunch"] remoteExec ["MCC_fnc_globalSay3D", 0, false];
} else {
	while {(alive _pod) && ((_pod distance _vehicle) < 3 )} do {
		_attachPos set [2,(_attachPos select 2) - 0.7];
		_pod attachTo [_vehicle, _attachPos];
		sleep 0.01;
	};
	detach _pod;
	[[netid _pod,_pod], "missileLunch"] remoteExec ["MCC_fnc_globalSay3D", 0, false];
	_pod setVelocity [0, 0, -10];
};

_vehicle setVariable ["MCC_attachedPod",objnull,true];
_vehicle setMass [(getMass _vehicle)- (_vehicle getVariable ["MCC_attachedPodMass",0]),0.5];
sleep 2;
_vehicle enableRopeAttach true;

private _relH = (ASLToATL (getPosWorld _vehicle)) select 2;
["INFO", "paradrop", "drop pod released %1 m up - %2", [round _relH, ["no parachute (100 m or lower)", "parachute"] select (_relH > 100)]] call MCC_fnc_log;
[_pod, driver _vehicle, velocity _vehicle, _relH] spawn {
	private "_pod";
	private _class = "";
	private "_pilot";
	private _para = objNull;
	private "_velocity";
	private "_vel";
	_pod 		= _this select 0;
	_pilot		= _this select 1;
	_velocity	= _this select 2;

	private _relH = _this param [3, 400];
	private _tgt = _pod getVariable ["MCC_podTarget", []];
	if (_relH > 100) then {
		waituntil {(!alive _pod || ((getpos _pod) select 2) < 150)};
		if (!alive _pod) exitWith {};
		sleep 0.2;
		private _who = (crew _pod) param [0, _pilot];
		_class = switch (side group _who) do {case east: {"O_Parachute_02_F"}; case independent: {"I_Parachute_02_F"}; default {"B_Parachute_02_F"}};
		if !(isClass (configFile >> "CfgVehicles" >> _class)) then {_class = "B_Parachute_02_F"};
		private _pp = getPosASL _pod;
		private _top = ((boundingBoxReal _pod) select 1) select 2;
		_para = createVehicle [_class, [0, 0, 1000], [], 0, "CAN_COLLIDE"];
		_pod disableCollisionWith _para;
		_para disableCollisionWith _pod;
		_para setDir (getDir _pod);
		_para setPosASL (_pp vectorAdd [0, 0, _top + 0.3]);
		_para setVelocity (velocity _pod);
		_pod attachTo [_para, [0, 0, -(_top + (missionNamespace getVariable ["MCC_podChuteGap", -0.4]))]];
		waitUntil {!alive _pod || {(getPos _pod select 2) < 3}};
		_vel = velocity _pod;
		detach _pod;
		_pod setVelocity _vel;
		if (!isNull _para) then {
			private _nd = missionNamespace getVariable ["MCC_podChuteNudge", 0.4];
			(boundingBoxReal _pod) params ["_q1", "_q2"];
			private _ax = if (((_q2 select 0) - (_q1 select 0)) < ((_q2 select 1) - (_q1 select 1))) then {[1, 0, 0]} else {[0, 1, 0]};
			private _w = _pod vectorModelToWorld _ax;
			_para setPosASL ((getPosASL _para) vectorAdd ((vectorNormalized [_w select 0, _w select 1, 0]) vectorMultiply _nd));
			[_para] spawn {sleep 20; deleteVehicle (_this select 0)};
		};
	} else {
		["INFO", "paradrop", "drop pod let go with no parachute (released at 100 m or lower)", []] call MCC_fnc_log;
	};
	private _tl = time + 15;
	waitUntil {sleep 0.5; !alive _pod || {(getPos _pod select 2) < 1 && {vectorMagnitude (velocity _pod) < 1}} || {time > _tl}};
	sleep 1;
	private _nOut = count crew _pod;
	{
		[_x, {params ["_u"]; if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by pods (releasePod) | %1 from %2 at %3 m", [name _u, typeOf (vehicle _u), round ((getPosATL _u) select 2)]] call MCC_fnc_log}; unassignVehicle _u; moveOut _u}] remoteExec ["call", _x];
	} forEach (crew _pod);
	["INFO", "paradrop", "drop pod landed at %1 - %2 passengers out%3", [mapGridPosition _pod, _nOut, if (count _tgt > 1) then {format [" - %1 m from the middle of the line", round (_pod distance2D _tgt)]} else {""}]] call MCC_fnc_log;
};