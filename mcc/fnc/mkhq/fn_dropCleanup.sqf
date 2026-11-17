/*
	MCCMK_fnc_dropCleanup - server postInit: removes piles of dropped weapons and items (left by players, by dead units
	outside generated missions, by a broken-down crate ...) after MCCMK_dropCleanup minutes, once no player is within 50 m
	or looking. Not touched: anything within 300 m of a respawn point (HQ, F.O.B.s), anything carried or attached, and
	weapons beside enemy bodies of generated missions - the mission cleanup removes those with the body.
	(MK) Body cleanup, in the same pass (MCCMK_bodyCleanup minutes; 0 = off): every body no mission owns - enemy and
	friendly AI, at bases too - removed with the weapons beside it, once no player is within 50 m or looking. Players'
	own bodies after twice the time (their kit can be recovered first). Never one carried or dragged, or mission bodies.
*/
if (!isServer) exitWith {};
// a player's body: marked as it dies (afterwards it no longer counts as a player)
addMissionEventHandler ["EntityKilled", {
	params ["_u"];
	if (_u isKindOf "CAManBase" && {isPlayer _u}) then {_u setVariable ["MCCMK_wasPlayer", true, true]};
}];
[] spawn {
	private _watched = {
		params ["_o", "_ppl"];
		private _end = (getPosASL _o) vectorAdd [0, 0, 0.5];
		(_ppl findIf {
			private _d = _x distance _o;
			(_d < 50) || {(_d < (viewDistance max 500)) && {private _rd = _x getRelDir _o; (_rd < 70) || {_rd > 290}} && {([_x, "VIEW", _o] checkVisibility [eyePos _x, _end]) > 0}}
		}) >= 0
	};
	while {true} do {
		sleep 60;
		private _mins = missionNamespace getVariable ["MCCMK_dropCleanup", 30];
		private _bMins = missionNamespace getVariable ["MCCMK_bodyCleanup", 30];
		private _ppl = [];
		{_ppl append ((units group _x) select {alive _x})} forEach (allPlayers - (entities "HeadlessClient_F"));
		_ppl = _ppl arrayIntersect _ppl;
		//(MK) bodies no mission owns: enemy and friendly AI (players' own after twice the time), at bases too
		if (_bMins > 0) then {
			private _nb = 0;
			{
				private _b = _x;
				private _seen = _b getVariable "MCCMK_bodySeen";
				private _veh = vehicle _b;	//(MK) a body inside a vehicle: taken out of an intact one (it stays); a wreck's goes with it
				private _inV = !(_veh isEqualTo _b);
				if (isNil "_seen") then {_b setVariable ["MCCMK_bodySeen", time]} else {
					private _wait = _bMins * 60 * ([1, 2] select (_b getVariable ["MCCMK_wasPlayer", false]));
					if ((time - _seen) >= _wait
						&& {(_b getVariable ["MCC_MWid", ""]) == ""}
						&& {isNull (attachedTo _b)}
						&& {!_inV || {alive _veh && {((crew _veh) findIf {alive _x && {isPlayer _x}}) < 0}}}
						&& {!([_b, _ppl] call _watched)}) then {
						if (_inV) then {_veh deleteVehicleCrew _b} else {
							{deleteVehicle _x} forEach (nearestObjects [_b, ["GroundWeaponHolder", "WeaponHolderSimulated"], 3]);
							deleteVehicle _b;
						};
						_nb = _nb + 1;
					};
				};
			} forEach allDeadMen;
			if (_nb > 0) then {["INFO", "MCCMK_fnc_dropCleanup", "removed %1 bodies", [_nb]] call MCC_fnc_log};
		};
		if (_mins > 0) then {
			private _bases = [];
			{_bases append ([_x] call BIS_fnc_getRespawnPositions)} forEach [west, east, resistance, civilian];
			private _missionDead = allDeadMen select {((_x getVariable ["MCC_MWid", ""]) != "") && {!(_x getVariable ["MCC_seized", false])}};
			private _n = 0;
			{
				private _h = _x;
				private _seen = _h getVariable "MCCMK_dropSeen";
				if (isNil "_seen") then {_h setVariable ["MCCMK_dropSeen", time]} else {
					if ((time - _seen) >= _mins * 60
						&& {isNull attachedTo _h}
						&& {(_bases findIf {(_h distance2D _x) < 300}) < 0}
						&& {(_missionDead findIf {(_x distance _h) < 3}) < 0}
						&& {!([_h, _ppl] call _watched)}) then {
						deleteVehicle _h;
						_n = _n + 1;
					};
				};
			} forEach ((allMissionObjects "GroundWeaponHolder") + (allMissionObjects "WeaponHolderSimulated"));
			if (_n > 0) then {["INFO", "MCCMK_fnc_dropCleanup", "removed %1 piles of dropped items", [_n]] call MCC_fnc_log};
		};
	};
};
