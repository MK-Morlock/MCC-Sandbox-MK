/*
    ANC_fnc_findDock  (server)
    Looks for a pier, dock, jetty, wharf, quay or pontoon within 20 m of the
    boat: from the bow, the stern and both sides amidships it looks out all
    round (every 15 degrees) at deck height and just above, and keeps hits on objects whose model name says they're a
    dock (works on any map).

    Mooring lines:
      bow line   - from the bow deck cleat on the dock side (dinghies: the bow
                   eye) to the nearest dock point from the bow;
      stern line - from the stern deck cleat on the dock side to the nearest
                   dock point from the stern.
    Cleats sit on deck just inside the rail, where crew could reach them (ANC_fnc_deckPoint), or wherever they've been
    adjusted to. Boats 6 m and over always get both. Dinghies: per "Dinghy mooring". Each dock end is made fast on top
    of the dock, 0.4 m in from its edge (found by looking straight down onto the dock there).

    Returns [[boatPoint, cleatASL, gap, side], ...] - empty if nothing in reach.
      gap = distance from that point on the boat to the dock face.
*/
params [["_boat", objNull, [objNull]]];
if (isNull _boat) exitWith {[]};
(_boat call ANC_fnc_boatGeometry) params ["_cx", "_sternY", "_bowY", "_halfW", "_bottomZ", "_topZ", "_length", "_zWater"];
private _keywords = ["pier", "dock", "jetty", "wharf", "quay", "pontoon", "mooring", "bollard", "destroyer_01", "carrier_01", "submarine_01", "cup_lhd"];
// Large static ships count as a dock: boats moor alongside their hull. Their lines are tied on the hull side where they
// meet it (there's no deck within reach to tie onto).
private _shipWords = ["destroyer_01", "carrier_01", "submarine_01", "cup_lhd"];
private _shipCleats = []; // lines made fast on a ship are thrown DOWN from its deck (ANC_fnc_moor)
private _isShip = {
    params ["_o"];
    if (isNull _o) exitWith {false};
    private _name = toLower format ["%1 %2", (getModelInfo _o) select 0, typeOf _o];
    (_shipWords findIf {(_name find _x) != -1}) != -1
};
private _isDock = {
    params ["_o"];
    if (isNull _o || {_o isEqualTo _boat}) exitWith {false};
    private _name = toLower format ["%1 %2", (getModelInfo _o) select 0, typeOf _o];
    (_keywords findIf {(_name find _x) != -1}) != -1
};

// Quick check first: is there anything dock-like near the boat at all? If not, skip the detailed search (about 200
// line-of-sight checks).
private _reach = (_length / 2) + 22;
private _nearby = (nearestTerrainObjects [_boat, [], _reach, false, true]) + (nearestObjects [_boat, ["Static", "Building"], _reach]) + ((allSimpleObjects []) select {(_x distance _boat) < (_reach + 60)});
if ((_nearby findIf {[_x] call _isDock}) == -1) exitWith {[]};

// Look all round from one point on the boat; returns the nearest dock hit: [dist, posASL, dirWorld, object] _pref: 1
// = only abeam or forward of the point (the bow line), -1 = only abeam or aft (the stern line), 0 = any direction.
private _scan = {
    params ["_modelPoint", ["_pref", 0]];
    private _best = [];
    private _origin = _boat modelToWorldWorld _modelPoint;
    private _fwd = vectorDir _boat;
    _fwd = vectorNormalized [_fwd select 0, _fwd select 1, 0];
    {
        private _h = _x;
        for "_a" from 0 to 345 step 15 do {
            private _dir = [sin _a, cos _a, 0];
            private _from = _origin vectorAdd [0, 0, _h];
            private _to = _from vectorAdd (_dir vectorMultiply 20);
            // Directions behind the wanted side (more than 15 degrees past abeam) aren't looked at.
            private _hits = if (_pref != 0 && {((_dir vectorDotProduct _fwd) * _pref) < -0.26}) then {[]} else {
                (lineIntersectsSurfaces [_from, _to, _boat, objNull, true, 3, "GEOM", "FIRE"]) select {
                    [[_x select 3, _x select 2] select (isNull (_x select 3))] call _isDock
                }
            };
            if (count _hits > 0) then {
                private _hit = _hits select 0;
                private _d = _from distance (_hit select 0);
                if (count _best == 0 || {_d < (_best select 0)}) then {
                    _best = [_d, _hit select 0, _dir, [_hit select 3, _hit select 2] select (isNull (_hit select 3)), _hit select 1];
                };
            };
        };
    } forEach [0, 0.7, -0.3];
    _best
};

