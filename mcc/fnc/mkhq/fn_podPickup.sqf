// (server) "Pick up pod": a Taru flies in (5 km out, from the map edge side), hovers over the pod, winches it up and
// flies off to the map edge with it. Free. Only an empty pod, not on a sling already. [pod, caller]
params [["_pod", objNull, [objNull]], ["_u", objNull, [objNull]]];
if (!isServer || {isNull _pod} || {!alive _pod}) exitWith {};
private _say = {params ["_m"]; if (!isNull _u) then {[_m] remoteExec ["MCCMK_fnc_hint", _u]}};
if (!isNull attachedTo _pod || {(count crew _pod) > 0}) exitWith {["The pod has to be empty, and on the ground."] call _say};
if (_pod getVariable ["MCCMK_pickupPending", false]) exitWith {["A Taru is already on its way for that pod."] call _say};
_pod setVariable ["MCCMK_pickupPending", true, true];
private _side = _pod getVariable ["MCCMK_podSide", side group _u];
private _sl = ["B", "O", "I"] param [[west, east, resistance] find _side, "B"];
private _black = ((toLower typeOf _pod) find "black") >= 0;
private _heliCls = format ["MCC_%1_Heli_Transport_04%2_F", _sl, ["", "_black"] select _black];
if !(isClass (configFile >> "CfgVehicles" >> _heliCls)) then {_heliCls = ["O_Heli_Transport_04_F", "O_Heli_Transport_04_black_F"] select _black};
private _p = getPosWorld _pod;
private _toEdge = ([[0, 0], [worldSize, 0], [0, worldSize], [worldSize, worldSize]] apply {[_p distance2D _x, _p getDir _x]});
_toEdge sort true;
private _start = _p getPos [5000, (_toEdge select 0) select 1];
private _h = createVehicle [_heliCls, _start, [], 0, "FLY"];
_h setPosASL [_start select 0, _start select 1, ((getTerrainHeightASL _start) max 0) + 150];
_h setDir (_start getDir _p);
private _g = createVehicleCrew _h;
[_h, if (isNull _u) then {_side} else {faction _u}] call MCCMK_fnc_crewFix;	//(MK) the caller's faction flies it
if ((side _g) != _side) then {private _ng = createGroup [_side, true]; (units _g) joinSilent _ng; _g = _ng};
[_h, [faction _u, _side] call MCCMK_fnc_factionPilot] call MCCMK_fnc_recrew;
_g setBehaviour "CARELESS";
_g setCombatMode "BLUE";
_h flyInHeight 60;
_h doMove _p;
["A Taru is on its way to pick up the pod."] call _say;
["INFO", "pods", "pick-up of %1 at grid %2 by %3", [typeOf _pod, mapGridPosition _pod, name _u]] call MCC_fnc_log;
private _t = time;
waitUntil {sleep 0.5; !alive _h || {isNull _pod} || {(_h distance2D _pod) < 1000} || {(time - _t) > 300}};
if (!alive _h || {isNull _pod} || {(count crew _pod) > 0}) exitWith {
	if (!isNull _pod) then {_pod setVariable ["MCCMK_pickupPending", false, true]};
	["The pick-up was called off."] call _say;
	if (alive _h) then {[_h, _g] spawn MCCMK_fnc_podExit};
};
// (MK) the AI Taru's own pick-up (MCC_fnc_taruAI "pickup") - as it picks up a bench: in fast, the pod hooked and winched
// up as it flies off
[_h, "pickup", getPosATL _pod] call MCC_fnc_taruAI;
private _ok = (attachedTo _pod) isEqualTo _h || {(getSlingLoad _h) isEqualTo _pod} || {(ropeAttachedTo _pod) isEqualTo _h};
_pod setVariable ["MCCMK_pickupPending", false, true];
//(MK) A pod returned: part of what it cost back - only a pod this side paid for (not a free one: the MCC console's, or
// ordered while resources were Free). 30% for the pod itself, plus for a fuel, ammo or repair pod up to 30% more for
// what's left in it (full 60%, half 45%, empty 30%); the other pods (no contents that run down) 30%.
private _back = [];
if (_ok && {!(call MCCMK_fnc_resFree)}) then {
	private _paid = _pod getVariable ["MCCMK_podPaid", []];
	if (count _paid == 2 && {(_paid select 1) isEqualTo _side}) then {
		private _c = configOf _pod;
		private _left = [];
		if (getNumber (_c >> "transportFuel") > 0) then {_left pushBack (getFuelCargo _pod)};
		if (getNumber (_c >> "transportAmmo") > 0) then {_left pushBack (getAmmoCargo _pod)};
		if (getNumber (_c >> "transportRepair") > 0) then {_left pushBack (getRepairCargo _pod)};
		private _frac = 0;
		if (count _left > 0) then {{_frac = _frac + (_x max 0)} forEach _left; _frac = (_frac / (count _left)) min 1};
		if (true) then {
			private _pct = 0.3 + (0.3 * _frac);
			(_paid select 0) params [["_ca", 0], ["_cs", 0], ["_cf", 0], ["_cm", 0]];
			_back = [floor (_ca * _pct), floor (_cs * _pct), floor (_cf * _pct), floor (_cm * _pct)];
			private _var = format ["MCC_res%1", _side];
			private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
			_r set [0, (_r select 0) + (_back select 0)];
			_r set [1, (_r select 1) + (_back select 1)];
			_r set [2, (_r select 2) + (_back select 2)];
			_r set [4, (_r select 4) + (_back select 3)];
			missionNamespace setVariable [_var, _r];
			publicVariable _var;
			_pod setVariable ["MCCMK_podPaid", [], true];	// refunded once
		};
	};
};
if (_back isNotEqualTo []) then {
	[format ["Pod picked up - returned: +%1 Supply, +%2 Ammo, +%3 Fuel, +%4 Meds.", _back select 1, _back select 0, _back select 2, _back select 3]] call _say;
	["INFO", "pods", "%1 returned | refunded %2 (ammo, supply, fuel, meds)", [typeOf _pod, _back]] call MCC_fnc_log;
} else {
	[["The Taru couldn't pick the pod up.", "Pod picked up."] select _ok] call _say;
};
["INFO", "pods", "pick-up of %1: %2", [typeOf _pod, ["failed", "done"] select _ok]] call MCC_fnc_log;
[_h, _g] spawn MCCMK_fnc_podExit;
