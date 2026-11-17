/*
	MCCMK_fnc_taruPodActions - a player flying a Taru attaches and drops pods, as in Halv's Taru pod script (Taru Pod's mod
	script by Halv, 2015, GPL v3 - credited in the readme): "Attach" when a free pod is within 5.5 m and the Taru is
	touching the ground; "Drop" at any height - its collisions with the Taru back on after 2 s, and above 25 m it comes
	down on a parachute. Scroll actions; with ACE, in the ACE self-interaction menu. (postInit, every player)
*/
if (!hasInterface) exitWith {};

MCCMK_fnc_taruPodNear = {
	params ["_h"];
	((_h nearEntities ["Pod_Heli_Transport_04_base_F", 5.5]) - [_h]) select {alive _x && {isNull (attachedTo _x)}}
};
MCCMK_fnc_taruPodOn = {
	params ["_h"];
	private _p = _h getVariable ["MCC_attachedPod", objNull];
	if (isNull _p) then {{if (_x isKindOf "Pod_Heli_Transport_04_base_F") exitWith {_p = _x}} forEach (attachedObjects _h)};
	_p
};
// Halv's place under the Taru and flight-model weight for each pod (by kind, so the black and NATO ones too)
MCCMK_fnc_taruPodPlace = {
	params ["_pod"];
	private _t = toLower (typeOf _pod);
	switch (true) do {
		case ((_t find "bench") >= 0): {[[0, 0, -1.2], 680]};
		case ((_t find "covered") >= 0): {[[0, -1, -0.82], 1413]};
		case ((_t find "medevac") >= 0): {[[-0.15, -1.08, -0.87], 1321]};
		case ((_t find "fuel") >= 0): {[[-0.025, -0.5, -1.22], 13311]};
		default {[[-0.1, -1.08, -1.07], 1270]};
	}
};
MCCMK_fnc_taruPodSound = {
	params ["_h", "_up"];
	{
		playSound3D [format ["A3\Sounds_F\vehicles\air\Heli_Transport_01\gear_%1_%2.wss", ["down", "up"] select _up, _x], _h];
	} forEach ["IN", "OUT"];
};
MCCMK_fnc_taruPodAttach = {
	params ["_h"];
	if !(isTouchingGround _h) exitWith {titleText ["Need to be touching ground to attach a pod ...", "PLAIN DOWN"]};
	private _pods = [_h] call MCCMK_fnc_taruPodNear;
	if (_pods isEqualTo []) exitWith {};
	private _pod = _pods select 0;
	[_h, true] call MCCMK_fnc_taruPodSound;
	([_pod] call MCCMK_fnc_taruPodPlace) params ["_off", "_w"];
	_pod disableCollisionWith _h;
	_pod attachTo [_h, _off];
	_h setCustomWeightRTD (((weightRTD _h) select 3) + _w);
	_h setMass ((getMass _h) + (getMass _pod));
	_pod enableRopeAttach false;
	_h setVariable ["MCC_attachedPod", _pod, true];
	["INFO", "taruPod", "%1 attached %2 at grid %3", [name player, typeOf _pod, mapGridPosition _h]] call MCC_fnc_log;
};
MCCMK_fnc_taruPodDrop = {
	params ["_h"];
	private _pod = [_h] call MCCMK_fnc_taruPodOn;
	if (isNull _pod) exitWith {};
	[_h, false] call MCCMK_fnc_taruPodSound;
	detach _pod;
	([_pod] call MCCMK_fnc_taruPodPlace) params ["", "_w"];
	_h setCustomWeightRTD (((weightRTD _h) select 3) - _w);
	_h setMass ((getMass _h) - (getMass _pod));
	_pod enableRopeAttach true;
	_h setVariable ["MCC_attachedPod", objNull, true];
	private _p = getPosATL _pod;
	if (surfaceIsWater _p) then {_p = getPosASL _pod};
	["INFO", "taruPod", "%1 dropped %2 at %3 m%4", [name player, typeOf _pod, round (_p select 2), ["", " - parachute"] select ((_p select 2) > 25)]] call MCC_fnc_log;
	[_pod, _h, _p select 2] spawn {
		params ["_pod", "_h", "_alt"];
		sleep 2;
		_pod enableCollisionWith _h;
		if (_alt > 25 && {alive _pod}) then {
			// the parachute made at the pod and moving with it, so its opening is seen
			// made where it will sit (Halv hangs the pod 0.6 m above its centre) with no collision between the two
			private _cp = (getPosASL _pod) vectorAdd [0, 0, -0.6];
			private _chute = createVehicle ["B_Parachute_02_F", ASLToAGL _cp, [], 0, "CAN_COLLIDE"];
			_chute disableCollisionWith _pod;
			_pod disableCollisionWith _chute;
			_chute setPosASL _cp;
			// (MK) with the pod's speed, so the pod doesn't stop dead while the canopy is still crumpled - the chute slows it as
			// it opens (the longer carry is allowed for in the release lead)
			_chute setVelocity (velocity _pod);
			_chute disableCollisionWith _h;
			_pod attachTo [_chute, [0, 0, 0.6]];
			private _t = time + 150;
			waitUntil {sleep 1; isNull _pod || {isTouchingGround _pod} || {time > _t}};
			if (!isNull _chute) then {detach _pod; deleteVehicle _chute};
			if (!isNull _pod) then {private _q = getPos _pod; _q set [2, 0]; _pod setPos _q};
		};
	};
};

