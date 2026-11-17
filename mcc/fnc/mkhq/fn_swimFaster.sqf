/*
	MCCMK_fnc_swimFaster - (every computer, postInit) faster swimming and diving.
	Based on "Swim Faster" by Alkanet (Alkanet_smorgastarta) - Steam Workshop 1808723766, ADPL-SA - used with the author's
	permission ("feel free to copy paste whatever you need"). The original raises the speed of six swimming animations
	in config, about 1.5x vanilla (surface 0.238 -> 0.35-0.38, diving 0.122 -> 0.2); it can't be switched off, leaves
	Shift (sprint) swimming at vanilla speed - so Shift is slower than plain swimming - and only speeds up diving with a
	rifle in hand. Here it's done by script instead: while a soldier is swimming (on the surface) or diving, his animation
	speed multiplier (setAnimSpeedCoef) is set - normal and Shift swimming alike, diving with or without a weapon - and put
	back to 1 when he's out of those animations.
	Settings (MCCMK General > Swimming): "Swim faster" (on), "Swim faster: surface speed" and "...: diving speed" (1.5x).
	Each computer handles its own soldiers (the multiplier is the game's, seen by everyone). Side effect: anything else he
	does while swimming (a reload) plays at that speed too.
*/
[] spawn {
	waitUntil {sleep 1; time > 1};
	private _mult = [1.25, 1.5, 1.75, 2];
	//(MK) only the soldiers in the water (or still sped up) are looked at four times a second; who they are is worked
	// out once a second.
	private _wet = [];
	private _tick = 0;
	while {true} do {
		if (_tick % 4 == 0) then {
			_wet = allUnits select {local _x && {alive _x} && {((_x getVariable ["MCCMK_swimCoef", 1]) != 1) || {((getPosASL _x) select 2) < 1.5 && {surfaceIsWater (getPosASL _x)}}}};
		};
		_tick = _tick + 1;
		private _on = missionNamespace getVariable ["MCCMK_swimFaster", true];
		private _surf = _mult select ((missionNamespace getVariable ["MCCMK_swimSurface", 1]) min 3 max 0);
		private _dive = _mult select ((missionNamespace getVariable ["MCCMK_swimDive", 1]) min 3 max 0);
		{
			private _u = _x;
			private _a = toLower (animationState _u);
			private _want = 1;
			if (_on && {vehicle _u == _u}) then {
				private _p = _a select [0, 4];
				if (_p in ["aswm", "assw", "absw"]) then {_want = _surf};
				if (_p in ["adve", "asdv", "abdv"]) then {_want = _dive};
			};
			private _set = _u getVariable ["MCCMK_swimCoef", 1];
			if !(_want isEqualTo _set) then {
				_u setAnimSpeedCoef _want;
				_u setVariable ["MCCMK_swimCoef", _want];
			};
		} forEach (_wet select {!isNull _x && {alive _x}});
		sleep 0.25;
	};
};
