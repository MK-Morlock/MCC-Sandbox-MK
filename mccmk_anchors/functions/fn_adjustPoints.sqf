/*
    ANC_fnc_adjustPoints  (client)
    Edit where the anchor, tow lines and mooring lines attach to this type of boat. Opened with "Adjust attachment
    points" (Ctrl+Shift+R) by anyone aboard. Opens an edit screen with a free mouse cursor and its own camera looking
    at the point - nothing you do here reaches the boat, so it can't be steered or moved by accident.

    Mouse (like the 3DEN editor):
      Drag a coloured arrow     move the point along that axis
                                  red = port / starboard, green = forward / back, blue = up / down
      Drag the yellow dot       move it across the deck (forward / back and side to side)
      Alt + drag the dot        move it up / down
      Right-drag                orbit the camera around the point
      Mouse wheel               zoom in / out
    Keys (only while this screen is open):
      Space    next point        Enter   save
      Delete   reset this point to automatic
      Esc / Backspace   leave (unsaved changes are dropped)

    Movement is free; G turns snapping to 6 inch (15 cm) steps on or off. T chooses where Enter saves:
      every boat of this type (default) - kept on the server, in its profile, so they last between missions; this boat
      only - kept on the boat itself and used before its type's points; a boat with a variable name (given in the Eden
      editor) has them kept in the server's profile too, under this mission and that name, and they come back every
      time.
    Used by everyone for every anchor, tow, mooring and shore line made from then on. the next one uses the new point.
*/
params [["_boat", objNull, [objNull]]];
if (isNull _boat || {!isNil "ANC_adj"}) exitWith {};

// Mooring layout for this boat type: bow & stern (default) or port & starboard - L toggles it.
ANC_adjLayout = _boat call ANC_fnc_moorLayout;
// Where Enter saves (and Delete resets): every boat of this type (default) or this boat only - T toggles it.
ANC_adjAllType = true;
// A boat's own points are set on the boat itself (shared with everyone, no server needed); "all of this type" goes to
// the server.
ANC_adjSetOwn = {
    params ["_boat", "_name", "_point"];
    private _list = (_boat getVariable ["ANC_boatPoints", []]) select {!((_x select 0) isEqualTo _name)};
    if (count _point == 3) then {_list pushBack [_name, _point]};
    _boat setVariable ["ANC_boatPoints", _list, true];
    // a boat with a variable name (from the Eden editor): kept in the server's profile for this mission too
    if ((vehicleVarName _boat) != "") then {[[vehicleVarName _boat, _list], "saveBoatPoints", 2] call ANC_fnc_remote};
};
ANC_adjLayoutChanged = false;
ANC_adjNames = {
    [
        ["anchorBow",   "Anchor (bow)"],
        ["anchorStern", "Anchor (stern / landing craft kedge)"],
        ["towBow",      "Tow point - bow"],
        ["towStern",    "Tow point - stern"]
    ] + ([
        [["moorBow", "Mooring - bow line (starboard - port mirrors it)"], ["moorStern", "Mooring - stern line (starboard - port mirrors it)"]],
        [["moorFwd", "Mooring - forward side cleat (starboard - port mirrors it)"], ["moorAft", "Mooring - aft side cleat (starboard - port mirrors it)"]]
    ] select (ANC_adjLayout isEqualTo "sides"))
};
private _names = call ANC_adjNames;
ANC_adjSnap = false; // snapping off by default - G toggles it
ANC_adjStep = 0.1524; // snap step: 6 inches
ANC_adjLen = 0.6; // length of each arrow, metres

// State: [boat, names, index, pending (name -> point), drag, camera, camYaw, camPitch, camDist] drag = [] or [kind
// ("x"/"y"/"z"/"plane"), mouse start, point start]
ANC_adj = [_boat, _names, 0, createHashMap, [], objNull, (getDir _boat) + 210, 25, 4];

ANC_adjPoint = {
    ANC_adj params ["_boat", "_names", "_i", "_pending"];
    private _name = (_names select _i) select 0;
    _pending getOrDefault [_name, [_boat, _name, 1] call ANC_fnc_pointFor]
};
ANC_adjAxes = [["x", [1, 0, 0], [1, 0.25, 0.25, 1]], ["y", [0, 1, 0], [0.25, 1, 0.25, 1]], ["z", [0, 0, 1], [0.35, 0.55, 1, 1]]];

