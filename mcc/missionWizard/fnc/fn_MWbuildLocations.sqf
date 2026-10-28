//======================================================MCC_fnc_MWbuildLocations=================================================================================================
//If the map have locations system it will build the locations
// Example: [_pos,_Radius,_type] call MCC_fnc_MWbuildLocations;
// _pos = position, from where to start looking.
//_Radius = integer, radius to search distance from _pos
//_type = string, "city","mil","hill","marine","nature"
// Return - _locationsArray - array [[location,name],[location,name],[location,name].....]
//===============================================================================================================================================================================
private _name = "";
private _cityLocations = [];
private _militaryLocations = [];
private _natureLocations = [];
private _hillsLocations = [];
private _marineLocations = [];
private _locations = nil;
private _markerColor = "";
private _locationsArray = [];
params [["_pos", [0,0,0], [[]]], ["_radius", 0, [0]], ["_type", "", [""]]];

_cityLocations = ["Airport","CityCenter","FlatAreaCity","FlatAreaCitySmall","NameCity","NameCityCapital","NameVillage"];
_militaryLocations = ["BorderCrossing","Strategic","StrongpointArea"];
_hillsLocations = ["Hill","Mount","RockArea","ViewPoint"];
_marineLocations = ["NameMarine"];
_natureLocations = ["Flag","FlatArea","Name","NameLocal","VegetationBroadleaf","VegetationFir","VegetationPalm","VegetationVineyard"];
_locationsArray = [];

switch (tolower _type) do
{
	case "city":
	{
		_locations = _cityLocations;
		_markerColor = "ColorGreen";
	};

	case "mil":
	{
		_locations = _militaryLocations;
		_markerColor = "ColorRed";
	};

	case "hill":
	{
		_locations = _hillsLocations;
		_markerColor = "ColorBlack";
	};

	case "marine":
	{
		_locations = _marineLocations;
		_markerColor = "ColorYellow";
	};

	case "nature":
	{
		_locations = _natureLocations;
		_markerColor = "ColorBlue";
	};
};

if (isnil "_locations") exitWith {["WARN", "fn_MWbuildLocations", "no type of location was selected (%1)", [_type]] call MCC_fnc_log; []};

{
	_type = type _x;
	_name = text _x;
	_locationsArray pushBack [_x,_name];
	if (missionNamespace getVariable ["MCC_debug",false]) then
	{
		createmarkerlocal [_name ,getpos _x];
		if (isNil "MCCMK_debugMarkers") then {MCCMK_debugMarkers = []};
		MCCMK_debugMarkers pushBackUnique _name;
		_name setmarkertypelocal "mil_box";
		_name setMarkerTextLocal format ["%1: %2",_name, _type];
		_name setmarkerColorlocal _markerColor;
		_name setMarkerSizeLocal [0.3, 0.3];
	};

} foreach nearestLocations [_pos,_locations, _radius];

_locationsArray
