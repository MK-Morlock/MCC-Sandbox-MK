//==================================================================MCC_fnc_makeUnitsArray================================================================================
// returns a unit array consist of all the units from the given function and simulation in format [_cfgclass,_vehicleDisplayName]
// Example:_unitsArray	= [_faction ,_sim,_classType] call MCC_fnc_makeUnitsArray;
// faction = string, the faction to search in: "CIV" , "USMC", "INS", "CDF", "RU", "GUE" or "all" to all factions
// _sim = string, simulation type: "soldier", "car", "motorcycle", "tank", "helicopter", "airplane", "ship", "parachute"
// _classType = string, class type "men","car","ship","sumarine"
//========================================================================================================================================================================
private _CfgVehicles = configNull;
private _i = 0;
private _CfgVehicle = configNull;
private _simulation = "";
private _simTypesUnits = "";
private _idx = 0;
private _faction = "";
private _vehicleDisplayName = "";
private _cfgclass = configNull;
private _cfgFaction = "";
private _unitsArray = [];
private _vehicleClass = "";
private _classType = "";
private _notArmed = false;
private _dlc = "";

_faction			=  toLower (param [0, "", [""]]);
_simTypesUnits		=  toLower (param [1, "", [""]]);
_classType			=  toLower (param [2, "", [""]]);
_notArmed 			=  param [3, true, [true]]; 	//false for only armed units

if (_faction == "" || _simTypesUnits == "") exitWith {};

_idx      			= 0;
_unitsArray			=[];

//Result kept for the game session (same faction, simulation, category and armed rule = same list)
private _resultKey = format ["MCC_unitsArray_%1_%2_%3_%4", _faction, _simTypesUnits, _classType, _notArmed];
private _cachedResult = uiNamespace getVariable _resultKey;
if (!isNil "_cachedResult") exitWith {+_cachedResult};

//Only the faction public classes, picked by the engine (MCC_fnc_factionClasses) instead of walking every class
_CfgVehicles = [_faction] call MCC_fnc_factionClasses;

_simTypesUnits = [_simTypesUnits, _simTypesUnits + "x"];

for "_i" from 0 to (count _CfgVehicles - 1) do
{
	_CfgVehicle = _CfgVehicles select _i;
	//Keep going when it is a public entry
	if (getNumber(_CfgVehicle >> "scope") == 2) then {
		_vehicleDisplayName 	= getText(_CfgVehicle >> "displayname");
		_vehicleDisplayName		= [_vehicleDisplayName, gettext(_CfgVehicle >> "picture")];
		_cfgclass 				= (configName (_CfgVehicle));
		_cfgFaction 			= toLower (getText(_CfgVehicle >> "faction"));
		_simulation 			= getText(_CfgVehicle >> "simulation");
		_vehicleClass			= "";
		_dlc					= toLower (getText(_CfgVehicle >>"DLC"));

		//Invisible targets ("Invisible Target (Soldier)" / "(Vehicle)" ...) are AI aiming aids, not units: they cannot be
		//hit or destroyed, so they never go into a spawn list. Nothing in MCC needs them from these lists.
		private _invisibleTarget = ((toLower (_vehicleDisplayName select 0)) find "invisible") >= 0
			|| {((toLower _cfgclass) find "targetsoldier") >= 0} || {((toLower _cfgclass) find "target_vehicle") >= 0}
			|| {((toLower _cfgclass) find "targetvehicle") >= 0};
		if (_faction in [_cfgFaction,"all"] && !(_dlc in ["kart"]) && !_invisibleTarget) then
		{
			_vehicleClass = [_CfgVehicle] call MCC_fnc_unitCategory;	//mod vehicleClass names mapped to MCCs (GitHub #48)
			if (toLower(_simulation) in _simTypesUnits && !(gettext(_CfgVehicle >> "DLC") in ["Kart"])) then {

				if ((toLower(_vehicleClass) == _classType) || (_classType == "")) then {

					if (!(["vr",tolower _vehicleClass] call bis_fnc_inString) && //no karts
						(count getArray(_CfgVehicle >> "weapons")>2 || _notArmed)	//no unarmed
						) then {

						_unitsArray set[_idx,[_cfgclass,_vehicleDisplayName]];
						_idx = _idx + 1;
					};
				};
			};
		};
	};
};
uiNamespace setVariable [_resultKey, +_unitsArray];
_unitsArray
