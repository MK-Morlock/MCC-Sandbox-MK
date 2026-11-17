private _objet_Attacher_Au_Module = param [0,objnull];
private _pos_module = param [1,[0,0,0]];

_liste_vehicule_Objets = [[],[]];


// On détermine si le module a été mis sur un objet ou pas, et si dans un rayon de 15m on trouve un hélico et un objet valide
[] call
{
	// Si objet attaché au module n'est pas null
	if !(isnull _objet_Attacher_Au_Module) exitwith
	{
		// On vérifie si il a un truc accroché, si oui on sait que c'est un hélico et qu'il a un object accroché
		if !(isnull getslingload _objet_Attacher_Au_Module) exitwith
		{
			// l'hélico
			(_liste_vehicule_Objets select 0) pushback _objet_Attacher_Au_Module;
			// Le conteneur
			(_liste_vehicule_Objets select 1) pushback getslingload _objet_Attacher_Au_Module;
		};

		// On vérifie si l'objet est accroché et a quoi,si oui on sait que c'est un objet accroché a une hélico
		if !(isnull ropeAttachedTo _objet_Attacher_Au_Module) exitwith
		{
			// l'hélico
			(_liste_vehicule_Objets select 0) pushback ropeAttachedTo _objet_Attacher_Au_Module;
			// Le conteneur
			(_liste_vehicule_Objets select 1) pushback _objet_Attacher_Au_Module;
		};

		// Sinon on faite une recherche sur 15m de tout objet repondant au critère a partir de l'objet
		(_liste_vehicule_Objets select 0) pushback (nearestObjects [_objet_Attacher_Au_Module, ["Helicopter_Base_F"], 15] select 0);
		(_liste_vehicule_Objets select 1) pushback (nearestObjects [_objet_Attacher_Au_Module, ["LandVehicle","ThingX"], 15] select 0);
	};

	// Sinon on fait une recherche a partir de la position du module
	if (isnull _objet_Attacher_Au_Module) then
	{
		if !(isnull (nearestObjects [_pos_module, ["Helicopter_Base_F"], 15] select 0)) then
		{
			(_liste_vehicule_Objets select 0) pushback (nearestObjects [_pos_module, ["Helicopter_Base_F"], 15] select 0);
		};

		if !(isnull (nearestObjects [_pos_module, ["LandVehicle","ThingX"], 15] select 0)) then
		{
			(_liste_vehicule_Objets select 1) pushback (nearestObjects [_pos_module, ["LandVehicle","ThingX"], 15] select 0);
		};
	};
};

// Si on a un élément mais qu'il manque l'autre on refait une recherche a partir de l'objet si il est accroché par cordes sinon a partir de l'objet lui meme.
[] call
{
	if (count (_liste_vehicule_Objets select 0) isEqualTo 0 AND {!(count (_liste_vehicule_Objets select 1) isEqualTo 0)}) exitwith
	{
		// On vérifie si l'objet est accroché et a quoi
		if !(isnull ropeAttachedTo ((_liste_vehicule_Objets select 1) select 0)) exitwith
		{
			(_liste_vehicule_Objets select 0) pushback ropeAttachedTo ((_liste_vehicule_Objets select 1) select 0);
		};

		(_liste_vehicule_Objets select 0) pushback (nearestObjects [(_liste_vehicule_Objets select 1) select 0, ["Helicopter_Base_F"], 15] select 0);
	};

	if (count (_liste_vehicule_Objets select 1) isEqualTo 0 AND {!(count (_liste_vehicule_Objets select 0) isEqualTo 0)}) then
	{
		// On vérifie si il a un truc accroché, si oui on sait que c'est un hélico et qu'il a un object accroché
		if !(isnull getslingload ((_liste_vehicule_Objets select 0) select 0)) exitwith
		{
			(_liste_vehicule_Objets select 1) pushback getslingload ((_liste_vehicule_Objets select 0) select 0);
		};

		(_liste_vehicule_Objets select 1) pushback (nearestObjects [(_liste_vehicule_Objets select 0) select 0, ["LandVehicle","ThingX"], 15] select 0);
	};
};

_liste_vehicule_Objets