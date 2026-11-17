private _nacelle = param [0,objnull];


if !(local _nacelle) exitwith {};

[_nacelle,"Déploiement auto","Hint"] call MCCMK_Taru_fnc_Messages;

_nacelle setVariable ["MCCMK_Info_Nacelle","Peut déployer principal",true];

waituntil
{
	_pos_nacelle = (ASLToATL getposworld _nacelle select 2) - (150 - (velocity _nacelle select 2) * 4);

	if (_pos_nacelle <= 0) exitwith
	{
		[_nacelle,"Déployer principal",true] remoteExec ["MCCMK_Taru_fnc_Action_Creation_Parachute",_nacelle];

		[_nacelle,"Ouverture auto","Tous"] call MCCMK_Taru_fnc_Messages;

		_nacelle setVariable ["MCCMK_Info_Nacelle","Auto",true];

		true
	};

	if !(alive _nacelle) exitwith
	{
		[_nacelle,"Nacelle endommagé","Tous"] call MCCMK_Taru_fnc_Messages;

		true
	};

	if ((_nacelle getvariable ["MCCMK_Info_Nacelle",""]) isNotEqualTo "Peut déployer principal") exitwith
	{
		[_nacelle,"Déployer principal","Hint"] call MCCMK_Taru_fnc_Messages;

		true
	};

	false
};