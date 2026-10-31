["start"] spawn {sleep 0.1; ["start"] call MCC_fnc_consoleCampaignTiles};	//no campaign territory overlay on the Commander Console map (once its display exists)
private _mccdialog = controlNull;
private _control = controlNull;
private _effectParams = [];
private "_time";
private _message = "";
private _messageFinal = [];
// By: Shay_gman
// Version: 1.1 (April 2013)
#define mcc_playerConsole2_IDD 5000

#define MCC_CONSOLE_UAVPIP 9106
#define MCC_CONSOLE_UAVMISSILELEFTTEXT 9107
#define MCC_CONSOLE_UAVPIP_BCKG 9108
#define MCC_CONSOLE_UAV_MISSILE_COUNT 9110
#define MCC_CONSOLE_VISION_TEXT 9111
#define MCC_CONSOLE_TIME_TEXT 9112
#define MCC_CONSOLE_ZOOM_TEXT 9113
#define MCC_CONSOLE_UAV_TARGET 9114
#define MCC_CONSOLE_DIR_TEXT 9115
#define MCC_CONSOLE_COMPASS_N 9116
#define MCC_CONSOLE_COMPASS_E 9117
#define MCC_CONSOLE_COMPASS_S 9118
#define MCC_CONSOLE_COMPASS_W 9119
#define MCC_MINIMAP 9120
#define MCC_CONSOLE_AC_MAP 5022

#define MCC_CONSOLEUAVFLIGHTHIGHT 9121
#define MCC_CONSOLEUAVFLIGHTHIGHTTEXT 9122
#define MCC_CONSOLEUAVTAKECONTROL 9123

disableSerialization;
_mccdialog = findDisplay mcc_playerConsole2_IDD;
if !(missionNamespace getVariable ["MCC_consoleCruise", false]) then {
	_mccdialog displayAddEventHandler ["Unload", {if !(missionNamespace getVariable ["MCC_consoleTakingControl", false]) then {[] spawn {sleep 0.5; if (!dialog && {alive player}) then {[nil, nil, nil, [0]] execVM format ["%1mcc\general_scripts\console\conoleOpenMenu.sqf", MCC_path]}}}}];
};

MCC_Console1Open = false;
MCC_Console2Open = true;
MCC_Console3Open = false;
MCC_Console4Open = false;

//-------------------------------------------------UAV--------------------------------------------------------------------------------
ctrlShow [MCC_CONSOLE_UAV_TARGET,false];
ctrlShow [MCC_CONSOLE_COMPASS_N,false];
ctrlShow [MCC_CONSOLE_COMPASS_E,false];
ctrlShow [MCC_CONSOLE_COMPASS_S,false];
ctrlShow [MCC_CONSOLE_COMPASS_W,false];
ctrlShow [MCC_MINIMAP,false];
ctrlShow [MCC_CONSOLEUAVFLIGHTHIGHT,false];
ctrlShow [MCC_CONSOLEUAVFLIGHTHIGHTTEXT,false];
ctrlShow [MCC_CONSOLEUAVTAKECONTROL,false];
ctrlShow [MCC_CONSOLE_AC_MAP,false];
ctrlShow [9188,false];
ctrlShow [9189,false];

ctrlSetText [MCC_CONSOLE_UAVPIP, ""];
_time = time + (1);
while {_time > time && (str (finddisplay mcc_playerConsole2_IDD) != "no display")} do {
	_message = "";
	_messageFinal = ["C","o","n","n","e","c","t","i","n","g"," ","D","R","O","N","E",".",".",".","."];
	for "_i" from 0 to (count _messageFinal - 1) do {
		_message = _message + (_messageFinal select _i);
		ctrlSetText [MCC_CONSOLE_UAVPIP_BCKG, _message];
		sleep 0.05;
	};
};

if ((str (finddisplay mcc_playerConsole2_IDD) == "no display") || (isNull (missionNamespace getVariable ["MCC_ConolseUAV",objNull]))) exitWith {
	if (missionNamespace getVariable ["MCC_Console2Open",false]) then {
		ctrlSetText [MCC_CONSOLE_UAVPIP_BCKG, "No UAV signal found, connection failed"];
	};
};

