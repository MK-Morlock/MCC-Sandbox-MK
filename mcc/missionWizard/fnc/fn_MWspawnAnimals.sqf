//======================================================MCC_fnc_MWspawnAnimals=========================================================================================================
// Spawn animals in the zone.
// Example:[_zoneNumber] call MCC_fnc_MWspawnAnimals;
// Return - amount of animals or animals groups spawned
//========================================================================================================================================================================================
private _unitPlaced = 0;
private _range = 0;
private _places = [];
private _animalType = [];
private _group = grpNull;
private _index = 0;
params [["_zoneNumber", 0, [0, ""]]];

if (!isServer) exitWith {};

_unitPlaced = 0;
_range		= (getMarkerSize str _zoneNumber) select 0;
_pos		= getMarkerPos str _zoneNumber;

_toPlace	= (floor (_range/500)) + 1;

_places = selectBestPlaces [_pos, _range,  "(2 * houses) * (meadow)", 10, (_toPlace * 2)];

for "_x" from 0 to _toPlace step 1 do
{
	if (count _places == 0) exitWith {};

	//Select animal type
	_animalType = ["ModuleAnimalsGoats_F","ModuleAnimalsPoultry_F","ModuleAnimalsSheep_F"] call BIS_fnc_selectRandom;

	//Select pos
	_index = floor random (count _places);
	_pos  = _places select _index;

	_pos = [(_pos select 0) select 0, (_pos select 0) select 1,0];

	_group = createGroup sidelogic;
	_animal = _group createUnit [_animalType, _pos, [], 0, "none"];
	{_x addCuratorEditableObjects [[_animal],false]} forEach allCurators;

	//resize the possible positon array
	_places set [_index, -1];
	_places = _places - [-1];

	_unitPlaced = _unitPlaced + 1;
};

_unitPlaced;





