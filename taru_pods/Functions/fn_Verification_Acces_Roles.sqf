private _reponse = false;


_a_Un_Chef_De_Soute_Joueur = [true,false] select (fullCrew [vehicle player,"gunner"] select {isplayer (_x select 0)} isEqualTo []);
_a_Un_Copilote_Joueur = count (fullCrew vehicle player select {_x select 1 in ["driver","Turret"] AND {isplayer (_x select 0)}}) > 1;

[] call
{
	if (vehicle player != player && {!isNull currentPilot vehicle player} && {!isPlayer (currentPilot vehicle player)}) exitwith
	{
		_reponse = true;
	};

	if (player isEqualTo (gunner vehicle player)) exitwith
	{
		_reponse = true;
	};

	if (player isEqualTo currentPilot vehicle player) then
	{
		if (!(_a_Un_Chef_De_Soute_Joueur) AND {!(_a_Un_Copilote_Joueur)}) then
		{
			_reponse = true;
		};
	} else
	{
		if !(_a_Un_Chef_De_Soute_Joueur) then
		{
			_reponse = true;
		};
	};
};

_reponse