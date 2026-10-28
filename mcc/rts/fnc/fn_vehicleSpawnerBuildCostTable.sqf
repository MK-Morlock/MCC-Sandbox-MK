/*======================================== MCC_fnc_vehicleSpawnerBuildCostTable ===============================================================================
build cost table for a vehicle kiosk

<IN>
	0:	_vehicleType - STRING "vehicle","tank","heli","jet","ship","units"
	1:	_side - SIDE - side from which to build the array
	2:	_faction - STRING - faction from which to build the array
	3: _sideBuy - BOOLEAN - if true faction will be ignored and all vehicles from the side will be shown

<OUT>
	[_cfgclass,[_vehicleDisplayName,_pic],_cost]
===============================================================================================================================================================
*/

 params [
        ["_vehicleType","vehicle",[""]],
        ["_side",west,[sideLogic]],
        ["_faction","BLU_F",[""]],
        ["_sideBuy",false,[false]]
    ];

private _baseCost = 0;
private _simTypesUnits = [];
private "_vehicleArray";
private _cfgclass = configNull;
private "_cfgSide";
private _simulation = "";
private _cfgFaction = "";
private _pic = "";
private _CfgVehicles = configNull;
private "_CfgVehicle";
private _vehicleDisplayName = "";
private _cost = nil;

_faction = toLower _faction;

_baseCost = 500;
switch (tolower _vehicleType) do {
    case "vehicle": {
        _simTypesUnits = ["car","carx", "motorcycle"];
        _baseCost = 2000;
    };
    case "tank":  {
         _simTypesUnits = ["tank","tankx"];
         _baseCost = 4000;
    };
    case "heli":  {
        _simTypesUnits = ["helicopter","helicopterX", "helicopterrtd"];
         _baseCost = 8000;
    };
    case "jet":  {
        _simTypesUnits = ["airplane","airplanex"];
        _baseCost = 12000;
    };
    case "ship":  {
        _simTypesUnits = ["ship","shipx", "shipX","submarinex"];
         _baseCost = 3000;
    };
    case "units":  {
        _simTypesUnits =  ["men","menx","soldier"];
        _baseCost = 50;
    };
    default  {
    	 _simTypesUnits = ["car","carx", "motorcycle"];
    	 _baseCost = 2000;
	};
};

//Is there a user designed vehicle costs? (MCC_RTS_<type>_<side>, set by the mission maker)
_vehicleArray = missionNamespace getVariable [format["MCC_RTS_%1_%2",tolower _vehicleType,_side],[]];

//Built list, cached per type + side + faction (it used to be cached per side only, so the first player's faction decided the list for everyone)
private _cacheKey = format ["MCC_RTS_cache_%1_%2_%3_%4", tolower _vehicleType, _side, _faction, _sideBuy];
if (count _vehicleArray == 0) then {_vehicleArray = + (missionNamespace getVariable [_cacheKey, []])};

private _fnc_build = {
    params ["_sideBuy"];
    private _out = [];
    _CfgVehicles        = configFile >> "CfgVehicles" ;

    for "_i" from 1 to (count _CfgVehicles - 1) do {
        _CfgVehicle = _CfgVehicles select _i;

        //Keep going when it is a public entry
        if ((getNumber(_CfgVehicle >> "scope") == 2)) then {

            _simulation         = toLower (getText(_CfgVehicle >> "simulation"));

            if (_simulation in _simTypesUnits) then  {
                _cfgSide            = (getNumber(_CfgVehicle >> "side")) call BIS_fnc_sideType;
                _cfgFaction         = tolower (getText(_CfgVehicle >> "faction"));

                if ((((_cfgSide == _side) && _sideBuy) ||
                      (_cfgFaction == _faction)) &&
                      !(tolower(getText(_CfgVehicle >> "vehicleClass")) in ["static","support","autonomous"])) then {

                    _vehicleDisplayName = getText(_CfgVehicle >> "displayname");
                    _cfgclass           = (configName (_CfgVehicle));
                    _pic                =  if ((gettext(_CfgVehicle >> "editorPreview")) == "") then {gettext(_CfgVehicle >> "picture")} else {gettext(_CfgVehicle >> "editorPreview")};
                    if (!(["paa", _pic] call BIS_fnc_inString) && !(["jpg", _pic] call BIS_fnc_inString)) then {_pic = ""};
                    _vehicleDisplayName = [_vehicleDisplayName, _pic];

                    //Get the cost
                    if (tolower _vehicleType == "units") then {
                        _cost  = floor (getNumber(_CfgVehicle >> "cost")/100);
                        {
                            _cost = _cost + ([_x,0.5] call MCC_fnc_getWeaponCost);
                        } forEach (getArray(_CfgVehicle >> "weapons"));
                    } else {
                        _cost = [_cfgclass, _baseCost] call MCC_fnc_getVehicleCost;
                    };
                    if (isNil "_cost") then {_cost = 500};

                    _out pushback [_cfgclass,_vehicleDisplayName,_cost];
                };
            };
        };
    };
    _out
};

if (count _vehicleArray == 0) then {
    _vehicleArray = [_sideBuy] call _fnc_build;

    // The player's own faction has nothing of this type (e.g. CTRG / special-forces or many mod factions have no vehicles):
    // offer everything from the player's side instead of an empty list
    if (count _vehicleArray == 0 && !_sideBuy) then {
        _vehicleArray = [true] call _fnc_build;
        ["INFO", "fn_vehicleSpawnerBuildCostTable", "faction %1 has no '%2' entries - showing all %3 '%2' entries instead (%4)", [_faction, _vehicleType, _side, count _vehicleArray]] call MCC_fnc_log;
    };
    if (count _vehicleArray == 0) then {
        ["WARN", "fn_vehicleSpawnerBuildCostTable", "nothing to buy: no '%1' entries for faction %2 or side %3", [_vehicleType, _faction, _side]] call MCC_fnc_log;
    };

    missionNamespace setVariable [_cacheKey, _vehicleArray];
};

_vehicleArray
