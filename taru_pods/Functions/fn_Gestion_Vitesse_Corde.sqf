private _vitesse_Corde = param [0,0];
private _hauteur_Relative = param [1,0];
private _vitesse_Corde_Max = param [2,5];

[] call
{
	if (_hauteur_Relative < 1.50) exitwith
	{
		_vitesse_Corde = 15;
		_vitesse_Corde_Max = 15;
	};

	if (_hauteur_Relative < 7 AND {((_vehicule getVariable "MCCMK_Info_Taru" select 0) in ["Allonger","Désarrimage d'assaut"])}) exitwith
	{
		_vitesse_Corde = 2;
	};
};

_vitesse_Corde = _vitesse_Corde + 0.3 min _vitesse_Corde_Max;

_vitesse_Corde