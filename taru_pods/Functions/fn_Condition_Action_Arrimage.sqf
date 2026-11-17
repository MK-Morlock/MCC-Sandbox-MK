private _vehicule = param [0,objnull];
private _userActions_SelfActions = param [1,""];

private _reponse = true;
private _MCCMK_Taru_Action = _vehicule getVariable ["MCCMK_Info_Taru",""];

// Si le code d'action n'est pas nul c'est qu'une action est en cours donc on sort du script pour ne pas refaire l'action";
if (_MCCMK_Taru_Action isEqualTo "Arrimage") exitwith {};

private _a_Acces_Aux_Actions = [] call MCCMK_Taru_fnc_Verification_Acces_Roles;
private _interactions_Ace_Ou_Molette = [_userActions_SelfActions] call MCCMK_Taru_fnc_Verification_Interactions_Ace;
private _objet_Est_Arrimable = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Helitreuiller_Est_Arrimable;
private _objet_Est_Arrimer = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer;

[] call
{
	if !(MCCMK_Taru_Pod_Mod_Action_Arrimage_Disponible) exitwith {_reponse = false;};
	if !(_a_Acces_Aux_Actions) exitwith {_reponse = false;};
	if !(_interactions_Ace_Ou_Molette) exitwith {_reponse = false;};
	if !(_objet_Est_Arrimable) exitwith {_reponse = false;};
	if (_objet_Est_Arrimer) then {_reponse = false;};
};

_reponse