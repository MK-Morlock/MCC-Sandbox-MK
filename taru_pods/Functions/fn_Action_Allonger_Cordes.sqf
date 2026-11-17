private _vehicule = param [0,objnull];
private _longueur_Corde = param [1,(_vehicule getVariable ["MCCMK_Info_Taru",["",0]]) select 1];


if !(local _vehicule) exitwith {};

// On prend la longueur de la corde de l'helico et on enlève 10";
_longueur_Corde = _longueur_Corde + 10;

// "Si moins de 10 on remet a 10";
if (_longueur_Corde > 100) then {_longueur_Corde = 100;};

// "On met la valeur dans le script de traitement de la longueur de corde qui va faire en sorte que le nombre inséré reste dans les dizaines : ex 10.3 => 10, 11.8 => 10,15 =>20";

_longueur_Corde = [_longueur_Corde] call MCCMK_Taru_fnc_Traitement_Longueur_Cordes;
_MCCMK_Info_Taru = "Allonger";

_message = (localize "STR_MCCMK_Taru_Pod_Mod_Allongement_Corde") + " " + str(_longueur_Corde) + "m";

[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;

_vehicule setvariable ["MCCMK_Info_Taru",[_MCCMK_Info_Taru,_longueur_Corde],true];

// "Lancement du son de l'action dans un autre spawn";
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

// Action pour allonger les cordes";
_script = [_vehicule,"Allonger",_longueur_Corde] spawn MCCMK_Taru_fnc_Action_Gestion_Cordes;

waituntil
{
	if (scriptdone _script) exitwith {true};
	if (!alive _vehicule or {isnull (getSlingLoad _vehicule)}) exitwith {true};

	sleep 0.3;

	false
};
if (!alive _vehicule or {isnull (getSlingLoad _vehicule)}) exitwith {};
if ((_vehicule getVariable "MCCMK_Info_Taru" select 0) isNotEqualTo _MCCMK_Info_Taru) exitwith {true};

_message = (localize "STR_MCCMK_Taru_Pod_Mod_Corde_Allonger_A") + " " + str(_longueur_Corde) + "m";

[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;

_vehicule setvariable ["MCCMK_Info_Taru",["En attente",_longueur_Corde],true];