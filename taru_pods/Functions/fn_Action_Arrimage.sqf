private _vehicule = param [0,objnull];
private _type_Action = param [1,"Arrimage"];


if !(local _vehicule) exitwith {};

_longueur_Corde = 1;
_MCCMK_Info_Taru = "Arrimage";

_nacelle = getSlingLoad _vehicule;
_nom_Nacelle = gettext (configfile >> "CfgVehicles" >> typeof _nacelle >> "displayname");

_vehicule setvariable ["MCCMK_Info_Taru",[_MCCMK_Info_Taru,_longueur_Corde],true];

// Si l'helico est a moins de 3.1m du sol on réduit les cordes pour faire monter la nacelle";
if (ASLToATL getPosWorld _vehicule select 2 <= 3.1) then
{
	// Si l'helico touche le sol on diminue les cordes au minimum pour les cacher dans l'objet arrime";
	{ropeUnwind [_x, 15, _longueur_Corde];} foreach ropes _vehicule;
} else
{
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

			["Raccourcir Corde",_vehicule] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];

			sleep 1.8;

			false
		};
	};

	[] call
	{
		if (_type_Action isEqualTo "Arrimage") exitwith
		{
			_message = _nom_Nacelle + " : " + (localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Mot_Arrimage");
			[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
		};

		if (_type_Action isEqualTo "Désarrimage d'assaut") then
		{
			_message = (localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Mot_Desarrimage_Assaut_Arrimage_Nacelle");
			[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
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
if (!alive _vehicule or {isnull (getSlingLoad _vehicule)}) exitwith {};
if ((_vehicule getVariable "MCCMK_Info_Taru" select 0) isNotEqualTo _MCCMK_Info_Taru) exitwith {true};

[] call
{
	_vehicule allowdamage false;

	_mass_Helicoptere = getmass _vehicule;
	_mass_Objet_Accrocher = getmass _nacelle;

	if (typeOf _nacelle isKindOf "Cargo10_base_F") exitwith
	{
		_nacelle attachTo [_vehicule,[0,0.4,-1.6]];
		_vehicule setCustomWeightRTD 680;
		_vehicule setmass _mass_Objet_Accrocher + _mass_Helicoptere;
	};

	if (typeOf _nacelle isKindOf "Land_Pod_Heli_Transport_04_bench_F") exitwith
	{
		_nacelle attachTo [_vehicule,[0,0.1,-1.3]];
		_vehicule setCustomWeightRTD 680;
		_vehicule setmass _mass_Objet_Accrocher + _mass_Helicoptere;
	};

	if (typeOf _nacelle isKindOf "Land_Pod_Heli_Transport_04_covered_F") exitwith
	{
		_nacelle attachTo [_vehicule,[0,-1.05,-0.995]];
		_vehicule setCustomWeightRTD 1413;
		_vehicule setmass _mass_Objet_Accrocher + _mass_Helicoptere;
	};

	if (typeOf _nacelle isKindOf "Land_Pod_Heli_Transport_04_fuel_F") exitwith
	{
		_nacelle attachTo [_vehicule,[0.05,-0.35,-1.44]];
		_vehicule setCustomWeightRTD 13311;
		_vehicule setmass _mass_Objet_Accrocher + _mass_Helicoptere;
	};

	if (typeOf _nacelle isKindOf "Land_Pod_Heli_Transport_04_medevac_F") exitwith
	{
		_nacelle attachTo [_vehicule,[-0.04,-1.05,-1.087]];
		_vehicule setCustomWeightRTD 1321;
		_vehicule setmass _mass_Objet_Accrocher + _mass_Helicoptere;
	};

	if (typeOf _nacelle isKindOf "Land_Pod_Heli_Transport_04_repair_F") exitwith
	{
		_nacelle attachTo [_vehicule,[0,-1.05,-1.276]];
		_vehicule setCustomWeightRTD 1270;
		_vehicule setmass _mass_Objet_Accrocher + _mass_Helicoptere;
	};

	if (["Land_Pod_Heli_Transport_04_box_F","Land_Pod_Heli_Transport_04_ammo_F"] select {typeOf _nacelle isKindOf _x} isnotequalto []) then
	{
		_nacelle attachTo [_vehicule,[0,-1.05,-1.265]];
		_vehicule setCustomWeightRTD 1270;
		_vehicule setmass _mass_Objet_Accrocher + _mass_Helicoptere;
	};
};

_vehicule allowdamage true;

// Si plus de 4 cordes on supprime tout et on en remet des neuves en oubliant pas de les re diminuer";
if (count (ropes _vehicule) > 4) then
{
	{
		deletevehicle _x;
	} foreach ropes _vehicule;

	_vehicule setslingload _nacelle;
};

["Accrochage",_vehicule] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];

[] call
{
	if (_type_Action isEqualTo "Arrimage") exitwith
	{
		_message = _nom_Nacelle + " : " + (localize "STR_MCCMK_Taru_Pod_Mod_Arrimee");
		[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
	};

	if (_type_Action isEqualTo "Désarrimage d'assaut") then
	{
		_message = (localize "STR_MCCMK_Taru_Pod_Mod_Chat_Zeus_Mot_Desarrimage_Assaut_Nacelle_Arrimee");
		[_vehicule,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
	};
};

_vehicule setvariable ["MCCMK_Info_Taru",["Arrimé",1],true];

// Script de veille lorsque nacelle arrimée pour détacher la nacelle ou l'helico est suppr ou détruit";
[_vehicule] spawn
{
	private _vehicule = param [0,objnull];
	private _nacelle = getSlingLoad _vehicule;

	waituntil
	{

		if (!alive _vehicule OR {!alive _nacelle OR {isnull _vehicule}}) exitwith {true};
		if (isnull (getSlingLoad _vehicule)) exitwith {detach _nacelle; true};
		if !([_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer) exitwith {true};

		sleep 0.3;

		false
	};
};