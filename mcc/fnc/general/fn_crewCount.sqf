private _vehicleClass = "";
private _returnType = "";
private _cargo = 0;

_vehicleClass = param [0,"", [""]];
_returnType = tolower (param [1,"allCargo", [""]]);

if (_vehicleClass == "") exitWith {};

_cargo = getNumber (configfile >> "CfgVehicles" >> _vehicleClass >> "transportSoldier");
_crew = [_vehicleClass, false] call BIS_fnc_crewCount;
_allCrew = [_vehicleClass, true] call BIS_fnc_crewCount;
_allCargo = _allCrew - _crew;
_ffv = _allCargo - _cargo;


switch (_returnType) do
{
	case "cargo":{_cargo};
	case "crew":{_crew};
	case "ffv":{_ffv};
	case "allcargo":{_allCargo};
	default	{_allCrew};
};