//Create the UAV
if ((str (finddisplay mcc_playerConsole2_IDD) != "no display") && (alive MCC_ConolseUAV) && MCC_Console2Open) then {
	//Get rid of the connecting text
	ctrlSetText [MCC_CONSOLE_UAVPIP_BCKG, ""];
	_control = _mccdialog displayCtrl MCC_CONSOLE_UAVPIP;
	[_control] call MCC_fnc_pipOpen;
	// Create fake UAV
	if (isNil "MCC_fakeUAV" || {isNull MCC_fakeUAV}) then {
		MCC_fakeUAV 		= "Camera" camCreate [10,10,10];
		if (!isnil "MCC_fakeUAVCenter") then {deletevehicle MCC_fakeUAVCenter};
		MCC_fakeUAVCenter	= "Sign_Sphere10cm_F" createvehicle [((getpos MCC_ConolseUAV) select 0),(getpos MCC_ConolseUAV) select 1, 0];
		["hideGlobal", [MCC_fakeUAVCenter]] remoteExec ["MCC_fnc_secAction", 2, false];
		MCC_fakeUAV cameraEffect ["INTERNAL", "BACK", "rendertarget9"];
		MCC_fakeUAVFOV = 0.6;
		MCC_fakeUAV camsetTarget MCC_fakeUAVCenter;
		MCC_fakeUAV camsetFOV MCC_fakeUAVFOV;
		MCC_fakeUAV camCommit 0;
};
	if (!isNil "MCC_fakeUAVCenter" && {!isNull MCC_fakeUAVCenter}) then {MCC_fakeUAVCenter setPos [(getPos MCC_ConolseUAV) select 0, (getPos MCC_ConolseUAV) select 1, 0]};
	//Link the picture to the camera now that it exists (linked before it existed, the first feed showed no effects)
	ctrlSetText [MCC_CONSOLE_UAVPIP, format ["#(argb,%1,%1,1)r2t(rendertarget9,1.0);", missionNamespace getVariable ["MCC_pipResolution", 1024]]];	//resolution: CBA Video feed resolution (was 512)
	//First view of a session stayed black: bind the camera to the picture again a few times (only the binding: changing
	//the picture each time made it flicker). Also covers a camera made before the picture was set.
	[] spawn {
		{
			sleep _x;
			if (!isNil "MCC_fakeUAV" && {!isNull MCC_fakeUAV}) then {MCC_fakeUAV cameraEffect ["INTERNAL", "BACK", "rendertarget9"]};
		} forEach [0.1, 0.3, 0.8];
	};

	ctrlSetText [MCC_CONSOLE_ZOOM_TEXT, format ["ZOOM X %1",(10-(10*MCC_fakeUAVFOV))]];

	//Cruise missile view: right mouse button + drag swings the camera round the missile, wheel moves it closer / further
	if (missionNamespace getVariable ["MCC_consoleCruise", false]) then {
		MCC_cruiseOrbit = [0, 0, 1];
		MCC_cruiseDrag = false;
		private _d = findDisplay mcc_playerConsole2_IDD;
		_d displayAddEventHandler ["MouseButtonDown", {params ["_dd", "_b", "_mx", "_my"]; if (_b == 1) then {MCC_cruiseDrag = true}; if (_b == 0 && {((allControls _dd) findIf {ctrlShown _x && {(ctrlType _x) in [1, 16, 100, 101]} && {(ctrlPosition _x) params ["_px", "_py", "_pw", "_ph"]; _mx >= _px && {_mx <= _px + _pw} && {_my >= _py} && {_my <= _py + _ph}}}) < 0}) then {[] spawn {while {dialog} do {closeDialog 0; sleep 0.01}}}}];
		_d displayAddEventHandler ["Unload", {if (missionNamespace getVariable ["MCC_cruiseFromCommander", false]) then {[] spawn {sleep 0.5; if (!dialog) then {[nil, nil, nil, [0]] execVM format ["%1mcc\general_scripts\console\conoleOpenMenu.sqf", MCC_path]}}}}];
		_d displayAddEventHandler ["MouseButtonUp", {params ["", "_b"]; if (_b == 1) then {MCC_cruiseDrag = false}}];
		_d displayAddEventHandler ["MouseMoving", {
			params ["", "_dx", "_dy"];
			if (missionNamespace getVariable ["MCC_cruiseDrag", false]) then {
				MCC_cruiseOrbit set [0, ((MCC_cruiseOrbit select 0) + _dx * 4) mod 360];
				MCC_cruiseOrbit set [1, (((MCC_cruiseOrbit select 1) - _dy * 3) max -70) min 60];
			};
		}];
		_d displayAddEventHandler ["MouseZChanged", {
			params ["", "_z"];
			MCC_cruiseOrbit set [2, (((MCC_cruiseOrbit select 2) * (1 - _z * 0.1)) max 0.35) min 3];	//closest about 8 m behind / beside it
		}];
	};
	ctrlSetText [MCC_CONSOLE_VISION_TEXT, MCC_ConsoleUAVvision];

	//Check Ammo
	MCC_ConsoleUAVmissiles = ["",0,""];
	MCC_ConsoleUAVmissiles = [MCC_ConolseUAV] call MCC_fnc_uavPickWeapon;
	if ((MCC_ConsoleUAVmissiles select 0) != "") then {ctrlSetText [MCC_CONSOLE_UAV_MISSILE_COUNT, format ["%1 #: %2",MCC_ConsoleUAVmissiles select 0,MCC_ConsoleUAVmissiles select 1]]};

	MCC_ConsoleUAVCameraMod = profileNamespace getVariable ["MCC_feedVision_uav", 0];	//the mode last chosen for this feed
	switch (MCC_ConsoleUAVCameraMod) do
	{
		// Normal
		case 0: {
			_effectParams = [0];	//normal view: the same picture as an Arma UAV camera in its normal mode
			MCC_ConsoleUAVvision = "VIDEO";
		};

		// Night vision
		case 1: {
			_effectParams = [1];
			MCC_ConsoleUAVvision = "N/V";
		};

		// Thermal imaging
		case 2: {
			_effectParams = [2];
			MCC_ConsoleUAVvision = "WHOT";
		};
	};
	"rendertarget9" setPiPEffect _effectParams;
	[_mccdialog, 9170, MCC_ConsoleUAVCameraMod] call MCC_fnc_consoleModeButtons;	//the vision buttons show the mode in use
	ctrlShow [MCC_CONSOLE_UAV_TARGET, !(missionNamespace getVariable ["MCC_consoleCruise", false])];	//no cross on the cruise missile feed
	ctrlShow [MCC_CONSOLE_COMPASS_N,false];
	ctrlShow [MCC_CONSOLE_COMPASS_E,false];
	ctrlShow [MCC_CONSOLE_COMPASS_S,false];
	ctrlShow [MCC_CONSOLE_COMPASS_W,false];
	ctrlShow [MCC_CONSOLE_AC_MAP,true];
	ctrlShow [MCC_CONSOLEUAVTAKECONTROL,true];
	private _cruise = missionNamespace getVariable ["MCC_consoleCruise", false];
	ctrlShow [9188, !_cruise];
	ctrlShow [9189, !_cruise && {count (allTurrets [MCC_ConolseUAV, false]) > 0}];

	//Show flight hight slider
	if (MCC_ConolseUAV iskindof "AIR") then {
		private "_alt";
		ctrlShow [MCC_CONSOLEUAVFLIGHTHIGHT,true];
		ctrlShow [MCC_CONSOLEUAVFLIGHTHIGHTTEXT,true];

		if (MCC_ConolseUAV iskindof "Plane") then
			{
				sliderSetRange [MCC_CONSOLEUAVFLIGHTHIGHT, 300, 1500];
				_alt = if (((getpos MCC_ConolseUAV) select 2) > 1500) then {1500} else {(getpos MCC_ConolseUAV) select 2};
			};
		if (MCC_ConolseUAV iskindof "Helicopter") then
			{
				sliderSetRange [MCC_CONSOLEUAVFLIGHTHIGHT, 1, 500];
				_alt = if (((getpos MCC_ConolseUAV) select 2) > 500) then {500} else {(getpos MCC_ConolseUAV) select 2};
			};
		sliderSetPosition [MCC_CONSOLEUAVFLIGHTHIGHT, _alt];
		//(_mccdialog displayCtrl MCC_CONSOLEUAVFLIGHTHIGHT) ctrlSetTooltip format ["%1 Meters",sliderPosition MCC_CONSOLEUAVFLIGHTHIGHT];
	};

	//Handle on screen data
	[] spawn {
		private "_structured";
		private _data = [];
		private _mccdialog = controlNull;
		private _relPos = 0;
		disableSerialization;

		while {MCC_Console2Open && (str (finddisplay mcc_playerConsole2_IDD) != "no display") && alive MCC_ConolseUAV} do {
			if (missionNamespace getVariable ["MCC_consoleCruise", false]) then {
				//Cruise missile: the camera is moved every frame by an EachFrame handler (smooth); this loop only keeps
				//the handler running
				if ((missionNamespace getVariable ["MCC_cruiseCamEH", -1]) < 0) then {
					MCC_cruiseCamEH = addMissionEventHandler ["EachFrame", {
						private _m = missionNamespace getVariable ["MCC_ConolseUAV", objNull];
						private _c = missionNamespace getVariable ["MCC_fakeUAV", objNull];
						if (isNull _m || {isNull _c} || {!alive _m} || {!(missionNamespace getVariable ["MCC_consoleCruise", false])}) exitWith {
							removeMissionEventHandler ["EachFrame", _thisEventHandler];
							MCC_cruiseCamEH = -1;
						};
						//Chase camera behind and beside the missile, swung round it with the right mouse button and moved
						//closer / further with the wheel (MCC_cruiseOrbit = [yaw, pitch, distance factor]); it always looks at
						//the missile (a little ahead of it), so zooming in never goes past it
						private _mp = getPosASLVisual _m;
						private _fd = vectorDirVisual _m;
						(missionNamespace getVariable ["MCC_cruiseOrbit", [0, 0, 1]]) params [["_oy", 0], ["_op", 0], ["_oz", 1]];
						private _hd = (_fd select 0) atan2 (_fd select 1);
						private _az = _hd + 180 - 29 + _oy;	//(29 deg to the side, as the camera was: 18 m back, 10 m aside)
						private _el = ((19 + _op) max -60) min 80;	//(19 deg up: 7 m up)
						private _dist = 21.8 * _oz;
						private _cp = _mp vectorAdd [(sin _az) * (cos _el) * _dist, (cos _az) * (cos _el) * _dist, (sin _el) * _dist];
						_cp set [2, (_cp select 2) max ((getTerrainHeightASL _cp) + 1)];
						_c camSetPos (ASLToAGL _cp);
						_c camSetTarget (ASLToAGL (_mp vectorAdd (_fd vectorMultiply 15)));
						_c camSetFov 0.7;
						_c camCommit 0;
						MCC_cruiseLastPos = _mp;
					}];
				};
			};
			if (missionNamespace getVariable ["MCC_consoleCruise", false]) then {
			} else {
				if ((missionNamespace getVariable ["MCC_uavCamEH", -1]) < 0) then {
					MCC_uavCamEH = addMissionEventHandler ["EachFrame", {
						private _u = missionNamespace getVariable ["MCC_ConolseUAV", objNull];
						private _c = missionNamespace getVariable ["MCC_fakeUAV", objNull];
						private _t = missionNamespace getVariable ["MCC_fakeUAVCenter", objNull];
						if (isNull _u || {isNull _c} || {!alive _u} || {isNull (findDisplay 5000)} || {missionNamespace getVariable ["MCC_consoleCruise", false]}) exitWith {removeMissionEventHandler ["EachFrame", _thisEventHandler]; MCC_uavCamEH = -1};
						private _p = ASLToAGL (getPosASLVisual _u);
						_c camSetPos [_p select 0, _p select 1, (_p select 2) + ([3, -0.2] select (_u isKindOf "AIR"))];
						_c camSetTarget _t;
						_c camCommit 0;
					}];
				};
			};
			_mccdialog = findDisplay mcc_playerConsole2_IDD;
			_structured = composeText [""];
			_data =
				[
				format ["Time:  %1:%2",[date select 3]call MCC_fnc_time2string,[date select 4]call MCC_fnc_time2string],
				format ["Elapsed:  %1",[time]call MCC_fnc_time],
				format ["X: %1  Y: %2",floor ((getpos MCC_fakeUAV) select 0),floor ((getpos MCC_fakeUAV) select 1)],
				format ["Altitude: %1",floor ((getpos MCC_ConolseUAV) select 2)],
				format ["Dir:      %1",floor getdir MCC_ConolseUAV],
				format ["Speed:    %1",floor speed MCC_ConolseUAV]
				];
			if !(missionNamespace getVariable ["MCC_consoleCruise", false]) then {_data pushBack (format ["Fuel:     %1",floor ((fuel MCC_ConolseUAV)*100)])};
			{_structured = composeText [_structured,_x,lineBreak]} forEach _data;
			(_mccdialog displayctrl MCC_CONSOLE_TIME_TEXT) ctrlSetStructuredText _structured;
			ctrlSetText [MCC_CONSOLE_DIR_TEXT, format ["Dir:%1",floor (getdir MCC_fakeUAV)]];

			//Compass
			for [{_i = 0;_j = 0},{_i < 360;_j < 4},{_i = _i + 90;_j = _j + 1}] do
			{
				_x = (0.476 + sin(_i - (getdir MCC_fakeUAV))*(SafeZoneW/8 - SafeZoneW/200));
				_y = (0.42 - cos(_i - (getdir MCC_fakeUAV))*(SafeZoneH/8 - SafeZoneH/200));

				(_mccdialog displayCtrl 9116+_j) ctrlSetPosition [_x,_y];
				(_mccdialog displayCtrl 9116+_j) ctrlCommit 0;

			};
			sleep 0.01;
		};

		//Cruise missile: stay on the explosion for 2 s (the camera stops where it was, looking at the impact point)
		private _cruiseEnd = missionNamespace getVariable ["MCC_consoleCruise", false];
		if (_cruiseEnd && {!isNil "MCC_fakeUAV"} && {!isNil "MCC_cruiseLastPos"} && {!isNull (findDisplay mcc_playerConsole2_IDD)}) then {
			MCC_fakeUAV camSetTarget (ASLToAGL MCC_cruiseLastPos);
			MCC_fakeUAV camCommit 0.5;
			sleep 5;
		};

		//Cleanup
		if (!isnil "MCC_fakeUAV") then {
			MCC_fakeUAV cameraEffect ["TERMINATE", "BACK"];
			camdestroy MCC_fakeUAV;
			MCC_fakeUAV = nil;
			_mccdialog = findDisplay mcc_playerConsole2_IDD;
			if (_cruiseEnd) then {
				//Cruise missile feed: after the impact the console it was launched from comes back (the commander console's main page, or the MCC console).
				if (missionNamespace getVariable ["MCC_cruiseFromCommander", false]) then {
					MCC_cruiseFromCommander = false;
					if (!isNull _mccdialog) then {_null = [1] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf",MCC_path]};
				} else {
					if (!isNull _mccdialog) then {closeDialog 0};
					if (missionNamespace getVariable ["MCC_cruiseFromMCC", false]) then {
						MCC_cruiseFromMCC = false;
						[] spawn {waitUntil {!dialog}; [nil,nil,nil,nil,0] execVM format ["%1mcc\dialogs\mcc_PopupMenu.sqf",MCC_path]};
					};
				};
			} else {
				if (!isNull _mccdialog) then {[(_mccdialog displayctrl MCC_CONSOLE_UAVPIP)] call MCC_fnc_pipOpen};
				_null = [1] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf",MCC_path];
			};
		};
	};

};

