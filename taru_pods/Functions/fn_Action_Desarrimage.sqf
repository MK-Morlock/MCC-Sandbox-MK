private _vehicule = param [0,objnull];
private _type_Action = param [2,"Désarrimage"];


if !(local _vehicule) exitwith {};

_longueur_Corde = 10;
_MCCMK_Info_Taru = "Désarrimage";

_nacelle = getSlingLoad _vehicule;
_nom_Nacelle = gettext (configfile >> "CfgVehicles" >> typeof _nacelle >> "displayname");

// On vérifie si la nacelle était bien arrimé avant d'enlever son poid pour éviter de trop allégé l'hélico";
_vehicule setCustomWeightRTD 0;
_vehicule setmass (getmass _vehicule) - (getmass _nacelle);

_vehicule setvariable ["MCCMK_Info_Taru",[_MCCMK_Info_Taru,_longueur_Corde],true];

["Desarrimage",_vehicule] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];
detach _nacelle;

// Si l'helico est au sol on re accroche l'objet pour remettre les cordes a 10m";
if (ASLToATL getPosWorld _vehicule select 2 <= 3.1) then
{
	_vehicule setSlingLoad _nacelle;
} else
{
	if (_type_Action isEqualTo "Désarrimage") then
	{
		// Si l'action est un désarrimage simple on envoie un message a tout l'équipage";
		_message = _nom_Nacelle + " : " + localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Mot_Desarrimage";
		[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
	};

	// Lancement du son de l'action dans un autre spawn";
	[_vehicule,_MCCMK_Info_Taru,_longueur_Corde] spawn
	{
		private _vehicule = _this select 0;
		private _MCCMK_Info_Taru = _this select 1;
		private _longueur_Corde = _this select 2;

		waituntil
		{
			if (ropeLength (ropes _vehicule select 0) isEqualTo _longueur_Corde or {!alive _vehicule or {isnull (getSlingLoad _vehicule)}}) exitwith {true};
			if ((_vehicule getVariable "MCCMK_Info_Taru" select 0) isNotEqualTo _MCCMK_Info_Taru) exitwith {true};

			["Allonger Corde",_vehicule] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];

			sleep 1.77;

			false
		};
	};

	_script = [_vehicule,_MCCMK_Info_Taru,_longueur_Corde] spawn MCCMK_Taru_fnc_Action_Gestion_Cordes;

	waituntil
	{
		if (scriptdone _script) exitwith {true};
		if (!alive _vehicule or {isnull (getSlingLoad _vehicule)}) exitwith {true};

		sleep 0.3;

		false
	};
};
if (!alive _vehicule or {isnull getSlingLoad _vehicule}) exitwith {};
if ((_vehicule getVariable "MCCMK_Info_Taru" select 0) isNotEqualTo _MCCMK_Info_Taru) exitwith {};

_vehicule enableCollisionWith _nacelle;

// Si l'action est un désarrimage simple on envoie un message a tout l'équipage";
if (_type_Action isEqualTo "Désarrimage") then
{
	_message = _nom_Nacelle + " : " + localize "STR_MCCMK_Taru_Pod_Mod_Desarrimee";
	[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
};

_vehicule setvariable ["MCCMK_Info_Taru",["Désarrimé",10],true];