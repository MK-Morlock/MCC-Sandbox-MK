private _vehicule = param [0,objnull];
private _userActions_SelfActions = param [1,""];
private _longueur_Corde_Condition = param [2,""];

// Valide par défaut on passe a false on fonction des conditions ne permettant pas de descendre la corde";
_reponse = true;

// Si longueur corde plus petite ou égale à 10 on annule";


_a_Acces_Aux_Actions = [] call MCCMK_Taru_fnc_Verification_Acces_Roles;
_interactions_Ace_Ou_Molette = [_userActions_SelfActions] call MCCMK_Taru_fnc_Verification_Interactions_Ace;
_objet_Est_Arrimable = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Helitreuiller_Est_Arrimable;
_objet_Est_Arrimer = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer;
_longueur_Corde_Plus_Petit_Ou_Egal_A_10 = ropeLength (ropes _vehicule select 0) <= 10;

[] call
{
	if (_longueur_Corde_Condition isEqualTo "De 10" AND {!MCCMK_Taru_Pod_Mod_Action_Raccourcir_De_10m_Disponible}) exitwith {_reponse = false;};
	if (_longueur_Corde_Condition isEqualTo "A 10" AND {!MCCMK_Taru_Pod_Mod_Action_Raccourcir_A_10m_Disponible}) exitwith {_reponse = false;};
	if !(_a_Acces_Aux_Actions) exitwith {_reponse = false;};
	if !(_interactions_Ace_Ou_Molette) exitwith {_reponse = false;};
	if !(_objet_Est_Arrimable) exitwith {_reponse = false;};
	if (_objet_Est_Arrimer) exitwith {_reponse = false;};
	if (_longueur_Corde_Plus_Petit_Ou_Egal_A_10) then {_reponse = false;};
};

_reponse