// MCC SANDBOX MK - 3D VIEW. Opened from the MCC console's 3D View button on the unit or
// group selected (MCCMK_fnc_view3D) - not by a click on the map; any side. MCC MK's
// own names (MCCMK_av_*, MCCMK_fnc_av*), settings (MCCMK_BombViewEnabled ... - all on unless set) and key bindings (CBA:
// MCCMK > 3D View). On closing, the MCC console opens again.
//
// THE ALTERNATIVE VIEW 
//
// OPENING: SHIFT + right-click a group's icon on the map (Map Intel) or the map next to a unit - CBA "Alternative View"
// (MCCMK_AltViewFriendly / MCCMK_AltViewEnemy / MCCMK_AltViewCivilian - three separate options) say which sides; an enemy
// or a civilian only if the player's side knows of it. The view goes to the pilot / driver of the leader's vehicle, or the leader on foot. The FIRST time on
// a vehicle (or man) this mission: the script camera, first or third person as the player's own camera was; after that
// as it was left on that vehicle - script camera or AI view, first or third person, and its C view. (as it was last
// on THAT MAN, else on his vehicle, else as last used on anyone - kept over missions - and only then those defaults; and it is
// kept when the view is left. The map never shows what is outside the world - MCCMK_fnc_avMapFit.) With the view open,
// a Shift + right-click on the map jumps to that group instead.
//
// THE CAMERAS: the SCRIPT CAMERA - first person at the crewman's eye (the man hidden on this machine), the mouse looking
// round within the seat's look limits, turning with the vehicle; the arrow keys move it off the eye (then free all the
// way round); the scroll wheel raises / lowers the eye a little. Third person: an orbit round the vehicle or man, the
// mouse swinging it, the scroll wheel in / out, eased (MCCMK_av_lookLag 0.10 s), never below ground or sea. The AI VIEW
// (V): the game's own camera on the man, first or third person. Mouse speed: MCCMK_av_sens.
// C / SHIFT + C: the view cycle, forwards / backwards - in a vehicle Default, Fixed Horizon, Heading Only, No Nose,
// World Locked, Fly By (Opposite of Heading Only and Banking Only cut); on foot Default, World Locked, Fly By. (Not in the AI view.)
// THE KEYS (CBA: MCCMK > 3D View): switch-view key - first / third person; C / Shift + C - view cycle; V - AI
// view; arrows - move the camera (Ctrl + Up / Down: up / down, Right Shift: fine); Space - camera back to its place;
// Left Shift + Left / Right - previous / next crewman or group member; Page Up / Down - mouse speed; the map key - the
// game's own map (the mouse free on it while it is up); left-click - bomb view on / off; right-click or Esc - exit.
// ISOLATED: an empty screen of its own over the game takes the keyboard and mouse, so nothing reaches the player's
// character or other mods; the mouse pointer is parked off the bottom-right of the screen, and the look comes from the
// game's own look input (see MCCMK_fnc_avLookFrame). The player's simulation is
// held; he can still be hurt. No HUD - two lines at the top and one at the bottom: bomb view / exit; the C and V keys and what they do next
// (fades after 10 s); the camera now (fades with it).
// BOMB VIEW (CBA "Bomb View", MCCMK_BombViewEnabled, on from the start): everything the vehicle (any seat) or man fires
// is followed - not flares / chaff - a round that splits into its first piece; an orbit 14 m behind it (mouse, scroll
// 5 - 80 m); on impact it pulls back and holds 3.5 s, then back. One round at a time. (and what an AIRCRAFT drops - a
// supply or vehicle drop by parachute, a slung load or a vehicle let go of in the air - followed the same way until it
// lands. LEFT-CLICK while one is followed: back to the unit, bomb view STAYS ON for the next; not following: on / off.)
// CLOSES: right-click / Esc, at once if the player dies, 5 s after the man watched dies or is gone. Opened whenever asked -
// also while the player drives.
// SOUND: what is heard comes from where the camera IS - the cabin sound with the camera on the crewman's eye inside a
// vehicle, the open air everywhere else (third person, the Fly By shots, the camera moved off the eye, bomb view) - including
// when coming out of the AI view (CBA "Alternative View: Sound Follows Camera"). The man watched has his radio silenced for as
// long as he is watched, and gets it back when the view moves on or closes; the player's own radio is never touched (CBA
// "Alternative View: Silence Watched Unit's Radio").
// THE MAP: the game's map key as bound - the keyboard key, ANY mouse button, or anything else the game's own ShowMap action
// is bound to - opens the game's own map over the view; it opens on the man watched with the pointer in the middle of the screen
// (the pointer is parked in a corner for the view, and the map would scroll away to that corner from there).
// Started once per client the first time the MCC console's 3D View button is used (MCCMK_fnc_view3D). Local only - the
// same in single and multiplayer.

if (!hasInterface) exitWith {};
if (!isNil "MCCMK_av_init") exitWith {};
MCCMK_av_init = true;
waitUntil { sleep 0.5; !isNull player && {!isNull (findDisplay 46)} };

MCCMK_av_on = false;
MCCMK_av_bomb = false;
MCCMK_av_fol = false;
MCCMK_av_offShown = false; // the camera is off the crewman's eye - the hint "Space: Back to Crewman" has been shown for it
MCCMK_av_drop = false;     // what is followed is a DROPPED LOAD (a crate, a vehicle), not a round: it ends by landing, not by being gone
MCCMK_av_dwVeh = objNull;  // the aircraft whose slung load and vehicle cargo are watched for a release
MCCMK_av_dwPrev = [];
MCCMK_av_cam = objNull;
MCCMK_av_camOn = false;
MCCMK_av_mapCam = false;   // (the script camera put aside while the map is up)
// (sound follows the camera, and the watched man's radio is silent - MCCMK_fnc_avAudio / MCCMK_fnc_avMute)
MCCMK_av_camFx = "";       // the script camera's effect type now: "internal" (inside a vehicle) or "external"
MCCMK_av_focusKey = [];    // [man, view] the game's own camera focus was last put on while the script camera is up
MCCMK_av_mute = [];        // [[man, his speaker]] - the men whose radio is silenced while they are watched
// (the map from the alternative view - MCCMK_fnc_avMapKey)
MCCMK_av_mapKeyT = -1;     // the map key (or button) is taken once within half a second, however many ways it reports itself
MCCMK_av_mapPendT = -1;    // until then the pointer is NOT parked again - it is in the middle of the screen, for the map that is opening
// (first person on the SCRIPT camera by preference - look-around matters more than the cockpit's look;
//  MCCMK_av_fpNative = true gives the game's own fixed view instead)
if (isNil "MCCMK_av_fpNative") then { MCCMK_av_fpNative = profileNamespace getVariable ["MCCMK_av_fpNative", false]; };
// (V switches between the script camera and the AI view (the game's own camera on the man,
//  MCCMK_av_fpNative). C cycles the script camera's view in a vehicle (MCCMK_av_hzMode): what the view
//  follows of the vehicle - [heading, nose up / down, banking] - and Fly By (shots from outside, a new one every 5 - 10 s).
//  Not following the heading: the compass direction it faced when that view was chosen (MCCMK_av_h0). 
//  the camera, first / third person and the C view are remembered on each vehicle (or man) for the mission.)
// (the views: 0 Default, 1 Fixed Horizon, 2 Heading Only, 3 No Nose, 4 World Locked, 5 Fly By - on foot Default,
//   World Locked, Fly By are 0, 4, 5.)
// ONCE, a view number from an older numbering in the player's profile is turned into this one (a view not in the cycle
// becomes World Locked).
if ((profileNamespace getVariable ["MCCMK_av_hzVer", 1]) < 2) then {
	private _hzMap = [0, 1, 2, 4, 4, 3, 4, 5];
	{
		private _ov = profileNamespace getVariable _x;
		if (!isNil "_ov" && {_ov isEqualType 0}) then { profileNamespace setVariable [_x, _hzMap select (((floor _ov) max 0) min 7)]; };
	} forEach ["MCCMK_av_hzMode", "MCCMK_av_hzModeFoot", "MCCMK_av_mHzV_last", "MCCMK_av_mHzF_last"];
	profileNamespace setVariable ["MCCMK_av_hzVer", 2];
	saveProfileNamespace;
};
MCCMK_av_hzNames = ["Default", "Fixed Horizon", "Heading Only", "No Nose", "World Locked", "Fly By"];
MCCMK_av_hzAxes = [[true, true, true], [true, true, false], [true, false, false], [true, false, true], [false, false, false], [true, true, true]];
if (isNil "MCCMK_av_hzMode") then { MCCMK_av_hzMode = profileNamespace getVariable ["MCCMK_av_hzMode", 0]; };
if !(MCCMK_av_hzMode isEqualType 0) then { MCCMK_av_hzMode = 0; };
MCCMK_av_hzMode = ((floor MCCMK_av_hzMode) max 0) min 5;
MCCMK_av_h0 = 0;
// (ON FOOT, C cycles Default > World Locked > Fly By (MCCMK_av_hzModeFoot - 0, 4 or 5 - remembered): World
//  Locked faces one compass direction while the man turns; Fly By - three of the shots, scaled to a man on foot)
MCCMK_av_footCycle = [0, 4, 5];
if (isNil "MCCMK_av_hzModeFoot") then { MCCMK_av_hzModeFoot = profileNamespace getVariable ["MCCMK_av_hzModeFoot", 0]; };
if !(MCCMK_av_hzModeFoot in MCCMK_av_footCycle) then { MCCMK_av_hzModeFoot = 0; };
// [unit] -> the view now: in a vehicle its cycle's, on foot the on-foot cycle's
// THE VIEW REMEMBERED - the camera last chosen: first or third person (mMode), the AI view or the script camera (mNative),
// and the C view (mHzV in a vehicle, mHzF on foot). Every change is kept on the man watched, on his vehicle, and as the LAST
// USED in the player's profile (so it lasts over missions); and everything is kept again when the view is left.
// Opening or switching to a man: as it was last on HIM; else as it was last on his vehicle; else as it was last used on anyone;
// only then the defaults (Default view, the script camera, the player's own first / third person).
MCCMK_fnc_avMemSet = {
	params ["_key", "_val"];
	private _u = MCCMK_av_unit;
	if (isNull _u) exitWith {};
	_u setVariable [_key, _val];
	(vehicle _u) setVariable [_key, _val];
	profileNamespace setVariable [_key + "_last", _val];
};
// [man, key, default] -> the value
MCCMK_fnc_avMemGet = {
	params ["_u", "_key", "_def"];
	private _r = _u getVariable _key;
	if (isNil "_r") then { _r = (vehicle _u) getVariable _key; };
	if (isNil "_r") then { _r = profileNamespace getVariable (_key + "_last"); };
	if (isNil "_r") then { _r = _def; };
	_r
};
// everything now chosen, kept (called when the view is left)
MCCMK_fnc_avMemSaveAll = {
	if (isNull MCCMK_av_unit) exitWith {};
	["MCCMK_av_mMode", MCCMK_av_mode] call MCCMK_fnc_avMemSet;
	["MCCMK_av_mNative", MCCMK_av_fpNative] call MCCMK_fnc_avMemSet;
	if ((vehicle MCCMK_av_unit) == MCCMK_av_unit) then { ["MCCMK_av_mHzF", MCCMK_av_hzModeFoot] call MCCMK_fnc_avMemSet; } else { ["MCCMK_av_mHzV", MCCMK_av_hzMode] call MCCMK_fnc_avMemSet; };
	profileNamespace setVariable ["MCCMK_av_hzMode", MCCMK_av_hzMode];
	profileNamespace setVariable ["MCCMK_av_hzModeFoot", MCCMK_av_hzModeFoot];
	profileNamespace setVariable ["MCCMK_av_fpNative", MCCMK_av_fpNative];
	saveProfileNamespace;
};

