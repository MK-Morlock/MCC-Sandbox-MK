#define MCC_AIRDROPTYPECONTROL 1031
#define MCC_AIRDROPCLASSCONTROL 1032
#define MCC_AIRDROPARRAYCONTROL 1033

disableSerialization;
private _indecator = controlNull;
private _array = [];
private _arrayName = "";
private _side = sideUnknown;
private _index = 0;
private _dummy = "";
private _isParachute = false;
params ["_type"];

_side = switch (toLower mcc_sidename) do
		{
			case "west": {west};
			case "east": {east};
			case "guer": {resistance};
			case "civ": {civilian};
		};

//(MK) Taru Pod chosen: a free supply pod for the console's chosen faction - the map's click and drag marks where it
// goes and the direction the Taru comes in from (MCC console map: general_scripts\groupGen\mouseDown.sqf)
if (_type == 0 && {(missionNamespace getVariable ["MCCMK_adMem", createHashMap]) getOrDefault ["pod", false]}) exitWith {
	// (MK) read from the panel itself as Call is pressed (the lists' change events could leave an older choice saved)
	private _pd = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
	private _pi = lbCurSel (_pd displayCtrl 1112);
	if (_pi < 0) then {_pi = MCCMK_adMem getOrDefault ["podType", 0]};
	private _pm = lbCurSel (_pd displayCtrl 1114);
	if (_pm < 0) then {_pm = MCCMK_adMem getOrDefault ["podMethod", 0]};
	private _psm = cbChecked (_pd displayCtrl 1116);
	private _hc = _pd displayCtrl 1118;
	private _ph = if (lbCurSel _hc >= 0) then {_hc lbValue (lbCurSel _hc)} else {MCCMK_adMem getOrDefault ["podHeight", 120]};
	MCCMK_adMem set ["podType", _pi]; MCCMK_adMem set ["podMethod", _pm]; MCCMK_adMem set ["podSmoke", _psm]; MCCMK_adMem set ["podHeight", _ph];
	MCCMK_podReq = [_pi, _pm, _psm, _ph];
	MCC_spawnkind = ["MCCMK_TARUPOD"];
	MCC_planeType = [toLower mcc_sidename];
	MCC_CASrequestMarker = true;
	[format ["%1 pod: left click on the map, hold and drag to mark where it goes and the direction the Taru comes in from.", ((call MCCMK_fnc_podInfo) param [_pi, ["", "Supply"]]) select 1]] call MCCMK_fnc_hint;
};

//If slingload ignore array and call what we have or we didn't fill the array
_isParachute = (missionNamespace getVariable ["MCC_airdropIsParachute",0])==0;
if (_isParachute && {_type in [0,3]} && {count MCC_airDropArray == 0}) exitWith {
	["Current Airdrop is empty: pick something to drop."] call MCCMK_fnc_hint;
};
if ((_type in [0,1] && !_isParachute) || (count MCC_airDropArray == 0)) then {
	_index = lbCurSel ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl MCC_AIRDROPCLASSCONTROL);
	if (_index == -1) exitWith {};

	_dummy = ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl MCC_AIRDROPCLASSCONTROL) lbData _index;
	MCC_airDropArray = [_dummy];
	MCCMK_adLive = true;
};

//CAS with an aircraft that has no suitable attack (empty Type list)
if (_type in [1,2] && {(lbCurSel ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 26)) < 0}) exitWith {
	["This aircraft cannot fly any of the CAS attacks. Pick another aircraft."] call MCCMK_fnc_hint;
};

