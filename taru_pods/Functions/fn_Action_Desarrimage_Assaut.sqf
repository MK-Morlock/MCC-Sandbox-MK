private _vehicule = param [0,objnull];


if !(local _vehicule) exitwith {};

_longueur_Corde = 100;
_MCCMK_Info_Taru = "Désarrimage d'assaut";
_nacelle_Accrocher = getSlingLoad _vehicule;
_nom_Nacelle = gettext (configfile >> "CfgVehicles" >> typeof _nacelle_Accrocher >> "displayname");

// // On met une variable TIME sur l'hélico qui servira à stopper l'action si une autre action est enclenchée";
_vehicule setvariable ["MCCMK_Info_Taru",[_MCCMK_Info_Taru,_longueur_Corde],true];

["Desarrimage",_vehicule] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];
detach _nacelle_Accrocher;

_vehicule setCustomWeightRTD 0;
_vehicule setmass (getmass _vehicule) - (getmass _nacelle_Accrocher);

_message = localize "STR_MCCMK_Taru_Pod_Mod_Desarrimage_Assaut_Descente_Nacelle";
[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;

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

_script = [_vehicule,"Désarrimage d'assaut",_longueur_Corde,12,4] spawn MCCMK_Taru_fnc_Action_Gestion_Cordes;

waituntil
{
	if (scriptdone _script) exitwith {true};
	if (!alive _vehicule or {isnull (getSlingLoad _vehicule)}) exitwith {true};
	sleep 0.3;

	false
};
if (!alive _vehicule or {isnull (getSlingLoad _vehicule)}) exitwith {};
if ((_vehicule getVariable "MCCMK_Info_Taru" select 0) isNotEqualTo _MCCMK_Info_Taru) exitwith {true};

_message = localize "STR_MCCMK_Taru_Pod_Mod_Desarrimage_Assaut_Nacelle_Sol";
[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;

// On commence la partie ou on fait sortir les IA de la nacelle et une fois ca fait on remonte automatiquement en arrimage";
waituntil
{
	_liste_Passagers = fullCrew _nacelle_Accrocher;

	{
		_passager = _x select 0;
		_numero_Place_Passager = _x select 2;

		[[_passager,_nacelle_Accrocher],{(_this select 0) leaveVehicle (_this select 1);}] remoteExec ["bis_fnc_spawn",0];
		[[_passager],{unassignVehicle (_this select 0);}] remoteExec ["bis_fnc_spawn",0];

		moveout _passager;

		private _tp = time + 10;
		waituntil {isnull objectParent _passager || {time > _tp}};

		[] call
		{
			if (_numero_Place_Passager isEqualTo 0) exitwith
			{
				_passager setpos (vehicle _passager modeltoworld [-1.4,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) + 45);
				_passager setdir ((getdir _nacelle_Accrocher) + 45);

				_passager setUnitPos "MIDDLE";
			};

			if (_numero_Place_Passager isEqualTo 1) exitwith
			{
				_passager setpos (vehicle _passager modeltoworld [-0.5,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) + 90);
				_passager setdir ((getdir _nacelle_Accrocher) + 90);
			};

			if (_numero_Place_Passager isEqualTo 2) exitwith
			{
				_passager setpos (vehicle _passager modeltoworld [0.4,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) + 90);
				_passager setdir ((getdir _nacelle_Accrocher) + 90);
			};

			if (_numero_Place_Passager isEqualTo 3) exitwith
			{
				_passager setpos (vehicle _passager modeltoworld [1.3,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) + (180 - 45));
				_passager setdir ((getdir _nacelle_Accrocher) + (180 - 45));

				_passager setUnitPos "MIDDLE";
			};

			if (_numero_Place_Passager isEqualTo 4) exitwith
			{
				_passager setpos (vehicle _passager modeltoworld [-1.4,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) + (180 + 45));
				_passager setdir ((getdir _nacelle_Accrocher) + (180 + 45));

				_passager setUnitPos "MIDDLE";
			};

			if (_numero_Place_Passager isEqualTo 5) exitwith
			{
				_passager setpos (vehicle _passager modeltoworld [-0.5,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) - 90);
				_passager setdir ((getdir _nacelle_Accrocher) - 90);
			};

			if (_numero_Place_Passager isEqualTo 6) exitwith
			{
				_passager setpos (vehicle _passager modeltoworld [0.4,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) - 90);
				_passager setdir ((getdir _nacelle_Accrocher) - 90);
			};

			if (_numero_Place_Passager isEqualTo 7) then
			{
				_passager setpos (vehicle _passager modeltoworld [1.3,0,0]);
				_passager setFormdir ((getdir _nacelle_Accrocher) - 45);
				_passager setdir ((getdir _nacelle_Accrocher) - 45);

				_passager setUnitPos "MIDDLE";
			};
		};

		sleep 0.15;
	} foreach _liste_Passagers;

	if (crew _nacelle_Accrocher isEqualTo []) exitwith
	{
		_message = (localize "STR_MCCMK_Taru_Pod_Mod_Desarrimage_Assaut_Nacelle_Vide");
		[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;

		sleep 2;

		_vehicule setvariable ["MCCMK_Info_Taru",[_MCCMK_Info_Taru,_longueur_Corde],true];

		[_vehicule,"Désarrimage d'assaut"] remoteExec ["MCCMK_Taru_fnc_Action_Arrimage",owner _vehicule];

		true
	};

	if (!alive _vehicule or {isnull (getSlingLoad _vehicule)}) exitwith {true};

	false
};