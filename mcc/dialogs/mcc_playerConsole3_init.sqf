["start"] spawn {sleep 0.1; ["start"] call MCC_fnc_consoleCampaignTiles};	//no campaign territory overlay on the Commander Console map (once its display exists)
private _mccdialog = controlNull;
private "_time";
private _message = "";
private _messageFinal = [];
private _control = controlNull;
private _data = [];
private _rad = 0;
private _alt = 0;
private _coords = [];
private _effectParams = [];
private "_leftDownPos";
private "_uav";
private _ammoLeft = [];
// By: Shay_gman
// Version: 1.1 (April 2013)
#define mcc_playerConsole3_IDD 5010

#define MCC_CONSOLE_AC_BCKG 5011
#define MCC_CONSOLE_AC_MISSILE_COUNT 5012
#define MCC_CONSOLE_AC_MISSILE_COUNT2 5019
#define MCC_CONSOLE_AC_MISSILE_COUNT3 5020
#define MCC_CONSOLE_AC_VISION_TEXT 5013
#define MCC_CONSOLE_AC_TIME_TEXT 5014
#define MCC_CONSOLE_AC_ZOOM_TEXT 5015
#define MCC_CONSOLE_AC_TARGET 5016
#define MCC_CONSOLE_AC_WEAPON 5017
#define MCC_CONSOLE_ACPIP 5018
#define MCC_CONSOLE_AC_DIR_TEXT 5021
#define MCC_CONSOLE_COMPASS_N 9116
#define MCC_CONSOLE_COMPASS_E 9117
#define MCC_CONSOLE_COMPASS_S 9118
#define MCC_CONSOLE_COMPASS_W 9119
#define MCC_MINIMAP 9120
#define MCC_CONSOLE_AC_MAP 5022

#define MCC_CONSOLEUAVFLIGHTHIGHT 9121

disableSerialization;
_mccdialog = findDisplay mcc_playerConsole3_IDD;
_mccdialog displayAddEventHandler ["Unload", {if !(missionNamespace getVariable ["MCC_consoleTakingControl", false]) then {[] spawn {sleep 0.5; if (!dialog && {alive player}) then {[nil, nil, nil, [0]] execVM format ["%1mcc\general_scripts\console\conoleOpenMenu.sqf", MCC_path]}}}}];
MCC_Console1Open = false;
MCC_Console2Open = false;
MCC_Console3Open = true;
MCC_Console4Open = false;
//-------------------------------------------------AC-130--------------------------------------------------------------------------------
ctrlShow [MCC_CONSOLE_AC_TARGET,false];
ctrlShow [MCC_CONSOLE_COMPASS_N,false];
ctrlShow [MCC_CONSOLE_COMPASS_E,false];
ctrlShow [MCC_CONSOLE_COMPASS_S,false];
ctrlShow [MCC_CONSOLE_COMPASS_W,false];
ctrlShow [MCC_MINIMAP,false];

ctrlShow [MCC_CONSOLE_AC_MAP,false];
ctrlShow [5055,false];

ctrlSetText [MCC_CONSOLE_ACPIP, ""];
_time = time + (2 + random 5);

_uav = (missionNamespace getVariable ["MCC_ACConsoleUp",objNull]);

while {_time > time && dialog && (isNil "MCC_fakeAC")} do {
	_message = "";
	_messageFinal = ["C","o","n","n","e","c","t","i","n","g"," ","A","C","-","1","3","0",".",".","."];
	for "_i" from 0 to (count _messageFinal - 1) do {
		_message = _message + (_messageFinal select _i);
		ctrlSetText [MCC_CONSOLE_AC_BCKG, _message];
		sleep 0.05;
	};
};

if (dialog && (isNull(missionNamespace getVariable ["MCC_ACConsoleUp",objNull]) || isNull _uav)) then {
	ctrlSetText [MCC_CONSOLE_AC_BCKG, "Error connecting to AC-130, connection failed"];
};