// ---- Edit screen: free cursor; the game gets no input while it's open ----
private _disp = (findDisplay 46) createDisplay "RscDisplayEmpty";
// Screens and their controls must be kept in uiNamespace (Arma can't store them in the mission).
uiNamespace setVariable ["ANC_adjDisp", _disp];
private _txt = _disp ctrlCreate ["RscStructuredText", -1];
_txt ctrlSetPosition [safeZoneX + safeZoneW - 0.56, safeZoneY + 0.02, 0.54, 0.34];
_txt ctrlSetBackgroundColor [0, 0, 0, 0.45];
_txt ctrlCommit 0;
uiNamespace setVariable ["ANC_adjText", _txt];

ANC_adjShow = {
    ANC_adj params ["_boat", "_names", "_i", "_pending"];
    private _n = count _pending;
    (uiNamespace getVariable ["ANC_adjText", controlNull]) ctrlSetStructuredText parseText format [
        "<t size='0.85' color='#ffcc66'>Adjust attachment points</t><br/><t size='0.75'>%1 (%2 of %3) - %4<br/><br/>" +
        "Drag an arrow: <t color='#ff6666'>red</t> port / starboard, <t color='#66ff66'>green</t> forward / back, <t color='#6699ff'>blue</t> up / down<br/>" +
        "Drag the orange dot across the deck, Alt+drag it up / down<br/>" +
        "Right-drag: orbit camera  |  Wheel: zoom<br/>" +
        "Space: next point  |  Enter: save%5<br/>G: snap to 6 in steps (%6)  |  Delete: automatic  |  Esc: leave<br/>" +
        "L: mooring points - %7<br/>T: save for - <t color='#ffcc66'>%8</t></t>",
        (_names select _i) select 1, _i + 1, count _names, typeOf _boat,
        ["", format [" (%1 changed)", _n + ([0, 1] select ANC_adjLayoutChanged)]] select (_n > 0 || ANC_adjLayoutChanged), ["off", "on"] select ANC_adjSnap,
        ["bow and stern", "port and starboard side cleats"] select (ANC_adjLayout isEqualTo "sides"),
        [format ["this boat only (not other %1s)", typeOf _boat], format ["every boat of this model (%1 and its variants)", typeOf _boat]] select ANC_adjAllType
    ];
};

// ---- Camera orbiting the point ----
private _cam = "camera" camCreate (positionCameraToWorld [0, 0, 0]);
_cam cameraEffect ["internal", "back"];
ANC_adj set [5, _cam];
ANC_adjCamUpdate = {
    ANC_adj params ["_boat", "", "", "", "", "_cam", "_yaw", "_pitch", "_dist"];
    private _c = _boat modelToWorldVisual (call ANC_adjPoint);
    private _off = [sin _yaw * cos _pitch, cos _yaw * cos _pitch, sin _pitch] vectorMultiply _dist;
    _cam camSetPos (_c vectorAdd _off);
    _cam camSetTarget _c;
    _cam camCommit 0;
};

// ---- Drawing: thick arrows (dotted shafts + arrowheads) and the centre dot ----
// The widget is drawn as small coloured squares on the edit screen itself, placed over the 3D view every frame -
// screen controls always show on top, unlike icons drawn in the 3D scene.
private _mk = {
    params ["_disp", "_col", "_text"];
    private _c = _disp ctrlCreate ["RscText", -1];
    _c ctrlSetBackgroundColor _col;
    _c ctrlSetTextColor [1, 1, 1, 1];
    _c ctrlSetText _text;
    _c ctrlSetFontHeight 0.03;
    _c ctrlCommit 0;
    _c
};
private _dots = [];
{
    _x params ["_k", "_axis", "_col"];
    private _shaft = [];
    for "_t" from 0 to 40 do {_shaft pushBack ([_disp, _col, ""] call _mk)};
    private _tip = [_disp, _col, ""] call _mk;
    private _label = _disp ctrlCreate ["RscText", -1];
    _label ctrlSetText (["starboard", "forward", "up"] select _forEachIndex);
    _label ctrlSetTextColor _col;
    _label ctrlSetFontHeight 0.03;
    _label ctrlCommit 0;
    _dots pushBack [_shaft, _tip, _label];
} forEach ANC_adjAxes;
// The point itself: a round, see-through orange dot - a screen control, since anything drawn in the 3D view doesn't
// show over this edit screen.
private _centre = _disp ctrlCreate ["RscPicture", -1];
_centre ctrlSetText "\a3\ui_f\data\map\markers\military\dot_ca.paa";
_centre ctrlSetTextColor [1, 0.6, 0.1, 0.6];
_centre ctrlCommit 0;
private _name = _disp ctrlCreate ["RscText", -1];
_name ctrlSetTextColor [1, 1, 1, 0.8];
_name ctrlSetFontHeight 0.026;
_name ctrlCommit 0;
uiNamespace setVariable ["ANC_adjDots", [_dots, _centre, _name]];

