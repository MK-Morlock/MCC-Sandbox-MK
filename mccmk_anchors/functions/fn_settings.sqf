/*
    ANC_fnc_settings  (every computer, preInit)
    CBA settings: Options > Addon Options > Anchors. Shared settings: in multiplayer the server's values are used.
    Tooltips are wrapped to short lines so they don't stretch across the screen.
*/
if (call ANC_fnc_builtIn) exitWith {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] The mission has Anchors built in - this mod stands aside (the mission's is used)."}};
private _cat = "MCCMK Anchors";
ANC_keyCat = _cat; // the key bindings use the same category (ANC_fnc_postInit)
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Version %1 loaded (keys: Shift+R anchor, Shift+F tow line, Shift+Page Down haul in, Shift+Page Up pay out, Ctrl+Shift+R adjust points).", getText (configFile >> "CfgPatches" >> (["MCCMK_Anchors", "Anchors_main"] select (isClass (configFile >> "CfgPatches" >> "Anchors_main"))) >> "versionStr")];};

// Wrap a tooltip at about 55 characters per line.
private _w = {
    params ["_text"];
    private _lines = [];
    private _line = "";
    {
        if (count _line > 0 && {(count _line) + (count _x) + 1 > 55}) then {_lines pushBack _line; _line = _x} else {
            _line = [_x, _line + " " + _x] select (count _line > 0);
        };
    } forEach (_text splitString " ");
    if (count _line > 0) then {_lines pushBack _line};
    _lines joinString endl
};

// ---- Anchor ----
["ANC_boats", "LIST", ["Boats with anchors", ["Which boats can anchor (the Anchor / moor key - Shift+R by default) and use a tow line (the Tow line / rope bag key - Shift+F by default)."] call _w], [_cat, "Anchor"],
    [[0, 1], [
        ["Standard boats only", ["Zodiacs, speedboats, motorboat, RHIB, Sailing Mod boat, MkV SOC."] call _w],
        ["All boats", ["Every boat and ship, modded ones too. Submarines and SDVs can't anchor, but can moor when surfaced."] call _w]
    ], 1], 1] call CBA_fnc_addSetting;

["ANC_anchorScope", "LIST", ["Anchor rope / chain length", ["How much is let out, as a multiple of the depth. Boats under 12 m use rope, larger ones chain. Under 3 x it can drag."] call _w], [_cat, "Anchor"],
    [[0, 1, 2, 3], [
        ["Short: depth + 4 m", ["Game-friendly. Stays close to the anchor, may drag."] call _w],
        ["Short stop: rope 3 x, chain 3 x", ["A quick stop in calm water. 5 m deep = 15 m out."] call _w],
        ["Realistic: rope 5 x, chain 3 x", ["Normal anchoring. 5 m deep = 25 m rope or 15 m chain."] call _w],
        ["Rough weather: rope 7 x, chain 5 x", ["Strong wind or swell. 5 m deep = 35 m rope or 25 m chain."] call _w]
    ], 2], 1] call CBA_fnc_addSetting;

["ANC_windlassSpeed", "LIST", ["Weighing anchor speed", ["How fast the anchor is hauled in. Real rates are slow (a ship takes about 18 min for 165 m of chain). Lowering is always real-time."] call _w], [_cat, "Anchor"],
    [[0, 1, 2, 3, 4, 5], [
        ["Realistic", ["Real-life hauling rates."] call _w],
        ["x5", ""], ["x10", ""], ["x15", ""], ["x20", ""], ["x30", ""]
    ], 4], 1] call CBA_fnc_addSetting;

["ANC_anchorEnd", "LIST", ["Anchor position (other boats)", ["Where boats without a known anchor point anchor from. Landing craft always use the stern."] call _w], [_cat, "Anchor"],
    [[0, 1], [
        ["Bow (realistic)", ["Boats swing to face the wind."] call _w],
        ["Stern", ["Rarely used on its own in real life."] call _w]
    ], 0], 1] call CBA_fnc_addSetting;

["ANC_anchorModel", "EDITBOX", ["Anchor model", ["An object's class name or a .p3d path. Empty = Land_Jens_Sharpeye_Hook_01_F, then Arma's anchor model. Next mission start."] call _w], [_cat, "Anchor"], "", 1] call CBA_fnc_addSetting;

// ---- Wind drift and mission boats ----
["ANC_windDrift", "LIST", ["Wind drift", ["Arma's wind doesn't move boats. This adds the push of the wind against the water's resistance. Boats under power are only affected when anchored or moored."] call _w], [_cat, "Wind drift"],
    [[0, 1, 2], [
        ["Off", ["Off: vanilla Arma. Wind never moves a boat."] call _w],
        ["Anchored and moored boats only", ["Anchored and moored boats only: only boats with anchor or mooring points swing to the wind and lean on their lines."] call _w],
        ["All boats with the engine off (realistic)", ["All boats with the engine off (realistic): every unpowered boat drifts downwind. That includes paddled boats, empty boats and boats with the engine off. Unattended boats without an anchor or mooring can slowly drift away."] call _w]
    ], 2], 1] call CBA_fnc_addSetting;

["ANC_settleTime", "SLIDER", ["Settling time (seconds)", ["No drift for this long after the mission starts, so placed boats can settle."] call _w], [_cat, "Wind drift"], [0, 60, 10, 0], 1] call CBA_fnc_addSetting;

["ANC_editorBoats", "LIST", ["Boats placed in the mission", ["What boats already in the mission do when it starts. Boats that are aground never drift."] call _w], [_cat, "Wind drift"],
    [[0, 1, 2], [
        ["Drift from the start (realistic)", ["They drift with the wind straight away."] call _w],
        ["Stay put until someone has been aboard (mission-friendly)", ["No drift until someone gets in. Crewed boats stay put until given any order (waypoint, command, combat)."] call _w],
        ["Anchor all boats or moor them if near a mooring position", ["Friendly boats that are stopped with no waypoints anchor, or moor within 20 m of a dock (AI-crewed too, per 'AI crews'). Enemy boats stay put as above. A boat's own Eden attribute overrides this."] call _w]
    ], 2], 1] call CBA_fnc_addSetting;

// ---- AI crews ----
["ANC_aiWeigh", "LIST", ["AI crews weigh anchor", ["When an anchored or moored AI boat is ordered to move, the crew weigh anchor or cast off first, then go."] call _w], [_cat, "AI crews"],
    [[0, 1], [
        ["Same as 'Weighing anchor speed'", ["Weighs at the speed set in 'Weighing anchor speed'; casting off takes a few seconds. The boat waits until it's free."] call _w],
        ["Quick", ["Anchor up or lines off in a few seconds, so missions don't stall."] call _w]
    ], 0], 1] call CBA_fnc_addSetting;

["ANC_aiCrewedStart", "CHECKBOX", ["Anchor / moor AI-crewed boats at start", ["With 'Anchor all boats or moor them', friendly boats with AI crews are anchored or moored too. They weigh anchor or cast off by themselves when ordered to move."] call _w], [_cat, "AI crews"], true, 1] call CBA_fnc_addSetting;

["ANC_commMenu", "CHECKBOX", ["Orders in the 0-8 menu", ["Anchor, Weigh anchor, Moor, Cast off and Throw line ashore in the 0-8 menu, shown only while you've selected units or High Command groups in boats. Next mission start."] call _w], [_cat, "AI crews"], true, 1] call CBA_fnc_addSetting;

// ---- Landing craft ----
["ANC_kedge", "CHECKBOX", ["Stern (kedge) anchor", ["Landing craft drop an anchor astern on the way in, then haul themselves off the beach with it. Not hovercraft."] call _w], [_cat, "Landing craft"], true, 1] call CBA_fnc_addSetting;

["ANC_kedgeExtra", "EDITBOX", ["Extra landing craft classes", ["Found automatically by name or bow ramp. Add others as class names, comma separated."] call _w], [_cat, "Landing craft"], "", 1] call CBA_fnc_addSetting;

// ---- Mooring ----
["ANC_tieUp", "CHECKBOX", ["Moor to piers and docks", ["Within 20 m of a dock, the Anchor / moor key (Shift+R by default) offers to moor. Submarines and SDVs too, when surfaced."] call _w], [_cat, "Mooring"], true, 1] call CBA_fnc_addSetting;

["ANC_moorPhysics", "LIST", ["Mooring line physics", ["What holds a moored boat on its lines."] call _w], [_cat, "Mooring"],
    [[0, 1], [
        ["Anchors model (default)", ["The mod's own nylon-rope pull at each line's point: smooth and steady. The visible ropes carry no load."] call _w],
        ["Arma rope physics", ["Arma's own ropes hold the boat: the ropes are set to the line length and Arma applies the force. For comparison - can snatch or jitter in waves."] call _w]
    ], 0], 1] call CBA_fnc_addSetting;

["ANC_dinghyMooring", "LIST", ["Dinghy mooring", ["How dinghies (Zodiacs, boats under 6 m) tie up. Larger boats use bow and stern lines."] call _w], [_cat, "Mooring"],
    [[0, 1, 2], [
        ["Bow painter (realistic)", ["One line at the bow; lies off the dock on it."] call _w],
        ["Stern line", ["One line from the stern."] call _w],
        ["Bow and stern lines", ["Held alongside like a larger boat."] call _w]
    ], 0], 1] call CBA_fnc_addSetting;

// ---- Shore lines ----
["ANC_pullForce", "SLIDER", ["Pulling force per person (N)", ["How hard each person holding the shore line pulls (people on the same line add together). The line stretches as you lean into it - your full pull at 1 m of stretch. The boat speeds up while the pull beats the drag below and settles at your pace with the line just taut. 4,000 N (the default) lets one person pull a Zodiac out of the water and up the beach at real (100 %) friction with plenty to spare; 350 N is a real person (a Zodiac on the beach then needs about five people). Takes effect at once."] call _w], [_cat, "Shore lines"], [350, 10000, 4000, 0], 1] call CBA_fnc_addSetting;
["ANC_waterDrag", "SLIDER", ["Water drag (%) - pulling a boat through the water", ["How much the water drags on a boat pulled by its shore line: 100 % = real water (the drag on the hull grows with speed squared), 0 % = none. Takes effect at once."] call _w], [_cat, "Shore lines"], [0, 100, 100, 0], 1] call CBA_fnc_addSetting;
["ANC_groundDrag", "SLIDER", ["Ground friction (%)", ["How strongly the ground grips a hull dragged up the beach by its shore line: 100 % = real sand (about a third of the boat's weight for an inflatable, half for a hard hull), 0 % = none. The ground always holds the boat up. Your pull has to beat the grip before the boat moves - the smaller the gap, the more the line stretches first and the more the boat springs forward when it breaks free. Eg. a Zodiac's grip on the sand is about 1,660 N, so: 1,700 N pull at 100 % friction: a 40 N gap, a big spring. 1,700 N pull at 60 % friction: grip about 1,000 N, a 700 N gap, a much smaller spring. 3,000 N pull at 100 % friction: a 1,340 N gap, a smooth pull. Takes effect at once."] call _w], [_cat, "Shore lines"], [0, 100, 100, 0], 1] call CBA_fnc_addSetting; // //

["ANC_maxSlope", "SLIDER", ["Steepest shore (degrees)", ["The steepest ground a boat can be dragged up."] call _w], [_cat, "Shore lines"], [5, 45, 30, 0], 1] call CBA_fnc_addSetting;

["ANC_lineInBoats", "CHECKBOX", ["Heaving line in every boat", ["Every boat gets one Heaving line in its inventory."] call _w], [_cat, "Shore lines"], true, 1] call CBA_fnc_addSetting;

["ANC_lineModel", "EDITBOX", ["Line end model", ["What lies at the end of a heaving line: a class name or .p3d path. Default: a folded bag. Next mission start."] call _w], [_cat, "Shore lines"], "Land_Sleeping_bag_brown_folded_F", 1] call CBA_fnc_addSetting;

// ---- Debug ----
["ANC_debug", "CHECKBOX", ["Debug logging", ["Detailed lines in the RPT log (towing, hauling, weighing anchor, mooring, drift, and the diagnostic tools) - for troubleshooting only. Off: only the load line and warnings."] call _w], [_cat, "Debug"], false, 1] call CBA_fnc_addSetting;
