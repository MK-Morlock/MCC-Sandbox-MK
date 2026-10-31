params [["_entry", "", ["", configNull]]];
private _cfg = if (_entry isEqualType "") then {configFile >> "CfgVehicles" >> _entry} else {_entry};
if (!isClass _cfg) exitWith {""};

private _class = configName _cfg;
private _sim = toLower getText (_cfg >> "simulation");
private _lvc = toLower getText (_cfg >> "vehicleClass");
private _sub = toLower getText (_cfg >> "editorSubcategory");
private _text = _lvc + " " + _sub + " " + toLower _class;

if ((_sim == "soldier" || {_sim == "soldierx"}) && {
	(["target", "virtual", "uav_ai", "uavai", "invisible", "dummy"] findIf {_text find _x >= 0 || {(toLower getText (_cfg >> "displayName")) find _x >= 0}}) >= 0
	|| {getText (_cfg >> "model") in ["", "\A3\Weapons_f\empty", "\A3\Weapons_F\empty.p3d"]}
}) exitWith {""};

private _lcClass = toLower _class;
private _dnRaw = getText (_cfg >> "displayName");
private _dnLoc = toLower (if ((_dnRaw select [0, 1]) == "$") then {localize (_dnRaw select [1])} else {_dnRaw});
if ((_dnLoc find "invisible") >= 0 || {((toLower getText (_cfg >> "model")) find "invisible") >= 0} || {(_lcClass find "invisibletarget") >= 0}
	|| {(_lcClass find "targetsoldier") >= 0} || {(_lcClass find "target_vehicle") >= 0} || {(_lcClass find "targetvehicle") >= 0}
	|| {getText (_cfg >> "model") in ["", "\A3\Weapons_f\empty", "\A3\Weapons_F\empty.p3d"]}
) exitWith {""};

private _known = ["Men","MenDiver","MenRecon","MenSniper","MenSupport","MenStory","Car","Armored","Air","Autonomous","Support","Ship","Submarine","Static"];
private _vc = getText (_cfg >> "vehicleClass");
private _i = _known findIf {_x == _vc};
if (_i >= 0) exitWith {_known select _i};


switch (true) do {
	case (_sim == "soldier" || {_sim == "soldierx"}): {
		switch (true) do {
			case (_text find "vr" == 0 || {_text find "_vr" >= 0} || {_lvc find "story" >= 0}): {"MenStory"};
			case (_text find "diver" >= 0): {"MenDiver"};
			case (_text find "sniper" >= 0): {"MenSniper"};
			case (_text find "recon" >= 0 || {_text find "special" >= 0}): {"MenRecon"};
			case (_lvc find "support" >= 0): {"MenSupport"};
			default {"Men"};
		}
	};
	case (getNumber (_cfg >> "isUav") == 1): {"Autonomous"};
	case (_class isKindOf "StaticWeapon"): {"Static"};
	case (_sim in ["car","carx","motorcycle"]): {if (getNumber (_cfg >> "transportRepair") > 0 || {getNumber (_cfg >> "transportFuel") > 0} || {getNumber (_cfg >> "transportAmmo") > 0}) then {"Support"} else {"Car"}};
	case (_sim in ["tank","tankx"]): {"Armored"};
	case (_sim in ["helicopter","helicopterx","helicopterrtd","airplane","airplanex"]): {"Air"};
	case (_sim in ["ship","shipx"]): {"Ship"};
	case (_sim in ["submarine","submarinex"]): {"Submarine"};
	default {""};
}
