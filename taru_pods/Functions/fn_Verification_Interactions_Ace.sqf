private _userActions_SelfActions = param [0,""];

_reponse = false;
private _ace = (missionNamespace getVariable ["MCCMK_Taru_Pod_Mod_Action_Par_Ace", false]) && {!isNil "ace_interact_menu_fnc_addActionToClass"};

[] call {
	// Si l'action fait appel aux action par le menu molette de arma";
	if (_userActions_SelfActions isEqualTo "UserActions") exitwith
	{
		// Si le mod ACE est lancé et activé on utilise pas le menu molette";
		if !(_ace) then
		{
			_reponse = true;
		};
	};

	// Si l'action fait appel au menu personnel ace";
	if (_userActions_SelfActions isEqualTo "SelfActions") then
	{
		// Si le mod ACE n'est pas lancé ou pas activé";
		if (_ace) then
		{
			_reponse = true;
		};
	};
};

_reponse