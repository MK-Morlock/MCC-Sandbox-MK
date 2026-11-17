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

	if (isnull (getSlingLoad _vehicule)) exitwith {_message = "Véhicule non compatible";};
	if ((aslToAtl getposworld _vehicule) select 2 > 100) exitwith {_message = "Véhicule trop haut pour le désarrimage d'assaut";};

	_hauteur_Surface = lineIntersectsSurfaces [ASLToATL getPosWorld _vehicule,atltoasl (_vehicule modelToWorld [0,0,-1000]),_vehicule,_vehicule] select 0 select 0 select 2;
	_hauteur_Nacelle = ASLToATL getPosWorld _vehicule select 2;
	_hauteur_Relative = _hauteur_Nacelle - _hauteur_Surface;

	if (_hauteur_Relative > 100) exitwith
	{
		_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Desarrimage_Impossible_Trop_Haut";
	};

	_nom_Nacelle = gettext (configfile >> "CfgVehicles" >> typeof getslingload _vehicule >> "displayname");

	if (_message isequalto "Aucun") then
	{
		_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Mot_Desarrimage_Assaut" + " " + _nom_Nacelle;
		[_vehicule] remoteExec ["MCCMK_Taru_fnc_Action_Desarrimage_Assaut",(objectcurators _module select {local _x})];
	};
};

if (_message isNotEqualTo "Aucun") then
{
	[objnull,_message] call bis_fnc_showCuratorFeedbackMessage;
};

deleteVehicle _module;