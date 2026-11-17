//==================================================================MCC_fnc_logTruckRefresh======================================================================================
// Refresh the logistics dialog
//===============================================================================================================================================================================
#include "..\defines.sqf"

#define MCC_LOGISTICS_LOAD_TRUCK (uiNamespace getVariable "MCC_LOGISTICS_LOAD_TRUCK")
#define MCC_loadTruckC1 (uiNamespace getVariable "MCC_loadTruckC1")

#define MCC_loadTruckSupplies (uiNamespace getVariable "MCC_loadTruckSupplies")
#define MCC_loadTruckRepair (uiNamespace getVariable "MCC_loadTruckRepair")
#define MCC_loadTruckFuel (uiNamespace getVariable "MCC_loadTruckFuel")

#define MCC_loadTruckOutpot (uiNamespace getVariable "MCC_loadTruckOutpot")
#define MCC_loadTruckOutpot2 (uiNamespace getVariable "MCC_loadTruckOutpot2")
#define MCC_loadTruckOutpot3 (uiNamespace getVariable "MCC_loadTruckOutpot3")

private _loadedCrates = [];
private _loadedCratesIDC = [];
private "_ctrl";
private _displayname = "";
private "_truck";
private _isHeli = false;
private _startLoad = false;
private "_pos";
disableSerialization;
_isHeli = param [0,false,[false]];
_truck = vehicle player;
_startLoad = player getVariable ["mcc_logTruck_screenStart",false];

//If not next to HQ center UI
if (!_startLoad) then {
	MCC_loadTruckC1 ctrlShow false;
	{
		_pos = ctrlPosition _x;
		_pos set [1,0.4];
		_x ctrlSetPosition _pos;
		_x ctrlCommit 0;
		_x ctrlRemoveAllEventHandlers "ButtonClick";
		_x ctrlAddEventHandler ["ButtonClick",format ["[%3, %1, _this, %2] call MCC_fnc_logTruckAdd",_startLoad, _isHeli, ctrlText _x == ""]];
	} foreach [MCC_loadTruckOutpot,MCC_loadTruckOutpot2,MCC_loadTruckOutpot3];
};

//clear
sleep 0.1;
MCC_loadTruckOutpot2 ctrlsetText "";

if (_isHeli && !(isnull getSlingLoad _truck)) then {
	{
		_displayname 	= getText(configFile >> "CfgVehicles">> typeof _x >> "displayname");
		MCC_loadTruckOutpot2 ctrlsetText _displayname;
	} foreach [getSlingLoad _truck];
} else {
	//(MK) one slot per crate the vehicle takes (MCCMK_fnc_crateSlots), showing what's on it now - read from the vehicle,
	// so crates loaded on foot show too. A filled slot takes that crate off; an empty one adds a crate.
	private _disp = MCC_LOGISTICS_LOAD_TRUCK;
	private _crates = [_truck] call MCCMK_fnc_crateOnTruck;
	_truck setVariable ["mcc_supplyTruckCurrentLoad", _crates apply {typeOf _x}, true];
	{_x ctrlShow false} forEach [MCC_loadTruckOutpot,MCC_loadTruckOutpot2,MCC_loadTruckOutpot3];
	{ctrlDelete _x} forEach (uiNamespace getVariable ["MCCMK_slotCtrls", []]);
	private _n = [_truck] call MCCMK_fnc_crateSlots;
	private _cols = _n min 4;
	private _rows = ceil (_n / 4);
	private _gap = 0.006 * safezoneW;
	private _w = ((0.32 * safezoneW) - (_cols - 1) * _gap) / _cols;
	private _h = if (_rows > 1) then {0.037 * safezoneH} else {0.077 * safezoneH};
	private _y0 = if (_startLoad) then {0.588 * safezoneH + safezoneY} else {0.4};
	private _made = [];
	for "_i" from 0 to (_n - 1) do {
		private _c = _disp ctrlCreate [["MCC_RscButtonRound", "MCC_RscButtonRound3D"] select (profileNamespace getVariable ["MCC_consoleButtons", false]), 9330 + _i];	//(MK) the console look
		_c ctrlSetPosition [(0.34 * safezoneW + safezoneX) + (_i mod 4) * (_w + _gap), _y0 + (floor (_i / 4)) * (_h + 0.004 * safezoneH), _w, _h];
		_c ctrlCommit 0;
		private _crate = _crates param [_i, objNull];
		if (isNull _crate) then {
			_c ctrlSetText "Empty";
			_c ctrlSetTextColor [0.55, 0.56, 0.58, 1];
		} else {
			_c ctrlSetText getText (configFile >> "CfgVehicles" >> typeOf _crate >> "displayName");
		};
		_c ctrlAddEventHandler ["ButtonClick", format ["[%1, %2, _this, false, %3] call MCC_fnc_logTruckAdd", isNull _crate, _startLoad, _i]];
		_made pushBack _c;
	};
	uiNamespace setVariable ["MCCMK_slotCtrls", _made];
};

//(MK) Adjust crates: only when MCC placed crates on the bed (vehicle-in-vehicle cargo is placed by Arma)
(MCC_LOGISTICS_LOAD_TRUCK displayCtrl 9320) ctrlShow (((attachedObjects (vehicle player)) findIf {(_x getVariable ["MCCMK_bedSlot", -1]) >= 0}) >= 0);
