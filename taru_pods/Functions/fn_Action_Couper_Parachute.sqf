private _joueur = param [0,objnull];
private _type_Action = param [1,""];

private _nacelle = vehicle _joueur;
private _parachute = attachedto _nacelle;
private _message= "";
private _action_Message = "";


[] call
{
	if (_nacelle getvariable ["MCCMK_Info_Nacelle",""] isEqualTo "Détacher principal") exitWith
	{
		_nacelle setVariable ["MCCMK_Info_Nacelle","Peut déployer secondaire",true];
		_message = name _joueur + " " + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_VehicleChat_Detacher_Principal");
		_action_Message = "Détacher principal";
	};

	if (_nacelle getvariable ["MCCMK_Info_Nacelle",""] isEqualTo "Détacher secondaire") then
	{
		_nacelle setVariable ["MCCMK_Info_Nacelle","A terre",true];
		_message = name _joueur + " " + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_VehicleChat_Detacher_Secondaire");
		_action_Message = "Détacher secondaire";
	};
};

[_nacelle,_action_Message,"Hint"] call MCCMK_Taru_fnc_Messages;
[_nacelle,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;

detach _nacelle;

sleep 5;

deletevehicle _parachute;