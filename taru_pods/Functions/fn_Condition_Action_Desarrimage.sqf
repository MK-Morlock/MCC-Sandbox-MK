private _vehicule = param [0,objnull];
private _userActions_SelfActions = param [1,""];
private _type_Desarrimage = param [2,""];

private _reponse = true;

if (
	_type_Desarrimage isEqualTo "Desarrimage dassaut" AND 
	{(aslToAtl getposworld _vehicule) select 2 > 100 OR
	{(aslToAtl getposworld _vehicule) select 2 < 10 OR
	{!MCCMK_Taru_Pod_Mod_Action_Desarrimage_Assaut_Disponible OR
	{floor (abs speed _vehicule) > 15}}}}
) exitwith {_reponse = false; _reponse};

_a_Acces_Aux_Actions = [] call MCCMK_Taru_fnc_Verification_Acces_Roles;
_interactions_Ace_Ou_Molette = [_userActions_SelfActions] call MCCMK_Taru_fnc_Verification_Interactions_Ace;
_objet_Est_Arrimer = [_vehicule] call MCCMK_Taru_fnc_Verification_Objet_Est_Arrimer;

[] call
{
	if (!MCCMK_Taru_Pod_Mod_Action_Desarrimage_Disponible AND {_type_Desarrimage isEqualTo "Desarrimage"}) exitwith {_reponse = false;};
	if !(_a_Acces_Aux_Actions) exitwith {_reponse = false;};
	if !(_interactions_Ace_Ou_Molette) exitwith {_reponse = false;};
	if !(_objet_Est_Arrimer) then {_reponse = false;};
};

_reponse