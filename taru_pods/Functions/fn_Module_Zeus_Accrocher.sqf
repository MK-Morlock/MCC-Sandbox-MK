private _module = param [0,objnull];

if (!local _module) exitwith {};


//--- Terminate on client (unless it's curator who created the module)
if (!isserver AND {local _x} count (objectcurators _module) == 0) exitwith {};

_message = "Aucun";
_objet_Attacher_Au_Module = _module getvariable ["bis_fnc_curatorAttachObject_object",objnull];

_liste_vehicule_Objets = [_objet_Attacher_Au_Module,ASLToATL getposworld _module] call MCCMK_Taru_fnc_Recherche_Objet;
_liste_vehicule = _liste_vehicule_Objets select 0;
_liste_Objets = _liste_vehicule_Objets select 1;

// En fonction de ce que l'on a ou pas on lance un message adéquat
[] call
{
	if ((_liste_vehicule + _liste_Objets) isEqualTo []) exitwith {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Aucun_Heli_Ou_Objet";};
	if (count _liste_Objets > 0 AND {count _liste_vehicule isEqualTo 0}) exitwith {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Objet_A_Portee_Aucun_Heli";};
	if (count _liste_vehicule > 0 AND {count _liste_Objets isEqualTo 0}) then {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Heli_A_Portee_Aucun_Objet";};
};

if (_message isequalto "Aucun") then
{
	_vehicule = _liste_vehicule select 0;
	_objet = _liste_Objets select 0;


	if !(isnull (getSlingLoad _vehicule)) exitwith
	{
		_nom_objet = gettext (configfile >> "CfgVehicles" >> typeof (getSlingLoad _vehicule) >> "displayname");
		_message = _nom_objet + " " + localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Deja" + " " + localize "STR_MCCMK_Taru_Pod_Mod_Accrochee";
	};

	if !(_vehicule canslingload _objet) exitwith
	{
		_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Accrochage";
	};

	_nom_objet = gettext (configfile >> "CfgVehicles" >> typeof _objet >> "displayname");
	_message = _nom_objet + " " + localize "STR_MCCMK_Taru_Pod_Mod_Accrochee";

	[_vehicule,_objet] remoteExec ["MCCMK_Taru_fnc_Action_Accrochage",_vehicule];
};

if (_message isNotEqualTo "Aucun") then
{
	[objnull,_message] call bis_fnc_showCuratorFeedbackMessage;
};

deleteVehicle _module;