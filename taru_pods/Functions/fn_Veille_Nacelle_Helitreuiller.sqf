private _vehicule = param [0,objnull];


[{params ["_vehicule"];
	!isnull getSlingLoad _vehicule AND
	{isnull (_vehicule getvariable ["MCCMK_Info_Taru_Objet_Helitreuiller",objnull])} OR
	{!alive _vehicule}
},{params ["_vehicule"];	
	if (!alive _vehicule) exitwith {};	

	_objets_Helitreuiller = getSlingLoad _vehicule;
	
	_vehicule setvariable ["MCCMK_Info_Taru_Objet_Helitreuiller",_objets_Helitreuiller,true];
	
	[{params ["_vehicule"]; [_vehicule] call MCCMK_Taru_fnc_Veille_Nacelle_Deshelitreuiller;},[_vehicule],0.3] call CBA_fnc_waitAndExecute;
},[_vehicule]] call CBA_fnc_waitUntilAndExecute;

true