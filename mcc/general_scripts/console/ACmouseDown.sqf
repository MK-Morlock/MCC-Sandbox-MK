#define mcc_playerConsole3_IDD 5010

#define MCC_CONSOLE_AC_MISSILE_COUNT 5012
#define MCC_CONSOLE_AC_MISSILE_COUNT2 5019
#define MCC_CONSOLE_AC_MISSILE_COUNT3 5020

#define	 AMMO1 "gatling_20mm_VTOL_01"
#define	 AMMO2 "autocannon_40mm_VTOL_01"
#define	 AMMO3 "cannon_105mm_VTOL_01"

//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_pressed";
private "_posX";
private "_posY";
private "_shift";
private "_ctrlKey";
private "_alt";
private _mccdialog = controlNull;
private _control1 = controlNull;
private _control2 = controlNull;
private _control3 = controlNull;
private _ac = objNull;
private _center = objNull;
private _uav = objNull;
private _ammoLeft = [];
private "_ammoSelected";
disableSerialization;

params ["_params"];

_ctrl = _params select 0;
_pressed = _params select 1;
_posX = _params select 2;
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;

_ac = missionNamespace getVariable ["MCC_fakeAC",objNull];
_center = missionNamespace getVariable ["MCC_fakeACCenter",objNull];
_uav = missionNamespace getVariable ["MCC_ACConsoleUp",objNull];

if (isNull _ac || isNull _center || isNull _uav) exitWith {};

_mccdialog = findDisplay mcc_playerConsole3_IDD;
_control1 = _mccdialog displayCtrl MCC_CONSOLE_AC_MISSILE_COUNT;
_control2 = _mccdialog displayCtrl MCC_CONSOLE_AC_MISSILE_COUNT2;
_control3 = _mccdialog displayCtrl MCC_CONSOLE_AC_MISSILE_COUNT3;

//Control camera
if (_pressed==1) then {
	if (MCC_ConsoleACMouseButtonDown) then {
		MCC_ConsoleACMouseButtonDown = false;
	} else {
		setMousePosition [0.5,0.44];
		MCC_ConsoleACMouseButtonDown = true;
	};
};

if (typeOf _uav == "B_T_VTOL_01_armed_F") then {
	//AmmosetVehicleAmmo
	_ammoLeft = [
				 ["20mm",[_uav, "gatling_20mm_VTOL_01"] call MCC_fnc_acAmmo,"gatling_20mm_VTOL_01","B_25mm"],
				 ["40mm",([_uav] call MCC_fnc_acAmmoType) select 2,"HE","B_40mm_GPR_Tracer_Red"],
				 ["105mm",[_uav, "cannon_105mm_VTOL_01"] call MCC_fnc_acAmmo,"cannon_105mm_VTOL_01","Sh_105mm_HEAT_MP"]
				];

} else {
	_ammoLeft = _uav getVariable ["MCC_ConsoleACAmmo",[
						 ["20mm",4000,"gatling_20mm_VTOL_01","B_25mm"],
						 ["40mm",400,"HE","B_40mm_GPR_Tracer_Red"],
						 ["105mm",40,"cannon_105mm_VTOL_01","Sh_105mm_HEAT_MP"]
						]];
};

