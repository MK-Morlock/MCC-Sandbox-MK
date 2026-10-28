//==================================================================MCC_fnc_artyFlare===============================================================================================
// Create artillery strike with sounds on given spot
// Example: [_pos, _shelltype, _shellspread, _nshell, _sound] spawn MCC_fnc_artyFlare;
// _pos = position. Point of impact
//_shelltype = string. Ammuination class name
//_shellspread = integer. Spread radius.
// _nshell = integer. Number of shells per burst
// _sound = boolean, True - for impact wistle sound
//===========================================================================================================================================================================	
private _i = objNull;
params ["_pos", "_shelltype", "_shellspread", "_nshell", "_sound", "_delay"];

if (isnil "_delay") then {_delay = 0};

for [{_i=0},{_i<_nshell},{_i=_i+1}] do
	{
		_bomb = _shelltype createVehicle [(_pos select 0) + _shellspread - 2*(random _shellspread) ,(_pos select 1) + _shellspread - 2*(random _shellspread), 250];
		_bomb setVelocity [(random 10) - (random 10), (random 10) - (random 10), -10];
		sleep 1; 
		if (_sound) then {[[netid _bomb,_bomb],"SN_Flare_Fired_4"] remoteExec ["MCC_fnc_globalSay3D", 0, false];}; 
		sleep _delay;
	};
