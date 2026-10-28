/*======================================================MCC_fnc_loadGear=================================================================================
	Equip `player` from a saved gear array.
	Called from fn_loadPlayer.sqf (DB persistence restore) and general_scripts\save_gear.sqf
	(keep gear across respawn, on by default via MCC_saveGear).

	CLIENT ONLY - operates on `player`.

	<IN> ARRAY, in this exact order (matches fn_savePlayer.sqf / fn_loadPlayer.sqf / save_gear.sqf):
		0	STRING	goggles
		1	STRING	headgear
		2	STRING	uniform
		3	STRING	vest
		4	STRING	backpack
		5	ARRAY	backpack items
		6	ARRAY	primary weapon magazine(s)   (primaryWeaponMagazine returns an ARRAY; a STRING is also accepted)
		7	ARRAY	secondary weapon magazine(s)
		8	ARRAY	handgun magazine(s)
		9	ARRAY	assigned items (map, compass, watch, radio, GPS, NVG, binoculars ...)
		10	ARRAY	uniform items
		11	ARRAY	vest items
		12	STRING	primary weapon
		13	STRING	secondary weapon
		14	STRING	handgun
		15	ARRAY	primary weapon attachments
		16	ARRAY	secondary weapon attachments
		17	ARRAY	handgun attachments

	<OUT> BOOL - true if the gear was applied
//==========================================================================================================================================*/

if (!hasInterface) exitWith {false};

params [
	["_goggles", "", [""]],
	["_headgear", "", [""]],
	["_uniform", "", [""]],
	["_vest", "", [""]],
	["_backpack", "", [""]],
	["_backpackItems", [], [[]]],
	["_primaryMags", [], [[], ""]],
	["_secondaryMags", [], [[], ""]],
	["_handgunMags", [], [[], ""]],
	["_assignedItems", [], [[]]],
	["_uniformItems", [], [[]]],
	["_vestItems", [], [[]]],
	["_primaryWeapon", "", [""]],
	["_secondaryWeapon", "", [""]],
	["_handgunWeapon", "", [""]],
	["_primaryWeaponItems", [], [[]]],
	["_secondaryWeaponItems", [], [[]]],
	["_handgunItems", [], [[]]]
];

// A saved gear array with nothing in it at all - keep the current loadout rather than strip the player.
if ((_uniform == "") && (_vest == "") && (_backpack == "") && (_primaryWeapon == "") && (_secondaryWeapon == "") && (_handgunWeapon == "")) exitWith {
	["WARN", "fn_loadGear", "saved gear array is empty - keeping current loadout"] call MCC_fnc_log;
	false
};

// Valid, non-empty classname?
private _fnc_valid = {
	params [["_class", "", [""]]];
	_class != ""
};

// Normalise a magazine slot (array or single string) into an array of non-empty classnames
private _fnc_mags = {
	params [["_mags", [], [[], ""]]];
	if (_mags isEqualType "") then {_mags = [_mags]};
	_mags select {(_x isEqualType "") && {_x != ""}}
};

removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeUniform player;
removeVest player;
removeBackpack player;
removeHeadgear player;
removeGoggles player;

if ([_uniform] call _fnc_valid) then {player forceAddUniform _uniform};
if ([_vest] call _fnc_valid) then {player addVest _vest};
if ([_backpack] call _fnc_valid) then {
	player addBackpack _backpack;
	clearAllItemsFromBackpack player;		// backpacks can come pre-filled from config
};
if ([_headgear] call _fnc_valid) then {player addHeadgear _headgear};
if ([_goggles] call _fnc_valid) then {player addGoggles _goggles};

// Weapons: add the magazine(s) first so addWeapon loads them, then the attachments
{
	_x params ["_weapon", "_mags", "_attachments", "_slot"];
	if ([_weapon] call _fnc_valid) then {
		{player addMagazine _x} forEach ([_mags] call _fnc_mags);
		player addWeapon _weapon;
		{
			if ((_x isEqualType "") && {_x != ""}) then {
				switch (_slot) do {
					case 0: {player addPrimaryWeaponItem _x};
					case 1: {player addSecondaryWeaponItem _x};
					case 2: {player addHandgunItem _x};
				};
			};
		} forEach _attachments;
	};
} forEach [
	[_primaryWeapon, _primaryMags, _primaryWeaponItems, 0],
	[_secondaryWeapon, _secondaryMags, _secondaryWeaponItems, 1],
	[_handgunWeapon, _handgunMags, _handgunItems, 2]
];

// Container contents (containers exist now)
{if ((_x isEqualType "") && {_x != ""}) then {player addItemToUniform _x}} forEach _uniformItems;
{if ((_x isEqualType "") && {_x != ""}) then {player addItemToVest _x}} forEach _vestItems;
{if ((_x isEqualType "") && {_x != ""}) then {player addItemToBackpack _x}} forEach _backpackItems;

// Assigned items: binoculars/rangefinders/designators are weapons (type 4096), everything else is linked to its slot
{
	if ((_x isEqualType "") && {_x != ""}) then {
		if (getNumber (configFile >> "CfgWeapons" >> _x >> "type") == 4096) then {
			player addWeapon _x;
		} else {
			player linkItem _x;
		};
	};
} forEach _assignedItems;

// Put the primary weapon in the player's hands (as the original MCC did), on its main muzzle
private _primary = primaryWeapon player;
if (_primary != "") then {
	player selectWeapon _primary;
	private _muzzles = getArray (configFile >> "CfgWeapons" >> _primary >> "muzzles");
	if ((count _muzzles > 0) && {(_muzzles select 0) != "this"}) then {player selectWeapon (_muzzles select 0)};
};

true
