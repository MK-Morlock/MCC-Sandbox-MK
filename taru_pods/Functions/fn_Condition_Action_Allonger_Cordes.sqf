private _vehicule = param [0,objnull];
private _userActions_SelfActions = param [1,""];
private _longueur_Corde_Condition = param [2,0];

_reponse = true;

// Si longueur corde égale à 100 on annule";
_longueur_Corde = ropeLength (ropes _vehicule select 0);
if (_longueur_Corde isEqualTo 100 or {_longueur_Corde < 10}) exitwith {_reponse = false; _reponse};

_a_Acces_Aux_Actions = [] call MCCMK_Taru_fnc_Verification_Acces_Roles;
_interactions_Ace_Ou_Molette = [_userActions_SelfActions] call MCCMK_Taru_fnc_Verification_Interactions_Ace;
_objet_Est_Arrimable = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Helitreuiller_Est_Arrimable;
_objet_Est_Arrimer = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer;

[] call
{
	if (_longueur_Corde_Condition isEqualTo 10 AND {!MCCMK_Taru_Pod_Mod_Action_Allonger_De_10m_Disponible}) exitwith {_reponse = false;};
	if (_longueur_Corde_Condition isEqualTo 100 AND {!MCCMK_Taru_Pod_Mod_Action_Allonger_A_100m_Disponible}) exitwith {_reponse = false;};
	if !(_a_Acces_Aux_Actions) exitwith {_reponse = false;};
	if !(_interactions_Ace_Ou_Molette) exitwith {_reponse = false;};
	if !(_objet_Est_Arrimable) exitwith {_reponse = false;};
	if (_objet_Est_Arrimer) then {_reponse = false;};
};

_reponse