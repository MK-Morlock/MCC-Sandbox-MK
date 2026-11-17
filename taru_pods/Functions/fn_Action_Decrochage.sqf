private _vehicule = param [0,objnull];
private _type_Action = param [1,"Décrochage"];


if !(local _vehicule) exitwith {};

_objet_Accrocher = getSlingLoad _vehicule;
_liste_Nacelle_Parent = ["Pod_Heli_Transport_04_crewed_base_F","Pod_Heli_Transport_04_base_F","Cargo_base_F","Slingload_01_Base_F"];
_nom_Nacelle = gettext (configfile >> "CfgVehicles" >> typeof _objet_Accrocher >> "displayname");

["Décrochage",_vehicule] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];

_vehicule disableCollisionWith _objet_Accrocher;
_vehicule setSlingLoad objNull;
detach _objet_Accrocher;

_objet_Accrocher setvelocity [velocity _vehicule select 0,(velocity _vehicule select 1) - 2,(velocity _vehicule select 2) - 2];

if (_type_Action isEqualTo "Décrochage") then
{
	_message = _nom_Nacelle + " : " + localize "STR_MCCMK_Taru_Pod_Mod_Decrochee";
	[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
};

if (_type_Action isEqualTo "Parachutage") then
{
	_vehicule setvariable ["MCCMK_Info_Taru",["Parachuté",1],true];
};

_vehicule enableCollisionWith _objet_Accrocher;