//Fire
if (_pressed==0) then {
	MCC_consoleACmousebuttonUp = false;
	["DEBUG", "console", "AC-130 console fire: %1 at %2 | gunship at %3 heading %4 | camera at %5 looking %6", [["20mm", "40mm", "105mm"] select (MCC_ConsoleACweaponSelected max 0 min 2), (getPosATL _center) apply {round _x}, (getPosATL _uav) apply {round _x}, round (getDir _uav), (getPosATL _ac) apply {round _x}, (vectorDir _ac) apply {round (_x * 100) / 100}]] call MCC_fnc_log;

	switch (MCC_ConsoleACweaponSelected) do {
		// 25mm
		case 0: {
			_ammoSelected = _ammoLeft select 0;
			if (!MCC_consoleACgunReady1 || (_ammoSelected select 1) <=0) exitwith {};
			while {!MCC_consoleACmousebuttonUp && (_ammoSelected select 1) >0} do {
				MCC_consoleACgunReady1 = false;

				//Fire
				playSound "gun1";

				if (true) then {
					if (local _uav) then {[_uav, getPosATL _center, 0, 8] call MCC_fnc_casGuideArm} else {[_uav, getPosATL _center, 0, 8] remoteExec ["MCC_fnc_casGuideArm", _uav]};
				[_uav, "gatling_20mm_VTOL_01"] call MCC_fnc_acFire;
				} else {
					playSound3D ["A3\Sounds_F_Exp\arsenal\vehicle_weapons\gatling_20mm\20mm_01_burst.wss",_uav,false,getposasl _uav,1,1,1500];
				};



				//Update ammo count
				_ammoSelected set [1,(_ammoSelected select 1)-1];
				_ammoLeft set [0,_ammoSelected];

				//Update UI
				ctrlSetText [MCC_CONSOLE_AC_MISSILE_COUNT, ("20mm: " + str (_ammoSelected select 1))];

				_control1 ctrlSetTextColor [1, 0, 0, 0.4];
				sleep 0.05;
				MCC_consoleACgunReady1 = true;
				_control1 ctrlSetTextColor [1, 1, 1, 1];
			};
		};

		// 40mm
		case 1: {
			_ammoSelected = _ammoLeft select 1;
			if (!MCC_consoleACgunReady2 || (_ammoSelected select 1) <=0) exitwith {[] call MCC_fnc_acAmmoRefresh};
			while {!MCC_consoleACmousebuttonUp && (_ammoSelected select 1) >0} do {
				MCC_consoleACgunReady2 = false;

				if (local _uav) then {[_uav, getPosATL _center, 0, 8] call MCC_fnc_casGuideArm} else {[_uav, getPosATL _center, 0, 8] remoteExec ["MCC_fnc_casGuideArm", _uav]};
				private _fired = [_uav, "autocannon_40mm_VTOL_01"] call MCC_fnc_acFire;
				if (_fired) then {
					playSound "gun2";
					playSound3D ["A3\Sounds_F\arsenal\weapons_vehicles\gatling_30mm\30mm_02_burst.wss",_uav,false,getposasl _uav,1,1,1500];
					_ammoSelected set [1,(_ammoSelected select 1)-1];
				} else {
					_ammoSelected set [1,0];
				};
				_ammoLeft set [1,_ammoSelected];

				[] call MCC_fnc_acAmmoRefresh;

				_control2 ctrlSetTextColor [1, 0, 0, 0.4];
				sleep 0.5;
				MCC_consoleACgunReady2 = true;
				_control2 ctrlSetTextColor [1, 1, 1, 1];
			};
		};

		// 105mm
		case 2: {
			_ammoSelected = _ammoLeft select 2;
			if (!MCC_consoleACgunReady3 || (_ammoSelected select 1) <=0) exitwith {};
			MCC_consoleACgunReady3 = false;

			//Fire
			playSound "gun3";

			if (true) then {
				if (local _uav) then {[_uav, getPosATL _center, 0, 8] call MCC_fnc_casGuideArm} else {[_uav, getPosATL _center, 0, 8] remoteExec ["MCC_fnc_casGuideArm", _uav]};
				[_uav, "cannon_105mm_VTOL_01"] call MCC_fnc_acFire;
			} else {
				playSound3D ["A3\Sounds_F\arsenal\weapons_vehicles\cannon_105mm\slammer_105mm_distant.wss",_uav,false,getposasl _uav,1,1,1500];
			};



			//Update ammo count
			_ammoSelected set [1,(_ammoSelected select 1)-1];
			_ammoLeft set [2,_ammoSelected];

			//Update UI
			ctrlSetText [MCC_CONSOLE_AC_MISSILE_COUNT3, ("105mm: " + str (_ammoSelected select 1))];


			_control3 ctrlSetTextColor [1, 0, 0, 0.4];
			sleep 4;
			playSound "gunReload";
			sleep 2;
			MCC_consoleACgunReady3 = true;
			_control3 ctrlSetTextColor [1, 1, 1, 1];
		};
	};
};

_uav setVariable ["MCC_ConsoleACAmmo",_ammoLeft,true];