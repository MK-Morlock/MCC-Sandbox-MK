/*=================================================== MCC_fnc_MWCacheDestructible ==================================================
	Makes a "destroy the weapons cache" objective destroyable.

	The default cache types (Box_East_AmmoVeh_F, Land_Pallet_MilBoxes_F) are props that take no damage in Arma 3, so the
	"Destroy the enemy weapons cache" task could never complete. The cache is destroyed when:
		- an explosive charge (satchel, demo block, ACE explosive...) explodes within 6 m of it,
		- a shell, bomb, rocket or missile explodes within its blast radius of the cache, or
		- the object takes real damage of 0.9 or more (for cache types that can be damaged).
	The cache is then blown up, which completes the task: a split second after the trigger the main blast (cache and the
	crates next to it removed, a crater left), fire and smoke at once (fire ~5 min, smoke ~7 min), the two small
	secondary blasts, and an ammo cook-off of about 25 s that starts a second or two later.

	Detonations are detected with the projectile "Explode" event handler (Arma 3 2.10+), not by a charge disappearing.
	A charge that is defused, disarmed or picked up is deleted without exploding, so it no longer counts.
	Placed charges are local to the player who placed them, so the handler is added on the server and on the charge's owner.

	<IN>	0: OBJECT - the cache
			1: STRING - (internal) "init" (default), "charge" (add the handler where the charge is local), "blow" (server)
			2: ANY    - (internal) the charge for "charge", the cause for "blow"
==================================================================================================================================*/
#define MCC_CACHE_CHARGE_RANGE 6

params [["_cache", objNull, [objNull]], ["_mode", "init", [""]], ["_arg", objNull]];
if (isNull _cache) exitWith {};