// Where a line is made fast on the dock: on top, 0.4 m in from the edge that was hit. The cleat: on top of the deck
// just in from where the dock was found. If that spot was a pile or the underside of the deck, look a little further
// in (0.4, 0.8, 1.2 m) for the deck top before falling back to the spot found.
private _cleat = {
    params ["_hitPos", "_dir", "_obj"];
    // A ship's hull: the line is made fast on the ship's DECK EDGE (its bollards), as a crew would. Found by looking
    // straight down from above, just inside the hull where the line met it, then stepping outwards until the deck runs
    // out (the sides flare out towards the deck). The ship's crew throw the line down, so any height works. No deck
    // found: on the hull side instead.
    if ([_obj] call _isShip) exitWith {
        private _n = vectorNormalized [_dir select 0, _dir select 1, 0];
        private _probe = {
            params ["_p"];
            private _h = lineIntersectsSurfaces [[_p select 0, _p select 1, (_hitPos select 2) + 40], [_p select 0, _p select 1, (_hitPos select 2) + 0.5], _boat, objNull, true, 1, "GEOM", "NONE"];
            if (count _h > 0 && {[[(_h select 0) select 3, (_h select 0) select 2] select (isNull ((_h select 0) select 3))] call _isShip}) then {(_h select 0) select 0} else {[]}
        };
        private _edge = [];
        for "_k" from 0 to 42 do {
            private _top = [_hitPos vectorAdd (_n vectorMultiply (0.5 - (_k * 0.25)))] call _probe;
            if (_top isEqualTo []) exitWith {};
            _edge = _top;
        };
        private _onDeck = (_edge isNotEqualTo []) && {((_edge select 2) - (_hitPos select 2)) < 60};
        private _res = if (_onDeck) then {_edge vectorAdd [0, 0, 0.4]} else {(_hitPos vectorAdd (_n vectorMultiply -0.05)) vectorAdd [0, 0, 0.3]};
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Mooring alongside %1: line made fast %2, %3 m above sea level.", typeOf _obj, ["on the hull side (no deck found)", "on the deck edge"] select _onDeck, (_res select 2) toFixed 1]};
        if (_onDeck) then {_shipCleats pushBack _res};
        _res
    };
    private _top = [];
    {
        if (count _top == 0) then {
            private _in = _hitPos vectorAdd (_dir vectorMultiply _x);
            private _down = (lineIntersectsSurfaces [_in vectorAdd [0, 0, 5], _in vectorAdd [0, 0, -2], _boat, objNull, true, 5, "GEOM", "FIRE"]) select {
                [[_x select 3, _x select 2] select (isNull (_x select 3))] call _isDock
            };
            if (count _down > 0) then {_top = ((_down select 0) select 0) vectorAdd [0, 0, 0.15]};
        };
    } forEach [0.4, 0.8, 1.2];
    // Straight above the spot found (a pile under the deck): collision shape, then visible shape.
    if (count _top == 0) then {
        {
            if (count _top == 0) then {
                private _lod = _x;
                {
                    if (count _top == 0) then {
                        private _p = _hitPos vectorAdd (_dir vectorMultiply _x);
                        private _hits = lineIntersectsSurfaces [_p vectorAdd [0, 0, 5], _p vectorAdd [0, 0, 0.05], _boat, objNull, true, 5, _lod, "NONE"];
                        if (count _hits > 0) then {_top = ((_hits select 0) select 0) vectorAdd [0, 0, 0.15]};
                    };
                } forEach [0, 0.4, 0.8];
            };
        } forEach ["GEOM", "VIEW"];
    };
    // Last resort: the pier section's own top, above the spot found.
    if (count _top == 0 && {!isNull _obj}) then {
        private _bb = boundingBoxReal _obj;
        private _topZ = ((getPosASL _obj) select 2) + ((_bb select 1) select 2);
        if (_topZ > (_hitPos select 2) + 0.3 && {_topZ < (_hitPos select 2) + 6}) then {_top = [_hitPos select 0, _hitPos select 1, _topZ + 0.05]};
    };
    private _res = if (count _top > 0) then {_top} else {_hitPos vectorAdd [0, 0, 0.3]};
    if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Mooring cleat on %1: %2 m above sea level (%3).", if (isNull _obj) then {"terrain"} else {typeOf _obj},
        (_res select 2) toFixed 1,
        ["deck top found", "no deck found - tied where the pier was found"] select (count _top == 0)]};
    _res
};

