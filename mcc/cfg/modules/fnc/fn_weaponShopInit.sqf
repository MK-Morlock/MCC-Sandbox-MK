//==================================================================MCC_fnc_weaponShopInit============================================================================
// Sync with triggers to create MCC zones
//==============================================================================================================================================================
private _module = objNull;
private _text = "";
private _objects = [];
private "_object";
private "_box";
private _prices = 0;
private _persistent = false;
private _persistentName = "";
private "_pos";
private _resualt = [];
#define MCC_SHOP_ICON	"\a3\ui_f\data\IGUI\Cfg\Actions\reammo_ca.paa"

_module = param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

_pos = getpos _module;

//did we get here from the 2d editor?
// (it used to test for a class "MCC_Module_createShop" that does not exist, so a shop placed in Eden never did anything;
//  an Eden-placed module carries its attribute values, a Zeus-placed one does not)
if (!isNil {_module getVariable "tittle"} || {count (synchronizedObjects _module) > 0 && {isNull curatorcamera}}) then {

	if (isServer) then {

		_text = _module getVariable ["tittle","Open Shop"];
		_prices = _module getVariable ["prices",0.5];
		if (_prices > 1) then {_prices = _prices / 100};
		if (_prices <= 0) then {_prices = 0.5};
		_persistent = _module getVariable ["persistent",false];
		_persistentName =  _module getVariable ["persistentName","testShop"];

		//Find all the boxes and place holders
		_objects = [];
		{
			if (_x isKindOf "ReammoBox_F" || _x isKindOf "ReammoBox") then {
				_box = _x;
			} else {
				_objects pushBack _x;
			};
		} forEach (synchronizedObjects _module);

		if (isNil "_box") exitWith {
			["WARN", "fn_weaponShopInit", "Weapon shop module at %1 is not synced to an ammo box - shop not created", [_pos]] call MCC_fnc_log;
		};

		_box enableSimulation false;
		_box allowDamage false;
		_box setVariable ["MCC_vaultNoInventory",true,true];	//stock is bought/sold through the shop dialog only

		// Synced only to the ammo box: the box itself is the shop (it used to be hidden with nothing to open it).
		// Synced to other objects too (a table, a unit...): those open the shop and the box stays hidden as its stock.
		if (count _objects == 0) then {
			_objects = [_box];
		} else {
			_box hideObjectGlobal true;
		};

		//If persistent DB
		if (_persistent) then {
			_box setVariable ["MCC_virtualBox",true,true];
			_box setVariable ["MCC_virtualBoxSaveName",_persistentName,true];
		};

		//add objects actions
		{
			_object = _x;

			[
				 _object,
				 _text,
				 MCC_SHOP_ICON,
				 MCC_SHOP_ICON,
				 "(alive _target) && (_target distance _this < 5)",
				 "(alive _target) && (_target distance _this < 5)",
				 {},
				 {},
				 {(_this select 3) spawn MCC_fnc_mainBoxInit},
				 {},
				 [_box,_prices],
				 1,
				 100,
				 false,
				 false
			] remoteExec ["BIS_fnc_holdActionAdd", 0, _object];
		} forEach _objects;
	};
} else {

	//Not curator exit
	if (!(local _module) || isnull curatorcamera) exitWith {};

	_object = missionNamespace getVariable ["MCC_curatorMouseOver",[]];

	//if no object selected or not a vehicle
	if (count _object <2) exitWith {
		[objNull, localize "STR_GENERAL_ERROR_NOAMMOBOXSELECTED"] call bis_fnc_showCuratorFeedbackMessage;
		deleteVehicle _module
	};
	_object = _object select 1;

	if !(_object isKindOf "ReammoBox_F" || _object isKindOf "ReammoBox") exitWith {systemchat "No ammo box selected"; deleteVehicle _module};

	//If curator
	_resualt = ["Weapons Shop",[
				["Prices",10]
			  ]] call MCC_fnc_initDynamicDialog;

	if (count _resualt == 0) exitWith {deleteVehicle _module};


	_object enableSimulation false;
	_object allowDamage false;
	[_object, true] remoteExec ["hideObjectGlobal",2];

	_box = (typeOf _object) createVehicle _pos;
	_box setPos _pos;
	_box setDir (getDir _object);
	clearItemCargoGlobal _box;
	clearMagazineCargoGlobal _box;
	clearWeaponCargoGlobal _box;
	clearBackpackCargoGlobal _box;
	_box enableSimulation false;
	_box allowDamage false;
	_box setVariable ["MCC_vaultNoInventory",true,true];	//stock is bought/sold through the shop dialog only
	_object setVariable ["MCC_vaultNoInventory",true,true];


	//get prices
	_prices = ((_resualt select 0)/10) max 0.1;

	//Spawn action
	[
		 _box,
		 "Open Shop",
		 MCC_SHOP_ICON,
		 MCC_SHOP_ICON,
		 "(alive _target) && (_target distance _this < 5)",
		 "(alive _target) && (_target distance _this < 5)",
		 {},
		 {},
		 {_arguments spawn MCC_fnc_mainBoxInit},
		 {},
		 [_object,_prices],
		 1,
		 100,
		 false,
		 false
	] remoteExec ["BIS_fnc_holdActionAdd", 0, _box];
};

deleteVehicle _module;
