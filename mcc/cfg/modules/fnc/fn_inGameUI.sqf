/*==================================================================MCC_fnc_inGameUI=====================================================================================
	manage inGameUI
	[0,true,true,trur,true,false,true] call MCC_fnc_inGameUI
	<IN>
	_this select 0 		INTEGER - 3D view
							-1 Disabled
							0 force always
							1 allow 3d all vehicles
							2 allow 3d air only

	_this select 1		BOOLEAN Compass
							true - enable HUD compass
							false - disable HUD compass

	_this select 2		BOOLEAN Show teamate on compass
							true - enable HUD compass show teammates
							false - disable HUD compass show teammates

	_this select 3		BOOLEAN Show group markers on map
							true - enable Group Markers on map
							false - disable Group Markers on map

	_this select 4		BOOLEAN	Show indevidual markers on map
							true - enable Indivdual Markers on map
							false - disable Indivdual Markers on map

	_this select 5		BOOLEAN
							false - disable Name Tags
							true - enable Name Tags only when pointing on unit
							2 - enable Name Tags around the player


	_this select 6		BOOLEAN
							true - enable suppression
							false - disable suppression

	<<<<<<<<<<<         LOCAL Function     >>>>>>>>>>>>>>>>>>>>>>>>>>>

==============================================================================================================================================================*/
private _mode = 0;
private _compass = false;
private _compassTeamMates = false;
private "_module";
_mode = param [0,3,[0,objNull]];

//If it's a mod not a call
if (typeName _mode == typeName objNull) then {
	_module = _mode;

	[_module] spawn {
		params ["_module"];
		waitUntil {time > 5};

		private _mode = _module getVariable ["mode",3];
		private _compass = _module getVariable ["compass",false];
		private _compassTeamMates = _module getVariable ["compassTeamMates",false];

		//Group / unit markers: -1 = leave the players' Addon Options choice alone (default for newly placed modules),
		//0 = force off, 1 = force on. Missions saved with the older Enable/Disable (true/false) attribute still force it.
		{
			_x params ["_attr", "_var"];
			private _v = _module getVariable [_attr, -1];
			if (_v isEqualType "") then {_v = parseNumber _v};
			if (_v isEqualType true) then {_v = [0, 1] select _v};
			if (_v in [0, 1]) then {
				missionNamespace setVariable [_var, _v == 1];
				["INFO", "fn_inGameUI", "In-Game UI module forces %1 %2 (overrides the Addon Options setting)", [_attr, ["OFF","ON"] select _v]] call MCC_fnc_log;
			};
		} forEach [["groupMarkers", "MCC_groupMarkers"], ["indevidualMarkers", "MCC_indevidualMarkers"]];

		//NameTags
		missionNamespace setVariable ["MCC_nameTags",(_module getvariable ["nameTags",0])>1];
		missionNamespace setVariable ["MCC_NameTags_direct",!((_module getvariable ["nameTags",0])==2)];

		//Supression
		private _supp = _module getvariable ["suppression",false];
		if (_supp isEqualType "") then {_supp = toLower _supp in ["true", "1"]};
		if (_supp isEqualType 0) then {_supp = _supp > 0};
		missionNamespace setVariable ["MCC_suppressionOn",_supp];
		missionNamespace setVariable ["MCC_suppressionLevel",_module getvariable ["suppressionLevel",3]];

		//Hit Radar
		private _hr = _module getvariable ["hitRadar",0];
		if (_hr isEqualType "") then {_hr = parseNumber _hr};
		missionNamespace setVariable ["MCC_hitRadar",_hr];

		//Tickets
		missionNamespace setVariable ["MCC_UIModuleTickets",_module getvariable ["tickets",false]];

		//Tutorials
		if (_module getvariable ["tutorials",false]) then {
			0 spawn MCC_fnc_helpersInit;
		};

		//Compass HUD
		if (_compass) then {_compassTeamMates spawn MCC_fnc_initCompassHUD};

		//Supression
		if (missionNamespace getVariable ["MCC_suppressionOn",false]) then {[] spawn MCC_fnc_supressionInit};

		//Force first person camera
		[_mode] call MCC_fnc_forceCamera;

		//Tickets	- Move to function
		if (missionNamespace getVariable ["MCC_UIModuleTickets",true]) then {[] spawn MCC_fnc_PvPInterface};
	};

} else {
	_compass = param [1,true,[false]];
	_compassTeamMates = param [2,true,[false]];

	//Group Markers
	missionNamespace setVariable ["MCC_groupMarkers",param [3,true,[false]]];

	//Indevidual Markers
	missionNamespace setVariable ["MCC_indevidualMarkers",param [4,true,[false]]];

	//NameTags
	missionNamespace setVariable ["MCC_nameTags",param [5,true,[false]]];

	//NameTags Direct
	missionNamespace setVariable ["MCC_NameTags_direct",param [6,true,[false]]];

	//Supression
	missionNamespace setVariable ["MCC_suppressionOn",param [7,true,[false]]];

	//Suppression strength: index 0-2 from the Zeus dialog = Minimal/Average/Maximum
	if (count _this > 11) then {missionNamespace setVariable ["MCC_suppressionLevel",(param [11,2,[0]]) + 1]};

	//Hit Radar
	missionNamespace setVariable ["MCC_hitRadar",param [8,0,[0]]];

	//Tickets
	missionNamespace setVariable ["MCC_UIModuleTickets",param [9,true,[false]]];

	//Tutorials
	if (param [10,false,[false]]) then {
		0 spawn MCC_fnc_helpersInit;
	};

	//Compass HUD - unticking now really turns it off (it used to only ever switch things on)
	missionNamespace setVariable ["MCC_Settings_compassEnabled", [2, [0, 1] select _compassTeamMates] select _compass];
	if (missionNamespace getVariable ["MCC_initCompassHUD",false]) then {
		missionNamespace setVariable ["MCC_initCompassHUD",false];
		(["MCC_hud"] call BIS_fnc_rscLayer) cutText ["","Plain"];
		["MCC_fnc_compHudEVH", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	};
	if (_compass) then {
		_compassTeamMates spawn {
			sleep 0.2;	// let the old compass loop see it was switched off
			_this spawn MCC_fnc_initCompassHUD;
		};
	};

	//Supression / hit direction
	if ((missionNamespace getVariable ["MCC_suppressionOn",false]) || {(missionNamespace getVariable ["MCC_hitRadar",0]) != 2}) then {
		if !(missionNamespace getVariable ["MCC_initSupression",false]) then {[] spawn MCC_fnc_supressionInit};
	} else {
		missionNamespace setVariable ["MCC_initSupression",false];
		["MCC_initSupression", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
	};

	//Force first person camera
	[_mode] call MCC_fnc_forceCamera;

	//Tickets	- Move to function (the PvP loop stops by itself when MCC_UIModuleTickets is false)
	if (missionNamespace getVariable ["MCC_UIModuleTickets",true]) then {[] spawn MCC_fnc_PvPInterface};

	["INFO", "fn_inGameUI", "UI settings applied: 3rd person %1 | compass %2 | group markers %3 | unit markers %4 | name tags %5 (pointing %6) | suppression %7 | hit direction %8 | tickets %9",
		[_mode, [_compass, _compassTeamMates], MCC_groupMarkers, MCC_indevidualMarkers, MCC_nameTags, MCC_NameTags_direct, MCC_suppressionOn, MCC_hitRadar, MCC_UIModuleTickets]] call MCC_fnc_log;
};