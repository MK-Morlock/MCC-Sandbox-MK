private _nacelle = param [0,objnull];
private _parachute = param [1,objnull];


_parachute setVectorUp [0,0,1];

private _t0 = time;
waituntil
{
	if ((ASLToATL getposworld _nacelle select 2 <= 2.5) || {time > _t0 + 180} || {time > _t0 + 5 && {(vectorMagnitude (velocity _nacelle)) < 0.3}}) exitwith
	{
		detach _nacelle;

		_nacelle disableCollisionWith _parachute;
		_nacelle setVariable ["MCCMK_Info_Nacelle","A terre",true];

		["Fermeture parachute",_parachute] remoteExec ["MCCMK_Taru_fnc_Transmission_Sons",0];

		true
	};
	if !(alive _nacelle) exitwith
	{
		detach _nacelle;

		[_nacelle,"Nacelle endommagé","Hint"] call MCCMK_Taru_fnc_Messages;

		_nacelle setVariable ["MCCMK_Info_Nacelle","Détruite",true];

		true
	};
	if !(alive _parachute) exitwith
	{
		detach _nacelle;

		[] call
		{
			if (_nacelle getvariable ["MCCMK_Info_Nacelle",""] isEqualTo "Détacher principal") exitwith
			{
				_nacelle setVariable ["MCCMK_Info_Nacelle","Déployer secondaire",true];
			};

			if (_nacelle getvariable ["MCCMK_Info_Nacelle",""] isEqualTo "Détacher secondaire") then
			{
				_nacelle setVariable ["MCCMK_Info_Nacelle","A terre",true];
			};
		};

		true
	};

	if (isnull attachedTo _nacelle) exitwith
	{
		true
	};

	false
};

sleep 5;

deletevehicle _parachute;

[_nacelle,"","Hint"] call MCCMK_Taru_fnc_Messages;