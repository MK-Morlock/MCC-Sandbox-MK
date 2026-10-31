#define MCC_UM_LIST 3069
#define MCC_UM_PIC 3070
#define MCC_MINIMAP 9000

disableSerialization;

private _name = objNull;
private _worldPos = [];
private _ok = 0;
private _indices = [];
private _targetUnit = nil;
private _oldUnit = objNull;
private _group = grpNull;
private _mccdialog = displayNull;
private _comboBox = controlNull;
private _control = controlNull;

_mccdialog = (uiNamespace getVariable "MCC_groupGen_Dialog");
_comboBox = _mccdialog displayCtrl MCC_UM_LIST;
params ["_type"];
_indices = lbSelection _comboBox;

switch (_type) do {
	//Teleport
	case 0:{
		mapClick = false;
		hint "Click on the map";
		onMapSingleClick " 	hint format ['%1 teleported', UMName];
							teleportPos = _pos;
							mapClick = true;
							onMapSingleClick """";";
		waituntil {mapClick};
		if (MCC_UMUnit==0) then {
			{
				[[netID _x,_x],teleportPos] remoteExec ["MCC_fnc_moveToPos", _x, false];
			} foreach MCC_selectedUnits;
		} else {
			{
				{
					[[netID _x,_x],teleportPos] remoteExec ["MCC_fnc_moveToPos", _x, false];
					sleep 0.2;
				} foreach (units _x);
			} foreach MCC_selectedUnits;
		};
	};

		case 1:	//Teleport to LHD
		{
			_worldPos = deck modelToWorld [0,0,0];
			if (MCC_UMUnit==0) then
			{
				{[[netID _x,_x],[_worldPos select 0, _worldPos select 1, 15.9]] remoteExec ["MCC_fnc_moveToPos", 0, false];} foreach MCC_selectedUnits;
			}
			else
			{
				{{[[netID _x,_x],[_worldPos select 0, _worldPos select 1, 15.9]] remoteExec ["MCC_fnc_moveToPos", 0, false];} foreach (units _x);} foreach MCC_selectedUnits;
			};
		};

		case 2:	//Hijak unit
		{
			if (MCC_UMUnit==0) then
			{
				//then ran with no unit: "_targetUnit" undefined); no new hijack while already in a hijacked unit (it overwrote
				//the real player, so Back To Player could not get back, and each one added another MCC menu)
				if (!isNil "MCC_Prev_Player" && {!isNull MCC_Prev_Player} && {alive MCC_Prev_Player} && {player != MCC_Prev_Player}) exitWith {hint "Go back to your player first (Back To Player), then hijack another unit"};
				[] call MCC_fnc_umSelectionFromList;
				_targetUnit = MCC_selectedUnits param [0, objNull];	//Hijacked unit
				if (isNil "_targetUnit" || {!(_targetUnit isEqualType objNull)} || {isNull _targetUnit}) exitWith {hint "Select a unit to hijack first"};
				if (isplayer _targetUnit) exitwith {hint "Can't hijack other players"};
				MCC_PrevHijacked_Group = netID (group _targetUnit);
				MCC_Prev_HijackedGroupIsLeader = if (leader group _targetUnit == _targetUnit) then {true} else {false};

				MCC_Prev_Player = player;
				MCC_Prev_Group = group Player;
				MCC_Prev_GroupIsLeader = if (leader group player == player) then {true} else {false};
				MCC_Prev_Side = side player;
				_oldUnit = player;
				_group = creategroup (side _targetUnit);
				[_targetUnit] joinSilent _group;

				closeDialog 0;
				private _camera = "";
				private _ppgrain = objNull;
				_camera = "Camera" camcreate [(getpos _targetUnit) select 0, (getpos _targetUnit) select 1,((getpos _targetUnit) select 2) + 100];
				_camera cameraeffect ["internal","back"];
				_camera camPrepareFOV 0.900;
				_camera camsetTarget _targetUnit;
				_camera campreparefocus [-1,-1];
				_camera camCommitPrepared 0;
				_camera camcommit 0.01;
				cameraEffectEnableHUD true;

				_ppgrain = ppEffectCreate ["radialBlur", 100];
				_ppgrain ppEffectAdjust [0.5, 0.5, 0.3, 0.3];
				_ppgrain ppEffectCommit 0;
				_ppgrain ppEffectEnable true;

				playsound "MCC_woosh";
				for "_i" from floor(((getpos _targetUnit) select 2) + 100) to 0 step -3 do
				{
					_camera camsetpos [(getpos _targetUnit) select 0, (getpos _targetUnit) select 1,_i];
					_camera camcommit 0.01;
					sleep 0.01;
				};

				_camera cameraEffect ["TERMINATE", "BACK"];
				camdestroy _camera;
				_camera = nil;



				removeSwitchableUnit _oldUnit;
				_group selectLeader player;
				selectPlayer _targetUnit;

				deletegroup _group;

				_ppgrain ppEffectEnable false;
				MCC_hijack_effect = ppEffectCreate ["radialBlur", 100];
				MCC_hijack_effect ppEffectAdjust [0.05, 0.05, 0.5, 0.35];
				MCC_hijack_effect ppEffectCommit 0;
				MCC_hijack_effect ppEffectEnable true;

				if ((_targetUnit getVariable ["MCC_actionBackToPlayer", -1]) != -1) then {_targetUnit removeAction (_targetUnit getVariable ["MCC_actionBackToPlayer", -1])};
				MCC_backToplayerIndex = _targetUnit addaction ["<t color=""#CC0000"">Back To Player</t>", MCC_path + "mcc\general_scripts\unitManage\backToPlayer.sqf",[], 0,false, false, "","vehicle _target == vehicle _this"];
				_targetUnit setVariable ["MCC_actionBackToPlayer", MCC_backToplayerIndex];

				_string = "(vehicle _target == vehicle _this) && (getplayerUID player in (missionNamespace getvariable ['MCC_allowedPlayers',[]]) || 'all' in  (missionNamespace getvariable ['MCC_allowedPlayers',[]]) || (serverCommandAvailable '#kick' && missionNamespace getvariable ['MCC_allowAdmin',true]) || (isServer && missionNamespace getvariable ['MCC_allowAdmin',true]) || (player getvariable ['MCC_allowed',false]))";
				if ((player getVariable ["MCC_actionMCCMain", -1]) != -1) then {player removeAction (player getVariable ["MCC_actionMCCMain", -1])};
				mcc_actionInedx = player addaction ["<t color=""#99FF00"">--= MCC =--</t>",MCC_path + "mcc\dialogs\mcc_PopupMenu.sqf",[nil,nil,nil,nil,0], 0,false, false, "",_string];
				player setVariable ["MCC_actionMCCMain", mcc_actionInedx];
				player setVariable ["MCC_allowed",true,true];
				_ok = _targetUnit addEventHandler ["Killed", format ["[_this select 0] execVM '%1mcc\general_scripts\unitManage\backToPlayer.sqf'",MCC_path]];

				if (MCC_PrevHijacked_Group != "") then
				{
					[player] joinSilent (groupFromNetID MCC_PrevHijacked_Group);
					waituntil {group player == (groupFromNetID MCC_PrevHijacked_Group)};
					if (MCC_Prev_HijackedGroupIsLeader) then
					{
						if (isMultiplayer) then
						{
							["MCC_fnc_globalExecute", [2, compile format ["(groupFromNetID '%1') selectLeader objectFromNetId '%2'",netID (group Player), netID player]], 0, false] call MCC_fnc_secRemote;
						}
						else
						{
							(group player) selectLeader player;
						};
					};
				};
			}
			else
			{hint "Can only hijack units, not groups"};
		};

		case 3:	//Markers
		{
			MCC_trackMarker = !MCC_trackMarker;

			if (MCC_trackMarker) then
			{
				MCC_trackMarkerHandler = ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrladdeventhandler ["draw","_this call MCC_fnc_trackUnits;"];
				MCC_trackMarkerHandlerC = ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9010) ctrladdeventhandler ["draw","_this call MCC_fnc_trackUnits;"];
				MCC_trackMarkerHandlerMap = (findDisplay 12 displayCtrl 51) ctrladdeventhandler ["draw","_this call MCC_fnc_trackUnits; _this call MCC_fnc_mapDrawWP;"];
			}
			else
			{
				if (!isnil "MCC_trackMarkerHandler") then
				{
					((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9000) ctrlRemoveEventHandler ["draw",MCC_trackMarkerHandler];
				};
				if (!isnil "MCC_trackMarkerHandlerC") then
				{
					((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 9010) ctrlRemoveEventHandler ["draw",MCC_trackMarkerHandlerC];
				};

				if (!isnil "MCC_trackMarkerHandlerMap") then
				{
					(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ["draw",MCC_trackMarkerHandlerMap];
				};
			};
		};

		case 4:	//Indevidual Marker
		{
			//The row clicked, as the list reports it: in this multi-selection list lbCurSel can still be -1 on the first
			//click, so the video feed only started on the second click
			private _row = ((_this param [1, []]) param [1, -1]);
			if (_row < 0) then {_row = lbCurSel MCC_UM_LIST};
			if (_row>=0) then
			{
				if (MCC_UMisJoining) then //Joining
				{
					//(it used to error on an undefined UMJoin); the OLD, now empty group is deleted (it used to try to delete
					//the group joined into)
					MCC_UMisJoining = false;
					private _src = missionNamespace getVariable ["UMJoin", objNull];
					if (MCC_UMUnit==0) then
					{
						UMName = MCC_UMunitsNames param [_row, objNull];
						if (!(_src isEqualType objNull) || {isNull _src} || {isNull UMName} || {_src == UMName}) then {
							hint "Join cancelled - select the unit, press Join, then click a different unit";
						} else {
							[_src] joinSilent (group UMName);
							hint format ["%1 joined %2", name _src, groupId (group UMName)];
							["INFO", "um.sqf", "join: %1 -> %2", [name _src, groupId (group UMName)]] call MCC_fnc_log;
						};
					}
					else
					{
						UMName = UMgroupNames param [_row, grpNull];
						if (!(_src isEqualType grpNull) || {isNull _src} || {isNull UMName} || {_src == UMName}) then {
							hint "Join cancelled - select the group, press Join, then click a different group";
						} else {
							private _srcName = groupId _src;
							(units _src) joinSilent UMName;
							hint format ["%1 joined %2", _srcName, groupId UMName];
							["INFO", "um.sqf", "join: group %1 -> %2", [_srcName, groupId UMName]] call MCC_fnc_log;
							[_src] spawn {params ["_g"]; sleep 0.5; if (!isNull _g && {(count units _g) == 0}) then {_g remoteExecCall ["deleteGroup", 0]}};
						};
					};
				};

				private _name = objNull;
				if (MCC_UMUnit==0) then
				{
					_name =  MCC_UMunitsNames select _row;
				}
				else
				{
					_name = leader (UMgroupNames select _row);
				};

				//On the first click the list's unit names can still be filling (the feed stayed black until a second click):
				//wait for them up to a second, then give up
				private _tries = 0;
				while {(isNil "_name" || {isNull _name}) && {_tries < 20}} do {
					sleep 0.05;
					_tries = _tries + 1;
					_name = if (MCC_UMUnit == 0) then {MCC_UMunitsNames param [_row, objNull]} else {leader ((UMgroupNames param [_row, grpNull]))};
				};
				if (isNil "_name" || {isNull _name}) exitWith {["WARN", "um.sqf", "unit feed: no unit for row %1 (units %2, groups %3)", [_row, count (missionNamespace getVariable ["MCC_UMunitsNames", []]), count (missionNamespace getVariable ["UMgroupNames", []])]] call MCC_fnc_log};
				["INFO", "um.sqf", "unit feed: row %1 -> %2", [_row, _name]] call MCC_fnc_log;

				//Do not refresh if we haven't picked another group
				if (isnil "UMName") then {UMName = _name};

				UMName = _name;
				deletemarkerlocal "currentUnitSelected";
				["DEBUG", "um.sqf", "selection circle: %1 at %2, in %3 at %4", [UMName, (getPos UMName) apply {round _x}, typeOf (vehicle UMName), (getPos (vehicle UMName)) apply {round _x}]] call MCC_fnc_log;
				createMarkerLocal ["currentUnitSelected", getpos (vehicle UMName)];
				"currentUnitSelected" setMarkerTypelocal "Select";
				"currentUnitSelected" setMarkerColorlocal "ColorRed";
				_control = _mccdialog displayCtrl MCC_MINIMAP;
				_control ctrlMapAnimAdd [0.5, (ctrlMapScale ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl MCC_MINIMAP)), getpos UMName];
				ctrlMapAnimCommit _control;

				//Feed switched off with the On / Off button (MCC_fnc_umFeedToggle): the unit is selected, no camera
				if !(missionNamespace getVariable ["MCC_umFeedOn", true]) exitWith {["INFO", "um.sqf", "unit feed is off: %1 selected without camera", [_name]] call MCC_fnc_log};

				//Unit feed. The first click often gave no picture: the picture asked for the render target before any camera
				//was bound to it (the panel opens with that picture, and here it was set straight after the camera was made),
				//and a second run (two list events for one click) could replace the camera the follow code was moving.
				//Now: a newer click cancels an older one, the camera is made and bound first and renders while the static
				//plays, then the picture is set; the camera is bound once more a moment later (MCC_fnc_pipFollow).
				private _feedToken = (missionNamespace getVariable ["MCC_umFeedToken", 0]) + 1;
				MCC_umFeedToken = _feedToken;

				if (!isNil "MCC_PIPcam" && {!isNull MCC_PIPcam}) then {
					MCC_PIPcam cameraEffect ["TERMINATE", "BACK"];
					camDestroy MCC_PIPcam;
				};
				private _feedCam = "camera" camCreate (getPos (vehicle UMName) vectorAdd [0, -6, 3]);
				MCC_PIPcam = _feedCam;
				_feedCam camSetTarget (vehicle UMName);
				_feedCam camCommit 0;
				_feedCam cameraEffect ["INTERNAL", "BACK", "rendertarget10"];

				_control = _mccdialog displayCtrl MCC_UM_PIC;
				[_control] call MCC_fnc_pipOpen;
				if ((missionNamespace getVariable ["MCC_umFeedToken", 0]) != _feedToken) exitWith {["INFO", "um.sqf", "unit feed: %1 replaced by a newer click", [_name]] call MCC_fnc_log};
				if (isNull _feedCam) exitWith {["WARN", "um.sqf", "unit feed: camera for %1 was removed", [_name]] call MCC_fnc_log};

				//Smooth follow camera, resolution and view from the CBA settings (MCC User Interface > Video feeds)
				if !([_control, "rendertarget10", _feedCam, {missionNamespace getVariable ["UMName", objNull]}, {!isNull (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull])}] call MCC_fnc_pipFollow) then {
					//Original view
					_feedCam attachTo [vehicle (UMName),[10,15,10]];
					if(vehicle (UMName) isKindOf "Man") then {_feedCam camSetFov 0.15} else {_feedCam camSetFov 0.8};
					_feedCam camSetTarget vehicle (UMName);
					_feedCam camCommit 0;
				};
				["INFO", "um.sqf", "unit feed: camera on %1, picture set (%2)", [_name, ctrlText _control]] call MCC_fnc_log;

				if (isNil "MCC_UMPIPView") then {MCC_UMPIPView = profileNamespace getVariable ["MCC_feedVision_unit", 0]};
				private _effectParams = switch (MCC_UMPIPView) do
								{
									// Normal
									case 0:
									{
										[0]	//vanilla camera picture (was a blue-tinted colour correction)
									};

									// Night vision
									case 1:
									{
										[1]
									};

									// Thermal imaging
									case 2:
									{
										[2]
									};
								};

				sleep 0.1;
				// Set effect (the texture itself is set by MCC_fnc_pipFollow)
				["rendertarget10", MCC_UMPIPView, ""] call MCC_fnc_feedVision;
			};
		};

		case 5:	//High command: Assighn Commander
		{
		if ((lbCurSel MCC_UM_LIST)>=0) then
			{
			if (MCC_UMUnit==1) then
				{
				hint "Only units can be assigned as high commanders";
				}
				else
				{
				UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST);
				[[netID UMName,UMName],0] remoteExec ["MCC_fnc_highCommand", 0, false];
				};
			};
		};

		case 6:	//High command: Clear ALL groups
		{
		if ((lbCurSel MCC_UM_LIST)>=0) then
			{
			if (MCC_UMUnit==0) then
				{UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)}
				else {UMName = leader (UMgroupNames select (lbCurSel MCC_UM_LIST))};
			hint "cleared all High Command units";
			[[netID UMName,UMName],1] remoteExec ["MCC_fnc_highCommand", 0, false];
			};
		};

		case 7:	//High command: Add group
		{
		if ((lbCurSel MCC_UM_LIST)>=0) then
			{
			if (MCC_UMUnit==0) then
				{UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)}
				else {UMName = leader (UMgroupNames select (lbCurSel MCC_UM_LIST))};
			hint "Group Added";
			[[netID UMName,UMName],2] remoteExec ["MCC_fnc_highCommand", 0, false];
			};
		};

		case 8:	//Multi-Selection
		{
			if (MCC_UMUnit==0) then // Units selection
			{
				MCC_selectedUnits = [];
				{
					MCC_selectedUnits set [count MCC_selectedUnits, MCC_UMunitsNames select _x];
				} foreach _indices;
			}
			else
			{
				MCC_selectedUnits = [];
				{
					MCC_selectedUnits set [count MCC_selectedUnits, UMgroupNames select _x];
				} foreach _indices;
			};
		};

		case 9:	//HALO
		{
			[] call MCC_fnc_umSelectionFromList;
			if (count (MCC_selectedUnits select {!isNull _x}) == 0) exitWith {
				hint "No group or unit selected.\nSelect one or more groups or units in the list first.";
				playSound "MCC_pop";
			};
			/*
			["Click on the map to start the parachute drop"] call MCC_fnc_hintBrief;
			MCC_click = false;
			onMapSingleClick " 	hint format ['%1 paradropped', MCC_UMunitsNames];
								MCC_pos = _pos;
								MCC_click = true;
								onMapSingleClick """";";
			waituntil {MCC_click};
			if (MCC_UMUnit==0) then
			{
				{
					[MCC_pos,[netId _x,_x],true,5000,_forEachIndex] remoteExec ["MCC_fnc_paradrop", _x, false];
					sleep 0.5;
				} foreach MCC_selectedUnits;
			}
			else
			{
				{
					{
						[MCC_pos,[netId _x,_x],true,5000,_forEachIndex] remoteExec ["MCC_fnc_paradrop", _x, false];
						sleep 0.5;
					} foreach units _x;
				} foreach MCC_selectedUnits;
			};
			*/
			MCC_UMparadropIsHalo = 2; //HALO
			MCC_UMParadropRequestMarker = true;
			["Click and drag on the map to set the drop point and direction"] call MCC_fnc_hintBrief;
		};

		case 10:	//Parachute
		{
			[] call MCC_fnc_umSelectionFromList;
			if (count (MCC_selectedUnits select {!isNull _x}) == 0) exitWith {
				hint "No group or unit selected.\nSelect one or more groups or units in the list first.";
				playSound "MCC_pop";
			};
			//Small one-line window: [Drop pods] [Cancel] [Parachute]; Cancel / Esc calls nothing
			private _choice = ["Drop pods", "Cancel", "Paradrop"] call MCC_fnc_choiceBar;
			if (_choice == "") exitWith {};
			MCC_UMparadropIsHalo = [1, 0] select (_choice == "right");	//0 = parachutes, 1 = drop pods (2 = HALO) in MCC_fnc_realParadrop
			if (MCC_UMparadropIsHalo == 1) then {
				private _m = ["Paradrop", "Cancel", "Winch drop"] call MCC_fnc_choiceBar;
				if (_m == "") exitWith {MCC_UMparadropIsHalo = -1};
				missionNamespace setVariable ["MCC_podMethod", [1, 0] select (_m == "left"), true];
			};
			if (MCC_UMparadropIsHalo < 0) exitWith {};
			MCC_UMParadropRequestMarker = true;
			["Click and drag on the map to set the drop point and direction"] call MCC_fnc_hintBrief;
		};

		case 11:	//Broadcast
		{
			if (MCC_UMUnit==0) then
				{UMName =  MCC_UMunitsNames select (lbCurSel MCC_UM_LIST)}
				else {UMName = leader (UMgroupNames select (lbCurSel MCC_UM_LIST))};
			//Everyone sees the console camera as it is now, and its swing / zoom while the broadcast runs (25 s)
			private _orbit = +(missionNamespace getVariable ["MCC_pipOrbit", [0, 0, 0.75]]);
			missionNamespace setVariable ["MCC_bcOrbit", _orbit, true];
			[[netid UMName,UMName], MCC_UMPIPView, _orbit] remoteExec ["MCC_fnc_broadcast", 0, false];
			[] spawn {
				private _end = time + 25;
				private _last = +(missionNamespace getVariable ["MCC_pipOrbit", [0, 0, 0.75]]);
				while {time < _end} do {
					private _now = missionNamespace getVariable ["MCC_pipOrbit", [0, 0, 0.75]];
					if !(_now isEqualTo _last) then {_last = +_now; missionNamespace setVariable ["MCC_bcOrbit", +_now, true]};
					sleep 0.1;
				};
			};
		};

		case 12:	//Delete
		{
			//Delete key: work on the map selection (3) this once, then put the Units / Groups choice back
			private _delMode = MCC_UMUnit;
			if (_delMode == 3) then {MCC_UMUnit = missionNamespace getVariable ["MCC_UMUnitSaved", 0]};
			if (!dialog || (count MCC_selectedUnits == 0 && isnil "MCC_GroupGenGroupSelected")) exitWith {}; //For some reason when closing MCC it fire type = 12
			if (_delMode==0) then
			{
				{
					while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x; sleep 0.1};
				} foreach MCC_selectedUnits;
			}
			else
			{
				private _units = if (_delMode==3) then {MCC_GroupGenGroupSelected} else {MCC_selectedUnits};

				{
					{
						while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x; sleep 0.1};
					} foreach units _x
				} foreach _units;
			};
		};

		case 13:	//Join
		{
			//list is often -1 - it errored and the join then failed); nothing highlighted = a message, no joining
			[] call MCC_fnc_umSelectionFromList;
			UMJoin = MCC_selectedUnits param [0, objNull];
			if (isNull UMJoin) then {
				MCC_UMisJoining = false;
				hint "Select the unit or group that should join, then press Join";
			} else {
				MCC_UMisJoining = true;
				hint format ["Now click the %1 that %2 should join", ["unit", "group"] select (MCC_UMUnit != 0), if (UMJoin isEqualType grpNull) then {groupId UMJoin} else {name UMJoin}];
			};
		};

		case 14:	//Parachute
		{
			hint "Units parachuted";
			if (MCC_UMUnit==0) then
				{
					{while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x}} foreach MCC_selectedUnits;
					} else {
						{while {!(isnull _x) && !(isplayer _x)} do {deletevehicle vehicle _x};}foreach units MCC_selectedUnits;
						};
		};

		case 15:	//Kick
		{
			if (MCC_UMUnit==0) then
			{
				if (count MCC_selectedUnits > 1) then
				{
					systemchat "Select a single player unit";
				}
				else
				{
					if (isPlayer (MCC_selectedUnits select 0)) then
					{
						private _answer = nil;
						private _name = "";
						private _playerUID = "";
						_name 		= name (MCC_selectedUnits select 0);
						_playerUID	= getPlayerUID (MCC_selectedUnits select 0);
						_answer = [format ["<t size='0.8' align='center'>Are you sure you want to kick %1?</t>",_name],"Kick Player" ,nil,true,true] call MCC_fnc_messageBox;
						waituntil {!isnil "_answer"};
						if (_answer) then
						{
							 serverCommand format["#kick %1",_playerUID];
							 systemchat format["%1 has been kicked from the server",_name];
						};
					};
				};
			}
			else
			{
				systemchat "Select a single player unit";
			};
		};

		case 16:	//Ban
		{
			if (MCC_UMUnit==0) then
			{
				if (count MCC_selectedUnits > 1) then
				{
					systemchat "Select a single player unit";
				}
				else
				{
					if (isPlayer (MCC_selectedUnits select 0)) then
					{
						private _answer = nil;
						private _name = "";
						private _playerUID = "";
						_name 		= name (MCC_selectedUnits select 0);
						_playerUID	= getPlayerUID (MCC_selectedUnits select 0);
						_answer = [format ["<t size='0.8' align='center'>Are you sure you want to ban %1?</t>",_name],"Ban Player" ,nil,true,true] call MCC_fnc_messageBox;
						waituntil {!isnil "_answer"};
						if (_answer) then
						{
							 serverCommand format["#exec ban %1",_playerUID];
							 serverCommand format["#kick %1",_playerUID];
							 systemchat format["%1 has been ban from the server",_name];
						};
					};
				};
			}
			else
			{
				systemchat "Select a single player unit";
			};
		};

		default //default - no match
		{
			player globalchat format ["Access Denied: type %1", _type];
		};
	};