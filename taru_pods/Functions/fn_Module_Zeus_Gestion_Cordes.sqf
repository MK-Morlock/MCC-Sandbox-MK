private _module = param [0,objnull];

if (!local _module) exitwith {};


_message = "Aucun";
_objet_Attacher_Au_Module = _module getvariable ["bis_fnc_curatorAttachObject_object",objnull];

_liste_vehicule_Objets = [_objet_Attacher_Au_Module,ASLToATL getposworld _module] call MCCMK_Taru_fnc_Recherche_Objet;
_liste_vehicule = _liste_vehicule_Objets select 0;
_liste_Objets = _liste_vehicule_Objets select 1;
_vehicule = _liste_vehicule select 0;

_longueur_Corde = _vehicule getvariable "MCCMK_Info_Taru" select 1;
_typeof_Module = typeof _module;

[] call
{
	if ((_liste_vehicule + _liste_Objets) isEqualTo []) exitwith {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Aucun_Heli_Ou_Objet";};
	if (count _liste_Objets >= 1 AND {count _liste_vehicule < 1}) exitwith {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Objet_A_Portee_Aucun_Heli";};
	if (count _liste_vehicule >= 1 AND {count _liste_Objets < 1}) exitwith {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Heli_A_Portee_Aucun_Objet";};

	if (_typeof_Module in ["MCCMK_Zeus_Taru_Allonger","MCCMK_Zeus_Taru_Allonger_Max"] AND {_longueur_Corde >= 100}) exitwith {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Pas_Allonger";};
	if (_typeof_Module in ["MCCMK_Zeus_Taru_Raccourcir","MCCMK_Zeus_Taru_Raccourcir_Max"] AND {_longueur_Corde <= 10}) then {_message = localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Pas_Raccourcir";};
};

if (_message isequalto "Aucun") then
{
	// On vérifie si l'objet valide est arrimé";
	if ([_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer) then
	{
		[_vehicule] remoteExec ['MCCMK_Taru_fnc_Action_Desarrimage',_vehicule];

		private _tz = time + 60;
		waituntil
		{
			if (time > _tz) exitwith {true};
			if (!([_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer) AND {ropeLength (ropes _vehicule select 0) >= 10}) exitwith {true};
			if !(alive _vehicule) exitwith {true};

			false
		};
	};

	[] call
	{
		if (_typeof_Module isEqualTo "MCCMK_Zeus_Taru_Allonger") exitwith
		{
			_longueur_Corde = [_longueur_Corde] call MCCMK_Taru_fnc_Traitement_Longueur_Cordes;

			[_vehicule,_longueur_Corde] remoteExec ['MCCMK_Taru_fnc_Action_Allonger_Cordes',_vehicule];

			_message = (localize "STR_MCCMK_Taru_Pod_Mod_Allongement_Corde") + " " + str(_longueur_Corde + 10) + "m";
		};

		if (_typeof_Module isEqualTo "MCCMK_Zeus_Taru_Allonger_Max") exitwith
		{
			[_vehicule,100] remoteExec ['MCCMK_Taru_fnc_Action_Allonger_Cordes',_vehicule];

			_message = (localize "STR_MCCMK_Taru_Pod_Mod_Allongement_Corde") + " 100m";
		};

		if (_typeof_Module isEqualTo "MCCMK_Zeus_Taru_Raccourcir") exitwith
		{
			_longueur_Corde = [_longueur_Corde] call MCCMK_Taru_fnc_Traitement_Longueur_Cordes;

			[_vehicule] remoteExec ['MCCMK_Taru_fnc_Action_Raccourcir_Cordes',_vehicule];

			_message = (localize "STR_MCCMK_Taru_Pod_Mod_Raccourcissement_Corde") + " " + str(_longueur_Corde - 10) + "m";
		};

		if (_typeof_Module isEqualTo "MCCMK_Zeus_Taru_Raccourcir_Max") then
		{
			[_vehicule,10] remoteExec ['MCCMK_Taru_fnc_Action_Raccourcir_Cordes',_vehicule];

			_message = (localize "STR_MCCMK_Taru_Pod_Mod_Raccourcissement_Corde") + " 10m";
		};
	};
};

if (_message isNotEqualTo "Aucun") then
{
	[objnull,_message] call bis_fnc_showCuratorFeedbackMessage;
};

deleteVehicle _module;