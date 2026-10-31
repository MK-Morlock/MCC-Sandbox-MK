//======================================================MCC_fnc_MWObjectiveClear=================================================================================================
// Create a clear area objective
// Example:[_objPos,_isCQB,_side,_faction] call MCC_fnc_MWObjectiveClear;
// _objPos = position, objectice position
//_isCQB = Boolean, true - for CQB areay false if it doesn't matters.
//_side = enemy side
//_faction = enemy Faction
// Return - nothing
//===============================================================================================================================================================================
private _range = 0;

params [
	["_objPos", [0,0,0], [[]]],
	["_isCQB", false, [false]],
	["_side", sideUnknown, [sideUnknown]],
	["_faction", "", [""]],
	["_sidePlayer", west, [west]],
	["_preciseMarkers", false, [false]],
	["_campaignMission", false, [false]],
	["_maxObjectivesDistance", 400, [0]]
];

if (_isCQB) then {
	_range = if (_campaignMission) then {100} else {50};
	_objPos = getpos ((([_objPos, 100] call MCC_fnc_MWFindbuildingPos) call BIS_fnc_selectRandom) select 0);

} else {
	_range = if (_campaignMission) then {200} else {100};

	//Lets spawn an FOB
	if (!_campaignMission || (random 1 > 0.7)) then {

		//Clear area

		_objPos = [_objPos,"military"] call MCC_fnc_buildRandomComposition;
	};
};

//Lets populate it
[_objPos,_range, 0, (if (_campaignMission) then {0.5} else {2}),_faction, _side] call MCC_fnc_garrison;
[_objPos, 30, (if (_campaignMission) then {0.5} else {2}), _faction, _side] remoteExec ["MCC_fnc_MWcampGuards", 2];

sleep 2;

//Create Task
[objnull, _objPos,"clear_area",_preciseMarkers,_side,_maxObjectivesDistance*.5,_sidePlayer] call MCC_fnc_MWCreateTask;