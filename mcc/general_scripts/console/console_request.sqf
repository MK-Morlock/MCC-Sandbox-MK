// By: Shay_gman
// Version: 1.1 (May 2012)
#define mcc_playerConsole_IDD 2993

#define MCC_ConsoleCASAvailableTextBox_IDD 9100
#define MCC_ConsoleEvacFlyHightComboBox_IDD 9101
#define MCC_ConsoleEvacApproachComboBox_IDD 9102
#define MCC_ConsoleEvacTypeText_IDD 9103
#define MCC_ConsoleAirdropAvailableTextBox_IDD 9104

disableSerialization;
private _mccdialog = controlNull;
private _comboBox = controlNull;
private _counter = 0;
private _displayname = "";
private "_index";
private "_array";
private _arrayName = "";
private "_cost";
private "_selected";
private _available = false;
params ["_type"];
_mccdialog = findDisplay mcc_playerConsole_IDD;
_available = false;
//Slide the folder back in so the map can be clicked (Supply Drop 2020, CAS 2010)
[[2020, 2010] select (_type == 1)] call MCC_fnc_consoleFolderClose;

switch (_type) do {
	//AirDrop
   	case 0:	{
		_arrayName	= format ["MCC_ConsoleAirdropArray%1",side player];
		_array = missionNameSpace getVariable [_arrayName,[]];

		if (count _array > 0) then {
			_index = lbCurSel MCC_ConsoleAirdropAvailableTextBox_IDD;
			_selected = _array select _index;

			MCC_spawnkind = [(_selected select 0) select 0];
			MCC_planeType = [str (side player)];
			missionNamespace setVariable ["MCC_airdropIsParachute",(_selected select 2)];

			_cost = missionNamespace getVariable [str _selected,[]];

			//a buyable asset
			if (count _cost > 0) then {
				{
					_available = [playerSide, _x] call MCC_fnc_checkRes;
					if (!_available) exitWith {hint "Not Enough Resources"; sleep 5; hintSilent ""};
				} foreach _cost;
			} else {
				_available = true;
			};


			if (_available) exitWith {

				//remove resources
				MCCMK_consolePending = [_cost, _arrayName, +_selected];

				//supply drop with no helicopter simulation
				if ((toLower (MCC_planeType select 0)) == "") then {
					hint "Left click on the map, hold and drag the cursor to mark the target and the direction it comes in from";
				} else {
					hint "Left click on the map,hold and drag the cursor to mark the area and direction of the Air Support";
				};

				MCC_CASrequestMarker = true;

				//fill list box for Airdrop Types
				_comboBox = _mccdialog displayCtrl MCC_ConsoleAirdropAvailableTextBox_IDD;
				lbClear _comboBox;
				_counter = 0;
				{
					_counter = _counter + 1;
					_displayname = format ["%1: %2", _counter, ((((_x select 0) select 0) apply {getText (configFile >> "CfgVehicles" >> _x >> "displayname")}) joinString ", ")];
					_displayname = _displayname;
					_pic = if (!(_x select 2 isEqualTo 1) || (_x isEqualTo true)) then {"\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa"} else {"\A3\ui_f\data\map\markers\handdrawn\pickup_CA.paa"};
					_index = _comboBox lbAdd _displayname;
					_comboBox lbSetPictureRight [_index, _pic];

					//if we have a cost show the cost
					_cost = missionNamespace getVariable [str _x,[]];
					if (count _cost > 0) then {
						private _str = "";
						{
							_str = _str + (toUpper ((_x select 0) select [0, 1])) + ((_x select 0) select [1]) + " x " + str (_x select 1) + " ";
						} forEach _cost;

						_comboBox lbSetTooltip [_index, _str];

						private _available = false;
						{
							_available = [playerSide, _x] call MCC_fnc_checkRes;
							if (!_available) exitWith {_comboBox lbSetColor [_index, [0.311,0.311, 0.311, 0.8]]};
						} foreach _cost;
					};
				} foreach (missionNameSpace getVariable [_arrayName,[]]);
				_comboBox lbSetCurSel 0;

			};
		};
	};

	//CAS
    case 1: {
		_arrayName	= format ["MCC_CASConsoleArray%1",side player];
		_array = missionNameSpace getVariable [_arrayName,[]];

		if (count _array > 0) then {
			_index = lbCurSel MCC_ConsoleCASAvailableTextBox_IDD;
			_selected = _array select _index;

			if ((toLower ((_selected select 0) select 0)) == "ac-130" && {alive (missionNamespace getVariable ["MCC_ACConsoleUp", objNull])}) exitWith {[3] execVM format ["%1mcc\general_scripts\console\conoleSwitchMenu.sqf", MCC_path]};
			MCC_spawnkind	= [(_selected select 0) select 0];
			MCC_planeType 	= [(_selected select 1) select 0];

			_cost = missionNamespace getVariable [str _selected,[]];

			//a buyable asset
			if (count _cost > 0) then {
				{
					_available = [playerSide, _x] call MCC_fnc_checkRes;
					if (!_available) exitWith {hint "Not Enough Resources"; sleep 5; hintSilent ""};
				} foreach _cost;
			} else {
				_available = true;
			};

			if (_available) exitWith {
				//remove resources
				MCCMK_consolePending = [_cost, _arrayName, +_selected];
				if ((toLower (MCC_spawnkind select 0)) == "cruise missile") then {
					["Left click on the map at the target, hold and drag towards where the missile comes from"] call MCC_fnc_hintBrief;
				} else {if ((toLower (MCC_spawnkind select 0)) in ["uav","ac-130"]) then {
					hint "Left click on the map, hold and drag the cursor to mark the target and the direction it comes in from";
				} else {
					hint "Left click on the map,hold and drag the cursor to mark the area and direction of the Air Support";
				};};

				MCC_CASrequestMarker = true;

				sleep 1;
				//fill list box for CAS Types
				_comboBox = _mccdialog displayCtrl MCC_ConsoleCASAvailableTextBox_IDD;
				lbClear _comboBox;
				{
					_planeName = getText (configFile >> "CfgVehicles" >> (_x  select 1) select 0>> "displayname");
					_pic = getText (configFile >> "CfgVehicles" >> (_x  select 1) select 0>> "picture");
					_displayname = format [" %1",(_x  select 0) select 0];
					_index = _comboBox lbAdd _displayname;
					_comboBox lbSetPictureRight [_index, _pic];

					_cost = missionNamespace getVariable [str _x,[]];
					if (count _cost > 0) then {
						private _str = "";
						{
							_str = _str + (toUpper ((_x select 0) select [0, 1])) + ((_x select 0) select [1]) + " x " + str (_x select 1) + " ";
						} forEach _cost;

						_comboBox lbSetTooltip [_index, _str];

						private _available = false;
						{
							_available = [playerSide, _x] call MCC_fnc_checkRes;
							if (!_available) exitWith {_comboBox lbSetColor [_index, [0.311,0.311, 0.311, 0.8]]};
						} foreach _cost;
					} else {
						_comboBox lbSetTooltip [_index, _planeName];
					};

				} foreach (missionNameSpace getVariable [_arrayName,[]]);
				_comboBox lbSetCurSel 0;
			};
		};
	};
};



