private _vehicule = param [0,objnull];
private _type_Action = param [1,""];
private _longueur_Corde = param [2,0];
private _vitesse_Corde_Max = param [3,5];
private _vitesse_Corde = param [4,0];


if !(local _vehicule) exitwith {};

_nacelle = getSlingLoad _vehicule;

waituntil
{
	_hauteur_Nacelle = getPosWorld _nacelle select 2;
	_hauteur_Surface = lineIntersectsSurfaces [getPosWorld _nacelle,getPosWorld _nacelle vectorAdd [0,0,-1000],_vehicule,_nacelle] select 0 select 0 select 2;

	// On soustrait la hauteur de la nacelle par posworld a la hauteur de la premiere surface par un lineintersectsurface pour avoir la hauteur par rapport a l'objet dessous";
	_hauteur_Relative = _hauteur_Nacelle - _hauteur_Surface;

	if (ropeLength (ropes _vehicule select 0) <= 5) then
	{
		_vehicule disableCollisionWith _nacelle;
	};

	_vitesse_Corde = [_vitesse_Corde,_hauteur_Relative,_vitesse_Corde_Max] call MCCMK_Taru_fnc_Gestion_Vitesse_Corde;

	{ropeUnwind [_x, _vitesse_Corde, _longueur_Corde];} foreach ropes _vehicule;

	_longueur_Corde_actuel = [ropeLength (ropes _vehicule select 0)] call MCCMK_Taru_fnc_Traitement_Longueur_Cordes;

	if (_longueur_Corde_actuel isNotEqualTo ((_vehicule getVariable "MCCMK_Info_Taru") select 1)) then
	{
		_vehicule setvariable ["MCCMK_Info_Taru",[_type_Action,_longueur_Corde_actuel],true];
	};

	// Sortie si vehicle mort ou plus de chargement hélitreuillé";
	if !(alive _vehicule) exitwith
	{
		[_vehicule,"","vehicleChat","Objet hélitreuillé détruit"] call MCCMK_Taru_fnc_Messages;

		true
	};

	// Sortie si vehicle mort ou plus de chargement hélitreuillé";
	if (isnull (getSlingLoad _vehicule)) exitwith
	{
		[_vehicule,"","vehicleChat","Objet hélitreuillé décroché"] call MCCMK_Taru_fnc_Messages;

		true
	};

	// Sortie si MCCMK_Info_Taru différente de _type_Action";
	if ((_vehicule getVariable "MCCMK_Info_Taru" select 0) isNotEqualTo _type_Action) exitwith {true};

	// Sortie si on est en arrimage et que la nacelle est a < 2.5m de l'hélico";
	if (_vehicule getVariable "MCCMK_Info_Taru" isEqualTo "Arrimage" AND {_vehicule distance _nacelle < 2.5}) exitwith {true};

	// Sortie si on est en Désarrimage et que la corde est a 10m de longueur";
	if (ropeLength (ropes _vehicule select 0) isEqualTo _longueur_Corde) exitwith {true};

	// ";
	if (_type_Action isEqualTo "Désarrimage d'assaut" AND {isTouchingGround _nacelle AND {_hauteur_Relative < 10}}) exitwith
	{
		{ropeUnwind [_x, 0, ropeLength (ropes _vehicule select 0)];} foreach ropes _vehicule;

		true
	};

	sleep 0.3;

	false
};

_vehicule enableCollisionWith (getSlingLoad _vehicule);