// Scan from deck height at the bow and stern (the cleats are chosen afterwards, on the dock side).
private _scanBow = [_boat, false] call ANC_fnc_hullPoint;
private _bowPt = _scanBow;
private _sternMid = [_cx, _sternY + (_length * 0.15), _scanBow select 2];
// The bow line goes to the dock abeam of or ahead of the bow, the stern line abeam of or astern of the stern - as a
// real crew would lead them. Any direction only if there's nothing that way.
private _bowHit = [_bowPt, 1] call _scan;
if (count _bowHit == 0) then {_bowHit = [_bowPt] call _scan};
private _sternHit = [_sternMid, -1] call _scan;
if (count _sternHit == 0) then {_sternHit = [_sternMid] call _scan};
// Nothing from the ends? Try amidships on both sides (a long boat beside a short pontoon).
if (count _bowHit == 0 && {count _sternHit == 0}) then {
    {
        private _h = [[_cx + (_x * _halfW), (_sternY + _bowY) / 2, _bowPt select 2]] call _scan;
        if (count _h > 0) exitWith {_bowHit = _h};
    } forEach [1, -1];
};
if (count _bowHit == 0 && {count _sternHit == 0}) exitWith {[]};
if (count _bowHit == 0) then {_bowHit = _sternHit};
if (count _sternHit == 0) then {_sternHit = _bowHit};

// Which side the dock is on (from the boat's point of view).
private _sideOf = {params ["_dirW"]; [1, -1] select (((_boat vectorWorldToModel _dirW) select 0) < 0)};
private _want = [true, true];
if (_boat call ANC_fnc_isDinghy) then {
    _want = [[true, false], [false, true], [true, true]] select (((missionNamespace getVariable ["ANC_dinghyMooring", 0]) min 2) max 0);
};