MCCMK_fnc_avHz = { params ["_u"]; if ((vehicle _u) == _u) then {MCCMK_av_hzModeFoot} else {MCCMK_av_hzMode} };
// [unit] -> the view after it in its cycle
MCCMK_fnc_avHzNext = {
	params ["_u"];
	if ((vehicle _u) == _u) then { MCCMK_av_footCycle select (((MCCMK_av_footCycle find MCCMK_av_hzModeFoot) + 1) % (count MCCMK_av_footCycle)) } else { (MCCMK_av_hzMode + 1) % 6 }
};
MCCMK_av_fb = [];
MCCMK_av_fbLast = -1;
// (in first person the ARROW KEYS move the camera itself - Up / Down forward / back, Left / Right left /
//  right, LEFT CTRL + Up / Down up / down - in the vehicle's (or the
//  man's) own frame, MCCMK_av_moveSpd m a second, up to MCCMK_av_moveMax m (20) each way - up, down, left and right
//  separately; SPACE puts it back on the eye)
if (isNil "MCCMK_av_moveSpd") then { MCCMK_av_moveSpd = 3; };
// (no easing - the player's profile has mouse smoothing OFF (mouseSmoothing=0) and acceleration off, and the
//  game's own third person turns with the vehicle; raise these to bring the easing back)
if (isNil "MCCMK_av_lookLag") then { MCCMK_av_lookLag = 0.10; };   // (0.10 s - the orbit and the zoom eased again, the player's pick)
if (isNil "MCCMK_av_headLag") then { MCCMK_av_headLag = 0; };
if (isNil "MCCMK_av_moveMax") then { MCCMK_av_moveMax = 20; };
MCCMK_av_keys = [];
MCCMK_av_hold = [];
MCCMK_av_down = [];
MCCMK_av_off = [0, 0, 0];
// (RIGHT Shift held with the movement keys - fine movement, MCCMK_av_fineSpd m a second; LEFT Shift +
//  Left / Right switches crew)
if (isNil "MCCMK_av_fineSpd") then { MCCMK_av_fineSpd = 0.5; };
// (CBA Addon Options > Controls > "MCCMK" > "3D View" - every keyboard control, mappable to any key
//  combination; only acts while the view is open. CBA keybinds take Ctrl as either Ctrl key, so "Camera up / down"
//  default to Ctrl + Up / Down there; without CBA the keys are fixed: Right Ctrl + Up / Down.)
MCCMK_av_cba = isClass (configFile >> "CfgPatches" >> "cba_keybinding");
if (isNil "MCCMK_av_isolate") then { MCCMK_av_isolate = true; };
if (isNil "MCCMK_av_pinMouse") then { MCCMK_av_pinMouse = true; };
// THE LOOK INPUT. With the pointer parked off the bottom-right corner it cannot move right or down, so the
// mouse's own movement only carries left and up. The look is taken
// from the game's own look input instead (inputAction AimLeft / AimRight / AimUp / AimDown), every frame, scaled to the
// mouse's movement - the scale learnt from the left and up movement, which the pointer still reports. "learn" until the
// scale is known; then "input". If the game's look input gives nothing while the view is open (after 40 frames of
// moving left or up), "free": the pointer is parked a little inside the corner, where it can move every way, and the
// mouse's movement is used directly.
if (isNil "MCCMK_av_lookMode") then { MCCMK_av_lookMode = "learn"; };
if (isNil "MCCMK_av_cal") then { MCCMK_av_cal = [0, 0, 0, 0, 0]; };   // [mouse x, input x, mouse y, input y, frames moving]
MCCMK_av_mAcc = [0, 0];
MCCMK_av_child = false;
// (the view's CBA keybinds, read and matched on the isolating screen: [action id, "h" held movement / "c" code, what])
MCCMK_av_cbaActs = [
	["MCCMK_av_fwd", "h", "fwd"], ["MCCMK_av_back", "h", "back"], ["MCCMK_av_left", "h", "left"], ["MCCMK_av_right", "h", "right"],
	["MCCMK_av_up", "h", "up"], ["MCCMK_av_down", "h", "down"], ["MCCMK_av_fine", "h", "fine"],
	["MCCMK_av_next", "c", { [1] call MCCMK_fnc_avCycle; }], ["MCCMK_av_prev", "c", { [-1] call MCCMK_fnc_avCycle; }],
	["MCCMK_av_reset", "c", { call MCCMK_fnc_avReset; }],
	["MCCMK_av_sensUp", "c", { [true] call MCCMK_fnc_avSensStep; }], ["MCCMK_av_sensDown", "c", { [false] call MCCMK_fnc_avSensStep; }],
	["MCCMK_av_toggle", "c", { MCCMK_av_togT = -1; call MCCMK_fnc_avToggle; }],
	["MCCMK_av_bombKey", "c", { if (missionNamespace getVariable ["MCCMK_BombViewEnabled", true]) then { MCCMK_av_bomb = !MCCMK_av_bomb; if (!MCCMK_av_bomb) then { [true] call MCCMK_fnc_avFolEnd; }; call MCCMK_fnc_avText; }; }],
	["MCCMK_av_exitKey", "c", { [] spawn MCCMK_fnc_avClose; }],
	["MCCMK_av_aiViewV", "c", { call MCCMK_fnc_avAiToggle; }], ["MCCMK_av_camCycleC", "c", { [1] call MCCMK_fnc_avFixToggle; }],
	["MCCMK_av_camCycleBackC", "c", { [-1] call MCCMK_fnc_avFixToggle; }]
];
// [key, shift, ctrl, alt, down?] -> a CBA keybind of the view's, as the player has it set, pressed / released
MCCMK_fnc_avCbaKey = {
	params ["_k", "_sh", "_ct", "_al", "_dn", ["_rep", false]];
	{
		_x params ["_id", "_ty", "_a"];
		private _kb = ["MCCMK", _id] call CBA_fnc_getKeybind;
		if (isNil "_kb" || {!(_kb isEqualType [])} || {count _kb < 6}) then { _kb = [["MCCMK", "3D View"], _id] call CBA_fnc_getKeybind; };
		if (!isNil "_kb" && {_kb isEqualType []} && {count _kb > 5}) then {
			(_kb select 5) params [["_dik", -1], ["_mods", [false, false, false]]];
			if (_dik > 0 && {_dik == _k}) then {
				if (_dn) then {
					// (a key held down repeats - a one-shot action (switching crew etc.) only on the first press; the
					//  forward / back / up / down movement also with Shift held - the fine, slow movement)
					//  (Right Shift held - fine movement in all four directions, and no crew switching)
					private _rs = 54 in MCCMK_av_down;
					private _mOK = (_mods isEqualTo [_sh, _ct, _al]) || {_ty == "h" && {(_a == "fine") || {_rs && {_a in ["fwd", "back", "up", "down", "left", "right"]}}} && {(_mods select [1, 2]) isEqualTo [_ct, _al]}};
					if (_rs && {_id in ["MCCMK_av_next", "MCCMK_av_prev"]}) then { _mOK = false; };
					if (_mOK) then { if (_ty == "h") then { MCCMK_av_hold pushBackUnique _a; } else { if (!_rep) then { call _a; }; }; };
				} else {
					if (_ty == "h") then { MCCMK_av_hold = MCCMK_av_hold - [_a]; };
				};
			};
		};
	} forEach MCCMK_av_cbaActs;
};
if (MCCMK_av_cba) then {
	private _cat = ["MCCMK", "3D View"];
	{
		_x params ["_id", "_nm", "_tip", "_key", "_mods", "_act"];
		[_cat, _id, [_nm, _tip],
			compile format ["if (!MCCMK_av_on) exitWith {false}; MCCMK_av_hold pushBackUnique '%1'; true", _act],
			compile format ["MCCMK_av_hold = MCCMK_av_hold - ['%1']; MCCMK_av_on", _act],
			[_key, _mods], false] call CBA_fnc_addKeybind;
	} forEach [
		["MCCMK_av_fwd", "Camera forward", "First person: move the camera forward (hold)", 200, [false, false, false], "fwd"],
		["MCCMK_av_back", "Camera back", "First person: move the camera back (hold)", 208, [false, false, false], "back"],
		["MCCMK_av_left", "Camera left", "First person: move the camera left (hold)", 203, [false, false, false], "left"],
		["MCCMK_av_right", "Camera right", "First person: move the camera right (hold)", 205, [false, false, false], "right"],
		["MCCMK_av_up", "Camera up", "First person: move the camera up (hold)", 200, [false, true, false], "up"],
		["MCCMK_av_down", "Camera down", "First person: move the camera down (hold)", 208, [false, true, false], "down"],
		["MCCMK_av_fine", "Fine movement (hold)", "Held with the camera movement keys: slow, fine movement (0.5 m a second) in every direction", 54, [false, false, false], "fine"]
	];
	[_cat, "MCCMK_av_next", ["Next crew / group member", "Switch to the next one: pilot > co-pilot > gunner (driver > commander > gunner), then the rest of the group, round to the start"], { if (!MCCMK_av_on) exitWith {false}; [1] call MCCMK_fnc_avCycle; true }, {MCCMK_av_on}, [205, [true, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_prev", ["Previous crew / group member", "Switch back to the previous one"], { if (!MCCMK_av_on) exitWith {false}; [-1] call MCCMK_fnc_avCycle; true }, {MCCMK_av_on}, [203, [true, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_reset", ["Camera reset", "Put the camera back to its default position - first person: on the crewman's eye, looking forward; third person: behind"], { if (!MCCMK_av_on) exitWith {false}; call MCCMK_fnc_avReset; true }, {MCCMK_av_on}, [57, [false, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_sensUp", ["Mouse speed up", "The camera's mouse speed 10% up"], { if (!MCCMK_av_on) exitWith {false}; [true] call MCCMK_fnc_avSensStep; true }, {MCCMK_av_on}, [201, [false, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_sensDown", ["Mouse speed down", "The camera's mouse speed 10% down"], { if (!MCCMK_av_on) exitWith {false}; [false] call MCCMK_fnc_avSensStep; true }, {MCCMK_av_on}, [209, [false, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_toggle", ["First / third person", "Switch first / third person (the game's own switch-view key works too)"], { if (!MCCMK_av_on) exitWith {false}; MCCMK_av_togT = -1; call MCCMK_fnc_avToggle; true }, {MCCMK_av_on}, [0, [false, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_bombKey", ["Bomb view on / off", "Switch bomb view on or off (left-click works too)"], { if (!MCCMK_av_on || {!(missionNamespace getVariable ["MCCMK_BombViewEnabled", true])}) exitWith {false}; MCCMK_av_bomb = !MCCMK_av_bomb; if (!MCCMK_av_bomb) then { [true] call MCCMK_fnc_avFolEnd; }; call MCCMK_fnc_avText; true }, {MCCMK_av_on}, [0, [false, false, false]], false] call CBA_fnc_addKeybind;
	// (the two keybinds - their own names, as CBA keeps the keys a keybind was first given in the player's profile)
	[_cat, "MCCMK_av_aiViewV", ["AI view / default view", "First or third person: switch between the default view and the AI view (the game's own camera on the man) - it stays on when first / third person is switched"], { if (!MCCMK_av_on) exitWith {false}; call MCCMK_fnc_avAiToggle; true }, {MCCMK_av_on}, [47, [false, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_camCycleC", ["View cycle", "The camera views - in a vehicle: Default > Fixed Horizon > Heading Only > No Nose > World Locked > Fly By > Default; on foot: Default > World Locked > Fly By > Default"], { if (!MCCMK_av_on) exitWith {false}; [1] call MCCMK_fnc_avFixToggle; true }, {MCCMK_av_on}, [46, [false, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_camCycleBackC", ["View cycle back", "The camera views, backwards (Shift + C)"], { if (!MCCMK_av_on) exitWith {false}; [-1] call MCCMK_fnc_avFixToggle; true }, {MCCMK_av_on}, [46, [true, false, false]], false] call CBA_fnc_addKeybind;
	[_cat, "MCCMK_av_exitKey", ["Exit 3D View", "Back to your own character (right-click works too)"], { if (!MCCMK_av_on) exitWith {false}; [] spawn MCCMK_fnc_avClose; true }, {false}, [0, [false, false, false]], false] call CBA_fnc_addKeybind;
};
if (isNil "MCCMK_av_sens") then { MCCMK_av_sens = 0.6; };
if (isNil "MCCMK_av_eyeUp") then { MCCMK_av_eyeUp = 0.05; };
if (isNil "MCCMK_av_eyeDown") then { MCCMK_av_eyeDown = 0.15; };

// (CBA "Alternative View" - three separate options: Friendly (MCCMK_AltViewFriendly), Enemy (MCCMK_AltViewEnemy), Civilians
//  (MCCMK_AltViewCivilian).)
// -> how many of the three are on: 0 = the alternative view is off
MCCMK_fnc_avMode = {
	(if (missionNamespace getVariable ["MCCMK_AltViewFriendly", true]) then {1} else {0}) + (if (missionNamespace getVariable ["MCCMK_AltViewEnemy", true]) then {1} else {0}) + (if (missionNamespace getVariable ["MCCMK_AltViewCivilian", true]) then {1} else {0})
};
// [side] -> may that side be watched, by the settings? (civilians by their own option; any other side friendly to the player's
// by Friendly, else by Enemy)
MCCMK_fnc_avSideOK = {
	params ["_s"];
	if (_s == civilian) exitWith { missionNamespace getVariable ["MCCMK_AltViewCivilian", true] };
	if ([side group player, _s] call BIS_fnc_sideIsFriendly) then { missionNamespace getVariable ["MCCMK_AltViewFriendly", true] } else { missionNamespace getVariable ["MCCMK_AltViewEnemy", true] }
};
// [group] -> the unit to watch: the driver / pilot of the leader's vehicle (else its commander), or the leader on foot
MCCMK_fnc_avTarget = {
	params ["_g"];
	private _l = leader _g;
	private _v = vehicle _l;
	if (_v == _l) exitWith {_l};
	private _d = driver _v;
	if (!isNull _d && {alive _d}) exitWith {_d};
	effectiveCommander _v
};

// the line at the top (the control kept in uiNamespace - a control cannot be stored in the mission namespace)
MCCMK_fnc_avText = {
	private _ctl = uiNamespace getVariable ["MCCMK_av_ctrl", controlNull];
	if (isNull _ctl) exitWith {};
	private _bvOK = missionNamespace getVariable ["MCCMK_BombViewEnabled", true];
	private _txt = if (MCCMK_av_fol) then {"Left-click to go back to the unit (bomb view stays on)   |   Right-click to exit"} else { if (MCCMK_av_bomb) then {"Left-click exit bomb view   |   Right-click to exit"} else { if (_bvOK) then {"Left-click for bomb view   |   Right-click to exit"} else {"Right-click to exit"} } };
	private _isMsg = (time < (missionNamespace getVariable ["MCCMK_av_sensT", -1])) || {time < (missionNamespace getVariable ["MCCMK_av_msgT", -1])};
	if (time < (missionNamespace getVariable ["MCCMK_av_sensT", -1])) then { _txt = format ["Mouse speed %1   (Page Up / Page Down)", MCCMK_av_sens]; };
	if (time < (missionNamespace getVariable ["MCCMK_av_msgT", -1])) then { _txt = MCCMK_av_msg; };
	// shown whenever it changes, then faded out 10 s later; a newer change starts the 10 s again. The follow line (a round
	// being followed) only the first time for each unit watched - again after a switch or reopening the view
	if (_txt == (missionNamespace getVariable ["MCCMK_av_txtLast", ""])) exitWith {};
	private _wasFol = missionNamespace getVariable ["MCCMK_av_txtFol", false];
	MCCMK_av_txtLast = _txt;
	MCCMK_av_txtFol = !_isMsg && {MCCMK_av_fol};
	_ctl ctrlSetStructuredText parseText format ["<t align='center' size='0.75' shadow='2'>%1</t>", _txt];
	if (!_isMsg && {missionNamespace getVariable ["MCCMK_av_folShown", false]} && {MCCMK_av_fol || {_wasFol}}) exitWith {};
	if (MCCMK_av_txtFol) then { MCCMK_av_folShown = true; };
	_ctl ctrlSetFade 0;
	_ctl ctrlCommit 0;
	MCCMK_av_txtTok = (missionNamespace getVariable ["MCCMK_av_txtTok", 0]) + 1;
	[_ctl, MCCMK_av_txtTok] spawn {
		disableSerialization;
		params ["_c", "_tok"];
		uiSleep 10;
		if (!isNull _c && {(missionNamespace getVariable ["MCCMK_av_txtTok", 0]) == _tok}) then {_c ctrlSetFade 1; _c ctrlCommit 1;};
	};
};
// [CBA keybind id, default] -> the key's name as the player has it bound (CBA), else the default
MCCMK_fnc_avKeyName = {
	params ["_id", "_def"];
	if (!MCCMK_av_cba) exitWith {_def};
	private _kb = ["MCCMK", _id] call CBA_fnc_getKeybind;
	if (isNil "_kb" || {!(_kb isEqualType [])} || {count _kb < 6}) then { _kb = [["MCCMK", "3D View"], _id] call CBA_fnc_getKeybind; };
	if (isNil "_kb" || {!(_kb isEqualType [])} || {count _kb < 6}) exitWith {_def};
	private _dik = ((_kb select 5) param [0, -1]);
	if (_dik <= 0) exitWith {_def};
	((keyName _dik) splitString """") joinString ""
};
// the second line, under the top one (not while following a bomb or missile): "C <next view>   V AI View",
// or "V Default" in the AI view; the third line, at the bottom of the screen: the camera now. Both fade after 10 s.
// is the FIRST-PERSON script camera off the crewman's eye - moved by the arrow keys, or its height changed by the wheel?
// (then Space puts it back: MCCMK_fnc_avReset). Not in the AI view, a Fly By shot, or a bomb view.
MCCMK_fnc_avOffEye = {
	MCCMK_av_on && {MCCMK_av_mode == "INTERNAL"} && {!MCCMK_av_fpNative} && {!MCCMK_av_fol} && {([MCCMK_av_unit] call MCCMK_fnc_avHz) != 5} && {((vectorMagnitude MCCMK_av_off) > 0.05) || {(abs MCCMK_av_eyeZ) > 0.004}}
};
MCCMK_fnc_avLine2 = {
	private _ctl = uiNamespace getVariable ["MCCMK_av_ctrl2", controlNull];
	if (isNull _ctl) exitWith {};
	// (in third person too, in a vehicle - "V ..." only; V works there)
	private _veh = vehicle MCCMK_av_unit != MCCMK_av_unit;
	private _show = MCCMK_av_on && {!MCCMK_av_fol};   // (on foot in third person too - C works there now)
	if (!_show) exitWith { { private _c2 = uiNamespace getVariable [_x, controlNull]; if (!isNull _c2) then { _c2 ctrlSetFade 1; _c2 ctrlCommit 0; }; } forEach ["MCCMK_av_ctrl2", "MCCMK_av_ctrl3"]; };
	private _c = ["MCCMK_av_aiViewV", "V"] call MCCMK_fnc_avKeyName;    // (the AI view's key - V)
	private _vk = ["MCCMK_av_camCycleC", "C"] call MCCMK_fnc_avKeyName;   // (the view cycle's key - C)
	private _nx = MCCMK_av_hzNames select ([MCCMK_av_unit] call MCCMK_fnc_avHzNext);
	// (the same in first and third person - the AI view is in both)
	private _txt = if (MCCMK_av_fpNative) then { format ["%1  Default", _c] } else { format ["%2  %3      %1  AI View", _c, _vk, _nx] };
	// (the camera moved off the crewman's eye - Space puts it back; shown and faded with the rest of the line)
	if (call MCCMK_fnc_avOffEye) then { _txt = _txt + format ["      %1: Back to Crewman", ["MCCMK_av_reset", "Space"] call MCCMK_fnc_avKeyName]; };
	_ctl ctrlSetStructuredText parseText format ["<t align='center' size='0.75' shadow='2'>%1</t>", _txt];
	_ctl ctrlSetFade 0;
	_ctl ctrlCommit 0;
	// (the THIRD line - the camera now: "AI View", or the view of the cycle)
	private _ctl3 = uiNamespace getVariable ["MCCMK_av_ctrl3", controlNull];
	if (!isNull _ctl3) then {
		private _now = if (MCCMK_av_fpNative) then {"AI View"} else { MCCMK_av_hzNames select ([MCCMK_av_unit] call MCCMK_fnc_avHz) };
		_ctl3 ctrlSetStructuredText parseText format ["<t align='center' size='0.75' shadow='2'>%1</t>", _now];
		_ctl3 ctrlSetFade 0;
		_ctl3 ctrlCommit 0;
	};
	MCCMK_av_l2T = time + 10;
	[] spawn {
		sleep 10.05;
		if (time < MCCMK_av_l2T) exitWith {};
		{ private _c2 = uiNamespace getVariable [_x, controlNull]; if (!isNull _c2) then { _c2 ctrlSetFade 1; _c2 ctrlCommit 1; }; } forEach ["MCCMK_av_ctrl2", "MCCMK_av_ctrl3"];
	};
};
// V: the script camera / the AI view, first or third person
// NIGHT VISION (the game's own night vision key, as bound - N by default): on / off for the view's camera, kept while
// switching from man to man and between first and third person. The AI view is the game's own camera on the man and
// cannot be given night vision: switched on there, the view goes to the default view with it.
MCCMK_fnc_avNvg = {
	if (!MCCMK_av_on) exitWith {};
	MCCMK_av_nvg = !(missionNamespace getVariable ["MCCMK_av_nvg", false]);
	if (MCCMK_av_nvg && {MCCMK_av_fpNative} && {!MCCMK_av_fol}) then { call MCCMK_fnc_avAiToggle; };
	camUseNVG MCCMK_av_nvg;
	MCCMK_av_msg = if (MCCMK_av_nvg) then {"Night vision on"} else {"Night vision off"};
	MCCMK_av_msgT = time + 2;
	call MCCMK_fnc_avText;
};
MCCMK_fnc_avAiToggle = {
	if (!MCCMK_av_on || {MCCMK_av_fol}) exitWith {};   // (in third person too)
	MCCMK_av_fpNative = !MCCMK_av_fpNative;
	profileNamespace setVariable ["MCCMK_av_fpNative", MCCMK_av_fpNative];
	["MCCMK_av_mNative", MCCMK_av_fpNative] call MCCMK_fnc_avMemSet;   // (remembered for this man, his vehicle and as the last used)
	call MCCMK_fnc_avApply;
};
// C: the next view in the cycle ([-1]: Shift + C, the one before) - the script camera
MCCMK_fnc_avFixToggle = {
	params [["_st", 1]];   // (1 forwards, -1 backwards - Shift + C)
	// (in third person too - the view's settings for the third-person camera; in first person not in the AI view)
	if (!MCCMK_av_on || {MCCMK_av_fol} || {MCCMK_av_fpNative}) exitWith {};   // (not in the AI view - first or third person)
	// (on foot - Default > World Locked > Fly By)
	if (vehicle MCCMK_av_unit == MCCMK_av_unit) exitWith {
		private _oldF = MCCMK_av_hzModeFoot;
		private _nf = count MCCMK_av_footCycle;
		MCCMK_av_hzModeFoot = MCCMK_av_footCycle select ((((MCCMK_av_footCycle find _oldF) max 0) + _st + _nf) % _nf);
		if (_oldF == 0) then { MCCMK_av_h0 = getDirVisual MCCMK_av_unit; };
		MCCMK_av_fb = [];
		MCCMK_av_dirKey = [];
		profileNamespace setVariable ["MCCMK_av_hzModeFoot", MCCMK_av_hzModeFoot];
		["MCCMK_av_mHzF", MCCMK_av_hzModeFoot] call MCCMK_fnc_avMemSet;   // (remembered for this man and as the last used)
		call MCCMK_fnc_avApply;
	};
	private _old = MCCMK_av_hzMode;
	MCCMK_av_hzMode = (_old + _st + 6) % 6;
	// (into a view not following the heading from one that did: it keeps the compass direction faced now)
	if ((MCCMK_av_hzAxes select _old) select 0) then { MCCMK_av_h0 = getDirVisual (vehicle MCCMK_av_unit); };
	MCCMK_av_fb = [];
	MCCMK_av_dirKey = [];
	profileNamespace setVariable ["MCCMK_av_hzMode", MCCMK_av_hzMode];
	["MCCMK_av_mHzV", MCCMK_av_hzMode] call MCCMK_fnc_avMemSet;   // (remembered for this man, his vehicle and as the last used)
	call MCCMK_fnc_avApply;
};
// [vehicle, simulated?] -> [forward, up] of the view's frame for views 1 - 4 : the vehicle's heading, nose up /
// down and banking - each followed or not (not: the locked compass direction / level / no banking)
MCCMK_fnc_avAxes = {
	params ["_v", "_sim"];
	private _d = if (_sim) then { vectorDir _v } else { vectorDirVisual _v };
	private _uv = if (_sim) then { vectorUp _v } else { vectorUpVisual _v };
	private _h = (_d select 0) atan2 (_d select 1);
	private _p = asin (((_d select 2) max -1) min 1);
	private _r0 = [cos _h, -(sin _h), 0];
	private _f0 = [(sin _h) * (cos _p), (cos _h) * (cos _p), sin _p];
	private _u0 = _r0 vectorCrossProduct _f0;
	private _b = (_uv vectorDotProduct _r0) atan2 (_uv vectorDotProduct _u0);
	(MCCMK_av_hzAxes select MCCMK_av_hzMode) params ["_fh", "_fp", "_fbk"];
	private _hs = if (_fh) then {_h} else {MCCMK_av_h0};
	private _ps = if (_fp) then {_p} else {0};
	private _bs = if (_fbk) then {_b} else {0};
	private _r = [cos _hs, -(sin _hs), 0];
	private _f = [(sin _hs) * (cos _ps), (cos _hs) * (cos _ps), sin _ps];
	private _u = _r vectorCrossProduct _f;
	[_f, (_u vectorMultiply (cos _bs)) vectorAdd (_r vectorMultiply (sin _bs))]
};
// [vehicle] -> FLY BY: the next shot, 5 - 10 s, a different kind from the last, picked at random:
//  0 fly-past - the camera still, ahead on the vehicle's path and off to one side, turning to follow it past
//  1 low - on the ground beside its path, looking up as it goes over
//  2 overhead - high above its path, looking down as it passes under
//  3 chase sweep - from behind, swinging round to its side, keeping with it
//  4 alongside - level with it to one side, drifting from its rear quarter to its front quarter
MCCMK_fnc_avFbNew = {
	params ["_v"];
	// (a MAN ON FOOT - three of the shots, scaled to him: low (on the ground beside his way, looking up), chase
	//  sweep (behind, swinging round to his side), alongside (level with him, drifting forward))
	if (_v isKindOf "CAManBase") exitWith {
		private _t = selectRandom ([1, 3, 4] - [MCCMK_av_fbLast]);
		MCCMK_av_fbLast = _t;
		private _dur = 5 + (random 5);
		private _p = getPosASLVisual _v;
		private _vel = velocity _v;
		private _spd = vectorMagnitude _vel;
		private _hd = if (_spd > 0.5) then { (_vel select 0) atan2 (_vel select 1) } else { getDirVisual _v };
		private _fw = [sin _hd, cos _hd, 0];
		private _rt = [cos _hd, -(sin _hd), 0];
		private _sd = selectRandom [-1, 1];
		private _a = [];
		switch (_t) do {
			case 1: { _a = (_p vectorAdd (_fw vectorMultiply ((_spd * _dur * 0.45) max 6))) vectorAdd (_rt vectorMultiply (_sd * (2 + (random 3)))); _a set [2, ((getTerrainHeightASL _a) max 0) + 0.3]; };
			case 3: { _a = [180 + (_sd * (random 20)), _sd * (60 + (random 40)), 5 + (random 4), 1.2 + (random 1.5)]; };
			default { _a = [_sd * 115, _sd * 65, 4 + (random 3), 0.3 + (random 1)]; };
		};
		MCCMK_av_fb = [_t, time + _dur, _dur, _a];
	};
	private _t = selectRandom ([0, 1, 2, 3, 4] - [MCCMK_av_fbLast]);
	MCCMK_av_fbLast = _t;
	private _dur = 5 + (random 5);
	private _p = _v modelToWorldVisualWorld [0, 0, 0];
	private _vel = velocity _v;
	private _spd = vectorMagnitude _vel;
	private _hd = if (_spd > 3) then { (_vel select 0) atan2 (_vel select 1) } else { getDirVisual _v };
	private _fw = [sin _hd, cos _hd, 0];
	private _rt = [cos _hd, -(sin _hd), 0];
	private _sd = selectRandom [-1, 1];
	// (where it will be a little under half way through the shot - at least 40 m ahead)
	private _tt = _dur * 0.45;
	private _pred = if ((_spd * _tt) > 40) then { _p vectorAdd (_vel vectorMultiply _tt) } else { _p vectorAdd (_fw vectorMultiply 40) };
	private _a = [];
	switch (_t) do {
		case 0: { _a = (_pred vectorAdd (_rt vectorMultiply (_sd * (15 + (random 30))))) vectorAdd [0, 0, (random 15) - 5]; };
		case 1: { _a = _pred vectorAdd (_rt vectorMultiply (_sd * (8 + (random 12)))); _a set [2, ((getTerrainHeightASL _a) max 0) + 1.5]; };
		case 2: { _a = (_pred vectorAdd (_rt vectorMultiply (_sd * (random 6)))) vectorAdd [0, 0, 25 + (random 25)]; };
		case 3: { _a = [180 + (_sd * (random 20)), _sd * (60 + (random 40)), 25 + (random 20), 3 + (random 7)]; };
		default { _a = [_sd * 115, _sd * 65, 20 + (random 15), (random 8) - 2]; };
	};
	MCCMK_av_fb = [_t, time + _dur, _dur, _a];
};

// [unit] -> everyone to switch between, in order: the vehicle's crew by rank - an aircraft: pilot, co-pilot,
// gunner, commander, other turrets, passengers; anything else: driver, commander, gunner, other turrets, passengers -
// then the rest of his group (each in his own vehicle or on foot), in the group's order
MCCMK_fnc_avCrewList = {
	params ["_u"];
	private _v = vehicle _u;
	private _list = [];
	if (_v != _u) then {
		private _air = _v isKindOf "Air";
		private _rk = [];
		{
			_x params ["_cu", "_role", "", "_tp"];
			if (alive _cu) then {
				private _r = toLower _role;
				private _cop = _r == "turret" && {count _tp > 0} && {(getNumber (([_v, _tp] call BIS_fnc_turretConfig) >> "isCopilot")) > 0};
				private _k = if (_air) then {
					switch (true) do { case (_r == "driver"): {0}; case (_cop): {1}; case (_r == "gunner"): {2}; case (_r == "commander"): {3}; case (_r == "turret"): {4}; default {5}; }
				} else {
					switch (true) do { case (_r == "driver"): {0}; case (_r == "commander"): {1}; case (_r == "gunner"): {2}; case (_r == "turret"): {3}; default {4}; }
				};
				_rk pushBack [(_k * 1000) + _forEachIndex, _cu];
			};
		} forEach (fullCrew [_v, "", false]);
		// (sorted by the rank number alone - "sort" fails on lists holding units, so nobody could be switched to)
		private _keys = _rk apply {_x select 0};
		_keys sort true;
		_list = _keys apply { private _kk = _x; (_rk select (_rk findIf {(_x select 0) == _kk})) select 1 };
	} else { _list = [_u]; };
	{ if (alive _x && {!(_x in _list)} && {_x != player}) then { _list pushBack _x; }; } forEach (units (group _u));
	_list
};
// [+1 / -1] -> the next / previous one in that order, round and round
MCCMK_fnc_avCycle = {
	params ["_st"];
	if (!MCCMK_av_on || {MCCMK_av_fol} || {time < (missionNamespace getVariable ["MCCMK_av_cycT", -1])}) exitWith {};
	MCCMK_av_cycT = time + 0.2;   // (once per press - the key and its CBA keybind can both report it)
	private _old = MCCMK_av_unit;
	// (the order is built from the same man each time - the one the switching started from - so it stays the same
	// while switching and the numbers count through it. A new man not in it (another group opened,
	//  or that man gone): built again from him.)
	private _anchor = missionNamespace getVariable ["MCCMK_av_cycAnchor", objNull];
	private _list = if (!isNull _anchor && {alive _anchor}) then {[_anchor] call MCCMK_fnc_avCrewList} else {[]};
	if !(_old in _list) then {
		MCCMK_av_cycAnchor = _old;
		_list = [_old] call MCCMK_fnc_avCrewList;
	};
	if (count _list < 2) exitWith { MCCMK_av_msg = "No one else in this vehicle or group"; MCCMK_av_msgT = time + 2; call MCCMK_fnc_avText; };
	private _i = _list find _old;
	private _nu = _list select ((_i + _st + (count _list)) % (count _list));
	_old hideObject false;
	MCCMK_av_unit = _nu;
	MCCMK_av_folShown = false;
	[_nu] call MCCMK_fnc_avSeat;
	[vehicle _nu] call MCCMK_fnc_avHookFired;
	call MCCMK_fnc_avApply;
	private _v = vehicle _nu;
	private _role = if (_v == _nu) then {"on foot"} else {
		private _r = toLower ((assignedVehicleRole _nu) param [0, ""]);
		private _tp = (assignedVehicleRole _nu) param [1, []];
		switch (true) do {
			case (driver _v == _nu): { if (_v isKindOf "Air") then {"pilot"} else {"driver"} };
			case (_r == "turret" && {count _tp > 0} && {(getNumber (([_v, _tp] call BIS_fnc_turretConfig) >> "isCopilot")) > 0}): {"co-pilot"};
			case (gunner _v == _nu): {"gunner"};
			case (commander _v == _nu): {"commander"};
			case (_r == "turret"): {"turret"};
			default {"passenger"};
		}
	};
	MCCMK_av_msg = format ["%1 - %2   (%3 of %4)", name _nu, _role, (_list find _nu) + 1, count _list];
	MCCMK_av_msgT = time + 3;
	call MCCMK_fnc_avText;
	[] spawn { sleep 3.1; call MCCMK_fnc_avText; };
};
// the camera back on the eye - and the look back inside the seat's limits
// (first person - the default cockpit position: on the eye, looking forward; third person - the default third-
//  person position: behind, at the config's distance and angle)
MCCMK_fnc_avReset = {
	if (MCCMK_av_fol) exitWith {};
	if (MCCMK_av_mode == "INTERNAL") then {
		MCCMK_av_off = [0, 0, 0];
		MCCMK_av_eyeZ = 0;
		MCCMK_av_vy = 0;
		MCCMK_av_vp = 0;
	} else {
		MCCMK_av_ty = 0;
		MCCMK_av_tp = missionNamespace getVariable ["MCCMK_av_tpBase", MCCMK_av_tp];
		MCCMK_av_tDist = MCCMK_av_tBase;
	};
};
// [up?] the mouse speed 10% up / down, shown at the top for 3 s
MCCMK_fnc_avSensStep = {
	params ["_upS"];
	MCCMK_av_sens = (round ((MCCMK_av_sens * (if (_upS) then {1.1} else {1 / 1.1})) * 1000)) / 1000;
	MCCMK_av_sensT = time + 3;
	call MCCMK_fnc_avText;
	[] spawn { sleep 3.1; call MCCMK_fnc_avText; };
};
// first / third person (not while following a bomb or missile; not twice within 0.3 s - the key and the game's own
// action both report it)
MCCMK_fnc_avToggle = {
	if (!MCCMK_av_on || {MCCMK_av_fol} || {time < (missionNamespace getVariable ["MCCMK_av_togT", -1])}) exitWith {};
	MCCMK_av_togT = time + 0.3;
	// (CBA "Enable Cockpit View" off - third person only)
	if (!(missionNamespace getVariable ["MCCMK_CockpitViewEnabled", true])) exitWith { if (MCCMK_av_mode != "EXTERNAL") then { MCCMK_av_mode = "EXTERNAL"; call MCCMK_fnc_avApply; }; };
	MCCMK_av_mode = if (MCCMK_av_mode == "INTERNAL") then {"EXTERNAL"} else {"INTERNAL"};
	call MCCMK_fnc_avApply;
};
// [key code, shift, ctrl, alt] -> is it the game's "switch view" key (personView) as the player has it bound - also
// with Shift / Ctrl / Alt held (the game keeps such a binding as the key plus the modifier in the top byte)
// THE MAP KEY, from wherever it is reported - the keyboard, a mouse button, or the game's own ShowMap action (a
// user-action handler, so ANY binding reaches it: the keyboard handler never saw a mouse button, and the mouse handler never
// looked for the map). Once only per press, however many of those report it.
//   1. The pointer goes to the middle of the screen NOW - before the map opens - and is not parked again meanwhile, so the
//      map's edge scrolling does not take hold of it and carry the map off.
//   2. The script camera is put aside for it (the game's own map will not open over it in a vehicle), and the map
//      is opened by hand a moment later if the key did not open it.
//   3. Once the map is up it is put on the man being watched, as the game's own map opens on the man the player is.
// [map control, position] -> the map put on that position at its own scale - but NEVER SHOWING WHAT IS OUTSIDE THE WORLD (the
// "out of bounds" area and the infinite terrain beyond the edge). The position is moved in from the edge until the whole
// of what the map shows is inside the world - so a man near the edge is not in the middle of the map - and if the map
// is zoomed out further than the world fills, it is zoomed in until it does. What the map shows is read back from the map
// itself (the corners of the control, in world coordinates) once it has moved, so it needs no assumption about the scale.
// Runs in a script (it waits for the map to move).
MCCMK_fnc_avMapFit = {
	params ["_map", "_pos"];
	private _ws = worldSize;
	private _px = ((_pos select 0) max 0) min _ws;
	private _py = ((_pos select 1) max 0) min _ws;
	private _sc = ctrlMapScale _map;
	ctrlMapAnimClear _map;
	_map ctrlMapAnimAdd [0, _sc, [_px, _py]];
	ctrlMapAnimCommit _map;
	private _t = time + 1;
	waitUntil { ctrlMapAnimDone _map || {time > _t} };
	private _cp = ctrlPosition _map;
	private _tl = _map ctrlMapScreenToWorld [_cp select 0, _cp select 1];
	private _br = _map ctrlMapScreenToWorld [(_cp select 0) + (_cp select 2), (_cp select 1) + (_cp select 3)];
	private _hw = (abs ((_br select 0) - (_tl select 0))) / 2;
	private _hh = (abs ((_tl select 1) - (_br select 1))) / 2;
	if (_hw <= 0 || {_hh <= 0}) exitWith {};
	// (zoomed out further than the world fills: zoomed in until it just does)
	private _f = (((_ws / (2 * _hw)) min (_ws / (2 * _hh))) min 1);
	if (_f < 1) then { _f = _f * 0.98; _sc = _sc * _f; _hw = _hw * _f; _hh = _hh * _f; };
	private _cx = (_px max _hw) min (_ws - _hw);
	private _cy = (_py max _hh) min (_ws - _hh);
	if (_f < 1 || {abs (_cx - _px) > 1} || {abs (_cy - _py) > 1}) then {
		ctrlMapAnimClear _map;
		_map ctrlMapAnimAdd [0, _sc, [_cx, _cy]];
		ctrlMapAnimCommit _map;
	};
};

MCCMK_fnc_avMapKey = {
	if (!MCCMK_av_on || {visibleMap} || {time < MCCMK_av_mapKeyT}) exitWith {};
	MCCMK_av_mapKeyT = time + 0.5;
	MCCMK_av_mapPendT = time + 2;
	setMousePosition [safeZoneX + (safeZoneW * 0.5), safeZoneY + (safeZoneH * 0.5)];
	// (the script camera is put aside only once the map COVERS the screen, so the game's own camera on the man (the AI
	//  view) does not show for a moment before the map comes up)
	[] spawn {
		sleep 0.1;
		if (MCCMK_av_on && {!visibleMap}) then { openMap [true, false]; };
		private _until = time + 2;
		waitUntil { visibleMap || {time > _until} };
		if (!visibleMap) exitWith { MCCMK_av_mapPendT = -1; };
		if (MCCMK_av_camOn) then {
			MCCMK_av_cam cameraEffect ["terminate", "back"];
			MCCMK_av_camOn = false;
			MCCMK_av_camFx = "";
			MCCMK_av_mapCam = true;
			MCCMK_av_mapCamT = time + 1;
			if (alive MCCMK_av_unit) then { MCCMK_av_unit switchCamera MCCMK_av_mode; };
		};
		MCCMK_av_mapPendT = -1;
		// (the pointer in the middle, and the map on the man watched - at the map's own scale, but never showing what lies outside
		//  the world: see MCCMK_fnc_avMapFit)
		setMousePosition [safeZoneX + (safeZoneW * 0.5), safeZoneY + (safeZoneH * 0.5)];
		private _map = (findDisplay 12) displayCtrl 51;
		private _u = MCCMK_av_unit;
		if (!isNull _map && {!isNull _u}) then { [_map, getPosWorld (vehicle _u)] call MCCMK_fnc_avMapFit; };
	};
};

MCCMK_fnc_avIsView = {
	params ["_k", ["_sh", false], ["_ct", false], ["_al", false], ["_act", "personView"]];
	private _ak = actionKeys _act;
	private _c = [_k];
	if (_sh) then { _c append [(42 * 16777216) + _k, (54 * 16777216) + _k]; };
	if (_ct) then { _c append [(29 * 16777216) + _k, (157 * 16777216) + _k]; };
	if (_al) then { _c append [(56 * 16777216) + _k, (184 * 16777216) + _k]; };
	(_c findIf {_x in _ak}) >= 0
};

// the very short fade from black
MCCMK_fnc_avFade = { "MCCMK_avFade" cutText ["", "BLACK IN", 0.35]; };

// [unit, vehicle] -> the man's eye in the vehicle's own frame, 10 cm forward: his eye position (eyePos) against
// the vehicle's position at the same moment (worldToModel - both simulated).
MCCMK_fnc_avEye = {
	params ["_u", "_v"];
	(_v worldToModel (ASLToAGL (eyePos _u))) vectorAdd [0, 0.1, 0]
};
// [unit] -> set up for the unit's seat: its eye in the vehicle's own frame, its look limits, the third-person distance
MCCMK_fnc_avSeat = {
	params ["_u"];
	private _v = vehicle _u;
	MCCMK_av_veh = _v;
	// (the eye, in the vehicle's frame - so the view moves with the vehicle smoothly; 10 cm forward of it. worked
	// out against the vehicle's SIMULATED position, as eyePos is - against its drawn position (worldToModelVisual) the
	// eye of a fast plane's pilot comes out metres ahead of the nose)
	if (_v != _u) then { MCCMK_av_eyeRel = [_u, _v] call MCCMK_fnc_avEye; };
	// (and measured again 0.3, 1 and 2 s later - on the FIRST opening the eye came out in the wrong place (the
	//  vehicle far off and not yet fully in the game's detail), right on re-opening. Each time the man is shown, measured
	//  and hidden again in the same instant, so nothing flickers.)
	if (_v != _u) then {
		[_u, _v] spawn {
			params ["_u", "_v"];
			{
				sleep _x;
				if (!MCCMK_av_on || {vehicle _u != _v} || {MCCMK_av_veh != _v}) exitWith {};
				isNil {
					private _hid = isObjectHidden _u;
					if (_hid) then { _u hideObject false; };
					MCCMK_av_eyeRel = [_u, _v] call MCCMK_fnc_avEye;
					if (_hid) then { _u hideObject true; };
				};
			} forEach [0.3, 0.7, 1];
		};
	};
	// (the look limits: the seat's own config - the driver's / pilot's ViewPilot, a turret's ViewGunner, a man's own)
	private _vc = if (_v == _u) then { configFile >> "CfgVehicles" >> typeOf _u >> "ViewPilot" } else {
		if (driver _v == _u) then { configFile >> "CfgVehicles" >> typeOf _v >> "ViewPilot" } else {
			private _tp = (assignedVehicleRole _u) param [1, []];
			if (count _tp > 0) then { ([_v, _tp] call BIS_fnc_turretConfig) >> "ViewGunner" } else { configFile >> "CfgVehicles" >> typeOf _u >> "ViewPilot" }
		}
	};
	private _yl = (abs (getNumber (_vc >> "minAngleY"))) max (abs (getNumber (_vc >> "maxAngleY")));
	private _pDn = getNumber (_vc >> "minAngleX");
	private _pUp = getNumber (_vc >> "maxAngleX");
	MCCMK_av_yLim = if (_yl > 1) then {_yl} else {150};
	MCCMK_av_pDn = if (_pDn < -1) then {_pDn} else {-60};
	MCCMK_av_pUp = if (_pUp > 1) then {_pUp} else {75};
	// (third person where the GAME'S OWN puts it - the vehicle's (or man's) config extCameraPosition [side, up,
	//  forward (negative: behind)] from its middle: its distance and its angle above, and the side offset (a man: over
	//  the shoulder). None in its config: back by the vehicle's size.)
	private _ec = getArray (configFile >> "CfgVehicles" >> typeOf _v >> "extCameraPosition");
	MCCMK_av_tSide = 0;
	if (count _ec >= 3 && {((abs (_ec select 1)) + (abs (_ec select 2))) > 0.1}) then {
		MCCMK_av_tBase = (sqrt (((_ec select 1) ^ 2) + ((_ec select 2) ^ 2))) max 1;
		MCCMK_av_tp = (_ec select 1) atan2 ((abs (_ec select 2)) max 0.1);
		MCCMK_av_tSide = _ec select 0;
	} else {
		MCCMK_av_tBase = if (_v == _u) then {3.5} else { ((sizeOf (typeOf _v)) * 1.1) + 2 };
		MCCMK_av_tp = 12;
	};
	MCCMK_av_tDist = MCCMK_av_tBase;
	MCCMK_av_tUp = if (_v == _u) then {1.2} else {0};
	MCCMK_av_vy = 0; MCCMK_av_vp = 0; MCCMK_av_eyeZ = 0; MCCMK_av_off = [0, 0, 0];
	MCCMK_av_attKey = []; MCCMK_av_dirKey = [];
	MCCMK_av_ty = 0;
	MCCMK_av_tpBase = MCCMK_av_tp;   // (for Space in third person)
	MCCMK_av_h0 = getDirVisual _v;
	MCCMK_av_fb = [];
	// (the C view last used on THIS vehicle (or man on foot) this mission; the first time: Default)
	private _lh = [_u, if (_v == _u) then {"MCCMK_av_mHzF"} else {"MCCMK_av_mHzV"}, 0] call MCCMK_fnc_avMemGet;   // (this man's, else his vehicle's, else the last used)
	if (_v == _u) then { MCCMK_av_hzModeFoot = if (_lh in MCCMK_av_footCycle) then {_lh} else {0}; } else { MCCMK_av_hzMode = if (_lh isEqualType 0 && {_lh >= 0} && {_lh <= 5}) then {_lh} else {0}; };
	// (what is SHOWN eases after what is asked - the look, the vehicle's heading, the distance - as the game's
	//  own third-person camera does: it trails a turn and settles, rather than snapping)
	MCCMK_av_tyS = 0; MCCMK_av_tpS = MCCMK_av_tp; MCCMK_av_tDistS = MCCMK_av_tDist; MCCMK_av_hdS = getDirVisual _v;
};

// ---------------------------------------------------------------------------------------------------------------
// SOUND FOLLOWS THE CAMERA. What is heard has to come from where the camera IS. Two things decide it:
//   - the script camera's EFFECT TYPE. "internal" is the game's inside-a-vehicle camera: it is used only for the
//     first-person eye in a vehicle, so the third-person orbit, the Fly By shots, a camera moved off the eye and the
//     bomb view do not sound as if in the cockpit.
//   - the game's own CAMERA FOCUS (switchCamera). The AI view puts it on the man watched, in the view it shows. The focus
//     is kept on the man watched in the SAME view as the script camera (INTERNAL where it is inside a vehicle, EXTERNAL
//     where it is not), so the sound does not stay inside the cockpit under a camera that is outside.
// The AI view itself is the game's own camera, so its sound is the game's. CBA "Alternative View: Sound Follows
// Camera" (MCCMK_AltViewSoundMatch) off = the game's own sound handling.
// ---------------------------------------------------------------------------------------------------------------
// is the script camera inside a vehicle? - the first-person eye in a vehicle, not following a bomb, not a Fly By
// shot, not moved more than 1.5 m off the eye. Everything else is out in the open.
MCCMK_fnc_avInside = {
	private _u = MCCMK_av_unit;
	if (!MCCMK_av_on || {isNull _u}) exitWith {false};
	(MCCMK_av_mode == "INTERNAL") && {!MCCMK_av_fol} && {(vehicle _u) != _u} && {([_u] call MCCMK_fnc_avHz) != 5} && {(vectorMagnitude MCCMK_av_off) < 1.5}
};
// the effect type and the game's camera focus made to say where the camera is (only while the script camera is up)
MCCMK_fnc_avAudio = {
	if (!MCCMK_av_on || {!(missionNamespace getVariable ["MCCMK_AltViewSoundMatch", true])}) exitWith {};
	if (isNull MCCMK_av_cam || {!MCCMK_av_camOn}) exitWith {};   // (the AI view, or the map: the game's own camera - its own sound)
	private _u = MCCMK_av_unit;
	if (isNull _u || {!alive _u}) exitWith {};
	private _in = call MCCMK_fnc_avInside;
	private _fx = if (_in) then {"internal"} else {"external"};
	private _view = if (_in) then {"INTERNAL"} else {"EXTERNAL"};
	private _key = [_u, _view];
	if (MCCMK_av_camFx == _fx && {_key isEqualTo MCCMK_av_focusKey}) exitWith {};
	// (all in one go, unscheduled: the effect off, the game's camera on the man in that view, the effect back on -
	//  nothing is drawn in between)
	isNil {
		MCCMK_av_cam cameraEffect ["terminate", "back"];
		_u switchCamera _view;
		MCCMK_av_cam cameraEffect [_fx, "back"];
		showCinemaBorder false;
	};
	MCCMK_av_camFx = _fx;
	MCCMK_av_focusKey = _key;
};

// ---------------------------------------------------------------------------------------------------------------
// THE WATCHED MAN'S RADIO SILENT - AND HIS GROUP'S AND HIS VEHICLE'S. With the camera on him, his radio
// calls and chatter are as loud as the player's own would be, over everything else - and so are the answers: a co-pilot
// confirming the pilot's orders, the rest of the group acknowledging theirs. So everyone round him is silenced with him:
//   - the man watched,  - everyone in his group,  - everyone aboard his vehicle (a crewman can be in another group).
// Each is given NoVoice (setSpeaker - local effect: only on this machine, so in multiplayer nobody else's game changes) for
// as long as he is in that set, and his own speaker back when he leaves it (the watched man changes, someone gets out or
// dies, the view closes). The player is never silenced - his own radio is untouched.
// CBA "Alternative View: Silence Watched Unit's Radio" (MCCMK_AltViewMuteRadio) off = no one is silenced.
// ---------------------------------------------------------------------------------------------------------------
// [men] (or a single man, or objNull / []: no one) - everyone silenced before gets his speaker back; then these are silenced
MCCMK_fnc_avMute = {
	params [["_list", []]];
	if !(_list isEqualType []) then { _list = [_list]; };
	{ _x params ["_m", "_sp"]; if (!isNull _m) then { _m setSpeaker _sp; }; } forEach MCCMK_av_mute;
	MCCMK_av_mute = [];
	if !(missionNamespace getVariable ["MCCMK_AltViewMuteRadio", true]) exitWith {};
	{
		if (!isNull _x && {_x != player}) then {
			MCCMK_av_mute pushBack [_x, speaker _x];
			_x setSpeaker "NoVoice";
		};
	} forEach _list;
};
// who is to be silent now: the man watched, his group, his vehicle's crew - alive, never the player. [] when none.
MCCMK_fnc_avMuteWho = {
	private _u = MCCMK_av_unit;
	if (!MCCMK_av_on || {isNull _u} || {_u == player} || {!alive _u} || {!(missionNamespace getVariable ["MCCMK_AltViewMuteRadio", true])}) exitWith {[]};
	private _all = [_u] + (units group _u) + (crew (vehicle _u));
	(_all arrayIntersect _all) select {!isNull _x && {alive _x} && {_x != player}}
};
// the ones silenced are the ones round the man watched now (called from avApply, and every quarter second by the watch - so
// the CBA setting is followed at once, someone who gets in, out or dies is followed, and the dead are given their voice back)
MCCMK_fnc_avMuteSync = {
	private _want = call MCCMK_fnc_avMuteWho;
	private _have = MCCMK_av_mute apply { _x select 0 };
	private _same = (count _want == count _have) && {(_want findIf {!(_x in _have)}) < 0};
	if (!_same) then { [_want] call MCCMK_fnc_avMute; };
};

// the man watched hidden in first person (this machine only), seen in third person
// (FIRST PERSON is the GAME'S OWN view from the crewman (switchCamera) - the real cockpit, fixed to where he
//  looks, no look-around; the script's own first-person camera is kept, switched off -
//  MCCMK_av_fpNative = false brings it back (full look-around, plainer cockpit). Third person and bomb view: the
//  script camera. This puts the right one on.)
MCCMK_fnc_avApply = {
	if (!MCCMK_av_on || {isNull MCCMK_av_cam}) exitWith {};
	call MCCMK_fnc_avMuteSync;   // (the man watched now is the one with the silent radio)
	private _fp = MCCMK_av_mode == "INTERNAL" && {!MCCMK_av_fol};
	// (the AI VIEW in third person too - the game's own camera on the man, first or third person as the view is;
	//  it stays on when first / third person is switched. Following a bomb or missile: the script camera.)
	private _nat = MCCMK_av_fpNative && {!MCCMK_av_fol};
	if (!isNull MCCMK_av_unit) then { ["MCCMK_av_mMode", MCCMK_av_mode] call MCCMK_fnc_avMemSet; };   // (first / third person remembered)
	if (!isNull MCCMK_av_unit) then { MCCMK_av_unit hideObject (_fp && {!_nat} && {([MCCMK_av_unit] call MCCMK_fnc_avHz) != 5}); };   // (on foot too)
	if (_nat) then {
		if (MCCMK_av_camOn) then { MCCMK_av_cam cameraEffect ["terminate", "back"]; MCCMK_av_camOn = false; };
		MCCMK_av_camFx = "";
		if (alive MCCMK_av_unit) then {
			MCCMK_av_unit switchCamera MCCMK_av_mode;
			// (held there for 1.5 s - the game's own switch-view key, let through, turned it straight back: first
			//  person flicked back to third. The watch below keeps it there after that.)
			[] spawn {
				private _e = time + 1.5;
				while {time < _e} do {
					if (MCCMK_av_on && {MCCMK_av_fpNative} && {!MCCMK_av_fol} && {!visibleMap} && {alive MCCMK_av_unit} && {cameraView in ["INTERNAL", "EXTERNAL"]} && {cameraView != MCCMK_av_mode}) then { MCCMK_av_unit switchCamera MCCMK_av_mode; };
					sleep 0.05;
				};
			};
		};
	} else {
		if (!MCCMK_av_camOn && {!MCCMK_av_mapCam}) then {   // (not while the map has it put aside)
			// ("internal" only where the camera is inside a vehicle - see MCCMK_fnc_avAudio)
			private _fx = if ((missionNamespace getVariable ["MCCMK_AltViewSoundMatch", true]) && {!(call MCCMK_fnc_avInside)}) then {"external"} else {"internal"};
			MCCMK_av_cam cameraEffect [_fx, "back"];
			showCinemaBorder false;
			MCCMK_av_camOn = true;
			MCCMK_av_camFx = _fx;
			MCCMK_av_focusKey = [];   // (the game's own focus may be on the man from the AI view, or was put there for the map: set it again)
		};
		call MCCMK_fnc_avAudio;
		camUseNVG (missionNamespace getVariable ["MCCMK_av_nvg", false]);
	};
	call MCCMK_fnc_avLine2;
};

// [dx, dy] call MCCMK_fnc_avLook: the look round - first person within the seat's limits, third person and bomb view an
// orbit (from the MouseMoving handler, moved here so the look input can drive it too)
MCCMK_fnc_avLook = {
	params ["_dx", "_dy"];
	private _s = MCCMK_av_sens;
	switch (true) do {
		case (MCCMK_av_fol): {
			MCCMK_av_by = MCCMK_av_by + (_dx * _s);
			MCCMK_av_bp = ((MCCMK_av_bp - (_dy * _s)) max -25) min 70;
		};
		case (MCCMK_av_mode == "INTERNAL"): {
			// (on the eye - the seat's own look limits; moved off it - free all the way round, up and down to
			//  89 degrees)
			if (MCCMK_av_off isEqualTo [0, 0, 0]) then {
				MCCMK_av_vy = ((MCCMK_av_vy + (_dx * _s)) max (-MCCMK_av_yLim)) min MCCMK_av_yLim;
				MCCMK_av_vp = ((MCCMK_av_vp - (_dy * _s)) max MCCMK_av_pDn) min MCCMK_av_pUp;
			} else {
				MCCMK_av_vy = ((((MCCMK_av_vy + (_dx * _s)) + 540) % 360) - 180);
				MCCMK_av_vp = ((MCCMK_av_vp - (_dy * _s)) max -89) min 89;
			};
		};
		default {
			MCCMK_av_ty = MCCMK_av_ty + (_dx * _s);
			MCCMK_av_tp = ((MCCMK_av_tp - (_dy * _s)) max -20) min 80;
		};
	};
};
// every frame, pointer parked: the look from the game's own look input, scaled to the mouse (see MCCMK_av_lookMode)
MCCMK_fnc_avLookFrame = {
	private _ix = (inputAction "AimRight") - (inputAction "AimLeft");
	private _iy = (inputAction "AimDown") - (inputAction "AimUp");
	MCCMK_av_mAcc params ["_mx", "_my"];
	MCCMK_av_mAcc = [0, 0];
	// (the scale, each way, from the two ways the parked pointer can still move - left and up; signed, so a player's own
	//  inverted mouse setting does not turn the camera the other way)
	if (_mx < 0 && {_ix != 0}) then { MCCMK_av_cal set [0, (MCCMK_av_cal select 0) - _mx]; MCCMK_av_cal set [1, (MCCMK_av_cal select 1) - _ix]; };
	if (_my < 0 && {_iy != 0}) then { MCCMK_av_cal set [2, (MCCMK_av_cal select 2) - _my]; MCCMK_av_cal set [3, (MCCMK_av_cal select 3) - _iy]; };
	if (_mx < 0 || {_my < 0}) then { MCCMK_av_cal set [4, (MCCMK_av_cal select 4) + 1]; };
	MCCMK_av_cal params ["_cmx", "_cix", "_cmy", "_ciy", "_cn"];
	if (MCCMK_av_lookMode == "learn") then {
		if (_cn >= 10 && {_cix != 0 || {_ciy != 0}}) then { MCCMK_av_lookMode = "input"; };
		if (_cn >= 40 && {_cix == 0} && {_ciy == 0}) then { MCCMK_av_lookMode = "free"; };
	};
	if (MCCMK_av_lookMode != "input") exitWith {};
	if (_ix == 0 && {_iy == 0}) exitWith {};
	// (one way not learnt yet: the other way's size of scale, the usual sign)
	private _kx = if (_cix != 0) then {_cmx / _cix} else { if (_ciy != 0) then {abs (_cmy / _ciy)} else {0} };
	private _ky = if (_ciy != 0) then {_cmy / _ciy} else {abs _kx};
	[_ix * _kx, _iy * _ky] call MCCMK_fnc_avLook;
};
// every frame: where the camera is and where it looks
MCCMK_fnc_avFrame = {
	// (the mouse pointer of the isolating screen parked in the bottom-right corner, out of the way - MCCMK_av_pinMouse =
	// false leaves it free) (in the MIDDLE - pinned in a corner, the pointer could not move further right or down, which
	// may have stopped the mouse look that way) (the very corner - the pointer's arrow is drawn down and right of its
	// tip, so there it falls off the screen) (the real bottom-right corner of the screen and a little past it - [1, 1]
	// is the corner of the 4:3 middle, still on a wide screen) (and the look from the game's look input -
	// MCCMK_fnc_avLookFrame; "free" - the game's look input gave nothing: parked a little inside the corner instead,
	// where the pointer can move every way)
	if (MCCMK_av_child && {MCCMK_av_pinMouse} && {!visibleMap} && {time > MCCMK_av_mapPendT} && {isGameFocused}) then {   // (not while the map is opening)
		if (MCCMK_av_lookMode == "free") then {
			setMousePosition [safeZoneX + (safeZoneW * 0.9), safeZoneY + (safeZoneH * 0.9)];
		} else {
			if (MCCMK_av_on) then { call MCCMK_fnc_avLookFrame; };
			setMousePosition [safeZoneX + safeZoneW + 0.05, safeZoneY + safeZoneH + 0.05];   // (never while the map is up)
		};
	};
	private _cam = MCCMK_av_cam;
	if (isNull _cam || {!MCCMK_av_camOn}) exitWith {};
	// BOMB VIEW - following a bomb or missile: an orbit round it, behind it along its flight to start with
	if (MCCMK_av_fol) exitWith {
		if (!isNull (attachedTo _cam)) then { detach _cam; MCCMK_av_attKey = []; MCCMK_av_dirKey = []; };
		private _p = MCCMK_av_proj;
		private _live = !isNull _p && {alive _p};
		// (a DROPPED LOAD is not gone when it arrives - it stays - it LANDS: down on the ground and nearly still)
		// ("on the ground" also when it comes to rest ON something - a helipad, a roof, rocks, another vehicle: touching the
		//  ground, or within 1.5 m of whatever is under it, nearly still - and never more than 45 s of following a drop.)
		if (_live && {MCCMK_av_drop} && {(vectorMagnitude (velocity _p)) < 2.5} && {(isTouchingGround _p) || {((getPos _p) select 2) < 1.5} || {((getPosATL _p) select 2) < 1.2}}) then { _live = false; };
		if (_live && {MCCMK_av_drop} && {time > (missionNamespace getVariable ["MCCMK_av_dropT0", 1e12]) + 45}) then { _live = false; };
		if (_live) then {
			MCCMK_av_last = getPosASLVisual _p;
			private _vl = velocity _p;
			// (a falling load has no direction of its own - the camera keeps to the way the aircraft was going)
			if (!MCCMK_av_drop && {(vectorMagnitude _vl) > 1}) then { MCCMK_av_lastDir = vectorNormalized _vl; };
		} else {
			// (it has hit or exploded: pulled back, holding on the spot 3 s, then back to the vehicle)
			if (MCCMK_av_endT < 0) then { MCCMK_av_endT = time + 3.5; MCCMK_av_bDist = MCCMK_av_bDist max 30; };
			if (time > MCCMK_av_endT) exitWith { MCCMK_av_endT = 1e12; [] spawn { [true] call MCCMK_fnc_avFolEnd; }; };
		};
		private _d = MCCMK_av_lastDir;
		private _yaw = ((_d select 0) atan2 (_d select 1)) + 180 + MCCMK_av_by;
		private _pit = ((15 + MCCMK_av_bp) max -10) min 85;
		private _cp = MCCMK_av_last vectorAdd [(sin _yaw) * (cos _pit) * MCCMK_av_bDist, (cos _yaw) * (cos _pit) * MCCMK_av_bDist, (sin _pit) * MCCMK_av_bDist];
		_cp set [2, (_cp select 2) max (((getTerrainHeightASL _cp) max 0) + 1)];
		_cam setPosASL _cp;
		_cam setVectorDirAndUp [vectorNormalized (MCCMK_av_last vectorDiff _cp), [0, 0, 1]];
	};
	private _u = MCCMK_av_unit;
	if (isNull _u) exitWith {};
	private _v = vehicle _u;
	// (how the FIRST-PERSON camera is placed - set from the debug console, MCCMK_av_camMethod =
	//  0: attached to the vehicle (or the man's head on foot), the game carrying it
	//  1: placed every frame from the vehicle's DRAWN position (modelToWorldVisualWorld) - the default
	//  2: placed every frame from the vehicle's SIMULATED position (modelToWorldWorld - the same moment the eye is measured at)
	//  Third person is not affected: level horizon, eased.)
	private _m = missionNamespace getVariable ["MCCMK_av_camMethod", 1];
	private _fb = ([_u] call MCCMK_fnc_avHz) == 5;   // (first and third person; on foot too)
	private _att = MCCMK_av_mode == "INTERNAL" && {_m == 0} && {!_fb};
	if (!_att && {!isNull (attachedTo _cam)}) then { detach _cam; MCCMK_av_attKey = []; MCCMK_av_dirKey = []; };
	// (the camera moved by the movement controls held - forward / back, right / left, up / down)
	private _hold = +MCCMK_av_hold;
	if (!MCCMK_av_cba) then {
		if (205 in MCCMK_av_keys && {!(42 in MCCMK_av_down)}) then { _hold pushBack "right"; };
		if (203 in MCCMK_av_keys && {!(42 in MCCMK_av_down)}) then { _hold pushBack "left"; };
		if (200 in MCCMK_av_keys) then { _hold pushBack (if (157 in MCCMK_av_keys) then {"up"} else {"fwd"}); };
		if (208 in MCCMK_av_keys) then { _hold pushBack (if (157 in MCCMK_av_keys) then {"down"} else {"back"}); };
	};
	if (MCCMK_av_mode == "INTERNAL" && {count _hold > 0}) then {
		private _fine = ("fine" in _hold) || {54 in MCCMK_av_down};   // (RIGHT Shift)
		private _st = (if (_fine) then {MCCMK_av_fineSpd} else {MCCMK_av_moveSpd}) * diag_deltaTime;
		private _o = +MCCMK_av_off;
		{ _x params ["_a", "_i", "_sg"]; if (_a in _hold) then { _o set [_i, (_o select _i) + (_st * _sg)]; }; } forEach [["right", 0, 1], ["left", 0, -1], ["fwd", 1, 1], ["back", 1, -1], ["up", 2, 1], ["down", 2, -1]];
		MCCMK_av_off = _o apply { (_x max (-MCCMK_av_moveMax)) min MCCMK_av_moveMax };
	};
	// (FLY BY - shots from outside, a new one every 5 - 10 s, the camera turning to keep the vehicle in view)
	if (_fb) exitWith {
		if (count MCCMK_av_fb == 0 || {time > (MCCMK_av_fb select 1)}) then { [_v] call MCCMK_fnc_avFbNew; call MCCMK_fnc_avFade; };
		MCCMK_av_fb params ["_t", "_end", "_dur", "_a"];
		private _man = _v == _u;
		private _vp = if (_man) then { (getPosASLVisual _u) vectorAdd [0, 0, 1.1] } else { _v modelToWorldVisualWorld [0, 0, 0] };   // (a man: his chest)
		private _cp = [];
		if (_t in [0, 1, 2]) then { _cp = +_a; } else {
			_a params ["_a0", "_a1", "_dist", "_ht"];
			private _k = (((time - (_end - _dur)) / _dur) max 0) min 1;
			_k = _k * _k * (3 - (2 * _k));
			private _ang = (getDirVisual _v) + _a0 + ((_a1 - _a0) * _k);
			_cp = _vp vectorAdd [(sin _ang) * _dist, (cos _ang) * _dist, _ht];
		};
		_cp set [2, (_cp select 2) max (((getTerrainHeightASL _cp) max 0) + (if (_man) then {0.3} else {1}))];
		private _d = vectorNormalized (_vp vectorDiff _cp);
		private _cu = (_d vectorCrossProduct [0, 0, 1]) vectorCrossProduct _d;
		if ((vectorMagnitude _cu) < 0.01) then { _cu = [0, 1, 0]; };
		_cam setPosASL _cp;
		_cam setVectorDirAndUp [_d, vectorNormalized _cu];
	};
	if (MCCMK_av_mode == "INTERNAL") then {
		// FIRST PERSON
		private _y = MCCMK_av_vy;
		private _pt = MCCMK_av_vp;
		if (_att) then {
			// (method 0 - attached at the eye in the vehicle's frame (on foot: the man's head), the look turned in
			//  that frame; attached again only when the place changes, turned only when the look changes)
			private _par = _v;
			private _bone = "";
			private _pos = [];
			if (_v == _u) then {
				_par = _u;
				_bone = "head";
				_pos = ([0, 0.1, 0.05] vectorAdd MCCMK_av_off) vectorAdd [0, 0, MCCMK_av_eyeZ];
			} else {
				_pos = (MCCMK_av_eyeRel vectorAdd [0, 0, MCCMK_av_eyeZ]) vectorAdd MCCMK_av_off;
			};
			private _dir = [(sin _y) * (cos _pt), (cos _y) * (cos _pt), sin _pt];
			private _up = vectorNormalized ((_dir vectorCrossProduct [0, 0, 1]) vectorCrossProduct _dir);
			private _key = [_par, _pos, _bone];
			if !(_key isEqualTo (missionNamespace getVariable ["MCCMK_av_attKey", []])) then {
				MCCMK_av_attKey = _key;
				if (_bone == "") then { _cam attachTo [_par, _pos]; } else { _cam attachTo [_par, _pos, _bone]; };
				MCCMK_av_dirKey = [];
			};
			if (MCCMK_av_hzMode in [1, 2, 3, 4] && {_v != _u}) then {
				// (the view cycle - the look worked out in the view's frame, turned into the vehicle's each frame)
				([_v, false] call MCCMK_fnc_avAxes) params ["_f0", "_u0"];
				private _r0 = _f0 vectorCrossProduct _u0;
				private _dW = vectorNormalized ((((_f0 vectorMultiply (cos _y)) vectorAdd (_r0 vectorMultiply (sin _y))) vectorMultiply (cos _pt)) vectorAdd (_u0 vectorMultiply (sin _pt)));
				private _uW = vectorNormalized ((_dW vectorCrossProduct _u0) vectorCrossProduct _dW);
				_cam setVectorDirAndUp [_v vectorWorldToModelVisual _dW, _v vectorWorldToModelVisual _uW];
				MCCMK_av_dirKey = [];
			} else {
				if !([_dir, _up] isEqualTo (missionNamespace getVariable ["MCCMK_av_dirKey", []])) then {
					MCCMK_av_dirKey = [_dir, _up];
					_cam setVectorDirAndUp [_dir, _up];
				};
			};
		} else {
			// (methods 1 and 2: placed at the eye every frame, the look turned in the vehicle's (or the
			//  man's) own frame; 1 from the vehicle's drawn position, 2 from its simulated position)
			private _sim = _m == 2;
			private _f = if (_sim) then { vectorDir _v } else { vectorDirVisual _v };
			private _up = if (_sim) then { vectorUp _v } else { vectorUpVisual _v };
			private _eye = [];
			if (_v == _u) then {
				private _hd = if (_sim) then { getDir _u } else { getDirVisual _u };
				if (MCCMK_av_hzModeFoot == 4) then { _hd = MCCMK_av_h0; };   // (World Locked - one compass direction)
				_f = [sin _hd, cos _hd, 0]; _up = [0, 0, 1];
				_eye = (eyePos _u) vectorAdd [0, 0, MCCMK_av_eyeZ];   // (the scroll wheel - the eye up / down a little)
			} else {
				_eye = (if (_sim) then { _v modelToWorldWorld MCCMK_av_eyeRel } else { _v modelToWorldVisualWorld MCCMK_av_eyeRel }) vectorAdd (_up vectorMultiply MCCMK_av_eyeZ);
				// (the view cycle - from the eye, the look turned in the view's frame)
				if (MCCMK_av_hzMode in [1, 2, 3, 4]) then {
					([_v, _sim] call MCCMK_fnc_avAxes) params ["_af", "_au"];
					_f = _af; _up = _au;
				};
			};
			private _r = _f vectorCrossProduct _up;
			_eye = _eye vectorAdd (((_r vectorMultiply (MCCMK_av_off select 0)) vectorAdd (_f vectorMultiply (MCCMK_av_off select 1))) vectorAdd (_up vectorMultiply (MCCMK_av_off select 2)));
			private _dir = vectorNormalized ((((_f vectorMultiply (cos _y)) vectorAdd (_r vectorMultiply (sin _y))) vectorMultiply (cos _pt)) vectorAdd (_up vectorMultiply (sin _pt)));
			private _cu = vectorNormalized ((_dir vectorCrossProduct _up) vectorCrossProduct _dir);
			_cam setPosASL _eye;
			_cam setVectorDirAndUp [_dir, _cu];
		};
	} else {
		// THIRD PERSON: round the vehicle or man, following its heading - level horizon
		private _c = if (_v == _u) then { (getPosASLVisual _u) vectorAdd [0, 0, MCCMK_av_tUp] } else { _v modelToWorldVisualWorld [0, 0, 0] };
		if (MCCMK_av_tSide != 0) then { private _hd0 = getDirVisual _v; _c = _c vectorAdd [(cos _hd0) * MCCMK_av_tSide, -(sin _hd0) * MCCMK_av_tSide, 0]; };
		// (the easing: the look and the distance close on what is asked with a 0.08 s time constant (MCCMK_av_lookLag),
		//  the vehicle's heading with 0.35 s (MCCMK_av_headLag) - frame-rate independent)
		private _dt = diag_deltaTime;
		private _kL = 1 - (exp (-_dt / (MCCMK_av_lookLag max 0.001)));
		private _kH = 1 - (exp (-_dt / (MCCMK_av_headLag max 0.001)));
		MCCMK_av_tyS = MCCMK_av_tyS + ((MCCMK_av_ty - MCCMK_av_tyS) * _kL);
		MCCMK_av_tpS = MCCMK_av_tpS + ((MCCMK_av_tp - MCCMK_av_tpS) * _kL);
		MCCMK_av_tDistS = MCCMK_av_tDistS + ((MCCMK_av_tDist - MCCMK_av_tDistS) * _kL);
		private _hErr = ((((getDirVisual _v) - MCCMK_av_hdS) + 540) % 360) - 180;
		MCCMK_av_hdS = MCCMK_av_hdS + (_hErr * _kH);
		if (_v != _u && {MCCMK_av_hzMode in [1, 2, 3, 4]}) exitWith {
			// (the view cycle in third person - the orbit round the vehicle turned in the view's frame (what it follows
			//  of the vehicle's heading, nose up / down and banking); the camera rolls with it where banking is followed)
			([_v, false] call MCCMK_fnc_avAxes) params ["_f", "_up"];
			private _r = _f vectorCrossProduct _up;
			private _cc = (_v modelToWorldVisualWorld [0, 0, 0]) vectorAdd (_r vectorMultiply MCCMK_av_tSide);
			private _ty = MCCMK_av_tyS;
			private _tp = MCCMK_av_tpS;
			private _off = ((((_f vectorMultiply (cos _ty)) vectorAdd (_r vectorMultiply (sin _ty))) vectorMultiply (-(cos _tp))) vectorAdd (_up vectorMultiply (sin _tp))) vectorMultiply MCCMK_av_tDistS;
			private _cp = _cc vectorAdd _off;
			_cp set [2, (_cp select 2) max (((getTerrainHeightASL _cp) max 0) + 0.5)];
			private _d = vectorNormalized (_cc vectorDiff _cp);
			private _cu = (_d vectorCrossProduct _up) vectorCrossProduct _d;
			if ((vectorMagnitude _cu) < 0.01) then { _cu = _up; };
			_cam setPosASL _cp;
			_cam setVectorDirAndUp [_d, vectorNormalized _cu];
		};
		private _yaw = (if (_v == _u && {MCCMK_av_hzModeFoot == 4}) then {MCCMK_av_h0} else {MCCMK_av_hdS}) + 180 + MCCMK_av_tyS;   // (on foot, World Locked)
		private _pit = MCCMK_av_tpS;
		private _cp = _c vectorAdd [(sin _yaw) * (cos _pit) * MCCMK_av_tDistS, (cos _yaw) * (cos _pit) * MCCMK_av_tDistS, (sin _pit) * MCCMK_av_tDistS];
		_cp set [2, (_cp select 2) max (((getTerrainHeightASL _cp) max 0) + 0.5)];
		_cam setPosASL _cp;
		_cam setVectorDirAndUp [vectorNormalized (_c vectorDiff _cp), [0, 0, 1]];
	};
};

// back from following a bomb or missile to the vehicle's view
MCCMK_fnc_avFolEnd = {
	params [["_fade", true]];
	if (!MCCMK_av_fol) exitWith {};
	MCCMK_av_fol = false;
	MCCMK_av_drop = false;
	MCCMK_av_proj = objNull;
	call MCCMK_fnc_avApply;
	if (_fade) then { call MCCMK_fnc_avFade; };
	call MCCMK_fnc_avText;
};

// (a round being followed split: follow its first piece on - and that piece's pieces in turn)
MCCMK_fnc_avSub = {
	params ["_p", "_sub"];
	if (!MCCMK_av_fol || {!(MCCMK_av_proj isEqualTo _p)} || {isNull _sub}) exitWith {};
	MCCMK_av_proj = _sub;
	_sub addEventHandler ["SubmunitionCreated", { call MCCMK_fnc_avSub; }];
};
// [projectile] -> follow it
MCCMK_fnc_avFolStart = {
	params ["_p"];
	if (!MCCMK_av_on || {!MCCMK_av_bomb} || {MCCMK_av_fol} || {isNull _p}) exitWith {};
	MCCMK_av_proj = _p;
	MCCMK_av_drop = false;
	// (a round that SPLITS as it leaves - the Wipeout's 30 mm (ACE) is a carrier that becomes its real round at
	//  once - is followed into its pieces: the first piece is followed on.)
	_p addEventHandler ["SubmunitionCreated", { call MCCMK_fnc_avSub; }];
	MCCMK_av_by = 0; MCCMK_av_bp = 0; MCCMK_av_bDist = 14;
	MCCMK_av_last = getPosASL _p;
	MCCMK_av_lastDir = vectorNormalized (velocity _p);
	MCCMK_av_endT = -1;
	MCCMK_av_fol = true;
	call MCCMK_fnc_avApply;
	call MCCMK_fnc_avFade;
	call MCCMK_fnc_avText;   // (the line says what a left-click does now)
};

// [object] -> follow a DROPPED LOAD - a supply crate, a vehicle, whatever has been let go of from an aircraft: the same
// orbit as for a round, a little further out for a big load, behind the way the aircraft was going; it ends when the load
// lands (see the frame) and holds 3.5 s, then back to the unit - or a left-click, which leaves bomb view ON.
MCCMK_fnc_avFolDrop = {
	params ["_o"];
	if (!MCCMK_av_on || {!MCCMK_av_bomb} || {MCCMK_av_fol} || {isNull _o} || {!alive _o}) exitWith {};
	MCCMK_av_proj = _o;
	MCCMK_av_drop = true;
	MCCMK_av_dropT0 = time;   // (when the following began - 45 s at most)
	MCCMK_av_by = 0; MCCMK_av_bp = 0;
	MCCMK_av_bDist = (((((boundingBoxReal _o) select 2) * 2.5) max 14) min 60);
	MCCMK_av_last = getPosASL _o;
	private _vd = velocity (vehicle MCCMK_av_unit);
	private _hd = [_vd select 0, _vd select 1, 0];
	MCCMK_av_lastDir = if ((vectorMagnitude _hd) > 1) then { vectorNormalized _hd } else { [sin (getDir (vehicle MCCMK_av_unit)), cos (getDir (vehicle MCCMK_av_unit)), 0] };
	MCCMK_av_endT = -1;
	MCCMK_av_fol = true;
	call MCCMK_fnc_avApply;
	call MCCMK_fnc_avFade;
	call MCCMK_fnc_avText;
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC [3D VIEW] following a drop - %1 from %2", typeOf _o, typeOf (vehicle MCCMK_av_unit)]};
};

// a parachute that has appeared (EntityCreated): looked at 0.7 s later - the vehicle drop makes its parachute at one
// point in the sky and moves it to the drop point, so it cannot be judged as it appears. A man's parachute (somebody in it) is
// no drop. A parachute within 400 m of the aircraft being watched, empty: what hangs from it - a crate, a vehicle - is followed
// (the parachute itself if nothing does). Vanilla supply drops, the vehicle drop and ACE's air drops all work this way.
MCCMK_fnc_avChuteCheck = {
	params ["_c"];
	sleep 0.7;
	if (isNull _c || {!MCCMK_av_on} || {!MCCMK_av_bomb} || {MCCMK_av_fol} || {isNull MCCMK_av_unit}) exitWith {};
	private _v = vehicle MCCMK_av_unit;
	if (!(_v isKindOf "Air") || {_v isKindOf "ParachuteBase"} || {(count (crew _c)) > 0} || {(_c distance _v) > 400}) exitWith {};
	private _load = (attachedObjects _c) select {alive _x && {!(_x isKindOf "ParachuteBase")}};
	[if (count _load > 0) then {_load select 0} else {_c}] call MCCMK_fnc_avFolDrop;
};

// every quarter second (the watch): what the aircraft watched has HELD - a slung load, vehicles in its cargo (vehicle in
// vehicle) - that is gone from it now, alive and more than 4 m up, within 60 m of it. (Set down on the ground, it is no
// drop.)
MCCMK_fnc_avDropWatch = {
	private _v = vehicle MCCMK_av_unit;
	if (isNull MCCMK_av_unit || {!(_v isKindOf "Air")} || {_v isKindOf "ParachuteBase"}) exitWith { MCCMK_av_dwVeh = objNull; MCCMK_av_dwPrev = []; };
	private _now = [];
	private _sl = getSlingLoad _v;
	if (!isNull _sl) then { _now pushBack _sl; };
	_now append (getVehicleCargo _v);
	if (MCCMK_av_dwVeh isEqualTo _v) then {
		{
			if (!(_x in _now) && {!isNull _x} && {alive _x} && {((getPosATL _x) select 2) > 4} && {(_x distance _v) < 60}) then { [_x] call MCCMK_fnc_avFolDrop; };
		} forEach MCCMK_av_dwPrev;
	};
	MCCMK_av_dwVeh = _v;
	MCCMK_av_dwPrev = _now;
};

MCCMK_fnc_avClose = {
	if (!MCCMK_av_on) exitWith {};
	call MCCMK_fnc_avMemSaveAll;   // (the camera chosen is kept - for this man, his vehicle and as the last used)
	MCCMK_av_on = false;
	MCCMK_av_nvg = false;
	camUseNVG false;
	MCCMK_av_bomb = false;
	MCCMK_av_fol = false;
	MCCMK_av_drop = false;
	MCCMK_av_offShown = false;
	if (!isNil "MCCMK_avDropEH") then { removeMissionEventHandler ["EntityCreated", MCCMK_avDropEH]; MCCMK_avDropEH = nil; };
	MCCMK_av_dwVeh = objNull; MCCMK_av_dwPrev = [];
	if (!isNil "MCCMK_avEachFrame") then { removeMissionEventHandler ["EachFrame", MCCMK_avEachFrame]; MCCMK_avEachFrame = nil; };
	if (!isNil "MCCMK_avMapEH") then { removeMissionEventHandler ["Map", MCCMK_avMapEH]; MCCMK_avMapEH = nil; };
	if (!isNil "MCCMK_avUAE") then { removeUserActionEventHandler ["personView", "Activate", MCCMK_avUAE]; MCCMK_avUAE = nil; };
	if (!isNil "MCCMK_avUAEmap") then { removeUserActionEventHandler ["ShowMap", "Activate", MCCMK_avUAEmap]; MCCMK_avUAEmap = nil; };
	MCCMK_av_mapPendT = -1;
	if (!isNull MCCMK_av_cam) then { if (MCCMK_av_camOn) then { MCCMK_av_cam cameraEffect ["terminate", "back"]; }; camDestroy MCCMK_av_cam; MCCMK_av_cam = objNull; };
	MCCMK_av_camOn = false;
	MCCMK_av_mapCam = false;
	if (!isNull MCCMK_av_unit) then { MCCMK_av_unit hideObject false; };
	private _d46 = findDisplay 46;
	// (the main screen's way out - see MCCMK_fnc_avInput)
	if (!isNull _d46) then {
		if (!isNil "MCCMK_avMB46") then { _d46 displayRemoveEventHandler ["MouseButtonDown", MCCMK_avMB46]; };
		if (!isNil "MCCMK_avKD46") then { _d46 displayRemoveEventHandler ["KeyDown", MCCMK_avKD46]; };
	};
	MCCMK_avMB46 = nil;
	MCCMK_avKD46 = nil;
	private _dsp = uiNamespace getVariable ["MCCMK_av_dsp", displayNull];
	uiNamespace setVariable ["MCCMK_av_dsp", nil];
	if (!isNull _dsp) then { _dsp closeDisplay 1; };
	if (MCCMK_av_child) then { _d46 = displayNull; };
	{ if (!isNil (_x select 0) && {!isNull _d46}) then { _d46 displayRemoveEventHandler [_x select 1, missionNamespace getVariable (_x select 0)]; missionNamespace setVariable [_x select 0, nil]; }; } forEach [["MCCMK_avKD", "KeyDown"], ["MCCMK_avMB", "MouseButtonDown"], ["MCCMK_avMM", "MouseMoving"], ["MCCMK_avMZ", "MouseZChanged"], ["MCCMK_avKU", "KeyUp"]];
	MCCMK_av_keys = [];
	MCCMK_av_hold = [];
	MCCMK_av_down = [];
	{ missionNamespace setVariable [_x, nil]; } forEach ["MCCMK_avKD", "MCCMK_avMB", "MCCMK_avMM", "MCCMK_avMZ", "MCCMK_avKU"];
	MCCMK_av_child = false;
	if (!isNil "MCCMK_avFiredV" && {!isNull MCCMK_avFiredV}) then { MCCMK_avFiredV removeEventHandler ["Fired", MCCMK_avFiredId]; };
	MCCMK_avFiredV = nil;
	ctrlDelete (uiNamespace getVariable ["MCCMK_av_ctrl", controlNull]);
	uiNamespace setVariable ["MCCMK_av_ctrl", nil];
	ctrlDelete (uiNamespace getVariable ["MCCMK_av_ctrl2", controlNull]);
	uiNamespace setVariable ["MCCMK_av_ctrl2", nil];
	ctrlDelete (uiNamespace getVariable ["MCCMK_av_ctrl3", controlNull]);
	uiNamespace setVariable ["MCCMK_av_ctrl3", nil];
	[objNull] call MCCMK_fnc_avMute;   // (the man watched speaks again)
	MCCMK_av_camFx = "";
	MCCMK_av_focusKey = [];
	player enableSimulation true;
	if (alive player) then { player switchCamera MCCMK_av_back; };
	showHUD MCCMK_av_hud;
	call MCCMK_fnc_avFade;
};

// (the vehicle's releases: a bomb or missile - followed when bomb view is on and nothing is being followed)
MCCMK_fnc_avHookFired = {
	params ["_v"];
	if (!isNil "MCCMK_avFiredV" && {!isNull MCCMK_avFiredV}) then { MCCMK_avFiredV removeEventHandler ["Fired", MCCMK_avFiredId]; };
	MCCMK_avFiredV = _v;
	MCCMK_avFiredId = _v addEventHandler ["Fired", {
		params ["_fv", "_wpn", "_muz", "_mode", "_ammo", "", "_proj"];
		if (!MCCMK_av_on || {!MCCMK_av_bomb} || {MCCMK_av_fol} || {isNull _proj}) exitWith {};
		private _sim = toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"));
		// (EVERYTHING fired is followed - any vehicle or man: bombs, missiles, rockets, shells, cannon and machine-gun
		//  rounds (each in turn), grenades, anything thrown; not flares / chaff)
		// (not chaff / countermeasure flares ("shotcm") and not illumination flares ("shotilluminating") - everything else)
		private _ok = !(_sim in ["shotcm", "shotilluminating"]);
		if (!_ok) exitWith {};
		[_proj] call MCCMK_fnc_avFolStart;
	}];
};

// the view's keyboard and mouse: the isolating screen over the game (MCCMK_av_isolate), the lines at the top,
// the key and mouse handlers - on opening, and again when the map is closed
MCCMK_fnc_avInput = {
	private _d46 = findDisplay 46;
	// (ISOLATED INPUT - an empty screen of its own laid over the game (the game's RscDisplayEmpty) takes the
	//  keyboard and mouse while the view is open, so nothing reaches the player's character OR any other mod (their keys
	//  all listen on the game's main screen underneath). The view's own controls are read on it - CBA keybinds included,
	//  matched here from the player's CBA settings. Esc closes it, and the view with it. MCCMK_av_isolate = false: on the
	//  main screen, other mods' keys not blocked.)
	private _ed = _d46;
	if (MCCMK_av_isolate) then {
		// (tried again for up to a second - opened from the map, the screen cannot be made while the map is still closing)
		private _dsp = displayNull;
		for "_r" from 1 to 20 do {
			if (isNull _dsp) then {
				_dsp = _d46 createDisplay "RscDisplayEmpty";
				if (isNull _dsp && {canSuspend}) then { uiSleep 0.05; };
			};
		};
		if (isNull _dsp) then { if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC [3D VIEW] the isolating screen could not be made - keys and mouse on the main screen"}; };
		if (!isNull _dsp) then {
			_ed = _dsp;
			uiNamespace setVariable ["MCCMK_av_dsp", _dsp];
			// closed (Esc): the view closes - but NOT when it is the map that closed it (opened from the view, or shut by a
			// Shift + right-click on a unit there, which switches the view to him): then the view goes on, and this screen is made
			// again once the map is gone (the watch below). 
			_dsp displayAddEventHandler ["Unload", {
				if (!MCCMK_av_on) exitWith {};
				if (visibleMap || {time < (missionNamespace getVariable ["MCCMK_av_mapGraceT", -1])}) then { MCCMK_av_needInput = true; if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC [3D VIEW] the map closed the view's own screen - the view stays open, the screen is made again"}; } else { [] spawn MCCMK_fnc_avClose; };
			}];
		};
	};
	MCCMK_av_child = !(_ed isEqualTo _d46);
	// A WAY OUT THAT ALWAYS WORKS: right-click and Esc on the game's main screen as well. If the view's own screen stops
	// getting the mouse and keys (after Alt+Tab, or another screen opened over it), the clicks go to the main screen -
	// where nothing else would close the view. One RPT line when that happens ("MCC [3D VIEW] closed from the main
	// screen").
	if (MCCMK_av_child && {!isNull _d46}) then {
		if (!isNil "MCCMK_avMB46") then { _d46 displayRemoveEventHandler ["MouseButtonDown", MCCMK_avMB46]; };
		if (!isNil "MCCMK_avKD46") then { _d46 displayRemoveEventHandler ["KeyDown", MCCMK_avKD46]; };
		MCCMK_avMB46 = _d46 displayAddEventHandler ["MouseButtonDown", {
			params ["", "_b"];
			if (!MCCMK_av_on || {visibleMap} || {_b != 1}) exitWith {false};
			if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC [3D VIEW] closed from the main screen (right-click) - the view's own screen was not getting the mouse"};
			[] spawn MCCMK_fnc_avClose;
			true
		}];
		MCCMK_avKD46 = _d46 displayAddEventHandler ["KeyDown", {
			params ["", "_k"];
			if (!MCCMK_av_on || {visibleMap} || {_k != 1}) exitWith {false};
			if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC [3D VIEW] closed from the main screen (Esc) - the view's own screen was not getting the keys"};
			[] spawn MCCMK_fnc_avClose;
			true
		}];
	};
	// (the line on the screen on top - on the main screen underneath, the isolating screen hid it)
	private _tx = _ed ctrlCreate ["RscStructuredText", -1];
	_tx ctrlSetPosition [safeZoneX, safeZoneY + (0.008 * safeZoneH), safeZoneW, 0.03 * safeZoneH];
	_tx ctrlCommit 0;
	uiNamespace setVariable ["MCCMK_av_ctrl", _tx];
	MCCMK_av_txtLast = "";	// a fresh line: shown (and its 10 s started) with its first text
	MCCMK_av_txtFol = false;
	// (the second line, under it)
	private _tx2 = _ed ctrlCreate ["RscStructuredText", -1];
	_tx2 ctrlSetPosition [safeZoneX, safeZoneY + (0.038 * safeZoneH), safeZoneW, 0.03 * safeZoneH];
	_tx2 ctrlSetFade 1;
	_tx2 ctrlCommit 0;
	uiNamespace setVariable ["MCCMK_av_ctrl2", _tx2];
	// (the third line - at the bottom of the screen, as far from the bottom as the top line is from the top)
	private _tx3 = _ed ctrlCreate ["RscStructuredText", -1];
	_tx3 ctrlSetPosition [safeZoneX, safeZoneY + safeZoneH - (0.008 * safeZoneH) - (0.03 * safeZoneH), safeZoneW, 0.03 * safeZoneH];
	_tx3 ctrlSetFade 1;
	_tx3 ctrlCommit 0;
	uiNamespace setVariable ["MCCMK_av_ctrl3", _tx3];
	call MCCMK_fnc_avText;
	call MCCMK_fnc_avLine2;
	// (the keyboard: the view key toggles first / third person; Esc passes; everything else is blocked from the
	//  player's own character)
	MCCMK_avKD = _ed displayAddEventHandler ["KeyDown", {
		params ["", "_k", "_sh", "_ct", "_al"];
		if (!MCCMK_av_on) exitWith {false};
		if (visibleMap) exitWith {false};   // (the map up - its keys are its own)
		// (a key HELD repeats its key-down every few hundredths of a second - one-shot actions only on the first:
		//  holding Shift + Right switched pilot / co-pilot / pilot... back and forth)
		private _rep = _k in MCCMK_av_down;
		MCCMK_av_down pushBackUnique _k;
		// (the view key as bound, with its modifier - and let through, so the game's own action fires too)
		if ([_k, _sh, _ct, _al] call MCCMK_fnc_avIsView) exitWith { if (!_rep) then { call MCCMK_fnc_avToggle; }; false };
		// (the map key as bound - the map opens; the isolating screen is put away while it is open (the mouse pointer
		//  free for the map) and back when the map closes. Not isolated: the key simply goes through to the game.)
		// (the map key goes straight to the game - its own map opens over the view. While the map is up every key goes to it,
		//  the mouse pointer is free and the view's mouse controls are off - so the map can be clicked: a Shift + right-click on
		//  another icon jumps to it.)
		// (in a vehicle the script camera (cameraEffect) stops the game's own map from opening. So it is
		//  put aside first: the game's camera on the man as the view is (first / third person), the key goes through, and the
		//  map is opened a moment later if the key did not open it. The watch below puts the script camera back once the map
		//  is closed.)
		// (the AI view too - with the view's own screen open the key does not reach the game: the map
		//  is opened the same way, a moment after the key, if the key did not open it)
		// (the night vision key as bound - night vision for the view on / off)
		if ([_k, _sh, _ct, _al, "nightVision"] call MCCMK_fnc_avIsView) exitWith { if (!_rep) then { call MCCMK_fnc_avNvg; }; true };
		if ([_k, _sh, _ct, _al, "ShowMap"] call MCCMK_fnc_avIsView) exitWith {
			if (!_rep) then { call MCCMK_fnc_avMapKey; };   // (the one routine, shared with the mouse and the game's own ShowMap action)
			false
		};
		// (no CBA: the default keys - the arrows (with Right Ctrl: up / down) move the camera while held, Space puts it
		//  back, Page Up / Page Down the mouse speed. With CBA these come through its keybinds instead.)
		// (either Shift - the key's own Shift flag - with Right / Left: next / previous; with or without CBA)
		// (LEFT Shift + Left / Right switches crew; RIGHT Shift with the arrows is the fine camera movement)
		if (_k == 205 && {42 in MCCMK_av_down} && {!(54 in MCCMK_av_down)}) exitWith { if (!_rep) then { [1] call MCCMK_fnc_avCycle; }; true };
		if (_k == 203 && {42 in MCCMK_av_down} && {!(54 in MCCMK_av_down)}) exitWith { if (!_rep) then { [-1] call MCCMK_fnc_avCycle; }; true };
		// (isolated, with CBA: the CBA keybinds matched here - CBA itself only listens on the main screen)
		if (MCCMK_av_cba && {MCCMK_av_child}) exitWith { [_k, _sh, _ct, _al, true, _rep] call MCCMK_fnc_avCbaKey; (_k != 1) };
		if (!MCCMK_av_cba) then {
			if (_k in [42, 54]) then { MCCMK_av_keys pushBackUnique _k; };
			if (_k in [200, 203, 205, 208, 157]) then { MCCMK_av_keys pushBackUnique _k; };
			if (_k == 57 && {!_rep}) then { call MCCMK_fnc_avReset; };
			if (_k == 47 && {!_rep}) then { call MCCMK_fnc_avAiToggle; };    // (V - the AI view)
			if (_k == 46 && {!_rep}) then { [(if (_sh) then {-1} else {1})] call MCCMK_fnc_avFixToggle; };   // (C - the view cycle; Shift + C backwards)
			if (_k == 201 && {!_rep}) then { [true] call MCCMK_fnc_avSensStep; };
			if (_k == 209 && {!_rep}) then { [false] call MCCMK_fnc_avSensStep; };
		};
		if (_k == 1) exitWith {false};
		true
	}];
	MCCMK_avKU = _ed displayAddEventHandler ["KeyUp", {
		params ["", "_k"];
		MCCMK_av_keys = MCCMK_av_keys - [_k];
		MCCMK_av_down = MCCMK_av_down - [_k];
		if (MCCMK_av_cba && {MCCMK_av_child}) then { [_k, false, false, false, false] call MCCMK_fnc_avCbaKey; };
		if (!MCCMK_av_on) exitWith {false};
		true
	}];
	// (the mouse buttons: right-click exits - always; left-click switches bomb view on / off)
	MCCMK_avMB = _ed displayAddEventHandler ["MouseButtonDown", {
		params ["", "_b"];
		if (!MCCMK_av_on) exitWith {false};
		if (visibleMap) exitWith {false};   // (the map up - a right-click is the map's, it does not close the view)
		if (_b == 1) exitWith { [] spawn MCCMK_fnc_avClose; false };
		if ([65536 + _b] call MCCMK_fnc_avIsView) exitWith { call MCCMK_fnc_avToggle; false };
		// (a mouse button bound to the game's map - it never reached the keyboard handler)
		if ([65536 + _b, false, false, false, "ShowMap"] call MCCMK_fnc_avIsView) exitWith { call MCCMK_fnc_avMapKey; false };
		// (following a round or a drop - left-click is back to the unit, and bomb view STAYS ON for the next one.
		//  Not following: it turns bomb view on / off.)
		if (_b == 0 && {missionNamespace getVariable ["MCCMK_BombViewEnabled", true]}) then {
			if (MCCMK_av_fol) then { [true] call MCCMK_fnc_avFolEnd; } else { MCCMK_av_bomb = !MCCMK_av_bomb; };
			call MCCMK_fnc_avText;
		};
		false
	}];
	// (the mouse moving: the look round - first person within the seat's limits, third person and bomb view an orbit)
	MCCMK_avMM = _ed displayAddEventHandler ["MouseMoving", {
		params ["", "_dx", "_dy"];
		if (!MCCMK_av_on) exitWith {false};
		if (visibleMap) exitWith {false};
		// (pointer parked - the movement kept for the look input's scale; used for the look itself only until
		//  that is known, or if the game's look input gives nothing ("free"))
		if (MCCMK_av_child && {MCCMK_av_pinMouse} && {MCCMK_av_lookMode != "free"}) then { MCCMK_av_mAcc = [(MCCMK_av_mAcc select 0) + _dx, (MCCMK_av_mAcc select 1) + _dy]; };
		if (MCCMK_av_child && {MCCMK_av_pinMouse} && {MCCMK_av_lookMode == "input"}) exitWith {false};
		[_dx, _dy] call MCCMK_fnc_avLook;
		false
	}];
	// (the scroll wheel: first person in a vehicle - the eye up / down a little; third person and bomb view - in / out)
	MCCMK_avMZ = _ed displayAddEventHandler ["MouseZChanged", {
		params ["", "_z"];
		if (!MCCMK_av_on) exitWith {false};
		if (visibleMap) exitWith {false};
		switch (true) do {
			case (MCCMK_av_fol): { MCCMK_av_bDist = ((MCCMK_av_bDist * (1 - (_z * 0.1))) max 5) min 80; };
			case (MCCMK_av_mode == "INTERNAL"): { MCCMK_av_eyeZ = ((MCCMK_av_eyeZ + (_z * 0.01)) max (-MCCMK_av_eyeDown)) min MCCMK_av_eyeUp; };   // (on foot too)
			default { MCCMK_av_tDist = ((MCCMK_av_tDist * (1 - (_z * 0.1))) max (MCCMK_av_tBase * 0.4)) min (MCCMK_av_tBase * (if ((vehicle MCCMK_av_unit) == MCCMK_av_unit) then {5} else {3})); };
		};
		false
	}];
};
// (the map is the game's own, over the view )
// [unit] -> the view switched to him (a right-click on him on the map with the view open); the map closes
MCCMK_fnc_avSwitchTo = {
	params ["_nu"];
	if (!MCCMK_av_on || {isNull _nu} || {!alive _nu} || {_nu == MCCMK_av_unit}) exitWith {};
	if (MCCMK_av_fol) then { [false] call MCCMK_fnc_avFolEnd; };
	MCCMK_av_unit hideObject false;
	MCCMK_av_unit = _nu;
	MCCMK_av_folShown = false;
	MCCMK_av_fpNative = [_nu, "MCCMK_av_mNative", false] call MCCMK_fnc_avMemGet;   // (the camera last used on him, else on his vehicle, else the last used)
	if !(MCCMK_av_fpNative isEqualType true) then { MCCMK_av_fpNative = false; };
	// (first or third person as it was last on it; the first time: the player's own when the view was opened)
	private _lm = [_nu, "MCCMK_av_mMode", ""] call MCCMK_fnc_avMemGet;
	if !(_lm in ["INTERNAL", "EXTERNAL"]) then { _lm = if (MCCMK_av_back == "EXTERNAL") then {"EXTERNAL"} else {"INTERNAL"}; };
	MCCMK_av_mode = if (missionNamespace getVariable ["MCCMK_CockpitViewEnabled", true]) then {_lm} else {"EXTERNAL"};
	[_nu] call MCCMK_fnc_avSeat;
	[vehicle _nu] call MCCMK_fnc_avHookFired;
	call MCCMK_fnc_avApply;
	// (the map shut a moment later, after the click that asked for the switch has finished - and the view kept open meanwhile)
	if (visibleMap) then {
		MCCMK_av_mapGraceT = time + 3;
		[] spawn { sleep 0.1; openMap [false, false]; };
	};
	MCCMK_av_msg = name _nu;
	MCCMK_av_msgT = time + 3;
	call MCCMK_fnc_avText;
	[] spawn { sleep 3.1; call MCCMK_fnc_avText; };
};

MCCMK_fnc_avOpen = {
	params ["_u"];
	if (MCCMK_av_on || {isNull _u} || {!alive _u} || {!alive player}) exitWith {};
	// opened whenever it is asked for - driving, moving, engine on or off. Only the checks it needs to work at all: not
	// already open, a living unit to watch, and the player alive.
	MCCMK_av_on = true;
	MCCMK_av_bomb = missionNamespace getVariable ["MCCMK_BombViewEnabled", true];   // (on from the start - a left-click turns it off)
	MCCMK_av_fol = false;
	MCCMK_av_unit = _u;
	MCCMK_av_folShown = false;
	openMap [false, false];
	// (opened from the map - the map gone first, so the isolating screen can be made)
	private _mw = time + 2;
	waitUntil { !visibleMap || {time > _mw} };
	MCCMK_av_back = cameraView;
	// (first or third person as the PLAYER was when he clicked (read then - MCCMK_av_reqView - the map was up),
	//  and always the script camera to start with - the AI view by V as usual)
	// (...the camera last used on THIS vehicle (or man on foot) this mission - the script camera or the AI view;
	//  the first time: the script camera)
	private _pv0 = missionNamespace getVariable ["MCCMK_av_reqView", cameraView];
	if !(_pv0 in ["INTERNAL", "EXTERNAL", "GUNNER"]) then { _pv0 = cameraView; };
	MCCMK_av_mode = if (_pv0 == "EXTERNAL" || {!(missionNamespace getVariable ["MCCMK_CockpitViewEnabled", true])}) then {"EXTERNAL"} else {"INTERNAL"};
	// (a vehicle (or man) watched before this mission - first or third person as it was last; only the first
	//  time is it the player's own)
	private _lm = [_u, "MCCMK_av_mMode", ""] call MCCMK_fnc_avMemGet;
	if (_lm in ["INTERNAL", "EXTERNAL"]) then { MCCMK_av_mode = if (missionNamespace getVariable ["MCCMK_CockpitViewEnabled", true]) then {_lm} else {"EXTERNAL"}; };
	MCCMK_av_fpNative = [_u, "MCCMK_av_mNative", false] call MCCMK_fnc_avMemGet;
	if !(MCCMK_av_fpNative isEqualType true) then { MCCMK_av_fpNative = false; };
	MCCMK_av_hud = shownHUD;
	showHUD false;
	player enableSimulation false;
	[_u] call MCCMK_fnc_avSeat;
	private _cam = "camera" camCreate (ASLToAGL (eyePos _u));
	MCCMK_av_cam = _cam;
	MCCMK_av_camOn = false;
	call MCCMK_fnc_avApply;
	// (back on EachFrame - first and third person are attached to the vehicle now, the game moves them)
	MCCMK_avEachFrame = addMissionEventHandler ["EachFrame", { call MCCMK_fnc_avFrame; }];
	// the map closed: the script camera back on AT ONCE (the watch below would do it up to a quarter of a second later,
	// the AI view showing meanwhile)
	MCCMK_avMapEH = addMissionEventHandler ["Map", {
		params ["_open"];
		if (_open || {!MCCMK_av_on} || {!MCCMK_av_mapCam}) exitWith {};
		MCCMK_av_mapCam = false;
		call MCCMK_fnc_avApply;
	}];
	// (a parachute that appears - a supply or vehicle drop - is looked at; see MCCMK_fnc_avChuteCheck)
	MCCMK_avDropEH = addMissionEventHandler ["EntityCreated", {
		params ["_e"];
		if (MCCMK_av_on && {MCCMK_av_bomb} && {!MCCMK_av_fol} && {_e isKindOf "ParachuteBase"}) then { [_e] spawn MCCMK_fnc_avChuteCheck; };
	}];
	MCCMK_av_dwVeh = objNull; MCCMK_av_dwPrev = [];
	MCCMK_av_attKey = []; MCCMK_av_dirKey = [];
	MCCMK_avUAE = addUserActionEventHandler ["personView", "Activate", { call MCCMK_fnc_avToggle; }];
	// (the game's own map action, from whatever it is bound to - a chord, a gamepad button, anything the keyboard and mouse handlers do not know)
	MCCMK_avUAEmap = addUserActionEventHandler ["ShowMap", "Activate", { if (MCCMK_av_on) then { call MCCMK_fnc_avMapKey; }; }];
	call MCCMK_fnc_avFade;
	[vehicle _u] call MCCMK_fnc_avHookFired;
	call MCCMK_fnc_avInput;
	// (watch: the player dead - close now; the unit watched dead or gone - 5 s, then close; the unit into or out of a
	//  vehicle - set up for the new seat and its releases; bomb view switched off in the CBA settings - off here too)
	[] spawn {
		while {MCCMK_av_on} do {
			private _u = MCCMK_av_unit;   // (whoever is watched now - it can be switched)
			if (!alive player) exitWith { call MCCMK_fnc_avClose; };
			if (!((call MCCMK_fnc_avMode) > 0)) exitWith { call MCCMK_fnc_avClose; };
			if (isNull _u || {!alive _u}) exitWith { sleep 5; call MCCMK_fnc_avClose; };
			if (MCCMK_av_mode == "INTERNAL" && {!(missionNamespace getVariable ["MCCMK_CockpitViewEnabled", true])}) then { MCCMK_av_mode = "EXTERNAL"; call MCCMK_fnc_avApply; };
			if ((vehicle _u) != MCCMK_av_veh) then { [_u] call MCCMK_fnc_avSeat; [vehicle _u] call MCCMK_fnc_avHookFired; };
			if (MCCMK_av_bomb && {!(missionNamespace getVariable ["MCCMK_BombViewEnabled", true])}) then { MCCMK_av_bomb = false; [true] call MCCMK_fnc_avFolEnd; call MCCMK_fnc_avText; };
			// (the game's own first person: the camera put back on the man if something took it - only when it is on neither
			//  him nor his vehicle)
			if (MCCMK_av_fpNative && {!MCCMK_av_fol} && {!visibleMap} && {!(cameraOn in [_u, vehicle _u])}) then { _u switchCamera MCCMK_av_mode; };   // (first or third person)
			// (the AI view kept on the view chosen - the game's own switch-view key can change it; not while the map is up)
			if (MCCMK_av_fpNative && {!MCCMK_av_fol} && {!visibleMap} && {cameraView in ["INTERNAL", "EXTERNAL"]} && {cameraView != MCCMK_av_mode} && {time > (missionNamespace getVariable ["MCCMK_av_togT", -1])}) then { _u switchCamera MCCMK_av_mode; };
			// (the map closed - the script camera put aside for it back on)
			if (MCCMK_av_mapCam && {!visibleMap} && {time > (missionNamespace getVariable ["MCCMK_av_mapCamT", 0])}) then { MCCMK_av_mapCam = false; call MCCMK_fnc_avApply; };
			// (the sound where the camera is - Fly By shots, the camera moved off the eye, first / third person; and the radio of whoever is watched)
			call MCCMK_fnc_avAudio;
			call MCCMK_fnc_avMuteSync;
			// (the camera has just left the crewman's eye - the key lines come up, with "Space: Back to Crewman", and fade as always)
			private _offEye = call MCCMK_fnc_avOffEye;
			if (_offEye && {!MCCMK_av_offShown} && {!visibleMap}) then { call MCCMK_fnc_avLine2; };
			MCCMK_av_offShown = _offEye;
			if (MCCMK_av_bomb && {!MCCMK_av_fol}) then { call MCCMK_fnc_avDropWatch; };   // (a slung load or vehicle let go of)
			// the map up: its closing does not close the view (see the isolating screen's Unload); once it is gone, the
			// isolating screen is made again if the map took it
			if (visibleMap) then { MCCMK_av_mapGraceT = time + 1.5; };
			if ((missionNamespace getVariable ["MCCMK_av_needInput", false]) && {!visibleMap}) then {
				MCCMK_av_needInput = false;
				if (isNull (uiNamespace getVariable ["MCCMK_av_dsp", displayNull])) then { call MCCMK_fnc_avInput; };
			};
			sleep 0.25;
		};
	};
};

// (a Shift + right-click on a friendly group's map icon - not the player's own group; Shift added, a plain
//  right-click on the map is left to the game)
// (CBA settings "Alternative View" - Friendly, Enemy and Civilians, three separate options - which
//  sides' icons open it; an ENEMY or CIVILIAN unit on the map only if the player's side knows of it (no peeking at hidden
//  ones). All three off: no opening by either click, and
//  an open view closes. Each click opens it only once: a Shift + right-click on a group icon is also one on the map -
//  whichever reports first opens it, the other is ignored for half a second.)
MCCMK_fnc_avTryOpen = {
	params ["_u"];
	if (!((call MCCMK_fnc_avMode) > 0) || {time < (missionNamespace getVariable ["MCCMK_av_clickT", -1])}) exitWith {};
	if (isNull _u || {!alive _u} || {_u == player}) exitWith {};
	MCCMK_av_clickT = time + 0.5;
	if (MCCMK_av_on) exitWith { [_u] call MCCMK_fnc_avSwitchTo; };   // (the view open - switched to him)
	MCCMK_av_reqView = cameraView;   // (the player's own first / third person, at the click)
	[_u] spawn MCCMK_fnc_avOpen;
};
// (MCC MK: opened from the MCC console's 3D View button - MCCMK_fnc_view3D - not by a click on the map)