private _canAttach = {
	params ["_u"];
	private _h = vehicle _u;
	(_h isKindOf "Heli_Transport_04_base_F") && {_u == driver _h} && {isNull ([_h] call MCCMK_fnc_taruPodOn)} && {isNull (getSlingLoad _h)} && {([_h] call MCCMK_fnc_taruPodNear) isNotEqualTo []}
};
private _canDrop = {
	params ["_u"];
	private _h = vehicle _u;
	(_h isKindOf "Heli_Transport_04_base_F") && {_u == driver _h} && {!isNull ([_h] call MCCMK_fnc_taruPodOn)} && {isNull (getSlingLoad _h)}
};
MCCMK_taruPodCanAttach = _canAttach;
MCCMK_taruPodCanDrop = _canDrop;

if (call MCCMK_fnc_aceMenus) then {
	// with ACE: the ACE self-interaction menu (MCC MK's design rule)
	private _a = ["MCCMK_taruAttach", "Attach pod", "\a3\Ui_f\data\map\Markers\Military\pickup_ca.paa",
		{[vehicle _player] call MCCMK_fnc_taruPodAttach}, {[_player] call MCCMK_taruPodCanAttach}] call ace_interact_menu_fnc_createAction;
	private _d = ["MCCMK_taruDrop", "Drop pod", "\a3\Ui_f\data\map\Markers\Military\end_ca.paa",
		{[vehicle _player] spawn MCCMK_fnc_taruPodDrop}, {[_player] call MCCMK_taruPodCanDrop}] call ace_interact_menu_fnc_createAction;
	{["Heli_Transport_04_base_F", 1, ["ACE_SelfActions"], _x, true] call ace_interact_menu_fnc_addActionToClass} forEach [_a, _d];
};
if !(call MCCMK_fnc_scrollMenus) exitWith {};	//(MK) "ACE menu only": no scroll action too

// without ACE: scroll actions on the player (put back after a respawn)
private _add = {
	player addAction ["<img size='1.5' image='\a3\Ui_f\data\map\Markers\Military\pickup_ca.paa'/> Attach pod", {[vehicle (_this select 1)] call MCCMK_fnc_taruPodAttach}, nil, 1.5, true, true, "", "[_this] call MCCMK_taruPodCanAttach"];
	player addAction ["<img size='1.5' image='\a3\Ui_f\data\map\Markers\Military\end_ca.paa'/> Drop pod", {[vehicle (_this select 1)] spawn MCCMK_fnc_taruPodDrop}, nil, 1.5, true, true, "", "[_this] call MCCMK_taruPodCanDrop"];
};
[_add] spawn {
	params ["_add"];
	waitUntil {sleep 1; !isNull player};
	call _add;
	player addEventHandler ["Respawn", _add];
};
