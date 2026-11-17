// Free resources (server): while costs are off, each side's stock is kept topped up at a million of everything, so no
// script anywhere can run short (shown as the infinity sign). When costs come back on, the stock it had before is
// put back, so Free can't be used to fill up.
// Runs only while costs are Free (or there's stock to give back): started at mission start, whenever either resources
// setting changes, and when a campaign starts; it stops once costs are back on and the stock is restored.
if (!isServer) exitWith {};
if (missionNamespace getVariable ["MCCMK_resFreeRunning", false]) exitWith {};
private _anySaved = ([west, east, resistance] findIf {!isNil {missionNamespace getVariable (format ["MCCMK_resBeforeFree%1", _x])}}) >= 0;
if (!(call MCCMK_fnc_resFree) && {!_anySaved}) exitWith {};
MCCMK_resFreeRunning = true;
[] spawn {
	sleep 1;
	while {true} do {
		private _free = call MCCMK_fnc_resFree;
		{
			private _var = format ["MCC_res%1", _x];
			private _saved = format ["MCCMK_resBeforeFree%1", _x];
			private _r = missionNamespace getVariable [_var, [500, 500, 200, 200, 100]];
			if (_free) then {
				if (isNil {missionNamespace getVariable _saved}) then {missionNamespace setVariable [_saved, +_r]};
				if ((_r findIf {_x < 900000}) >= 0) then {missionNamespace setVariable [_var, [1e6, 1e6, 1e6, 1e6, 1e6]]; publicVariable _var};
			} else {
				if (!isNil {missionNamespace getVariable _saved}) then {
					missionNamespace setVariable [_var, missionNamespace getVariable _saved];
					missionNamespace setVariable [_saved, nil];
					publicVariable _var;
				};
			};
		} forEach [west, east, resistance];
		if (!_free && {([west, east, resistance] findIf {!isNil {missionNamespace getVariable (format ["MCCMK_resBeforeFree%1", _x])}}) < 0}) exitWith {};
		sleep 2;
	};
	MCCMK_resFreeRunning = false;
};
