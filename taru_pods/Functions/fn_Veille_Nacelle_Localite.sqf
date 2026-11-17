private _vehicule = param [0,objnull];


[{params ["_vehicule"];
	!isnull (getSlingLoad _vehicule) AND
	{owner getSlingLoad _vehicule isNotEqualTo owner _vehicule} OR
	{!alive _vehicule}
},{params ["_vehicule"];
	if (!alive _vehicule) exitwith {};

	[getSlingLoad _vehicule,owner _vehicule] remoteExec ['setowner',2];

	[{params ["_vehicule"]; [_vehicule] call MCCMK_Taru_fnc_Veille_Nacelle_Localite;},[_vehicule],0.3] call CBA_fnc_waitAndExecute;
},[_vehicule]] call CBA_fnc_waitUntilAndExecute;

true