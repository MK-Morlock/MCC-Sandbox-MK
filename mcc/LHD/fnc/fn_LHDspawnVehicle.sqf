/*===================================================================MCC_fnc_LHDspawnVehicle======================================================================
	Handle spawn vehicles on LHD requests
 	INTERNAL USE ONLY

 		<IN>
		_array:	STRING - function type

		<OUT>
		Name of the LHD
==================================================================================================================================================================*/
#define MCC_PRICESFACTOR 0.2
#define CUP_WATERVEHICLES_FOLDABLE ["CUP_B_MV22_USMC","CUP_B_CH53E_USMC","CUP_AH1Z_base","CUP_B_UH1Y_Base"]
#define CUP_WATERVEHICLES_FOLDANIMS ["\cup\airvehicles\cup_airvehicles_mv22\scripts\pack.sqf","\cup\airvehicles\cup_airvehicles_CH53E\scripts\ch53_fold.sqf","\cup\airvehicles\cup_airvehicles_AH1Z\scripts\AH1Z_fold.sqf","\cup\airvehicles\cup_airvehicles_UH1Y\Scripts\UH1Y_fold.sqf"]

disableSerialization;
params [
	["_function","updateVehicleType",[""]],
	["_deck", 0, [0]],
	["_selection", "", [""]],
	["_operator", 0, [0]]
];

private _ctrl = controlNull;
private "_display";
private "_ctrlPos";
private _vehiclesArray = [];
private _index = controlNull;
private "_ship";
private "_side";
private "_hideCtrls";
_ship = (missionNamespace getVariable ["MCC_interatedLHD",objNull]);