_boat setVariable ["ANC_shipCleats", []];
private _lines = [];
// Lines are led as a crew leads them: the bow line forward to a cleat on the dock AHEAD of the bow, the stern line
// aft to a cleat BEHIND the stern - each at about 45 degrees (offset along the dock by about the boat's distance off
// it, at least 1 m, at most a third of the boat's length). Where there's no deck that far along (the end of a jetty),
// half that, then straight across, then the spot that was found. [hit, boat point, 1 = bow line / -1 = stern line]
private _opposite = {
    params ["_hit", "_pt", ["_lead", 1]];
    _hit params ["_d", "_pos", "_dir", "_obj", ["_normal", [0, 0, 0]]];
    private _n = vectorNormalized [_normal select 0, _normal select 1, 0]; // out of the dock
    if (vectorMagnitude _n < 0.1) exitWith {[_pos, _dir, _obj]};
    private _t = [_n select 1, -(_n select 0), 0]; // along the dock edge
    private _fwd = vectorDir _boat;
    if (((_t vectorDotProduct _fwd) * _lead) < 0) then {_t = _t vectorMultiply -1}; // towards the bow (bow line) / stern (stern line)
    private _bp = _boat modelToWorldWorld _pt;
    private _abeam = _pos vectorAdd ([_n select 1, -(_n select 0), 0] vectorMultiply ((_bp vectorDiff _pos) vectorDotProduct [_n select 1, -(_n select 0), 0]));
    _abeam set [2, _pos select 2];
    private _off = ((_bp distance2D _abeam) max 1) min (((_boat call ANC_fnc_boatGeometry) select 6) * 0.35);
    private _result = [];
    {
        if (count _result == 0) then {
            private _edge = _abeam vectorAdd (_t vectorMultiply (_off * _x));
            private _in = (_edge vectorAdd (_n vectorMultiply -0.4)) vectorAdd [0, 0, 4];
            private _onDeck = (lineIntersectsSurfaces [_in, _in vectorAdd [0, 0, -6], _boat, objNull, true, 3, "GEOM", "FIRE"]) findIf {
                [[_x select 3, _x select 2] select (isNull (_x select 3)), _boat] call ANC_fnc_isDock
            };
            if (_onDeck != -1) then {_result = [_edge, _n vectorMultiply -1, _obj]};
        };
    } forEach [1, 0.5, 0];
    if (count _result == 0) then {[_pos, _dir, _obj]} else {_result}
};
if (_want select 0) then {
    _bowHit params ["_d", "_pos", "_dir", "_obj"];
    private _side = [_dir] call _sideOf;
    private _bpt = [_boat, ["moorBow", "moorFwd"] select ((_boat call ANC_fnc_moorLayout) isEqualTo "sides"), _side] call ANC_fnc_pointFor;
    _lines pushBack [_bpt, ([_bowHit, _bpt, 1] call _opposite) call _cleat, _d, _side];
};
if (_want select 1) then {
    _sternHit params ["_d", "_pos", "_dir", "_obj"];
    private _local = _boat vectorWorldToModel _dir;
    private _side = [_dir] call _sideOf;
    // Dock to the side: stern quarter on that side. Dock astern: the transom.
    private _pt = [_boat, ["moorStern", "moorAft"] select ((_boat call ANC_fnc_moorLayout) isEqualTo "sides"), _side] call ANC_fnc_pointFor;
    _lines pushBack [_pt, ([_sternHit, _pt, -1] call _opposite) call _cleat, _d, _side];
};
// Last resort - both lines still on (nearly) the same spot: move the stern line's cleat along the dock to beside the
// stern, if that spot is on the deck.
if (count _lines == 2) then {
    (_lines select 0) params ["_bPt", "_bCleat"];
    (_lines select 1) params ["_sPt", "_sCleat", "_sGap", "_sSide"];
    if ((_bCleat distance _sCleat) < (2 max (_length * 0.3))) then {
        private _bowW = _boat modelToWorldWorld _bPt;
        private _n = vectorNormalized [(_bCleat select 0) - (_bowW select 0), (_bCleat select 1) - (_bowW select 1), 0]; // boat -> dock
        private _t = [_n select 1, -(_n select 0), 0]; // along the dock
        private _sternW = _boat modelToWorldWorld _sPt;
        private _c = _bCleat vectorAdd (_t vectorMultiply ((_sternW vectorDiff _bCleat) vectorDotProduct _t));
        private _down = (lineIntersectsSurfaces [_c vectorAdd [0, 0, 4], _c vectorAdd [0, 0, -3], _boat, objNull, true, 3, "GEOM", "FIRE"]) select {
            [[_x select 3, _x select 2] select (isNull (_x select 3))] call _isDock
        };
        if (count _down > 0) then {
            _c = ((_down select 0) select 0) vectorAdd [0, 0, 0.15];
            _lines set [1, [_sPt, _c, _sternW distance _c, _sSide]];
        };
    };
};
_boat setVariable ["ANC_shipCleats", _shipCleats];
_lines
