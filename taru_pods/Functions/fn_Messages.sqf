private _nacelle = param [0,objnull];
private _action_Message = param [1,""];
private _type_Message = param [2,""];
private _message = param [3,""];


if (_action_Message isNotEqualTo "") then
{
	if (_action_Message isEqualTo "Déploiement auto") exitwith
	{
		_ligne_1 = (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_1_Deploiement_Auto");
		_ligne_2 = "\n\n" + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_2_Deploiement_Auto");
		_ligne_3 = "\n\n" + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_3_Deploiement_Auto");
		_ligne_4 = "\n\n" + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_4_Deploiement_Auto");
		_message = _ligne_1 + _ligne_2 + _ligne_3 + _ligne_4;
	};

	if (_action_Message isEqualTo "Ouverture auto") exitwith
	{
		_message = (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_Ouverture_Auto");
	};

	if (_action_Message isEqualTo "Nacelle endommagé") exitwith
	{
		_message = (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_Nacelle_Endommager");
	};

	if (_action_Message isEqualTo "Déployer principal") exitwith
	{
		_ligne_1 = (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_1_Deployer_Principal");
		_ligne_2 = "\n\n " + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_2_Deployer_Principal");

		_message = _ligne_1 + _ligne_2;
	};

	if (_action_Message isEqualTo "Détacher principal") exitwith
	{
		_ligne_1 = (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_1_Detacher_Principal");
		_ligne_2 = "\n\n " + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_2_Detacher_Principal");

		_message = _ligne_1 + _ligne_2;
	};

	if (_action_Message isEqualTo "Déployer secondaire") exitwith
	{
		_ligne_1 = (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_1_Deployer_Secondaire");
		_ligne_2 = "\n\n " + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_2_Deployer_Secondaire");

		_message = _ligne_1 + _ligne_2;
	};

	if (_action_Message isEqualTo "Détacher secondaire") then
	{
		_message = (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_Message_Détacher_Secondaire");
	};
};

if (_type_Message isNotEqualTo "") then
{
	if (_type_Message in ["Hint","Tous"]) then
	{
		[_message] remoteexec ["hint",crew _nacelle];
	};

	if (_type_Message in ["vehicleChat","Tous"]) then
	{
		[_nacelle,_message] remoteexec ["vehicleChat",crew _nacelle select {isplayer _x}];
	};
};

true