//Create the AC
if (dialog && !isNull(missionNamespace getVariable ["MCC_ACConsoleUp",objNull])) then {
		//Get rid of the connecting text
		ctrlSetText [MCC_CONSOLE_AC_BCKG, ""];
		_control = _mccdialog displayCtrl MCC_CONSOLE_ACPIP;
		[_control] call MCC_fnc_pipOpen;
		ctrlSetText [MCC_CONSOLE_ACPIP, "#(argb,512,512,1)r2t(rendertarget8,1.0);"];

		// Create fake AC
		if (isNil "MCC_fakeAC") then {
			MCC_fakeAC 		= "Camera" camCreate [10,10,10];
			if (!isnil "MCC_fakeACCenter") then {deletevehicle MCC_fakeACCenter};
			_leftDownPos = _uav modelToWorld [-400,2,-5];
			_leftDownPos set [2,0];
			MCC_fakeACCenter	= "Sign_Sphere10cm_F" createvehicle _leftDownPos;
			MCC_fakeACCenter hideObjectGlobal true;
			_rad	=	400;
			_alt	=	300;
			MCC_ACAng	= 	0;
			MCC_fakeAC cameraEffect ["INTERNAL", "BACK", "rendertarget8"];
			_coords = [MCC_consoleACpos, _rad, MCC_ACAng] call BIS_fnc_relPos;
			_coords set [2, _alt];
			MCC_fakeACFOV = 25 / 120;
			MCC_fakeAC camsetTarget MCC_fakeACCenter;
			MCC_fakeAC camsetPos _coords;
			MCC_fakeAC camsetFOV MCC_fakeACFOV;
			MCC_fakeAC camCommit 0;

			_uav dowatch MCC_fakeACCenter;
			//MCC_fakeAC attachTo [_uav,[-6,2,-5]];
			//MCC_fakeACCenter attachTo [_uav,[-400,2,-5]];
		};

		ctrlSetText [MCC_CONSOLE_AC_ZOOM_TEXT, "WFOV"];
		ctrlSetText [MCC_CONSOLE_AC_VISION_TEXT, MCC_ConsoleACvision];

		if (typeOf _uav == "B_T_VTOL_01_armed_F") then {
			//AmmosetVehicleAmmo
			_ammoLeft = [
						 ["20mm",_uav ammo "gatling_20mm_VTOL_01","gatling_20mm_VTOL_01","B_25mm"],
						 ["40mm",((crew _uav) select 3) ammo "HE","HE","B_40mm_GPR_Tracer_Red"],
						 ["105mm",_uav ammo "cannon_105mm_VTOL_01","cannon_105mm_VTOL_01","Sh_105mm_HEAT_MP"]
						];

		} else {
			_ammoLeft = _uav getVariable ["MCC_ConsoleACAmmo",[
								 ["20mm",4000,"gatling_20mm_VTOL_01","B_25mm"],
								 ["40mm",400,"HE","B_40mm_GPR_Tracer_Red"],
								 ["105mm",40,"cannon_105mm_VTOL_01","Sh_105mm_HEAT_MP"]
								]];
		};

		ctrlSetText [MCC_CONSOLE_AC_MISSILE_COUNT, ("20mm: " + str ((_ammoLeft select 0) select 1))];
		ctrlSetText [MCC_CONSOLE_AC_MISSILE_COUNT2, ("40mm: " + str ((_ammoLeft select 1) select 1))];
		[] call MCC_fnc_acAmmoRefresh;
		ctrlSetText [MCC_CONSOLE_AC_MISSILE_COUNT3, ("105mm: " + str ((_ammoLeft select 2) select 1))];

		//Flight Height
		sliderSetRange [MCC_CONSOLEUAVFLIGHTHIGHT, 300, 1500];
		_alt = (((getpos _uav) select 2) min 1500) max 300;
		sliderSetPosition [MCC_CONSOLEUAVFLIGHTHIGHT, _alt];

		MCC_ConsoleACCameraMod = profileNamespace getVariable ["MCC_feedVision_ac", 0];	//the mode last chosen for this feed
		switch (MCC_ConsoleACCameraMod) do {
			// Normal
			case 0: {
				_effectParams = [0];	//normal view: the same picture as an Arma UAV camera in its normal mode
				MCC_ConsoleACvision = "VIDEO";
			};

			// Night vision
			case 1: {
				_effectParams = [1];
				MCC_ConsoleACvision = "N/V";
			};

			// Thermal imaging
			case 2: {
				_effectParams = [2];
				MCC_ConsoleACvision = "WHOT";
			};
		};
		"rendertarget8" setPiPEffect _effectParams;
		[_mccdialog, 9175, MCC_ConsoleACCameraMod] call MCC_fnc_consoleModeButtons;	//the vision buttons show the mode in use
		[_mccdialog, 9180, missionNamespace getVariable ["MCC_ConsoleACweaponSelected", 0]] call MCC_fnc_consoleModeButtons;

		switch (MCC_ConsoleACweaponSelected) do {
			// 20mm
			case 0: {
				
			};

			// 40mm
			case 1: {
				
			};

			// 105mm
			case 2: {
				
			};
		};

		ctrlshow [MCC_CONSOLE_AC_TARGET,true];
		ctrlShow [MCC_CONSOLE_COMPASS_N,false];
		ctrlShow [MCC_CONSOLE_COMPASS_E,false];
		ctrlShow [MCC_CONSOLE_COMPASS_S,false];
		ctrlShow [MCC_CONSOLE_COMPASS_W,false];
		ctrlShow [MCC_CONSOLE_AC_MAP,true];
		ctrlShow [5055,true];
		(["center"] call MCC_fnc_acAim) params ["_az0", "_el0"];
		MCC_acGround = ["ground", _az0, _el0] call MCC_fnc_acAim;
		MCC_consoleACgunReady1 = true;
		MCC_consoleACgunReady2 = true;
		MCC_consoleACgunReady3 = true;
		MCC_ConsoleACMouseButtonDown = false;
		[_mccdialog, 0] call MCC_fnc_acReticle;
		ctrlSetText [MCC_CONSOLE_AC_TARGET, ""];

		//Handle on screen data
		[] spawn {
			private "_structured";
			private _data = [];
			private _mccdialog = controlNull;
			private "_uavPos";
			private _uav = objNull;
			disableSerialization;
			_uav = missionNamespace getVariable ["MCC_ACConsoleUp",objNull];


			while {MCC_Console3Open && dialog && alive _uav} do {
				_mccdialog = findDisplay mcc_playerConsole3_IDD;
				_structured = composeText [""];
				_uavPos = getpos MCC_fakeAC;
				_data =
					[
						format ["Time: %1:%2",[date select 3]call MCC_fnc_time2string,[date select 4]call MCC_fnc_time2string],
						format ["Remain: %1",[MCC_ConsoleACTime -(time - (missionNameSpace getVariable ["MCC_ConsoleACTimeStart",0]))] call MCC_fnc_time],
						format ["X: %1 Y: %2",floor (_uavPos select 0),floor (_uavPos select 1)],
						format ["Z %1",floor (_uavPos select 2)]
					];
				_structured = parseText ((_data apply {format ["<t align='right'>%1</t>", _x]}) joinString "<br/>");
				(_mccdialog displayctrl MCC_CONSOLE_AC_TIME_TEXT) ctrlSetStructuredText _structured;
				ctrlSetText [MCC_CONSOLE_AC_DIR_TEXT, format ["Dir: %1",floor (getdir MCC_fakeAC)]];

				//Compass
				for [{_i = 0;_j = 0},{_i < 360;_j < 4},{_i = _i + 90;_j = _j + 1}] do
				{
					_x = (0.476 + sin(_i - (getdir MCC_fakeAC))*(SafeZoneW/8 - SafeZoneW/200));
					_y = (0.42 - cos(_i - (getdir MCC_fakeAC))*(SafeZoneH/8 - SafeZoneH/200));

					(_mccdialog displayCtrl 9116+_j) ctrlSetPosition [_x,_y];
					(_mccdialog displayCtrl 9116+_j) ctrlCommit 0;

				};

				//Set starting time
				if ((missionNameSpace getVariable ["MCC_ConsoleACTimeStart",-1]) <=0) then {
					missionNameSpace setVariable ["MCC_ConsoleACTimeStart",time];
					publicVariable "MCC_ConsoleACTimeStart";
				};

				//No time remain close the AC-130
				if (MCC_ConsoleACTime -(time - (missionNameSpace getVariable ["MCC_ConsoleACTimeStart",time])) <=0) exitWith {

					missionNamespace setVariable ["MCC_ACConsoleUp",objNull];
					publicVariable "MCC_ACConsoleUp";
					if !(_uav getVariable ["MCC_supportDone", false]) then {
						_uav setVariable ["MCC_supportDone", true, true];
						[group driver _uav, driver _uav, _uav, [_uav, 1500, floor random 360] call BIS_fnc_relPos] spawn MCC_fnc_deletePlane;
					};

					[_uav, "leave", "Gunship", "Left the scene", format ["%1data\AC130_icon.paa", MCC_path], playerSide] call MCC_fnc_supportNotice;
					MCC_ConsoleACMouseButtonDown = false;
					while {dialog} do {closeDialog 0};
					_null = [1] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf",MCC_path];
				};

				if (isNull(missionNamespace getVariable ["MCC_ACConsoleUp",objNull]) || {!alive (missionNamespace getVariable ["MCC_ACConsoleUp",objNull])}) exitWith {
					MCC_ConsoleACMouseButtonDown = false;
					while {dialog} do {closeDialog 0};
					MCC_ConsoleACMouseButtonDown = false;
					[(_mccdialog displayctrl MCC_CONSOLE_ACPIP)] call MCC_fnc_pipOpen;
					_null = [1] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf",MCC_path];

					if (alive _uav) then {[_uav, "leave", "Gunship", "Left the scene", format ["%1data\AC130_icon.paa", MCC_path], playerSide] call MCC_fnc_supportNotice};
				};

				sleep 0.1;
			};
			if (dialog && {!alive _uav}) then {
				MCC_ConsoleACMouseButtonDown = false;
				while {dialog} do {closeDialog 0};
				_null = [1] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf",MCC_path];
			};

			_cam = missionNamespace getVariable ["MCC_fakeAC",objNull];
			_target = missionNamespace getVariable ["MCC_fakeACCenter",objNull];

			if !(isNull _cam) then {
				_cam cameraeffect ["terminate","back"];
				camdestroy _cam;
				MCC_fakeAC = nil;
			};

			if !(isNull _target) then {
				deleteVehicle _target;
			};
		};

		// Move camera in a circle
		0 spawn	{
			private "_alt";
			private "_rad";
			private "_coords";
			private _uav = objNull;
			private _cam = objNull;
			private _target = objNull;

			_uav = missionNamespace getVariable ["MCC_ACConsoleUp",objNull];
			_cam = missionNamespace getVariable ["MCC_fakeAC",objNull];
			_target = missionNamespace getVariable ["MCC_fakeACCenter",objNull];

			{
				private _g = _uav turretUnit _x;
				if (!isNull _g) then {_g disableAI "AUTOTARGET"; _g disableAI "TARGET"; _g doWatch _target};
			} forEach [[1], [2]];
			if ((missionNamespace getVariable ["MCC_acCamEH", -1]) >= 0) then {removeMissionEventHandler ["EachFrame", MCC_acCamEH]};
			MCC_acCamEH = addMissionEventHandler ["EachFrame", {
				private _uav = missionNamespace getVariable ["MCC_ACConsoleUp", objNull];
				private _cam = missionNamespace getVariable ["MCC_fakeAC", objNull];
				private _target = missionNamespace getVariable ["MCC_fakeACCenter", objNull];
				if (isNull _cam || {!alive _uav} || {isNull _target} || {isNull (findDisplay 5010)}) exitWith {removeMissionEventHandler ["EachFrame", _thisEventHandler]; MCC_acCamEH = -1};
				private _eye = ["eye"] call MCC_fnc_acAim;
				private _g = missionNamespace getVariable ["MCC_acGround", []];
				if (count _g < 3) then {(["center"] call MCC_fnc_acAim) params ["_a0", "_e0"]; _g = ["ground", _a0, _e0] call MCC_fnc_acAim; MCC_acGround = _g};
				(["angles", _g] call MCC_fnc_acAim) params ["_az", "_el"];
				(["clamp", _az, _el] call MCC_fnc_acAim) params ["_caz", "_cel"];
				if (abs (_caz - _az) > 0.05 || {abs (_cel - _el) > 0.05}) then {_g = ["ground", _caz, _cel] call MCC_fnc_acAim; MCC_acGround = _g};
				_cam camSetPos _eye;
				_cam camSetTarget _g;
				_cam camCommit 0;
				private _ground = _g;
				_target setPosATL _ground;
				if (time > (missionNamespace getVariable ["MCC_acWatchT", 0])) then {
					MCC_acWatchT = time + 0.3;
					{private _g = _uav turretUnit _x; if (!isNull _g) then {_g doWatch _ground}} forEach [[1], [2]];
				};
			}];
		};
	};