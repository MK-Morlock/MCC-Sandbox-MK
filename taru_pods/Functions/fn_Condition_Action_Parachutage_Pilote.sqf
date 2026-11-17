private _vehicule = param [0,objnull];
private _userActions_SelfActions = param [1,""];

// Valide par défaut on passe a false en fonction des conditions ne permettant pas de descendre la corde";
_reponse = true;

_nacelle_A_Bonne_Hauteur = (aslToAtl getposworld _vehicule) select 2 > 100;
_a_Acces_Aux_Actions = [] call MCCMK_Taru_fnc_Verification_Acces_Roles;
_interactions_Ace_Ou_Molette = [_userActions_SelfActions] call MCCMK_Taru_fnc_Verification_Interactions_Ace;
_objet_Est_Arrimer = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer;

[] call
{
	if !(MCCMK_Taru_Pod_Mod_Action_Ouverture_Parachute_Pilote_Disponible) exitwith {_reponse = false;};
	if !(_nacelle_A_Bonne_Hauteur) exitwith {_reponse = false;};
	if !(_a_Acces_Aux_Actions) exitwith {_reponse = false;};
	if !(_interactions_Ace_Ou_Molette) exitwith {_reponse = false;};
	if !(_objet_Est_Arrimer) then {_reponse = false;};
};

_reponse