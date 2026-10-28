params [["_sel", -1, [0]]];
disableSerialization;
isNil {
	private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
	if (isNull _d) exitWith {};
	if (isNil "MCCMK_adMem") then {MCCMK_adMem = createHashMap};
	if (isNil "MCCMK_massCache") then {MCCMK_massCache = createHashMap};
	if (isNil "MCCMK_vivCache") then {MCCMK_vivCache = createHashMap};
	private _cType = _d displayCtrl 1031;
	private _cAir = _d displayCtrl 1038;
	private _c = _d displayCtrl 1032;
	private _type = if (_sel >= 0) then {_sel} else {lbCurSel _cType};
	if (_type < 0) exitWith {};
	private _airI = lbCurSel _cAir;
	private _air = if (_airI >= 0) then {_cAir lbData _airI} else {""};
	private _mode = missionNamespace getVariable ["MCC_airdropIsParachute", 0];
	if (_mode == 1 && {_air != ""} && {_air isKindOf "Plane"}) then {
		_mode = 0;
		MCC_airdropIsParachute = 0;
		[3, 0] execVM (MCC_path + "mcc\general_scripts\CAS\airdropReq.sqf");
		(_d displayCtrl 1037) lbSetCurSel 0;
	};
	private _sig = format ["%1|%2|%3", _type, _mode, _air];
	private _old = _c getVariable ["MCC_airdropSig", ""];
	if (_old != "" && {lbCurSel _c >= 0}) then {MCCMK_adMem set ["class|" + _old, _c lbData (lbCurSel _c)]};
	MCCMK_adMem set ["type", _type];
	MCCMK_adMem set ["air", _air];
	MCCMK_adMem set ["mode", _mode];
	MCCMK_adAircraft = _air;
	if (_sel == -2 && {_old == _sig}) exitWith {};
	private _sideS = missionNamespace getVariable ["mcc_sidename", "west"];
	private _carrier = _air;
	if (_carrier == "") then {
		_carrier = MCCMK_adMem getOrDefault ["auto|" + toLower _sideS, ""];
		if (_carrier == "") then {_carrier = [_sideS] call MCCMK_fnc_supplyAutoHeli; MCCMK_adMem set ["auto|" + toLower _sideS, _carrier]};
	};
	private _cfgCar = configFile >> "CfgVehicles" >> _carrier;
	private _arr = switch (_type) do {
		case 0: {missionNamespace getVariable ["U_GEN_CAR", []]};
		case 1: {missionNamespace getVariable ["U_GEN_TANK", []]};
		case 2: {missionNamespace getVariable ["U_GEN_MOTORCYCLE", []]};
		case 3: {missionNamespace getVariable ["U_GEN_SHIP", []]};
		default {missionNamespace getVariable ["U_AMMO", []]};
	};
	private _kind = ["Car", "Tank", "", "Ship", ""] param [_type, ""];
	if (_kind != "") then {_arr = _arr select {(_x isEqualType []) && {(_x select 1) isEqualType ""} && {(_x select 1) isKindOf _kind}}};
	private _fnc_mass = {
		params ["_cl"];
		private _m = MCCMK_massCache getOrDefault [_cl, -1];
		if (_m < 0) then {
			private _o = _cl createVehicleLocal [0, 0, 3000];
			_o enableSimulation false;
			_m = getMass _o;
			deleteVehicle _o;
			MCCMK_massCache set [_cl, _m];
		};
		_m
	};
	if (_mode == 0 && {_type < 4}) then {
		if !(isClass (_cfgCar >> "VehicleTransport" >> "Carrier")) then {_arr = []} else {
			private _need = (_arr select {(_x isEqualType []) && {getNumber (configFile >> "CfgVehicles" >> (_x select 1) >> "VehicleTransport" >> "Cargo" >> "canBeTransported") == 1}}) apply {_x select 1};
			_need = _need select {!((_carrier + "|" + _x) in MCCMK_vivCache)};
			if (count _need > 0) then {
				private _cv = _carrier createVehicleLocal [0, 0, 3000];
				_cv enableSimulation false;
				{
					private _o = _x createVehicleLocal [400, 0, 3000];
					_o enableSimulation false;
					MCCMK_vivCache set [_carrier + "|" + _x, (_cv canVehicleCargo _o) param [1, false]];
					deleteVehicle _o;
				} forEach _need;
				deleteVehicle _cv;
			};
			_arr = _arr select {(_x isEqualType []) && {MCCMK_vivCache getOrDefault [_carrier + "|" + (_x select 1), false]}};
		};
	};
	if (_mode == 1) then {
		private _maxSling = if (_carrier isKindOf "Helicopter") then {getNumber (_cfgCar >> "slingLoadMaxCargoMass")} else {0};
		_arr = if (_maxSling <= 0) then {[]} else {
			_arr select {
				(_x isEqualType []) && {count (getArray (configFile >> "CfgVehicles" >> (_x select 1) >> "slingLoadCargoMemoryPoints")) > 0} && {([_x select 1] call _fnc_mass) <= _maxSling}
			}
		};
	};
	lbClear _c;
	{
		private _i = _c lbAdd format ["%1", (_x select 3) select 0];
		if (_type < 4) then {_c lbSetPicture [_i, (_x select 3) select 1]};
		_c lbSetData [_i, _x select 1];
	} forEach _arr;
	private _want = MCCMK_adMem getOrDefault ["class|" + _sig, ""];
	private _pick = 0;
	if (_want != "") then {for "_i" from 0 to ((lbSize _c) - 1) do {if ((_c lbData _i) == _want) exitWith {_pick = _i}}};
	_c lbSetCurSel _pick;
	_c setVariable ["MCC_airdropSig", _sig];
	[] call MCCMK_fnc_airdropLive;
	["DEBUG", "supplyDrop", "class list filled: %1 | %2 | aircraft %3 | %4 items", [["Vehicles", "Tracked", "Motorcycles", "Ships", "Ammo"] param [_type, "?"], ["parachute", "slingload"] select (_mode == 1), [_carrier + " (automatic)", _carrier] select (_air != ""), count _arr]] call MCC_fnc_log;
};