if (isNull _ship) exitWith {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC_fnc_LHDspawnVehicle: Null ship"}};

_side = _ship getVariable ["MCC_side",sideLogic];
_display = uiNamespace getVariable ["MCC_LHD_MENU", displayNull];
_ctrl = _display displayCtrl 2300;

_ctrlPos = ctrlPosition _ctrl;

//If close open it
private _opened = false;
if ((_ctrlPos select 2)<=0) then {
	_opened = true;
	uiNamespace setVariable ["MCCMK_lhdCur", [_deck, _selection, _operator]];
	if (isNull (_display displayCtrl 7780)) then {
		private _grp = _display displayCtrl 2300;
		private _mkc = {
			params ["_cls", "_idc", "_pos"];
			private _c = _display ctrlCreate [_cls, _idc, _grp];
			_c ctrlSetPosition [(_pos select 0) * safezoneW, (_pos select 1) * safezoneH, (_pos select 2) * safezoneW, (_pos select 3) * safezoneH];
			_c ctrlCommit 0;
			_c
		};
		private _refresh = "(uiNamespace getVariable ['MCCMK_lhdCur', [0, '', 0]]) params ['_d', '_s', '_o']; ['updateVehicleType', _d, _s, _o] spawn MCC_fnc_LHDspawnVehicle;";
		private _l1 = ["RscText", 7784, [0.14, 0.099, 0.05, 0.033]] call _mkc;
		_l1 ctrlSetText "Faction";
		private _c1 = ["RscCheckBox", 7780, [0.185, 0.104, 0.011, 0.022]] call _mkc;
		_c1 cbSetChecked (uiNamespace getVariable ["MCCMK_lhdFactionOnly", true]);
		_c1 ctrlSetTooltip "Ticked: your faction's vehicles only. Unticked: your whole\nside's vehicles.";
		_c1 ctrlAddEventHandler ["CheckedChanged", "uiNamespace setVariable ['MCCMK_lhdFactionOnly', (_this select 1) == 1]; " + _refresh];
		private _l2 = ["RscText", 7785, [0.205, 0.099, 0.065, 0.033]] call _mkc;
		_l2 ctrlSetText "Sort by price";
		private _c2 = ["RscCheckBox", 7781, [0.27, 0.104, 0.011, 0.022]] call _mkc;
		_c2 cbSetChecked (uiNamespace getVariable ["MCCMK_lhdSortPrice", false]);
		_c2 ctrlSetTooltip "Cheapest first";
		_c2 ctrlAddEventHandler ["CheckedChanged", "uiNamespace setVariable ['MCCMK_lhdSortPrice', (_this select 1) == 1]; " + _refresh];
		private _ed = ["RscEdit", 7782, [0.14, 0.138, 0.105, 0.032]] call _mkc;
		_ed ctrlSetTooltip "Search by name";
		_ed ctrlAddEventHandler ["KeyUp", _refresh];
		private _cl = [["MCC_RscButtonRoundSmall", "MCC_RscButtonRoundSmall3D"] select (profileNamespace getVariable ["MCC_consoleButtons", false]), 7783, [0.248, 0.138, 0.036, 0.032]] call _mkc;
		_cl ctrlSetText "Clear";
		_cl ctrlAddEventHandler ["ButtonClick", "ctrlSetText [7782, '']; " + _refresh];
	};

	//Hide ctel depends on the player status
	_hideCtrls = switch (_operator) do
				{
					//Mission maker
					case 0:
					{
						[1100,1101,1102,1103,1000,1001,1002,1003,81,82,83,84,91,92,93,94]
					};

					//Commander
					case 1:
					{
						[1103,1003,84,94]
					};

					//Grunt
					default
					{
						[1100,1101,1102,1000,1001,1002,81,82,83,91,92,93]
					};
				};
	{ctrlShow [_x,false]} forEach _hideCtrls;
	private _px = 0.05 * safezoneW + safezoneX;
	private _py = 0.5 * safezoneH + safezoneY;
	{
		(ctrlPosition _x) params ["_bx", "_by", "_bw", "_bh"];
		if ((_bx + _bw) > _px && {_bx < (_px + 0.5 * safezoneW)} && {(_by + _bh) > _py} && {_by < (_py + 0.4 * safezoneH)}) then {_x ctrlShow false};
	} forEach (uiNamespace getVariable ["MCCMK_lhdSlotBtns", []]);

    //Disable purchase button
    if (_operator != 0)  then {ctrlEnable [2400,false]};

	_ctrlPos set [0,0.05 * safezoneW + safezoneX];
	_ctrlPos set [1,0.5 * safezoneH + safezoneY];
	_ctrlPos set [2,0.5 * safezoneW];
	_ctrlPos set [3,0.4 * safezoneH];
	_ctrl ctrlSetPosition _ctrlPos;

	//disable purchase by defualt
	_ctrl ctrlCommit 0.1;
	sleep 0.1;


	//Faction
	_ctrl = _display displayCtrl 8008;
	lbClear _ctrl;
	{
		_displayname = format ["%1(%2)",_x select 0,_x select 1];
		_ctrl lbAdd _displayname;
	} foreach U_FACTIONS;
	_ctrl lbSetCurSel (missionNamespace getVariable ["MCC_faction_index",0]);

	//Type
	_ctrl = _display displayCtrl 1501;
	lbClear _ctrl;
	private _slot = if ((_selection select [0, 1]) == "[") then {parseSimpleArray _selection} else {_selection};
	private _water = (_slot isEqualType []) && {(_slot param [2, 5]) <= 1};
	private _stype = _ship getVariable ["MCC_ShipType", 0];
	private _allowed = switch (true) do {
		case (_water || {_stype == 2}): {["ship"]};
		case (_stype == 0): {["heli", "vehicle", "tank"]};
		case (_stype == 3 && {_deck == 4}): {["ship", "vehicle", "tank"]};
		default {["vehicle", "tank", "heli", "jet"]};
	};
	private _what = switch (true) do {
		case (_water || {_stype == 2}): {"Boat slot: boats only"};
		case (_stype == 0): {"Helipad: helicopters, and vehicles to sling-load"};
		case (_stype == 3 && {_deck == 4}): {"Well deck: boats and amphibious vehicles"};
		default {"Deck: aircraft and vehicles"};
	};
	private _wl = _display displayCtrl 7778;
	if (isNull _wl) then {_wl = _display ctrlCreate ["RscStructuredText", 7778, _display displayCtrl 2300]};
	_wl ctrlSetPosition [0.01 * safezoneW, 0.004 * safezoneH, 0.38 * safezoneW, 0.03 * safezoneH];
	_wl ctrlSetStructuredText parseText format ["<t size='0.95' color='#ffd966'>%1</t>", _what];
	_wl ctrlCommit 0;
	private _types = ([["Vehicles", "vehicle"], ["Tracked/Static", "tank"], ["Helicopter", "heli"], ["Fixed-wing", "jet"], ["Ship", "ship"]] select {(_x select 1) in _allowed}) select {count ([_x select 1, _side, "", true] call MCC_fnc_vehicleSpawnerBuildCostTable) > 0};
	uiNamespace setVariable ["MCCMK_lhdTypes", _types apply {_x select 1}];
	{
		_ctrl lbAdd (_x select 0);
	} foreach _types;
	if (_types isEqualTo []) then {_ctrl lbAdd "Nothing available here"};
	_ctrl lbSetCurSel 0;

	//Change faction or vehicle type
	{
		_ctrl = _display displayCtrl _x;
		_ctrl ctrlRemoveAllEventHandlers "LBSelChanged";
		_ctrl ctrlAddEventHandler ["LBSelChanged",format ["['updateVehicleType',%1,'%2', %3] spawn MCC_fnc_LHDspawnVehicle;",_deck, _selection, _operator]];
		_ctrl ctrlCommit 0;
	} forEach [8008,1501];

	//Change class
	_ctrl = _display displayCtrl 1502;
	_ctrl ctrlRemoveAllEventHandlers "LBSelChanged";
	_ctrl ctrlAddEventHandler ["LBSelChanged",format ["['updateVehicleClass',%1,'%2', %3] spawn MCC_fnc_LHDspawnVehicle;",_deck, _selection, _operator]];
	_ctrl ctrlCommit 0;

	//Update
	["updateVehicleType",_deck, _selection, _operator] spawn MCC_fnc_LHDspawnVehicle;
};

if (_function == "updateSpawn" && {!_opened}) then {
	uiNamespace setVariable ["MCCMK_lhdCur", [_deck, _selection, _operator]];
	_ctrl = _display displayCtrl 1501;
	lbClear _ctrl;
	private _slot = if ((_selection select [0, 1]) == "[") then {parseSimpleArray _selection} else {_selection};
	private _water = (_slot isEqualType []) && {(_slot param [2, 5]) <= 1};
	private _stype = _ship getVariable ["MCC_ShipType", 0];
	private _allowed = switch (true) do {
		case (_water || {_stype == 2}): {["ship"]};
		case (_stype == 0): {["heli", "vehicle", "tank"]};
		case (_stype == 3 && {_deck == 4}): {["ship", "vehicle", "tank"]};
		default {["vehicle", "tank", "heli", "jet"]};
	};
	private _what = switch (true) do {
		case (_water || {_stype == 2}): {"Boat slot: boats only"};
		case (_stype == 0): {"Helipad: helicopters, and vehicles to sling-load"};
		case (_stype == 3 && {_deck == 4}): {"Well deck: boats and amphibious vehicles"};
		default {"Deck: aircraft and vehicles"};
	};
	private _wl = _display displayCtrl 7778;
	if (isNull _wl) then {_wl = _display ctrlCreate ["RscStructuredText", 7778, _display displayCtrl 2300]};
	_wl ctrlSetPosition [0.01 * safezoneW, 0.004 * safezoneH, 0.38 * safezoneW, 0.03 * safezoneH];
	_wl ctrlSetStructuredText parseText format ["<t size='0.95' color='#ffd966'>%1</t>", _what];
	_wl ctrlCommit 0;
	private _types = ([["Vehicles", "vehicle"], ["Tracked/Static", "tank"], ["Helicopter", "heli"], ["Fixed-wing", "jet"], ["Ship", "ship"]] select {(_x select 1) in _allowed}) select {count ([_x select 1, _side, "", true] call MCC_fnc_vehicleSpawnerBuildCostTable) > 0};
	uiNamespace setVariable ["MCCMK_lhdTypes", _types apply {_x select 1}];
	{
		_ctrl lbAdd (_x select 0);
	} foreach _types;
	if (_types isEqualTo []) then {_ctrl lbAdd "Nothing available here"};
	_ctrl lbSetCurSel 0;
	//Change faction or vehicle type
	{
		_ctrl = _display displayCtrl _x;
		_ctrl ctrlRemoveAllEventHandlers "LBSelChanged";
		_ctrl ctrlAddEventHandler ["LBSelChanged",format ["['updateVehicleType',%1,'%2', %3] spawn MCC_fnc_LHDspawnVehicle;",_deck, _selection, _operator]];
		_ctrl ctrlCommit 0;
	} forEach [8008,1501];

	//Change class
	_ctrl = _display displayCtrl 1502;
	_ctrl ctrlRemoveAllEventHandlers "LBSelChanged";
		_ctrl ctrlAddEventHandler ["LBSelChanged",format ["['updateVehicleClass',%1,'%2', %3] spawn MCC_fnc_LHDspawnVehicle;",_deck, _selection, _operator]];
	_ctrl ctrlCommit 0;

	["updateVehicleType",_deck, _selection, _operator] spawn MCC_fnc_LHDspawnVehicle;
};

switch (_function) do
{
	case "updateVehicleType":
	{
		/*
		//Upadate faction
		_index = lbCurSel (_display displayCtrl 8008);
		if ((missionNamespace getVariable ["MCC_faction_index",-1]) != _index) then	{
			mcc_sidename = (U_FACTIONS select _index) select 1;
			mcc_faction = (U_FACTIONS select _index) select 2; player setVariable ["MCCMK_faction", mcc_faction, true];
			MCC_faction_index = _index;
			0 = [false] call mcc_fnc_faction_choice;
		};
		*/

		//class
		_index = lbCurSel (_display displayCtrl 1501);
		_vehicleType = (uiNamespace getVariable ["MCCMK_lhdTypes", ["vehicle", "tank", "heli", "jet", "ship"]]) param [_index, ""];

		private _facOnly = uiNamespace getVariable ["MCCMK_lhdFactionOnly", true];
		_vehiclesArray = [_vehicleType, _side, faction player, !_facOnly] call MCC_fnc_vehicleSpawnerBuildCostTable;
		private _find = toLower (ctrlText (_display displayCtrl 7782));
		if (_find != "") then {_vehiclesArray = _vehiclesArray select {((toLower ((_x select 1) select 0)) find _find) >= 0}};
		if (uiNamespace getVariable ["MCCMK_lhdSortPrice", false]) then {_vehiclesArray = [_vehiclesArray, [], {_x select 2}, "ASCEND"] call BIS_fnc_sortBy};
		missionNamespace setVariable ["MCC_fnc_LHDspawnMenuInitArray", _vehiclesArray];
		_ctrl = _display displayCtrl 1502;
		lbClear _ctrl;

		{
			_displayname = format ["%1",(_x select 1) select 0];
			_index = _ctrl lbAdd _displayname;
			_ctrl lbsetData [_index, (_x select 0)];
			_ctrl lbsetpicture [_index, (_x select 1) select 1];
		} foreach _vehiclesArray;

		if (count _vehiclesArray > 0) then {_ctrl lbSetCurSel 0};
	};

	case "updateVehicleClass":
	{
		private _selectedVehicle = controlNull;
		private "_cfgclass";
		private _costAmmo = 0;
		private _costRepair = 0;
		private _costFuel = 0;
		private _costValor = 0;
		private "_array";
		private _purchaseEnable = false;
		private "_cost";
		_vehiclesArray = missionNamespace getVariable ["MCC_fnc_LHDspawnMenuInitArray", []];

		if (count _vehiclesArray <= 0) exitWith {};

		//Set info picture
		_ctrl = _display displayCtrl 111100;
		_ctrl ctrlSetText ((_vehiclesArray select (lbCurSel (_display displayCtrl 1502)) select 1) select 1);

		//Get costs
		_array = (missionNamespace getVariable format ["MCC_res%1",playerside]);
		_selectedVehicle = _vehiclesArray select (lbCurSel (_display displayCtrl 1502));
		_cfgclass = _selectedVehicle select 0;
		_cost = _selectedVehicle select 2;
		_costAmmo = floor (_cost * 0.3 * MCC_PRICESFACTOR);
		_costRepair = floor (_cost * 0.5 * MCC_PRICESFACTOR);
		_costFuel = floor (_cost * 0.2 * MCC_PRICESFACTOR);
		_costValor = floor (_cost * 0.3);

		_ctrl = 1000;
	    _purchaseEnable = true;

	    switch (_operator) do
		{
			//Mission maker
			case 0:
			{
			};

			//Commander
			case 1:
			{
				//Load available resources
			    {_display displayCtrl _x ctrlSetText ([(_array select _forEachIndex)] call MCC_fnc_formatNumber)} foreach [81,82,83];

		    	//Do we have enough side resources
		        {
		            ctrlSetText [_ctrl, [_x, true] call MCC_fnc_formatNumber];
		            if (_x <= (_array select _foreachindex)) then {
		                (_display displayctrl _ctrl) ctrlSetTextColor [1,1,1,1];
		            } else {
		                (_display displayctrl _ctrl) ctrlSetTextColor [1,0,0,1];
		                 _purchaseEnable = false;
		            };
		            _ctrl = _ctrl +1;
		        } forEach [_costAmmo,_costRepair,_costFuel];
			};

			//Grunt
			default
			{
				//Load available valor
		    	 _display displayCtrl 84 ctrlSetText ([(player getVariable ["MCC_valorPoints",50])] call MCC_fnc_formatNumber);

		        //Do we have enough personal valor
		        _ctrl = _display displayctrl 1003;
		        _ctrl ctrlSetText ([_costValor] call MCC_fnc_formatNumber);

		        if ((player getVariable ["MCC_valorPoints",50]) >= _costValor) then {
		            _ctrl ctrlSetTextColor [1,1,1,1];
		        } else {
		            _ctrl ctrlSetTextColor [1,0,0,1];
		             _purchaseEnable = false;
		        };
			};
		};


	     ctrlEnable [2400,_purchaseEnable];
	};

	case "spawn":
	{
		private _vehicleClass = controlNull;
		private "_direction";
		private "_cargo";
		private _dummy = "";
		private _str = "";
		private _null = [];
		private "_isCUPLHD";
		private "_boundingBox";
		private _boundingBoxIndecator = 0;
		private _costAmmo = 0;
		private _costRepair = 0;
		private _costFuel = 0;
		private _costValor = 0;
		private "_array";
		private "_cost";
		private _vehiclesArray = [];
		private _selectedVehicle = controlNull;
		private "_cfgclass";

		if (_selection isEqualTo "" || _selection isEqualTo []) exitWith {};
		if ((_ship getVariable ["MCCMK_crippled", false]) || {_ship getVariable ["MCCMK_disabled", false]} || {_ship getVariable ["MCCMK_sinking", false]}) exitWith {["The ship is too badly damaged - repair the hull first."] call MCCMK_fnc_lhdStatus};
		if (((_ship getVariable ["MCCMK_repositionUntil", 0]) - serverTime) > 0) exitWith {["Repositioning: available in " + ([((_ship getVariable ["MCCMK_repositionUntil", 0]) - serverTime), "MM:SS"] call BIS_fnc_secondsToString) + "."] call MCCMK_fnc_lhdStatus};

		//Get costs

		_vehiclesArray = missionNamespace getVariable ["MCC_fnc_LHDspawnMenuInitArray", []];
		if (count _vehiclesArray <= 0) exitWith {};

		_array = (missionNamespace getVariable format ["MCC_res%1",playerside]);
		_selectedVehicle = _vehiclesArray select (lbCurSel (_display displayCtrl 1502));
		_cfgclass = _selectedVehicle select 0;
		_cost = _selectedVehicle select 2;
		_costAmmo = floor (_cost * 0.3 * MCC_PRICESFACTOR);
		_costRepair = floor (_cost * 0.5 * MCC_PRICESFACTOR);
		_costFuel = floor (_cost * 0.2 * MCC_PRICESFACTOR);
		_costValor = floor (_cost * 0.3);

		_vehicleClass = (_display displayCtrl 1502) lbData (lbCurSel 1502);
		_isCUPLHD = _ship isKindOf "CUP_LHD_BASE";


		switch (true) do
		{
			case (_selection in ["fd_cargo_pos_2","fd_cargo_pos_3","fd_cargo_pos_4","fd_cargo_pos_5","fd_cargo_pos_6","fd_cargo_pos_11","fd_cargo_pos_12","fd_cargo_pos_13","fd_cargo_pos_14","fd_cargo_pos_16","fd_cargo_pos_18","[-30,70,24]","[-30,50,24]","[-30,30,24]","[-30,10,24]","[-30,-10,24]"]):
			{
				_direction = (direction _ship)+90;
				_boundingBoxIndecator = 0;
			};

			case (_selection in ["fd_cargo_pos_7","fd_cargo_pos_8","fd_cargo_pos_9","fd_cargo_pos_10","fd_cargo_pos_15","fd_cargo_pos_17","fd_cargo_pos_19","[20,50,24]","[37,70,24]","[-22,-55,24]","[5,-55,24]"]):
			{
				_direction = (direction _ship)+180;
				_boundingBoxIndecator = 1;
			};

			default {
				_direction =direction _ship;
				_boundingBoxIndecator = 0;
			};
		};

		_cargo = nil;

		// If valid class, spawn the vehicle, then move it into position
		if !(isClass (configFile >> "CfgVehicles" >> _vehicleClass)) exitWith {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format["MCC: MCC_fnc_LHDspawnVehicle: ERROR %1 Vehicle Not in config", _vehicleClass]}};

		//Check if available
		_dummy = "HeliH" createVehicleLocal [0,0,0];
		waitUntil {alive _dummy};

		if (_isCUPLHD) then {
			_dummy attachTo [_ship,[0,0,0],_selection]
		} else {
			_dummy attachTo [_ship,(call compile _selection)];
		};

		// Create the vehicle
		_cargo = createVehicle [_vehicleClass, [0,0,0], [], 0, "NONE"];
		_cargo setDamage 0;
		_cargo allowDamage false;
		_cargo setDir _direction;
		_boundingBox = (_cargo call BIS_fnc_boundingBoxDimensions) ;
		_maxDistance = _boundingBox select _boundingBoxIndecator;

		private _blocker = [getPosASL _dummy, _direction, boundingBoxReal _cargo, [_cargo, _dummy, _ship]] call MCCMK_fnc_bayBlocked;
		if (!isNull _blocker || (_selection isEqualTo "")) then {
			if (!isNull _blocker) then {["INFO", "LHDSpawn", "bay %1 blocked by %2 (%3 m away)", [_selection, typeOf _blocker, round (_blocker distance _dummy)]] call MCC_fnc_log};
			if (isNil "MCCMK_fnc_lhdStatus") then {
				_str = "<t size='0.8' font='PuristaLight' color='#FFFFFF'>" + "Bay is blocked" + "</t>";
				_null = [_str,0,1.1,2,0.1,0.0] spawn bis_fnc_dynamictext;
			} else {["Bay is blocked"] call MCCMK_fnc_lhdStatus};

			deleteVehicle _cargo;
			detach _dummy;
			deleteVehicle _dummy;
			_dummy = nil;
		} else {


			//Lets see if we need to pay for this spawn
			if (_operator > 0) then {
				_array = (missionNamespace getVariable format ["MCC_res%1",playerside]);

				//Reduce resources
				if (_operator == 1) then {

				    _array = [(_array select 0) -_costAmmo,(_array select 1) -_costRepair,(_array select 2) -_costFuel,(_array select 3),(_array select 4)];
				    missionNamespace setVariable [format ["MCC_res%1",playerside],_array];
				    publicVariable format ["MCC_res%1",playerside];
				} else {

				     //Reduce valor
				    player setVariable ["MCC_valorPoints",(player getVariable ["MCC_valorPoints",50])-_costValor,true];
				};

				0 = ["updateVehicleClass",_deck,_selection, _operator] spawn MCC_fnc_LHDspawnVehicle;
			};


			detach _dummy;
			deleteVehicle _dummy;
			_dummy = nil;


			// Check to see if vehicle should be folded/packed
			{
				if (_cargo iskindof _x) then {
					private "_animscript";

					_animscript = CUP_WATERVEHICLES_FOLDANIMS select (CUP_WATERVEHICLES_FOLDABLE find _x);
					_script = [_cargo,1] execVM _animscript;
				};
			} foreach CUP_WATERVEHICLES_FOLDABLE;

			if (_isCUPLHD) then {
				_cargo attachTo [_ship, [0,0,(_boundingBox select 2)/2], _selection];
				_cargo setVariable ["CUP_WaterVehicles_LHD_respawnPosition", _selection, true];

				//Add catapult
				if (_cargo isKindOf "air") then {

					[_cargo,["<t color=""#ff1111"">Steam Catapult</t>",{
						_target = (_this select 0);
						driver (_target) action ["ENGINEON", _target];
						addCamShake [5, 4, 15];
						for [{_i=1},{_i<=50},{_i=_i+5}] do {
							_target setvelocity [_i* sin (getdir _target),_i * cos (getdir _target),.15];
							sleep 0.02;
						};
						},[],1,true,true,"action","(driver _target == _this) && (isEngineOn _target) &&(_target distance2D (missionNamespace getVariable ['MCC_startfly',[0,0,0]])<15)"]] remoteExec ["addAction",0];
				};

			} else {
				_selection = call compile _selection;
				_selection set [2,(_selection select 2) + (_boundingBox select 2)/2];
				_cargo attachTo [_ship, _selection];
			};


			while {!(isnull attachedTo _cargo)} do {detach _cargo; sleep .1};
			_cargo setDir _direction;
			[_cargo] call MCCMK_fnc_spawnAnchor;
			["zeusAdd", [[_cargo], true, true]] remoteExec ["MCC_fnc_secAction", 2, false];
			private _paid = switch (_operator) do {case 1: {["res", [_costAmmo, _costRepair, _costFuel]]}; case 2: {["cr", _costValor]}; default {["free", 0]}};
			if ((_paid select 0) != "free") then {_cargo setVariable ["MCCMK_bought", [_paid select 0, _paid select 1, getPlayerUID player, playerSide, name player], true]};
			private _pl = uiNamespace getVariable ["MCCMK_lhdPurchases", []];
			_pl pushBack [_cargo, _paid select 0, _paid select 1, getPosASL _cargo];
			uiNamespace setVariable ["MCCMK_lhdPurchases", _pl];

			waitUntil {isTouchingGround _cargo};
			sleep 5;
			_cargo allowDamage true;

			/*
			if (_isCUPLHD) then {
				_cargo setFuel 0;

				// Get display name
				_displayName = getText (configFile >> "CfgVehicles" >> _vehicleClass >> "displayName");

				// For each vehicle add an action to detach from the ship - MP compliant
				[_cargo,[format ["%1 %2",localize "STR_CUP_CFG_RELEASEVEHICLE", _displayName], {_this remoteExec ["CUP_fnc_detachFromShip", _this select 0, false];},nil, 1.5, false, true]] remoteExec ["addAction", 0, true];
			};
			*/
		};
	};

	case "close":
	{
		{_x ctrlShow true} forEach (uiNamespace getVariable ["MCCMK_lhdSlotBtns", []]);
		_ctrlPos set [2,0];
		_ctrlPos set [3,0];
		_ctrl ctrlSetPosition _ctrlPos;
		_ctrl ctrlCommit 0.1;
	};
};


//spawn Button
_ctrl = _display displayCtrl 2400;
_ctrl ctrlRemoveAllEventHandlers "MouseButtonUp";
_ctrl ctrlAddEventHandler ["MouseButtonUp",format ["['spawn',%1,'%2', %3] spawn MCC_fnc_LHDspawnVehicle;",_deck, _selection, _operator]];

//Close
_ctrl = _display displayCtrl 2401;
_ctrl ctrlRemoveAllEventHandlers "MouseButtonUp";
_ctrl ctrlAddEventHandler ["MouseButtonUp","['close'] spawn MCC_fnc_LHDspawnVehicle"];