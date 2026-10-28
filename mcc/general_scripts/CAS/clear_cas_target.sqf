

params ["_cas_name", "_targeth", "_spawnkind"];

//hint format ["Target damage check A: %1", (damage _targeteh)];
//sleep 0.1;

if ( _spawnkind == "Gun-run short(ACE)" ) then	{
	sleep 40;
	}	else	{
		sleep 110;
};

if (!(IsNil "_targeth")) then {_targeth setdamage 1};

//allow time for strafe_cas_target.sqf script to catch up
sleep 5;

if (IsNil "_targeth") then {_targeth = objNull};
deleteVehicle _targeth;