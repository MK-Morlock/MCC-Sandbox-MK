/*======================================================================= MCC_fnc_logisticsWithdrawBox =========================================================================

	withdraw a box from HQ and reduce the resources - always local to the player

	<IN>
		0:		SIDE - the side to withdraw resources from
		1:		STRING - resources as: "ammo", "materials" ,"fuel"


	<OUT>
		Nothing
*/
#include "..\defines.sqf"
private _cratesType = [];
private "_res";
private _str = "";

params [
	["_side",sideLogic,[sideLogic,""]],
	["_boxType","",[""]]
];

if (_side isEqualType "") then {

	switch (_side) do
	{
		case "EAST": {_side = east};
		case "WEST": {_side = west};
		case "GUER": {_side = resistance};
		case "CIV": {_side = civilian};
		default	{_side = sideLogic};
	};
};

if (_side == sideLogic || _boxType == "") exitWith {};


//Find crates types
_cratesType = missionNamespace getVariable ["MCC_logisticsCrates_TypesWest",[]];
if (count _cratesType <=0) exitWith {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC Logistics: Error MCC_logisticsCrates_TypesWest not defined"}};

//Get side resources
_res = (missionNamespace getVariable format ["MCC_res%1",_side]);
_str = "";

switch (tolower _boxType) do
{
	case "ammo":
	{
		if ((_res select 0) >= CRATE_COST) then {

			//Spawn box
			_str = format ["-%1 <img color='#E60000' image='%2' />",CRATE_COST, MCC_ICONAMMO];
			_box = (_cratesType select 0) createVehicle position player;

			//reduce cost
			_res set [0, (_res select 0) - CRATE_COST];
		} else {
			_str = "Not Enough Ammo";
		};
	};

	case "materials":
	{
		if ((_res select 1) >= CRATE_COST) then {

			//Spawn box
			_str = format ["-%1 <img color='#0080E6' image='%2' />",CRATE_COST, MCC_ICONMETERIALS];
			_box = (_cratesType select 1) createVehicle position player;

			//reduce cost
			_res set [1, (_res select 1) - CRATE_COST];
		} else {
			_str = "Not Enough Supplies";
		};
	};

	case "fuel":
	{
		if ((_res select 2) >= CRATE_COST) then {

			//Spawn box
			_str = format ["-%1 <img color='#00E680' image='%2' />",CRATE_COST, MCC_ICONFUEL];
			_box = (_cratesType select 2) createVehicle position player;

			//reduce cost
			_res set [2, (_res select 2) - CRATE_COST];		} else {
			_str = "Not Enough Fuel";
		};
	};
};

missionNamespace setVariable [format ["MCC_res%1",_side],_res];
publicVariable format ["MCC_res%1",_side];

if (_str != "") then {
	playsound "MCC_pop";
	_null = [_str,0,0.5,2,0.1,0.0] spawn bis_fnc_dynamictext;
};