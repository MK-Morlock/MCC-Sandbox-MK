private _vehicule = param [0,objnull];


[{params ["_vehicule"];
	count (attachedObjects _vehicule select {!alive _x}) > 0 OR
	{!alive _vehicule}
},{params ["_vehicule"];	
	if (!alive _vehicule) exitwith {};

	_liste_Objets_Detruits = attachedObjects _vehicule select {!alive _x};

	{
		_objet_Attacher = _x;

		_vehicule setCustomWeightRTD 0;
		_vehicule setmass 20000;

		detach _objet_Attacher;

		_objet_Attacher setvelocity [velocity _vehicule select 0,(velocity _vehicule select 1) - 2,(velocity _vehicule select 2) - 2];
	} foreach _liste_Objets_Detruits;

	_vehicule setvariable ["MCCMK_Info_Taru",["Vide",objnull],true];

	_message = (localize "STR_MCCMK_Taru_Pod_Mod_Vehiclechat_Objet_Detruit");
	[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
	
	[{params ["_vehicule"]; [_vehicule] call MCCMK_Taru_fnc_Veille_Nacelle_Detruite;},[_vehicule],0.3] call CBA_fnc_waitAndExecute;
},[_vehicule]] call CBA_fnc_waitUntilAndExecute;

true