switch (_mode) do {

	// Where the charge is local: report an explosion close to the cache to the server
	case "charge": {
		private _charge = _arg;
		if (isNull _charge || {_charge getVariable ["MCC_cacheExplodeEH", false]}) exitWith {};
		_charge setVariable ["MCC_cacheExplodeEH", true];
		_charge setVariable ["MCC_cacheTarget", _cache];
		_charge addEventHandler ["Explode", {
			params ["_charge", "_pos"];
			private _cache = _charge getVariable ["MCC_cacheTarget", objNull];
			if (isNull _cache || {(_pos distance2D _cache) > MCC_CACHE_CHARGE_RANGE}) exitWith {};
			if (isServer) then {
				[_cache, "blow", "explosive charge"] call MCC_fnc_MWCacheDestructible;
			} else {
				[_cache, "blow", "explosive charge"] remoteExecCall ["MCC_fnc_MWCacheDestructible", 2];
			};
		}];
	};

	// Server: mark the cache for destruction, the watch loop below does the rest
	case "blow": {
		if (!isServer || {!(_cache getVariable ["MCC_cacheWatched", false])}) exitWith {};
		if (_cache getVariable ["MCC_cacheBlownCause", ""] != "") exitWith {};
		_cache setVariable ["MCC_cacheBlownCause", if (_arg isEqualType "") then {_arg} else {"explosion"}];
	};

	default {
		if (!isServer) exitWith {[_cache] remoteExec ["MCC_fnc_MWCacheDestructible", 2]};
		if (_cache getVariable ["MCC_cacheWatched", false]) exitWith {};
		_cache setVariable ["MCC_cacheWatched", true];

		// Real damage, for cache types that can take it
		_cache addEventHandler ["HandleDamage", {
			params ["_obj", "", "_damage"];
			if (_damage >= 0.9) then {[_obj, "blow", "damage"] call MCC_fnc_MWCacheDestructible};
			_damage
		}];

		[_cache] spawn {
			params ["_cache"];
			private _ordnance = [];     // [projectile, lastPos, blastRadius] flying near the cache (fallback if Explode is not raised on the server)
			private _cachePos = getPosASL _cache;
			private _cause = "";

			while {alive _cache && {(_cache getVariable ["MCC_cacheBlownCause", ""]) == ""}} do {
				_cachePos = getPosASL _cache;

				// Placed charges near the cache: add the "Explode" handler on the server and on the machine that owns the charge
				{
					if !(_x getVariable ["MCC_cacheExplodeEH", false]) then {
						[_cache, "charge", _x] call MCC_fnc_MWCacheDestructible;
						private _owner = owner _x;
						if (_owner > 2) then {[_cache, "charge", _x] remoteExecCall ["MCC_fnc_MWCacheDestructible", _owner]};
					};
				} forEach (allMines select {(_x distance2D _cache) < (MCC_CACHE_CHARGE_RANGE + 2)});

				// Shells, bombs, rockets, missiles: "Explode" handler for the exact impact point...
				private _near = (_cache nearObjects ["ShellCore", 40]) + (_cache nearObjects ["BombCore", 60]) + (_cache nearObjects ["MissileCore", 40]) + (_cache nearObjects ["RocketCore", 40]);
				_near = _near select {getNumber (configFile >> "CfgAmmo" >> typeOf _x >> "indirectHit") >= 20};
				{
					if !(_x getVariable ["MCC_cacheExplodeEH", false]) then {
						_x setVariable ["MCC_cacheExplodeEH", true];
						_x setVariable ["MCC_cacheTarget", _cache];
						_x setVariable ["MCC_cacheBlastRadius", ((getNumber (configFile >> "CfgAmmo" >> typeOf _x >> "indirectHitRange")) * 1.5) max 4];
						_x addEventHandler ["Explode", {
							params ["_proj", "_pos"];
							private _cache = _proj getVariable ["MCC_cacheTarget", objNull];
							if (!isNull _cache && {(_pos distance2D _cache) < (_proj getVariable ["MCC_cacheBlastRadius", 4])}) then {
								[_cache, "blow", "ordnance"] call MCC_fnc_MWCacheDestructible;
							};
						}];
					};
				} forEach _near;

				// ...and a fallback: one that vanished inside its blast radius of the cache hit it
				{
					_x params ["_proj", "_pos", "_radius"];
					if (isNull _proj && {(_pos vectorDistance _cachePos) < _radius}) exitWith {_cause = "ordnance"};
				} forEach _ordnance;
				if (_cause != "") exitWith {};
				_ordnance = _near apply {[_x, getPosASL _x, _x getVariable ["MCC_cacheBlastRadius", 4]]};

				sleep 0.05;
			};

			if (isNull _cache) exitWith {};
			if (_cause == "") then {_cause = _cache getVariable ["MCC_cacheBlownCause", ""]};
			if (_cause == "") then {_cause = "damage"};
			_cache setVariable ["MCC_cacheBlownCause", _cause];

			private _pos = getPosATL _cache;
			_pos set [2, 0];
			//The cache goes up a split second after whatever set it off (charge, shell, rocket), as a real dump would
			sleep (0.12 + random 0.13);

			//Main blast: the task completes, the cache and the ammo crates next to it are gone
			_cache setDamage 1;
			createVehicle ["HelicopterExploSmall", _pos, [], 0, "CAN_COLLIDE"];
			private _crates = (nearestObjects [_pos, ["ReammoBox_F", "ReammoBox", "Land_Pallet_MilBoxes_F", "Box_East_AmmoVeh_F"], 6]) select {_x != _cache};
			deleteVehicle _cache;
			{deleteVehicle _x} forEach _crates;

			//The two small secondary blasts that follow the main blast (kept from earlier builds)
			[_pos] spawn {
				params ["_pos"];
				for "_i" from 1 to 2 do {
					sleep (0.6 + random 1.2);
					createVehicle ["SmallSecondary", _pos getPos [random 3, random 360], [], 0, "CAN_COLLIDE"];
				};
			};

			//Crater where the cache stood (stays for the rest of the mission)
			private _craterType = ["Land_ShellCrater_02_small_F", "Land_ShellCrater_01_F", "Crater"] select {isClass (configFile >> "CfgVehicles" >> _x)};
			if (count _craterType > 0) then {
				private _crater = createVehicle [_craterType select 0, _pos, [], 0, "CAN_COLLIDE"];
				_crater setDir random 360;
				_crater setVectorUp (surfaceNormal _pos);
			};

			//Fire and smoke start at once: the fire burns about 5 minutes, the smoke lingers a little longer
			private _burn = [];
			{
				_x params ["_type", "_life"];
				if (isClass (configFile >> "CfgVehicles" >> _type)) then {
					private _obj = createVehicle [_type, _pos, [], 0, "CAN_COLLIDE"];
					_burn pushBack [_obj, _life];
				} else {
					["WARNING", "MCC_fnc_MWCacheDestructible", "%1 is not in this game's config - not created", [_type]] call MCC_fnc_log;
				};
			} forEach [["test_EmptyObjectForFireBig", 270 + random 60], ["test_EmptyObjectForSmoke", 390 + random 60]];
			{
				_x spawn {
					params ["_obj", "_life"];
					sleep _life;
					deleteVehicle _obj;
				};
			} forEach _burn;

			//Ammo cook-off (as well as the two secondary blasts): starts a second or two after the main blast and runs about 25 seconds - rapid pops at first,
			//thinning out as the ammo is used up. Pops are scattered up to 4 m around the cache, at different heights.
			[_pos] spawn {
				params ["_pos"];
				sleep (0.8 + random 1.2);
				private _end = time + 22 + random 8;
				private _start = time;
				while {time < _end} do {
					private _p = _pos getPos [random 4, random 360];
					_p set [2, 0.2 + random 1.3];
					createVehicle ["SmallSecondary", _p, [], 0, "CAN_COLLIDE"];
					//Now and then two go off together
					if (random 1 < 0.15) then {
						sleep (0.05 + random 0.1);
						private _p2 = _pos getPos [random 4, random 360];
						_p2 set [2, 0.2 + random 1.3];
						createVehicle ["SmallSecondary", _p2, [], 0, "CAN_COLLIDE"];
					};
					private _elapsed = time - _start;
					sleep (switch (true) do {
						case (_elapsed < 8):  {0.15 + random 0.65};	//intense
						case (_elapsed < 18): {0.5 + random 1.5};	//slowing
						default               {1.5 + random 2.5};	//last few
					});
				};
			};

			["INFO", "MCC_fnc_MWCacheDestructible", "weapons cache at %1 destroyed by %2", [mapGridPosition _pos, _cause]] call MCC_fnc_log;
		};
	};
};