ANC_adjDraw = addMissionEventHandler ["Draw3D", {
    if (isNil "ANC_adj") exitWith {};
    call ANC_adjCamUpdate;
    ANC_adj params ["_boat", "_names", "_i", "", "_drag"];
    (uiNamespace getVariable ["ANC_adjDots", []]) params ["_dots", "_centre", "_name"];
    private _p = call ANC_adjPoint;
    private _active = if (count _drag > 0) then {_drag select 0} else {""};
    private _place = {
        params ["_ctrl", "_worldAGL", "_size", ["_offX", 0]];
        private _s = worldToScreen _worldAGL;
        if (count _s == 2) then {
            _ctrl ctrlSetPosition [(_s select 0) - (_size / 2) + _offX, (_s select 1) - (_size / 2), _size, _size * (4 / 3)];
            _ctrl ctrlShow true;
        } else {_ctrl ctrlShow false};
        _ctrl ctrlCommit 0;
    };
    {
        (ANC_adjAxes select _forEachIndex) params ["_k", "_axis", "_col"];
        _x params ["_shaft", "_tip", "_label"];
        private _c = [_col, [1, 1, 1, 1]] select (_active isEqualTo _k);
        private _a = _p vectorDiff (_axis vectorMultiply ANC_adjLen);
        {
            _x ctrlSetBackgroundColor _c;
            private _t = _forEachIndex / 40;
            [_x, _boat modelToWorldVisual ((_a vectorMultiply (1 - _t)) vectorAdd ((_p vectorAdd (_axis vectorMultiply ANC_adjLen)) vectorMultiply _t)), 0.005] call _place;
        } forEach _shaft;
        _tip ctrlSetBackgroundColor _c;
        private _tipPos = _boat modelToWorldVisual (_p vectorAdd (_axis vectorMultiply ANC_adjLen));
        [_tip, _tipPos, 0.02] call _place;
        private _ls = worldToScreen _tipPos;
        if (count _ls == 2) then {_label ctrlSetPosition [(_ls select 0) + 0.015, (_ls select 1) - 0.015, 0.15, 0.03]; _label ctrlShow true} else {_label ctrlShow false};
        _label ctrlCommit 0;
    } forEach _dots;
    // The point itself: the round, see-through orange dot - white while it's being dragged.
    _centre ctrlSetTextColor ([[1, 0.6, 0.1, 0.6], [1, 1, 1, 0.8]] select (_active isEqualTo "plane"));
    private _cPos = _boat modelToWorldVisual _p;
    [_centre, _cPos, 0.09] call _place;
    private _cs = worldToScreen _cPos;
    _name ctrlSetText ((_names select _i) select 1);
    if (count _cs == 2) then {_name ctrlSetPosition [(_cs select 0) + 0.03, (_cs select 1) + 0.03, 0.4, 0.03]; _name ctrlShow true} else {_name ctrlShow false};
    _name ctrlCommit 0;
}];

