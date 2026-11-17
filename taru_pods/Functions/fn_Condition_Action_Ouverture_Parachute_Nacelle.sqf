private _nacelle = param [0,objnull];
private _userActions_SelfActions = param [1,""];
private _type_Action = param [2,""];


_reponse = true;

_nacelle_A_Bonne_Hauteur = (aslToAtl getposworld _nacelle) select 2 > 100;
_interactions_Ace_Ou_Molette = [_userActions_SelfActions] call MCCMK_Taru_fnc_Verification_Interactions_Ace;
_peut_Deployer_Principale = _type_Action isEqualTo "Déployer principal" AND {_nacelle getvariable ["MCCMK_Info_Nacelle",""] in ["Auto","Peut déployer principal"]};
_peut_Deployer_Secondaire = _type_Action isEqualTo "Déployer secondaire" AND {_nacelle getvariable ["MCCMK_Info_Nacelle",""] isEqualTo "Peut déployer secondaire"};
_peut_Detacher = _type_Action isEqualTo "Détacher" AND {_nacelle getvariable ["MCCMK_Info_Nacelle",""] in ["Détacher principal","Détacher secondaire"]};

[] call
{
	if !(MCCMK_Taru_Pod_Mod_Action_Ouverture_Parachute_Nacelle_Disponible) exitwith {_reponse = false;};
	if !(_nacelle_A_Bonne_Hauteur) exitwith {_reponse = false;};
	if !(_interactions_Ace_Ou_Molette) exitwith {_reponse = false;};

	if (_peut_Deployer_Principale) exitwith {};
	if (_peut_Deployer_Secondaire) exitwith {};
	if (_peut_Detacher) exitwith {};

	_reponse = false;
};

_reponse