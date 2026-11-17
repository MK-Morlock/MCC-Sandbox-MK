private _joueur = param [0,objnull];
private _type_Action = param [1,""];
private _ouverture_Auto = param [2,false];

private _nacelle = vehicle _joueur;
private _message = "";
private _action_Message = "";


_nacelle setVariable ["MCCMK_Info_Nacelle","Action en cours",true];

_parachute = createVehicle ["B_parachute_02_F",[0,0,0], [], 0, "CAN_COLLIDE"];
_parachute allowdamage false;
_nacelle disableCollisionWith _parachute;
_parachute disableCollisionWith _nacelle;
_parachute attachTo [_nacelle,[-0.1,0.05,0.95]];

if !(_ouverture_Auto) then
{
	if (_type_Action isEqualTo "Déployer principal") then
	{
		_message = name _joueur + " " + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_VehicleChat_Systemchat_Deployer_Principal");
		_action_Message = "Déployer principal";
	} else
	{
		_message = name _joueur + " " + (localize "STR_MCCMK_Taru_Pod_Mod_Nacelle_VehicleChat_Systemchat_Deployer_Secondaire");
		_action_Message = "Déployer secondaire";
	};

	[_nacelle,_action_Message,"Hint"]  call MCCMK_Taru_fnc_Messages;
	[_nacelle,"","vehicleChat",_message] call MCCMK_Taru_fnc_Messages;
};

["Ouverture parachute",_parachute] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];

sleep 4;

detach _parachute;

_parachute allowdamage true;

_velocite_Nacelle = velocity _nacelle;

_nacelle attachTo [_parachute,[0,0,-1]];

[] call
{
	if (_type_Action isEqualTo "Déployer principal") exitwith
	{
		_nacelle setVariable ["MCCMK_Info_Nacelle","Détacher principal",true];
	};

	if (_type_Action isEqualTo "Déployer secondaire") then
	{
		_nacelle setVariable ["MCCMK_Info_Nacelle","Détacher secondaire",true];
	};
};

_parachute setvelocity _velocite_Nacelle;

[_nacelle,_parachute] spawn MCCMK_Taru_fnc_Veille_Descente_Nacelle;