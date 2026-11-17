/*
	MCCMK_fnc_fltRepair - (server) "Repair helicopter" on the water: [aircraft, player]. 10 seconds' work (he must stay aboard
	it or in the boat in its bay), then repaired AS A TOOLKIT REPAIR IS in this game: with ACE, its field repair - every part
	brought back to ACE's field-repair limit (ace_repair_repairDamageThreshold); without ACE, Arma's own toolkit repair, the
	whole aircraft. Its Floatary leak follows: able to fly again, it is watertight again ("Plug the leak" pumps out the water).
	The parts' damage before and after is logged (debug on).
*/
params [["_v", objNull], ["_u", objNull]];
if (!isServer || {isNull _v} || {!alive _v} || {isNull _u}) exitWith {};
private _with = {params ["_m"]; [_m] remoteExec ["MCCMK_fnc_hint", _u]};
private _in = {((vehicle _u) isEqualTo _v) || {(attachedTo (vehicle _u)) isEqualTo _v}};
if !(call _in) exitWith {};
["Repairing the helicopter..."] call _with;
private _t = time + 10;
waitUntil {sleep 0.5; time > _t || {!alive _u} || {!alive _v} || {!(call _in)}};
if (!alive _u || {!alive _v} || {!(call _in)}) exitWith {["Repair stopped"] call _with};
private _before = getAllHitPointsDamage _v;
private _ace = isClass (configFile >> "CfgPatches" >> "ace_repair");
if (_ace) then {
	private _lim = missionNamespace getVariable ["ace_repair_repairDamageThreshold", 0.6];
	{
		private _d = (_before select 2) param [_forEachIndex, 0];
		if (_d > _lim) then {[_v, [_x, _lim]] remoteExec ["setHitPointDamage", _v]};
	} forEach (_before select 0);
} else {
	[_v, 0] remoteExec ["setDamage", _v];
};
["Helicopter repaired"] call _with;
[_v, _ace, _before] spawn {
	params ["_v", "_ace", "_before"];
	sleep 1;
	if (missionNamespace getVariable ["MCC_debug", false]) then {
		private _a = getAllHitPointsDamage _v;
		["INFO", "floatary", "%1 repaired on the water (%2): damage before %3 | after %4, can move %5", [typeOf _v, ["vanilla toolkit", "ACE field repair"] select _ace, (_before select 2) apply {_x toFixed 2}, (_a select 2) apply {_x toFixed 2}, canMove _v]] call MCC_fnc_log;
	};
};
