//============================================================MCC_fnc_findCivHouse===============================================================================================
// find nearest civilian house
// In:
//	_pos:	ARRAY
//	_RADIUS: INTEGER
//
//<OUT>
//	_nearhouses ARRAY of objects - good houses found
//===========================================================================================================================================================================
private _pos = [];
private _nearHouses = objNull;
private _civSpawnDistance = 0;
private _house = objNull;
_pos = _this param [0, [], [[]]];
_civSpawnDistance = _this param [1, 250, [250]];

//Find nearest houses
_nearHouses = (nearestObjects [_pos,["House","Church","FuelStation"],_civSpawnDistance]) select {!(_x call MCC_fnc_isWaterStructure)};

// Only real buildings: power lines, wires, pylons, walls and fences are also "House" objects (and some sit in the air),
// so ambient civilians used to spawn on power-line wires and fall. A usable building has at least one building position.
_nearHouses = _nearHouses select {!isNull _x && {count (_x buildingPos -1) > 0}};


//If vanila island make sure
if (tolower worldName in ["altis","stratis"]) then {
	//if not civ house remove from the list
	for "_i" from 0 to ((count _nearHouses)-1) do {
		_house = _nearHouses select _i;
		if !(["_i_house", str (typeof _house)] call BIS_fnc_inString) then {_nearHouses set [_i, -1]}
	};

	_nearHouses = _nearHouses -[-1];
};

_nearHouses