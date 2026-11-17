private _longueur_Corde_Voulu = param [0,10];


_hauteur_A_Traiter = str(round _longueur_Corde_Voulu) splitString "";

if (count _hauteur_A_Traiter isEqualTo 2) then
{
	_hauteur_A_Traiter_Dizaine = _hauteur_A_Traiter select 0;
	_hauteur_A_Traiter_Unite = _hauteur_A_Traiter select 1;

	if ((parsenumber _hauteur_A_Traiter_Unite) < 5) then
	{
		_longueur_Corde_Voulu = parsenumber (_hauteur_A_Traiter_Dizaine + "0");
	} else
	{
		_longueur_Corde_Voulu = parsenumber (str((parsenumber _hauteur_A_Traiter_Dizaine) + 1) + "0");
	};
};

if (_longueur_Corde_Voulu < 10) then
{
	_longueur_Corde_Voulu = 10;
};

if (_longueur_Corde_Voulu > 100) then
{
	_longueur_Corde_Voulu = 100;
};

_longueur_Corde_Voulu