// ---- Mouse ----
ANC_adjDistToSeg = {
    params ["_m", "_a", "_b"];
    private _ab = _b vectorDiff _a;
    private _len2 = _ab vectorDotProduct _ab;
    if (_len2 < 1e-8) exitWith {_m distance2D _a};
    private _t = (((_m vectorDiff _a) vectorDotProduct _ab) / _len2) max 0 min 1;
    _m distance2D (_a vectorAdd (_ab vectorMultiply _t))
};
_disp displayAddEventHandler ["MouseButtonDown", {
    params ["", "_button", "", "", "", "", "_alt"];
    getMousePosition params ["_mx", "_my"];
    ANC_adj params ["_boat"];
    if (_button == 1) exitWith {ANC_adjOrbit = [_mx, _my]};
    if (_button != 0) exitWith {};
    private _m = [_mx, _my, 0];
    private _p = call ANC_adjPoint;
    private _sc = worldToScreen (_boat modelToWorldVisual _p);
    private _best = ["", 0.025];
    if (count _sc == 2 && {(_m distance2D (_sc + [0])) < 0.015}) then {_best = [["plane", "z"] select _alt, 0]};
    if ((_best select 0) isEqualTo "") then {
        {
            _x params ["_k", "_axis"];
            private _a = worldToScreen (_boat modelToWorldVisual (_p vectorDiff (_axis vectorMultiply ANC_adjLen)));
            private _b = worldToScreen (_boat modelToWorldVisual (_p vectorAdd (_axis vectorMultiply ANC_adjLen)));
            if (count _a == 2 && {count _b == 2}) then {
                private _d = [_m, _a + [0], _b + [0]] call ANC_adjDistToSeg;
                if (_d < (_best select 1)) then {_best = [_k, _d]};
            };
        } forEach ANC_adjAxes;
    };
    if !((_best select 0) isEqualTo "") then {ANC_adj set [4, [_best select 0, [_mx, _my], _p]]};
}];
_disp displayAddEventHandler ["MouseButtonUp", {
    params ["", "_button"];
    if (_button == 1) then {ANC_adjOrbit = nil};
    if (_button == 0) then {ANC_adj set [4, []]}; // let go: the point stays where it is
}];
_disp displayAddEventHandler ["MouseMoving", {
    getMousePosition params ["_mx", "_my"]; // absolute cursor position
    ANC_adj params ["_boat", "_names", "_i", "_pending", "_drag", "_cam", "_yaw", "_pitch"];
    if (!isNil "ANC_adjOrbit") exitWith {
        ANC_adjOrbit params ["_ox", "_oy"];
        ANC_adj set [6, _yaw + ((_mx - _ox) * 180)];
        ANC_adj set [7, ((_pitch + ((_my - _oy) * 120)) max -80) min 85];
        ANC_adjOrbit = [_mx, _my];
    };
    if (count _drag == 0) exitWith {};
    _drag params ["_kind", "_m0", "_p0"];
    private _new = +_p0;
    if (_kind isEqualTo "plane") then {
        // Where the mouse ray meets the deck plane through the point.
        private _camPos = AGLToASL positionCameraToWorld [0, 0, 0];
        private _dir = screenToWorldDirection [_mx, _my];
        private _planeZ = (_boat modelToWorldWorld _p0) select 2;
        if (abs (_dir select 2) > 0.01) then {
            private _hit = _camPos vectorAdd (_dir vectorMultiply ((_planeZ - (_camPos select 2)) / (_dir select 2)));
            private _local = _boat worldToModel (ASLToAGL _hit);
            private _dx = (_local select 0) - (_p0 select 0);
            private _dy = (_local select 1) - (_p0 select 1);
            if (ANC_adjSnap) then {_dx = round (_dx / ANC_adjStep) * ANC_adjStep; _dy = round (_dy / ANC_adjStep) * ANC_adjStep};
            _new = _p0 vectorAdd [_dx, _dy, 0];
        };
    } else {
        // Along one axis: how far the mouse has moved along that axis's direction on screen.
        private _axis = ((ANC_adjAxes select (["x", "y", "z"] find _kind)) select 1);
        private _s0 = worldToScreen (_boat modelToWorldVisual _p0);
        private _s1 = worldToScreen (_boat modelToWorldVisual (_p0 vectorAdd _axis)); // 1 m along the axis
        private _sv = [0, 0];
        if (count _s0 == 2 && {count _s1 == 2}) then {_sv = [(_s1 select 0) - (_s0 select 0), (_s1 select 1) - (_s0 select 1)]};
        private _len2 = ((_sv select 0) ^ 2) + ((_sv select 1) ^ 2);
        // Up / down, or an axis seen almost end-on: use plain mouse up / down, scaled by camera distance.
        if (_kind isEqualTo "z" || {_len2 < 0.0025}) then {
            private _metres = -(_my - (_m0 select 1)) * (ANC_adj select 8) * 0.6;
            if (!(_kind isEqualTo "z")) then {_metres = -_metres};
            if (ANC_adjSnap) then {_metres = round (_metres / ANC_adjStep) * ANC_adjStep};
            _new = _p0 vectorAdd (_axis vectorMultiply _metres);
            _len2 = -1;
        };
        if (_len2 > 0) then {
            if (true) then {
                private _metres = ((((_mx - (_m0 select 0)) * (_sv select 0)) + ((_my - (_m0 select 1)) * (_sv select 1))) / _len2);
                if (ANC_adjSnap) then {_metres = round (_metres / ANC_adjStep) * ANC_adjStep};
                _new = _p0 vectorAdd (_axis vectorMultiply _metres);
            };
        };
    };
    _pending set [(_names select _i) select 0, _new];
    call ANC_adjShow;
}];
_disp displayAddEventHandler ["MouseZChanged", {
    params ["", "_z"];
    ANC_adj set [8, (((ANC_adj select 8) * (1 - (_z * 0.1))) max 1) min 25];
}];

