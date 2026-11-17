private _vehicule = param [0,objnull];


if !(local _vehicule) exitwith {};

_nacelle_Parachuter = getSlingLoad _vehicule;
_nom_Nacelle = gettext (configfile >> "CfgVehicles" >> typeof _nacelle_Parachuter >> "displayname");

[_vehicule,"Parachutage"] remoteExec ["MCCMK_Taru_fnc_Action_Decrochage",_vehicule];

_message = _nom_Nacelle + " : " + localize "STR_MCCMK_Taru_Pod_Mod_parachutee";
[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;

[_nacelle_Parachuter] remoteExec ["MCCMK_Taru_fnc_Veille_Parachutage_Auto",_nacelle_Parachuter];