/*
	MCCMK_fnc_mapIntel - (every player, postInit) Map Intel - Arma's own group
	icons, map markers and a tooltip panel (CBA "Map Intel", MCCMK User Interface >
	Map). Only one map is on the screen at a time, so what Arma shows is set by which one is open:
	  Main map           - group icons, "?" markers and gunfire; a checkbox bottom right (icons and gunfire).
	  Commander Console  - the same (not on the groups the console shows itself); a checkbox bottom right of its map.
	  MCC console        - gunfire only: Map Intel's icons are taken off and its "?" markers hidden while it's open (it
	                       shows every group itself); a checkbox bottom right of its map (gunfire).
	Each checkbox is unticked until the player ticks it (remembered in his profile). The "?" markers, as in the original,
	are not switched by the checkbox.
	"Map Intel: Arma's map content": Show all (default) / Difficulty's own / Hide units (the original script's).
	On the consoles (checkbox ticked), a group's own console icon flashes pale yellow as its men fire, as Map Intel's own do.
	Also: Shift + right-click on the main map, on a group icon or next to a unit's own map icon, opens the 3D View on it.
*/
if (!hasInterface) exitWith {};
[] spawn {
	waitUntil {sleep 1; !isNull player};

	// Parameters
	MCCMK_miMinGroupSize = 2;
	MCCMK_miLastKnownTime = 180;
	MCCMK_miBulletSpeed = 7.5;
	MCCMK_miBulletSize = [1, 4];
	MCCMK_miBulletColor = "ColorWhite";
	MCCMK_miBulletLifetime = 1;
	MCCMK_miRevealed = [];
	MCCMK_miShow = false;		// Map Intel's group icons on the groups (the open map wants them)
	MCCMK_miLostMarkers = [];

	// which open map wants gunfire / icons (by its checkbox)
	MCCMK_miCCOpen = {!isNull (findDisplay 2993)};
	MCCMK_miMCCOpen = {!isNull (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull])};
	MCCMK_miWantFire = {
		(missionNamespace getVariable ["MCCMK_mapIntel", true]) && {
			(visibleMap && {profileNamespace getVariable ["MCCMK_mi_main", false]})
			|| {(call MCCMK_miCCOpen) && {profileNamespace getVariable ["MCCMK_mi_cc", false]}}
			|| {(call MCCMK_miMCCOpen) && {profileNamespace getVariable ["MCCMK_mi_mcc", false]}}
		}
	};
	MCCMK_miWantIcons = {
		(missionNamespace getVariable ["MCCMK_mapIntel", true]) && {!(call MCCMK_miMCCOpen)} && {
			(visibleMap && {profileNamespace getVariable ["MCCMK_mi_main", false]})
			|| {(call MCCMK_miCCOpen) && {profileNamespace getVariable ["MCCMK_mi_cc", false]}}
		}
	};
	// a group the Commander Console is showing itself right now (it's open, and its icon is really on the group) - left to it
	// while it's open (the consoles leave their marker variable on a group when they close, so the variable alone kept your
	// side's AI groups out of Map Intel for the rest of the mission, on the main map too)
	MCCMK_miConsoleGroup = {
		params ["_g"];
		if !(call MCCMK_miCCOpen) exitWith {false};
		private _id = _g getVariable "MCCgroupIconData";
		// (MK) or shown by the console through Arma's own symbol (a commander's groups - MCCMK_iconMartaHas): its colour and name are on it
		(!isNil "_id" && {((_g getGroupIcon _id) param [0, ""]) != ""}) || {(_g getVariable ["MCCMK_iconMarta", false]) && {!isNil {_g getVariable "MCCMK_iconWant"}}}
	};

	// the tooltip panel (RKAG_fnc_createMapTooltip, as it is) - on the main map, and the Commander Console when it's open
	MCCMK_miPanel = {
		params ["_display"];
		private _pn = _display getVariable ["MCCMK_miPanel", []];
		if (_pn isNotEqualTo [] && {!isNull (_pn select 0)}) exitWith {_pn};
		private _grp = _display ctrlCreate ["RscControlsGroup", 2300];
		_grp ctrlSetPosition [0, 0, 0.4625, 0.34];
		_grp ctrlCommit 0;
		private _ih = _display ctrlCreate ["RscStructuredText", 1100, _grp];
		_ih ctrlSetPosition [0.0125, 0.02, 0.4375, 0.04];
		_ih ctrlSetStructuredText parseText ("<t font='PuristaSemibold' valign='middle' size='1' shadow='0' align='center'>Infantry Intel</t>");
		_ih ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.75];
		_ih ctrlCommit 0;
		private _ib = _display ctrlCreate ["RscStructuredText", 1101, _grp];
		_ib ctrlSetPosition [0.0125, 0.06, 0.4375, 0.1];
		_ib ctrlSetBackgroundColor [0.05, 0.05, 0.05, 0.75];
		_ib ctrlCommit 0;
		private _vh = _display ctrlCreate ["RscStructuredText", 1102, _grp];
		_vh ctrlSetPosition [0.0125, 0.18, 0.4375, 0.04];
		_vh ctrlSetStructuredText parseText ("<t font='PuristaSemibold' valign='middle' size='1' shadow='0' align='center'>Vehicle Intel</t>");
		_vh ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.75];
		_vh ctrlCommit 0;
		private _vb = _display ctrlCreate ["RscStructuredText", 1103, _grp];
		_vb ctrlSetPosition [0.0125, 0.22, 0.4375, 0.1];
		_vb ctrlSetBackgroundColor [0.05, 0.05, 0.05, 0.75];
		_vb ctrlCommit 0;
		_pn = [_grp, _ih, _ib, _vh, _vb];
		_display setVariable ["MCCMK_miPanel", _pn];
		{_x ctrlShow false} forEach _pn;
		_pn
	};
	MCCMK_miPanelDisplay = {if (visibleMap) then {findDisplay 12} else {findDisplay 2993}};
	// RKAG_fnc_hideMapTooltip
	MCCMK_miHideTooltip = {
		{{_x ctrlShow false} forEach (_x getVariable ["MCCMK_miPanel", []])} forEach [findDisplay 12, findDisplay 2993];
	};
	// RKAG_fnc_showMapTooltip, as it is
	MCCMK_miShowTooltip = {
		params ["_group", "_vehicleCount", "_footCount"];
		private _d = call MCCMK_miPanelDisplay;
		if (isNull _d) exitWith {};
		([_d] call MCCMK_miPanel) params ["_tg", "_ih", "_ib", "_vh", "_vb"];
		private _sideColor = ([side _group, false] call BIS_fnc_sideColor);
		_sideColor set [3, 0.75];
		_ih ctrlSetBackgroundColor (_sideColor);
		_vh ctrlSetBackgroundColor (_sideColor);
		_tg ctrlShow true;
		private _footText = "";
		private _vehicleText = "";
		private _vehs = [];
		{
			private _unit = _x;
			if (!alive _unit) then {continue};
			if (_footCount > 0 && (vehicle _unit isEqualTo _unit)) then {
				private _iconName = getText (configFile >> "CfgVehicles" >> typeOf _unit >> "icon");
				private _iconPath = getText (configFile >> "CfgVehicleIcons" >> _iconName);
				_footText = (_footText + "<img image='" + _iconPath + "' shadow='0' size='1.2' valign='middle'></img>");
			};
			if (_vehicleCount > 0 && !(vehicle _unit isEqualTo _unit) && !(vehicle _unit in _vehs)) then {
				_vehs pushBack vehicle _unit;
				_vehicleText = (_vehicleText + "<img image='" + (getText (configFile >> 'CfgVehicles' >> typeOf vehicle _unit >> 'picture')) + "' shadow='0' size='1.33' valign='middle'></img>");
			};
		} forEach units _group;
		if !(_footText isEqualTo "") then {
			_ih ctrlShow true;
			_ib ctrlShow true;
			_ib ctrlSetStructuredText parseText ("<t size='0.1'>&#160;</t><br/>" + _footText);
			_ib ctrlCommit 0;
		} else {
			_ih ctrlShow false;
			_ib ctrlShow false;
		};
		if !(_vehicleText isEqualTo "") then {
			_vh ctrlShow true;
			_vb ctrlShow true;
			_vb ctrlSetStructuredText parseText ("<t size='0.5'>&#160;</t><br/>" + _vehicleText);
			_vb ctrlCommit 0;
			if (_footText isEqualTo "") then {
				_vh ctrlSetPosition [0.0125, 0.02, 0.4375, 0.04];
				_vb ctrlSetPosition [0.0125, 0.06, 0.4375, 0.1];
				_vh ctrlCommit 0.05;
				_vb ctrlCommit 0.05;
			} else {
				_vh ctrlSetPosition [0.0125, 0.18, 0.4375, 0.04];
				_vb ctrlSetPosition [0.0125, 0.22, 0.4375, 0.1];
				_vh ctrlCommit 0.05;
				_vb ctrlCommit 0.05;
			};
		} else {
			_vh ctrlShow false;
			_vb ctrlShow false;
		};
	};
	// the panel follows the mouse (as the original's EachFrame) - only while the main map or the Commander Console is open
	addMissionEventHandler ["EachFrame", {
		if (!visibleMap && {isNull (findDisplay 2993)}) exitWith {};
		private _d = call MCCMK_miPanelDisplay;
		private _pn = _d getVariable ["MCCMK_miPanel", []];
		if (_pn isEqualTo []) exitWith {};
		(_pn select 0) ctrlSetPosition [(getMousePosition select 0), (getMousePosition select 1) + 0.05, 0.4625, 0.34];
		(_pn select 0) ctrlCommit 0;
	}];

	// RKAG_fnc_getGroupNATOMarkerType, as it is
	MCCMK_miType = {
		params ["_group"];
		private _prefix = switch (side _group) do {case west: {"b_"}; case east: {"o_"}; case independent: {"n_"}; default {""}};
		private _vehlist = [];
		private _infantry = 0; private _cars = 0; private _apcs = 0; private _tanks = 0; private _aa = 0; private _helis = 0;
		private _planes = 0; private _uavs = 0; private _boats = 0; private _artys = 0; private _mortars = 0;
		private _support_reammo = 0; private _support_repair = 0; private _support_refuel = 0; private _support_medic = 0;
		{
			if (!canStand vehicle _x && alive vehicle _x && !(vehicle _x in _vehlist)) then {
				private _veh = vehicle _x;
				_vehlist = _vehlist + [_veh];
				if (_veh isKindOf "car") then {_cars = _cars + 1};
				if (_veh isKindOf "tank") then {_tanks = _tanks + 1};
				if (getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "artilleryScanner") > 0) then {_artys = _artys + 1};
				if (_veh isKindOf "Wheeled_APC_F" || _veh isKindOf "APC_Tracked_01_base_F" || _veh isKindOf "APC_Tracked_02_base_F" || _veh isKindOf "APC_Tracked_03_base_F") then {_apcs = _apcs + 1};
				if (getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "radarType") > 0) then {_aa = _aa + 1};
				if (_veh isKindOf "helicopter") then {_helis = _helis + 1};
				if (_veh isKindOf "plane") then {_planes = _planes + 1};
				if (_veh in allUnitsUAV) then {_uavs = _uavs + 1};
				if (_veh isKindOf "staticcanon") then {_artys = _artys + 1};
				if (_veh isKindOf "staticmortar") then {_mortars = _mortars + 1};
				if (_veh isKindOf "ship") then {_boats = _boats + 1};
				if (getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "attendant") > 0) then {_support_medic = _support_medic + 1};
				if (getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "transportAmmo") > 0) then {_support_reammo = _support_reammo + 1};
				if (getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "transportFuel") > 0) then {_support_refuel = _support_refuel + 1};
				if (getNumber (configFile >> "cfgvehicles" >> typeOf _veh >> "transportRepair") > 0) then {_support_repair = _support_repair + 1};
			};
			if ((vehicle _x isEqualTo _x)) then {_infantry = (_infantry + 1)};
		} forEach units _group;
		private _type = "unknown";
		if (_infantry >= 1) then {_type = "inf"};
		if (_cars >= 1) then {_type = "motor_inf"};
		if (_tanks >= 1) then {_type = "armor"};
		if (_apcs >= 1) then {_type = "mech_inf"};
		if (_aa >= 1) then {_type = "antiair"};
		if (_artys >= 1) then {_type = "art"};
		if (_mortars >= 1) then {_type = "mortar"};
		if ((_support_reammo + _support_refuel) >= 1) then {_type = "support"};
		if (_support_repair >= 1) then {_type = "maint"};
		if (_support_medic >= 1) then {_type = "med"};
		if ((_support_medic + _support_reammo + _support_refuel + _support_repair) > 1) then {_type = "support"};
		if (_boats >= 1) then {_type = "naval"};
		if (_helis >= 1) then {_type = "air"};
		if (_planes >= 1) then {_type = "plane"};
		if (_uavs >= 1) then {_type = "uav"};
		(_prefix + _type)
	};

	// Map Intel's own icon on a group: on and off as the open map wants (the original's addGroupIcon / clearGroupIcons, but
	// only Map Intel's own icon - the consoles' icons on other groups are theirs)
	MCCMK_miIconOn = {
		params ["_group"];
		if ((_group getVariable ["MCCMK_miIcon", -1]) >= 0) exitWith {};
		private _id = _group addGroupIcon [[_group] call MCCMK_miType, [0, 0]];
		_group setGroupIconParams ([_group, [([side _group, false] call BIS_fnc_sideColor), "", 1, true]] call MCCMK_fnc_iconWithWp);
		_group setVariable ["MCCMK_miIcon", _id];
	};
	MCCMK_miIconOff = {
		params ["_group"];
		private _id = _group getVariable ["MCCMK_miIcon", -1];
		if (_id >= 0) then {_group removeGroupIcon _id};
		_group setVariable ["MCCMK_miIcon", -1];
	};
	// RKAG_fnc_spawnRevealGroup
	MCCMK_miReveal = {
		params ["_group"];
		if (MCCMK_miShow) then {[_group] call MCCMK_miIconOn};
		while {!(_group isEqualTo grpNull) && (_group in MCCMK_miRevealed)} do {
			private _id = _group getVariable ["MCCMK_miIcon", -1];
			if (_id >= 0) then {
				_group setGroupIcon [_id, [_group] call MCCMK_miType];
				comment "Check if any units are alive";
				private _i = units _group findIf {alive _x};
				if (_i < 0) then {_group setGroupIconParams ([_group, [[0, 0, 0, 0.75], "", 1, true]] call MCCMK_fnc_iconWithWp)};
			};
			sleep 1;
		};
		comment "Show last location";
		private _j = units _group findIf {alive _x};
		if (!(_group isEqualTo grpNull) && (_j > -1) && (side _group != side player)) then {[_group] spawn MCCMK_miLastKnown};
		if !(_group isEqualTo grpNull) then {[_group] call MCCMK_miIconOff};
	};
	// RKAG_fnc_hideGroup
	MCCMK_miHideGroup = {
		params ["_group"];
		MCCMK_miRevealed = (MCCMK_miRevealed - [_group]);
	};
	// RKAG_fnc_spawnLastKnownPositionMarker, as it is (hidden while the MCC console is open)
	MCCMK_miLastKnown = {
		params ["_group"];
		private _mkr = createMarkerLocal ["mccmk_mi_" + str (round random 1000000), getPos leader _group];
		_mkr setMarkerTypeLocal "mil_unknown";
		private _colorName = switch (side _group) do {
			case west: {"colorBLUFOR"};
			case east: {"colorOPFOR"};
			case independent: {"colorIndependent"};
			case civilian: {"colorCivilian"};
			default {"ColorUNKNOWN"};
		};
		_mkr setMarkerColorLocal _colorName;
		_mkr setMarkerSizeLocal [0.5, 0.5];
		if (call MCCMK_miMCCOpen) then {_mkr setMarkerAlphaLocal 0};
		MCCMK_miLostMarkers pushBack _mkr;
		private _time = 0;
		private _maxTime = MCCMK_miLastKnownTime;
		while {!(_group isEqualTo grpNull) && !(_group in MCCMK_miRevealed)} do {
			uiSleep 1;
			_time = _time + 1;
			if (_time >= _maxTime) exitWith {};
		};
		MCCMK_miLostMarkers = MCCMK_miLostMarkers - [_mkr];
		deleteMarkerLocal _mkr;
	};
	// RKAG_fnc_spawnFireEffect, as it is (the flash only on Map Intel's own icons; the streak when the open map wants it)
	MCCMK_miFireEffect = {
		params ["_unit"];
		private _group = group _unit;
		if ((_group getVariable ["MCCMK_miIcon", -1]) >= 0) then {
			_group spawn {
				_this setGroupIconParams ([_this, [[1, 1, 0.9, 0.75], "", 1, true]] call MCCMK_fnc_iconWithWp);
				uiSleep 0.05;
				_this setGroupIconParams ([_this, [([side _this, false] call BIS_fnc_sideColor), "", 1, true]] call MCCMK_fnc_iconWithWp);
			};
		} else {
			// (MK) a console's own icon on the group (the MCC console or the Commander Console open, its checkbox ticked - this
			// only runs then): the same pale yellow flash, the icon's own name and size kept, its colour put back after
			if ((call MCCMK_miCCOpen) || {call MCCMK_miMCCOpen}) then {
				private _id = _group getVariable "MCCgroupIconData";
				if (((!isNil "_id" && {((_group getGroupIcon _id) param [0, ""]) != ""}) || {(_group getVariable ["MCCMK_iconMarta", false]) && {!isNil {_group getVariable "MCCMK_iconWant"}}}) && {!(_group getVariable ["MCCMK_miFlashing", false])}) then {
					_group setVariable ["MCCMK_miFlashing", true];
					_group spawn {
						private _p = getGroupIconParams _this;
						_this setGroupIconParams ([_this, [[1, 1, 0.9, 0.75], _p select 1, _p select 2, _p select 3]] call MCCMK_fnc_iconWithWp);
						uiSleep 0.05;
						private _q = getGroupIconParams _this;
						if ((_q select 0) isEqualTo [1, 1, 0.9, 0.75]) then {_this setGroupIconParams ([_this, [_p select 0, _q select 1, _q select 2, _q select 3]] call MCCMK_fnc_iconWithWp)};
						_this setVariable ["MCCMK_miFlashing", false];
					};
				};
			};
		};
		_unit spawn {
			comment "Calculate vector forward for turret or man and convert to direction angle";
			private _forwardVectorFlat = [0, 0, 0];
			private _angle = 0;
			_forwardVectorFlat = (vehicle _this weaponDirection ((weaponState [vehicle _this, (vehicle _this unitTurret _this)]) select 0));
			if (_forwardVectorFlat isEqualTo [0, 0, 0]) then {_forwardVectorFlat = _this weaponDirection currentWeapon _this};
			_forwardVectorFlat set [2, 0];
			_forwardVectorFlat = vectorNormalized _forwardVectorFlat;
			_angle = acos ([0, 1, 0] vectorDotProduct _forwardVectorFlat);
			if ((_forwardVectorFlat select 0) < 0) then {_angle = _angle * -1};
			private _bulletMkr = createMarkerLocal ["mccmk_mi_" + str (round random 1000000), getPosWorldVisual _this];
			_bulletMkr setMarkerShapeLocal "RECTANGLE";
			_bulletMkr setMarkerBrushLocal "SolidFull";
			_bulletMkr setMarkerColorLocal MCCMK_miBulletColor;
			_bulletMkr setMarkerSizeLocal MCCMK_miBulletSize;
			_bulletMkr setMarkerDirLocal _angle;
			private _frameEvent = addMissionEventHandler ["EachFrame", {
				private _bulletMkr = _thisArgs select 1;
				private _forwardVector = _thisArgs select 2;
				private _currentPos = getMarkerPos _bulletMkr;
				_bulletMkr setMarkerPosLocal (_currentPos vectorAdd (_forwardVector vectorMultiply MCCMK_miBulletSpeed));
			}, [_this, _bulletMkr, _forwardVectorFlat]];
			uiSleep MCCMK_miBulletLifetime;
			removeMissionEventHandler ["EachFrame", _frameEvent];
			deleteMarkerLocal _bulletMkr;
		};
	};
	// RKAG_fnc_tryInitUnit
	MCCMK_miTryInitUnit = {
		params ["_unit"];
		private _initValue = _unit getVariable "MCCMK_miInit";
		if (isNil "_initValue") then {
			_unit addEventHandler ["FiredMan", {
				params ["_unit"];
				if (call MCCMK_miWantFire) then {[_unit] call MCCMK_miFireEffect};
			}];
			_unit setVariable ["MCCMK_miInit", true];
		};
	};

	// onGroupIconOverEnter / onGroupIconOverLeave, as they are (Arma's mission events of the same name - only Map Intel's
	// own groups: the consoles' icons are theirs)
	addMissionEventHandler ["GroupIconOverEnter", {
		params ["_is3D", "_group"];
		if (_is3D || {!(_group in MCCMK_miRevealed)} || {(_group getVariable ["MCCMK_miIcon", -1]) < 0}) exitWith {};
		private _mkrType = [_group] call MCCMK_miType;
		private _text = (getText (configFile >> "CfgMarkers" >> _mkrType >> "name"));
		private _vehCount = 0;
		private _footCount = 0;
		private _vehName = '';
		private _vehs = [];
		comment "Determine marker name based on vehicle count and type";
		{
			if (!(vehicle _x isEqualTo _x) && !(vehicle _x in _vehs)) then {
				_vehCount = (_vehCount + 1);
				_vehs pushBack vehicle _x;
				if (_vehName isEqualTo '') then {_vehName = [configFile >> "CfgVehicles" >> typeOf vehicle _x] call BIS_fnc_displayName};
			};
			if (vehicle _x isEqualTo _x) then {_footCount = (_footCount + 1)};
		} forEach units _group;
		if (_vehCount == 1) then {_text = _vehName};
		comment "Check if any units alive";
		private _i = units _group findIf {alive _x};
		if (_i < 0) then {_group setGroupIconParams ([_group, [[0, 0, 0, 0.75], _text + " (DEAD)", 1.25, true]] call MCCMK_fnc_iconWithWp)}
		else {_group setGroupIconParams ([_group, [([side _group, false] call BIS_fnc_sideColor), _text, 1.25, true]] call MCCMK_fnc_iconWithWp)};
		comment "Show map tooltip";
		if (visibleMap || {!isNull (findDisplay 2993)}) then {[_group, _vehCount, _footCount] call MCCMK_miShowTooltip};
	}];
	addMissionEventHandler ["GroupIconOverLeave", {
		params ["_is3D", "_group"];
		if (_is3D || {(_group getVariable ["MCCMK_miIcon", -1]) < 0}) exitWith {call MCCMK_miHideTooltip};
		_group setGroupIconParams ([_group, [([side _group, false] call BIS_fnc_sideColor), "", 1, true]] call MCCMK_fnc_iconWithWp);
		call MCCMK_miHideTooltip;
	}];

	// the checkbox (RKAG_fnc_createMapHideMarkersCheckbox: its size and green background; unticked, no tooltip): the main
	// map's at the original's place, a console's bottom right of its map
	MCCMK_miBox = {
		params ["_d", "_m", "_key"];
		private _c = _d ctrlCreate ["RscCheckbox", -1];
		if (_key == "MCCMK_mi_main") then {
			_c ctrlSetPosition [0.965937 * safezoneW + safezoneX, 0.948 * safezoneH + safezoneY, 0.018125 * safezoneW, 0.0336666 * safezoneH];
		} else {
			(ctrlPosition _m) params ["_x", "_y", "_w", "_h"];
			// (half the main map's size, its bottom-right corner where it was)
			_c ctrlSetPosition [_x + _w - 0.0110375 * safezoneW, _y + _h - 0.0188333 * safezoneH, 0.0090625 * safezoneW, 0.0168333 * safezoneH];
		};
		_c cbSetChecked (profileNamespace getVariable [_key, false]);
		_c ctrlSetBackgroundColor [0, 0.5, 0, 1];
		_c setVariable ["MCCMK_miKey", _key];
		_c ctrlCommit 0;
		_c ctrlAddEventHandler ["CheckedChanged", {params ["_c", "_st"]; profileNamespace setVariable [_c getVariable ["MCCMK_miKey", ""], _st == 1]}];
		_c
	};

	// the 3D View: Shift + right-click on a group icon or on the main map next to a unit
	MCCMK_miAvLoad = {
		if (isNil "MCCMK_fnc_avTryOpen") then {
			[] execVM ((missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"]) + "mcc\fnc\mkhq\altView\MCCMK_altView.sqf");
			private _t = time + 10;
			waitUntil {!isNil "MCCMK_fnc_avTryOpen" || {time > _t}};
		};
		!isNil "MCCMK_fnc_avTryOpen"
	};
	addMissionEventHandler ["GroupIconClick", {
		params ["_is3D", "_grp", "", "_mb", "", "", "_shift"];
		if (_is3D || {!visibleMap} || {_mb != 1} || {!_shift} || {isNull _grp} || {_grp == group player}) exitWith {};
		[_grp] spawn {
			params ["_grp"];
			if !(call MCCMK_miAvLoad) exitWith {};
			if (!((call MCCMK_fnc_avMode) > 0) || {!([side _grp] call MCCMK_fnc_avSideOK)}) exitWith {};
			[[_grp] call MCCMK_fnc_avTarget] call MCCMK_fnc_avTryOpen;
		};
	}];
	MCCMK_miHookMain = {
		private _d = findDisplay 12;
		private _map = _d displayCtrl 51;
		if (isNull _map || {_map getVariable ["MCCMK_miEH", false]}) exitWith {};
		_map setVariable ["MCCMK_miEH", true];
		_map ctrlAddEventHandler ["MouseButtonClick", {
			params ["_ctl", "_b", "_mx", "_my", "_shift"];
			if (_b != 1 || {!_shift}) exitWith {};
			[_ctl, _mx, _my] spawn {
				params ["_ctl", "_mx", "_my"];
				if !(call MCCMK_miAvLoad) exitWith {};
				if !((call MCCMK_fnc_avMode) > 0) exitWith {};
				private _tol = 15 * pixelW;
				private _best = objNull;
				private _bd = 1e9;
				private _ps = side group player;
				{
					private _sp = _ctl ctrlMapWorldToScreen (getPosATL (vehicle _x));
					private _dd = sqrt ((((_sp select 0) - _mx) ^ 2) + (((_sp select 1) - _my) ^ 2));
					if (_dd < _bd) then {_bd = _dd; _best = _x};
				} forEach (allUnits select {alive _x && {_x != player} && {[side group _x] call MCCMK_fnc_avSideOK} && {([_ps, side group _x] call BIS_fnc_sideIsFriendly) || {(_ps knowsAbout (vehicle _x)) > 0}}});
				if (isNull _best || {_bd > _tol}) exitWith {};
				private _v = vehicle _best;
				private _u = if (_v == _best) then {_best} else {private _dr = driver _v; if (!isNull _dr && {alive _dr}) then {_dr} else {effectiveCommander _v}};
				[_u] call MCCMK_fnc_avTryOpen;
			};
		}];
		uiNamespace setVariable ["MCCMK_miBoxMain", [_d, _map, "MCCMK_mi_main"] call MCCMK_miBox];
	};
	call MCCMK_miHookMain;
	// the map opened / closed (RKAGOnlyShowMarkersOnMap: Arma's group icons shown only while the map is open)
	addMissionEventHandler ["Map", {
		params ["_isOpened"];
		if (_isOpened) then {call MCCMK_miHookMain};
		if (!_isOpened) then {setGroupIconsVisible [false, false]; setGroupIconsSelectable false; call MCCMK_miHideTooltip};
	}];

	// what the open map wants, every quarter second: Map Intel's icons on or off, Arma's icons shown, the "?" markers, the
	// consoles' checkboxes, and Arma's map content (the difficulty override)
	[] spawn {
		private _diff = 1;	// (the mode applied: the difficulty's own at the start)
		while {true} do {
			private _on = missionNamespace getVariable ["MCCMK_mapIntel", true];
			private _want = call MCCMK_miWantIcons;
			if !(_want isEqualTo MCCMK_miShow) then {
				MCCMK_miShow = _want;
				{if (_want) then {[_x] call MCCMK_miIconOn} else {[_x] call MCCMK_miIconOff}} forEach (MCCMK_miRevealed - [grpNull]);
				if (!_want) then {call MCCMK_miHideTooltip};
			};
			// the main map open: Arma's group icons shown (the original's [true, true]); the Commander Console shows them itself
			if (visibleMap && {_on}) then {
				if !((groupIconsVisible select 0)) then {setGroupIconsVisible [true, true]; setGroupIconsSelectable true};
			};
			// the "?" markers: hidden while the MCC console is open
			private _a = [1, 0] select (call MCCMK_miMCCOpen);
			{_x setMarkerAlphaLocal _a} forEach MCCMK_miLostMarkers;
			// the checkboxes (only while on)
			{_x params ["_mkK", "_mkP"]; private _c = uiNamespace getVariable [_mkK, controlNull]; if (!isNull _c) then {_c ctrlShow (_on && {_mkP < 0 || {!(ctrlShown ((ctrlParent _c) displayCtrl _mkP))}})}} forEach [["MCCMK_miBoxMain", -1], ["MCCMK_miBoxCC", 9157], ["MCCMK_miBoxMCC", 510]];
			private _cd = findDisplay 2993;
			if (!isNull _cd && {!(_cd getVariable ["MCCMK_miHooked", false])}) then {
				private _cm = _cd displayCtrl 9120;
				if (!isNull _cm) then {
					_cd setVariable ["MCCMK_miHooked", true];
					private _b = [_cd, _cm, "MCCMK_mi_cc"] call MCCMK_miBox;
					_b ctrlShow _on;
					uiNamespace setVariable ["MCCMK_miBoxCC", _b];
				};
			};
			private _md = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
			if (!isNull _md && {!(_md getVariable ["MCCMK_miHooked", false])}) then {
				private _mm = _md displayCtrl 9000;
				if (!isNull _mm) then {
					_md setVariable ["MCCMK_miHooked", true];
					private _b = [_md, _mm, "MCCMK_mi_mcc"] call MCCMK_miBox;
					_b ctrlShow _on;
					uiNamespace setVariable ["MCCMK_miBoxMCC", _b];
				};
			};
			// Arma's own map content ("Map Intel: Arma's map content"): 0 Show all (whatever the difficulty), 1 the difficulty's
			// own, 2 Hide units (the original script's: friendly and enemy unit markers hidden, mines and pings shown); Map
			// Intel off: the difficulty's own
			private _mode = missionNamespace getVariable ["MCCMK_mapIntelContent", 0];
			if (_mode isEqualType true) then {_mode = [1, 0] select _mode};	// (the earlier on/off setting)
			if (!_on) then {_mode = 1};
			if !(_mode isEqualTo _diff) then {
				switch (_mode) do {
					case 1: {disableMapIndicators [(difficultyOption "mapContentFriendly") == 0, (difficultyOption "mapContentEnemy") == 0, (difficultyOption "mapContentMines") == 0, (difficultyOption "tacticalPing") == 0]};
					case 2: {disableMapIndicators [true, true, false, false]};
					default {disableMapIndicators [false, false, false, false]};
				};
				_diff = _mode;
			};
			sleep 0.25;
		};
	};

	// the original's loop, as it is (Map Intel off: nothing revealed)
	while {true} do {
		if (alive player && {missionNamespace getVariable ["MCCMK_mapIntel", true]}) then {
			{
				private _group = _x;
				private _inVehicle = !(vehicle (units _group select 0) isEqualTo (units _group select 0));
				if (isNil "_inVehicle") then {_inVehicle = false};
				private _i = units _group findIf {_x in allPlayers};
				if (_i > -1 || (side _group isEqualTo side player && (count units _group <= 1) && !_inVehicle) || side _group isEqualTo civilian) then {continue};
				if ([_group] call MCCMK_miConsoleGroup) then {[_group] call MCCMK_miHideGroup; {[_x] call MCCMK_miTryInitUnit} forEach units _group; continue};	// (a console's own icon - left to it)
				private _spottedAnyGroupMember = false;
				{
					if ((side player) knowsAbout vehicle _x == 4) then {_spottedAnyGroupMember = true};	// (ANY member - the original overwrote it for each man, so only the last counted)
					[_x] call MCCMK_miTryInitUnit;
				} forEach units _group;
				if (_spottedAnyGroupMember) then {
					if (_group in MCCMK_miRevealed) exitWith {};
					if (count units _group < MCCMK_miMinGroupSize && ((vehicle (units _group select 0)) isEqualTo (units _group select 0))) exitWith {};
					MCCMK_miRevealed pushBack _group;
					[_group] spawn MCCMK_miReveal;
				} else {
					[_group] call MCCMK_miHideGroup;
				};
			} forEach allGroups;
			comment "Try Init Players";
			{
				if !(side _x isEqualTo side player) then {continue};
				[_x] call MCCMK_miTryInitUnit;
			} forEach allPlayers;
			comment "Try Init Player's Own AI Squad Members";
			{
				if (isPlayer _x) then {continue};
				[_x] call MCCMK_miTryInitUnit;
			} forEach (units group player);
		} else {
			MCCMK_miRevealed = [];
		};
		MCCMK_miRevealed = (MCCMK_miRevealed - [grpNull]);
		uiSleep 1;
	};
};