// ---- Keys (this screen only) ----
_disp displayAddEventHandler ["KeyDown", {
    params ["_disp", "_key"];
    ANC_adj params ["_boat", "_names", "_i", "_pending"];
    switch (_key) do {
        case 57: {ANC_adj set [2, (_i + 1) mod (count _names)]; ANC_adj set [4, []]; call ANC_adjShow; true};
        case 28;
        case 156: {
            private _layoutVal = [[], [1, 0, 0]] select (ANC_adjLayout isEqualTo "sides");
            if (ANC_adjAllType) then {
                // every boat of this type: saved on the server (and in its profile); this boat's own points for the
                // same names are dropped, so it follows its type too
                {
                    [[typeOf _boat, _x, _y], "savePoint", 2] call ANC_fnc_remote;
                    [_boat, _x, []] call ANC_adjSetOwn;
                } forEach _pending;
                if (ANC_adjLayoutChanged) then {
                    [[typeOf _boat, "moorLayout", _layoutVal], "savePoint", 2] call ANC_fnc_remote;
                    [_boat, "moorLayout", []] call ANC_adjSetOwn;
                };
            } else {
                // this boat only: kept on the boat - and, if it has a variable name, in the server's profile for this
                // mission
                {[_boat, _x, _y] call ANC_adjSetOwn} forEach _pending;
                if ((vehicleVarName _boat) isEqualTo "") then {
                    systemChat "Anchors: this boat has no variable name, so its own points last for this mission only. Give it a name in the Eden editor to keep them.";
                };
                if (ANC_adjLayoutChanged) then {[_boat, "moorLayout", [[0, 0, 0], [1, 0, 0]] select (ANC_adjLayout isEqualTo "sides")] call ANC_adjSetOwn};
            };
            ANC_adjLayoutChanged = false;
            systemChat format ["Anchors: saved for %1 (mooring points: %2). Anything already tied on keeps its point until it's let go.",
                [format ["this %1 only", typeOf _boat], format ["every boat of this model (%1 and its variants)", typeOf _boat]] select ANC_adjAllType,
                ["bow and stern", "port and starboard"] select (ANC_adjLayout isEqualTo "sides")];
            ANC_adj set [3, createHashMap];
            call ANC_adjShow;
            true
        };
        case 211: {
            private _name = (_names select _i) select 0;
            _pending deleteAt _name;
            if (ANC_adjAllType) then {
                [[typeOf _boat, _name, []], "savePoint", 2] call ANC_fnc_remote;
                [_boat, _name, []] call ANC_adjSetOwn;
                systemChat format ["Anchors: point reset to automatic for every %1 (other variants of this model keep any points saved on them).", typeOf _boat];
            } else {
                [_boat, _name, []] call ANC_adjSetOwn;
                systemChat "Anchors: this boat's own point removed - it uses its type's point again.";
            };
            [] spawn {sleep 0.5; if (!isNil "ANC_adj") then {call ANC_adjShow}};
            true
        };
        case 34: {ANC_adjSnap = !ANC_adjSnap; call ANC_adjShow; true}; // G: snapping on / off
        case 20: {ANC_adjAllType = !ANC_adjAllType; call ANC_adjShow; true}; // T: save for this boat only / every boat of its type
        case 38: { // L: mooring layout
            ANC_adjLayout = ["sides", "ends"] select (ANC_adjLayout isEqualTo "sides");
            ANC_adjLayoutChanged = true;
            private _new = call ANC_adjNames;
            ANC_adj set [1, _new];
            ANC_adj set [2, (_i min ((count _new) - 1))];
            ANC_adj set [4, []];
            call ANC_adjShow;
            true
        };
        case 14: {_disp closeDisplay 2; true};
        default {false};
    };
}];

// Closing the screen (Esc, Backspace, or anything else) puts everything back.
_disp displayAddEventHandler ["Unload", {
    removeMissionEventHandler ["Draw3D", ANC_adjDraw];
    if (!isNil "ANC_adj") then {
        private _cam = ANC_adj select 5;
        _cam cameraEffect ["terminate", "back"];
        camDestroy _cam;
    };
    ANC_adj = nil;
    ANC_adjOrbit = nil;
}];

call ANC_adjShow;
