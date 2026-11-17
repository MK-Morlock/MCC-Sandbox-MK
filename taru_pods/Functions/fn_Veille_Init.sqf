private _vehicule = param [0,objnull];


[_vehicule] call MCCMK_Taru_fnc_Veille_Nacelle_Localite;
[_vehicule] call MCCMK_Taru_fnc_Veille_Nacelle_Detruite;
[_vehicule] call MCCMK_Taru_fnc_Veille_Nacelle_Helitreuiller;

true