switch (_type) do
	{
	   case 0:		//AirDrop Car
		{
			MCC_spawnkind = [MCC_airDropArray];
			MCC_planeType = [mcc_sidename];
		};

	    case 1:		//CAS
		{
			MCC_spawnkind	= [((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 26) lbData (lbCurSel ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 26))];
			_indecator 		= (lbCurSel ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 25));
			MCC_planeType 	= [((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 25) lbData _indecator];
		};

		 case 2:	//CAS Add
		{
			MCC_spawnkind	= [((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 26) lbData (lbCurSel ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 26))];

			_indecator 		= (lbCurSel ((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 25));
			MCC_planeType 	= [((uiNamespace getVariable "MCC_groupGen_Dialog") displayCtrl 25) lbData _indecator];
			_arrayName		= format ["MCC_CASConsoleArray%1",mcc_sidename];

			if (MCC_capture_state) then
			{
				MCC_capture_var = MCC_capture_var + FORMAT ['%5 set [count %5,[%1, %2]];
					publicVariable "%5";
					["MCC_fnc_globalExecute", [2,{["MCCNotifications",["%4 CAS available","%3data\ammo_icon.paa",""]] call bis_fnc_showNotification;}], 0, false] call MCC_fnc_secRemote;
					'
					,MCC_spawnkind
					,MCC_planeType
					,MCC_path
					,MCC_spawnkind select 0
					,_arrayName
					];
			}
			else
			{
					mcc_safe = mcc_safe + FORMAT ['%3 set [count %3,[%1, %2]];
					publicVariable "%3";'
					,MCC_spawnkind
					,MCC_planeType
					,_arrayName
					];

					_array = missionNameSpace getVariable [_arrayName,[]];
					_array set [count _array,[MCC_spawnkind, MCC_planeType]];
					missionNameSpace setVariable [_arrayName,_array];
					publicvariable _arrayName;

					["MCC_fnc_globalExecute", [2,compile format ['["MCCNotifications",["%1 CAS available","%2data\ammo_icon.paa",""]] call bis_fnc_showNotification;',MCC_spawnkind select 0,MCC_path]], _side, false] call MCC_fnc_secRemote;
			};
		};

		 case 3:	//Airdrop Add
		{
			MCC_spawnkind		= [MCC_airDropArray];
			MCC_planeType		= ["I_Heli_Transport_02_F"];

			_arrayName		= format ["MCC_ConsoleAirdropArray%1",mcc_sidename];

			if (MCC_capture_state) then
			{
				MCC_capture_var = MCC_capture_var + FORMAT ['%3 set [count %3,[%1, %2, %4]];
					publicVariable "%3";'
					,MCC_spawnkind
					,MCC_planeType
					,_arrayName
					,(missionNamespace getVariable ["MCC_airdropIsParachute",0])
					];
			}
			else
			{
				mcc_safe = mcc_safe + FORMAT ['%3 set [count %3,[%1, %2, %4]];
				publicVariable "%3";'
				,MCC_spawnkind
				,MCC_planeType
				,_arrayName
				,(missionNamespace getVariable ["MCC_airdropIsParachute",0])
				];

				_array = missionNameSpace getVariable [_arrayName,[]];
				_array set [count _array,[MCC_spawnkind, MCC_planeType,(missionNamespace getVariable ["MCC_airdropIsParachute",0])]];
				missionNameSpace setVariable [_arrayName,_array];
				publicvariable _arrayName;
			};
		};
	};

if (_type == 0 || _type == 1) then {
	private _skind = missionNamespace getVariable ["MCC_spawnkind", [""]];
	while {_skind isEqualType []} do {_skind = _skind param [0, ""]};
	if (!(_skind isEqualType "")) then {_skind = ""};
	if (((toLower _skind) find "air patrol") == 0) then {	//(MK)
		["Left click on the map on the side the aircraft should come from, hold and drag to the area it should patrol"] call MCC_fnc_hintBrief;
	} else {if (toLower _skind == "cruise missile") then {
		["Left click on the map, hold and drag: the line shows the direction the cruise missile comes from"] call MCC_fnc_hintBrief;
	} else {
		["Left click on the map, hold and drag the cursor to mark the area and direction of the Air Support"] call MCC_fnc_hintBrief;
	};};
	MCC_CASrequestMarker = true;
	};

if (_type == 2) then {
	[format ["CAS: %1, Plane: %2 Added to player's console",MCC_spawnkind,MCC_planeType]] call MCCMK_fnc_hint;
	//server globalchat format ["%1",MCC_CASConsoleArray];	//debug
	};

if (_type == 3) then {
	[format ["Airdrop: %1, Added to player's console",MCC_spawnkind]] call MCCMK_fnc_hint;
	//server globalchat format ["%1",MCC_ConsoleAirdropArray];	//debug
	};