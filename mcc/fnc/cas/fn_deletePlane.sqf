//==================================================================MCC_fnc_deletePlane===============================================================================================
// set a plane to move to a location and delete it once it come closer then 800 meters
// Example: [_pilotGroup, _pilot, _plane, _away] call MCC_fnc_deletePlane;
// _pilotGroup = group, the plane's pilot group
// _pilot = unit, the plane's pilot
// _plane = unit, the plane
// _away = position, waypoint for the plane
// _flyInHeight = number <optional>, default 300
// _watchOnly = bool <optional, internal> only run the "delete when away / stuck" watchdog (used on the server)
//
// Support aircraft (supply drops, CAS, evac...) used to be deleted only once they came within 800 m of _away. A heli
// that never got there (it kept hovering over the drop zone after a slingload/precise landing, its pilot was busy,
// or the client that called the support left and the script died with it) circled above the players forever.
// The plane is now also deleted when it makes no progress towards _away for 90 s, or after 6 minutes at most,
// provided no player is aboard. The watchdog runs on the server as well, so it survives the caller leaving.
//===========================================================================================================================================================================
params ["_pilotGroup", "_pilot", "_plane", "_away", "_flyInHeight", ["_watchOnly", false, [false]]];

if (isNil "_away") then {_away = [100,100,100]};
if (isNil "_flyInHeight") then { _flyInHeight = 300; };
if (isNull _plane) exitWith {};

if (!_watchOnly) then {
	_pilotGroup setvariable ["MCC_canbecontrolled",false,true];

	[2,[],[0,"NO CHANGE","NO CHANGE","FULL","AWARE","", "",0],[_pilotGroup]] remoteExec ["MCC_fnc_manageWp",_plane];

	_plane setfuel 0.2;
	_pilotGroup setSpeedMode "FULL";
	_pilotGroup setCombatMode "BLUE";
	_pilotGroup setBehaviour "CARELESS";
	_plane disableAI "AUTOTARGET";
	_plane flyInHeight _flyInHeight;

	[1,_away,[0,"BLUE","NO CHANGE","FULL","CARELESS","", "",0],[_pilotGroup]] remoteExec ["MCC_fnc_manageWp",_plane];
	_pilotGroup move _away;
	_pilot domove _away;

	//Keep a watchdog on the server too: this script dies if the player who called the support disconnects
	if (!isServer) then {[_pilotGroup, _pilot, _plane, _away, _flyInHeight, true] remoteExec ["MCC_fnc_deletePlane", 2]};
};

if (_plane getVariable ["MCC_deletePlaneWatch", false] && _watchOnly) exitWith {};
_plane setVariable ["MCC_deletePlaneWatch", true];

// If plane is far away enough, stuck, or has been around too long - delete it
private _start = time;
private _bestDist = _plane distance2D _away;
private _lastProgress = time;
waituntil {
	sleep 1;
	if (isNull _plane) exitWith {true};
	private _dist = _plane distance2D _away;
	if (_dist < _bestDist - 50) then {_bestDist = _dist; _lastProgress = time};

	// stuck: nudge it once more before giving up
	if (time - _lastProgress > 45 && {time - _lastProgress < 47} && {local _plane}) then {
		_plane flyInHeight _flyInHeight;
		(group driver _plane) move _away;
	};

	((_plane distance _away) < 800) || {!alive _plane} || {
		((time - _lastProgress > 90) || (time - _start > 360)) && {({isPlayer _x} count crew _plane) == 0}
	}
};

if (!isNull _plane && {alive _plane}) then {
	if (time - _start > 360 || {time - _lastProgress > 90}) then {
		["INFO", "MCC_fnc_deletePlane", "%1 never reached its exit point (%2 m away after %3 s) - deleted", [typeOf _plane, round (_plane distance2D _away), round (time - _start)]] call MCC_fnc_log;
	};
	{deleteVehicle _x} forEach crew _plane + [_plane];
};
