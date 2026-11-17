private _vehicule = param [0,objnull];


[{params ["_vehicule"];
	isnull getSlingLoad _vehicule AND
	{!isnull (_vehicule getvariable ["MCCMK_Info_Taru_Objet_Helitreuiller",objnull])} OR
	{!alive _vehicule} OR
	{isnull (_vehicule getvariable ["MCCMK_Info_Taru_Objet_Helitreuiller",objnull])}
},{params ["_vehicule"];
	if (!alive _vehicule) exitwith {};

	_vehicule allowdamage false;

	_objet_Helitreuiller = _vehicule getvariable ["MCCMK_Info_Taru_Objet_Helitreuiller",objnull];

	[_vehicule,0] remoteexec ["setCustomWeightRTD",_vehicule];
	[_vehicule,20000] remoteexec ["setmass",_vehicule];

	_vehicule setVariable ["MCCMK_Info_Taru",["Vide",0],true];

	_objet_Helitreuiller setvelocity [velocity _vehicule select 0,(velocity _vehicule select 1) - 2,(velocity _vehicule select 2) - 2];

	_vehicule setvariable ["MCCMK_Info_Taru_Objet_Helitreuiller",objnull,true];

	[{params ["_vehicule"]; [_vehicule] call MCCMK_Taru_fnc_Veille_Nacelle_Helitreuiller;},[_vehicule],0.3] call CBA_fnc_waitAndExecute;
	[{params ["_vehicule"]; _vehicule allowdamage true;},[_vehicule],1] call CBA_fnc_waitAndExecute;	
},[_vehicule]] call CBA_fnc_waitUntilAndExecute;

true