private _type_Son = param [0,""];
private _objet = param [1,objnull];
private _distance = param [2,25];
private _pitch = param [3,1];


if (_type_Son isEqualTo "Raccourcir Corde") exitwith
{
	_objet say3D ["MCCMK_Helitreuillage_Moteur_Arrimage_Exterieur", _distance, _pitch];

	if (player in crew _objet AND {isnull findDisplay 312}) then
	{
		playSound ["MCCMK_Helitreuillage_Moteur_Arrimage_Interieur",false];
	};
};

if (_type_Son isEqualTo "Allonger Corde") exitwith
{
	_objet say3D ["MCCMK_Helitreuillage_Moteur_Desarrimage_Exterieur", _distance, _pitch];

	if (player in crew _objet AND {isnull findDisplay 312}) then
	{
		playSound ["MCCMK_Helitreuillage_Moteur_Desarrimage_Interieur",false];
	};
};

if (_type_Son isEqualTo "Desarrimage") exitwith
{
	_objet say3D ["MCCMK_Helitreuillage_Desarrimage_Exterieur", _distance, _pitch];

	if (player in crew _objet AND {isnull findDisplay 312}) then
	{
		playSound ["MCCMK_Helitreuillage_Desarrimage_Interieur",false];
	};
};

if (_type_Son isEqualTo "Arrimage") exitwith
{
	_objet say3D ["MCCMK_Helitreuillage_Arrimage_Exterieur", _distance, _pitch];

	if (player in crew _objet AND {isnull findDisplay 312}) then
	{
		playSound ["MCCMK_Helitreuillage_Arrimage_Interieur",false];
	};
};

if (_type_Son isEqualTo "Décrochage") exitwith
{
	_objet say3D ["MCCMK_Helitreuillage_Decrochage", _distance, _pitch];

	if (player in crew _objet AND {isnull findDisplay 312}) then
	{
		playSound ["MCCMK_Helitreuillage_Decrochage",false];
	};
};

if (_type_Son isEqualTo "Accrochage") exitwith
{
	_objet say3D ["MCCMK_Helitreuillage_Accrochage", _distance, _pitch];

	if (player in crew _objet AND {isnull findDisplay 312}) then
	{
		playSound ["MCCMK_Helitreuillage_Accrochage",false];
	};
};

if (_type_Son isEqualTo "Ouverture parachute") exitwith
{
	_objet say3D ["MCCMK_Parachute_Ouverture", _distance, _pitch];
};

if (_type_Son isEqualTo "Fermeture parachute") then
{
	_objet say3D ["MCCMK_Parachute_Fermeture", _distance, _pitch];
};