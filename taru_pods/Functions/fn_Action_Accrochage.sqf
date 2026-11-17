private _vehicule = param [0,objnull];
private _objet_Accrocher = param [1,objnull];


if !(local _vehicule) exitwith {};

if (count (ropes _vehicule) > 0) then
{
	{
		deletevehicle _x;
	} foreach ropes _vehicule;
};

_vehicule setslingload _objet_Accrocher;

["Accrochage",_vehicule] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];

true