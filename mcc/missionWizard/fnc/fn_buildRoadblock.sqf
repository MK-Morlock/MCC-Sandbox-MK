//======================================================MCC_fnc_buildRoadblock=========================================================================================================
// Create a pick intel objective
// Example:[_pos,_dir._faction] call MCC_fnc_buildRoadblock;
// _pos: location
// _dir: integer, direction
// _faction: string
// _side: side
// Return - handler
//========================================================================================================================================================================================
private _dummyObject = [];
private _unitsArray = [];
private _type = "";
private _group = grpNull;
private _unit = objNull;
params [
	["_pos", [0,0,0], [[]]],
	["_dir", 0, [0]],
	["_faction", "", [""]],
	["_side", sideUnknown, [sideUnknown]]
];

if (isnil "_dir") then {_dir = 0};

_dummyObject =[_pos, _dir, "c_roadblock"] call MCC_fnc_objectMapper;
waituntil {alive _dummyObject};

if (MCC_debug) then
{
	private _marker = "";
	private _name = "";
	_name = FORMAT ["Rpdblock_%1", ["roadblockMarker",1] call bis_fnc_counter];
	_marker = createMarkerLocal[_name, _pos];
	_marker setMarkerTypeLocal "mil_dot";
	_marker setMarkerColorLocal "ColorRed";
	_marker setMarkerSizeLocal[0.4, 0.4];
};


//Lets spawn some guards
[_pos,30,0,3,_faction,str _side] call MCC_fnc_garrison;

//Lets spawn someone to take care of traffic
_unitsArray 	= [[_faction,"soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry;		//Let's build the faction unit's array

if (count _unitsArray >= 4) then {
	_type = _unitsArray select round (random 4);
	_group = creategroup _side;
	_unit = _group createUnit [_type select 0,(_dummyObject modeltoworld [0,-1,0]) ,[],0.5,"NONE"];
	sleep 0.5;
	_unit setBehaviour "SAFE";
	_unit setUnitPos "UP";
	[_unit, "STAND"] call BIS_fnc_ambientAnimCombat;
	_group setFormDir _dir;
	_group setVariable ["mcc_gaia_cache",mcc_caching];
};