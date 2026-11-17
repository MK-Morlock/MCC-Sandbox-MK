private _vehicule = param [0,objnull];

private _objet_Est_Arrimer = false;
private _liste_Classe_Accepter = ["Pod_Heli_Transport_04_crewed_base_F","Pod_Heli_Transport_04_base_F","Cargo_base_F","Slingload_01_Base_F"];
private _objet_accrocher = attachedto (getSlingLoad _vehicule);


// Si objet accroché n'est pas attaché au véhicule on quitte";
if (isnull _objet_accrocher) exitwith {_objet_Est_Arrimer};

private _objet_Attacher = (attachedobjects _vehicule select {!isnull _x}) select 0;

if (((_liste_Classe_Accepter select {_objet_Attacher iskindof _x}) isNotEqualTo []) AND {!alive _objet_Attacher}) exitwith {_objet_Est_Arrimer};

// On vérifie parmis les objets attaché si un fait partie de la bonne classe, si oui on valide";
{
	_classe_Parente = _x;

	if (attachedObjects _vehicule select {_x iskindof _classe_Parente} isNotEqualTo []) exitwith
	{
		_objet_Est_Arrimer = true;

		if (isnull getSlingLoad _vehicule) then {};
	};
} foreach _liste_Classe_Accepter;

_objet_Est_Arrimer