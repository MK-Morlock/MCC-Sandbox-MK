/*
    ANC_fnc_server  (server)
    Every anchor / mooring request comes here, so one place owns each boat's anchor and nothing gets out of step
    between players' computers.

      "toggle" - anchor key (anyone aboard). Nothing out: drop anchor / kedge,
                 or a menu if there's a choice (a provider's option such as the Paddle Mod rope bag; "Moor" within 20
                 m of a dock). Something
                 out: weigh anchor, cast off / re-moor, or hand to the provider.
      "towKey" - tow line key (anyone aboard): a numbered list of vehicles
                 within 20 m (boats first, nearest first, with where they are), leaving out any with enemies aboard
                 (empty or friendly-crewed vehicles are fine, whatever their faction); then Tow (you tow it, by its
                 bow or stern) / Towed (it tows you, from your bow or stern). Only one in reach: straight to those
                 choices. Pressed while towing: release.
      "towPick" - the vehicle picked from that list. "choose" - the player's pick from that menu "winch" - Shift+Page
      Down / Shift+Page Up: haul in (negative) or pay out (positive)
*/
if (!isServer) exitWith {};
params [["_action", "", [""]], ["_boat", objNull, [objNull]], ["_player", objNull, [objNull]], ["_arg", 0, [0, ""]], ["_aim", [], [[]]], ["_target", objNull, [objNull]]];
if (isNull _player) exitWith {};
if (isNil "ANC_providers") then {ANC_providers = createHashMap};

private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
private _ownLabel = createHashMapFromArray [
    ["anchor", "Anchor"],
    ["grapnel", "Anchor"],
    ["kedge", "Kedge anchor"],
    ["moor", "Moor"],
    ["shore_bow", "Throw the rope bag - from the bow"],
    ["shore_stern", "Throw the rope bag - from the stern"]
];

// A vehicle the player is looking at, close enough to throw the grapnel to. A vehicle still within the 20 m tow
// reach.
private _towTarget = {
    params ["_t"];
    if (isNull _t || {_t isEqualTo _boat} || {!alive _t}) exitWith {false};
    (([_boat, _player] call ANC_fnc_towCandidates) findIf {(_x select 0) isEqualTo _t}) != -1
};

private _options = {
    private _list = [];
    (_boat call ANC_fnc_info) params ["_mode", "", "", "", "_kind"];
    {
        _y params ["_label", "_available"];
        if ([_boat] call _available) then {_list pushBack [_label, _x]};
    } forEach ANC_providers;
    if !(_mode isEqualTo "") then {_list pushBack [_ownLabel get _kind, _mode]};
    // Submarines / SDVs can moor when surfaced (they don't anchor). THROW THE ROPE BAG - from the bow or the stern,
    // anywhere: ashore if there's shore where you look (within 20 m), otherwise into the water where you look - a
    // guide rope down to the bottom (as in Paddle Mod Fix). With a Heaving line in the boat or on you, under 8 km/h.
    if ((missionNamespace getVariable ["ANC_tieUp", true]) && {abs (speed _boat) < 8} && {_boat call ANC_fnc_isSurfaced} && {count ([_boat] call ANC_fnc_findDock) > 0}) then {
        _list pushBack [_ownLabel get "moor", "moor"];
    };
    // RAFT-UP / TETHER: another boat within 10 m (empty, civilian or friendly): Raft-Up alongside it, or - if either
    // boat is a dinghy - Tether to it. This boat already the other end of someone's raft-up / tether: let go from
    // here.
    // (tethers are extra lines now: several at once, one per point - released from the tow line key's menu)
    if (abs (speed _boat) < 8 && {_boat call ANC_fnc_isSurfaced} && {count ([_boat, _player] call ANC_fnc_raftTargets) > 0}) then {
        _list pushBack ["Tether", "tether"];
    };
    _list
};

// A tow line: the vehicles in reach - one: straight to Tow / Towed; several: the list to choose from; none: why not.
private _towOffer = {
    ([_boat, _player, true] call ANC_fnc_towCandidates) params ["_cands", "_blocked"];
    _boat setVariable ["ANC_towCands", _cands];
    switch (count _cands) do {
        case 0: {
            ([
                "No vehicle within 20 m to throw a tow line to.",
                "The only vehicles within 20 m have enemies aboard - they can't be towed."
            ] select (_blocked > 0)) call _say;
        };
        case 1: {
            _boat setVariable ["ANC_pending", [[], (_cands select 0) select 0]];
            [[_boat, [["Tow - line to their bow", "tow_bow"], ["Tow - line to their stern", "tow_stern"], ["Towed - line from my bow", "towed_bow"], ["Towed - line from my stern", "towed_stern"]], "Tow line"], "menu", _player] call ANC_fnc_remote;
        };
        default {[[_boat, _cands], "towMenu", _player] call ANC_fnc_remote};
    };
};
// the rope bag can be thrown: a Heaving line in the boat or on you, under 8 km/h - and shore within 20 m, all round.
// It's only for getting a line ashore now: out at sea the tow line (to another boat) and the anchor (a line to the
// bottom) do what throwing it into the water did.
private _bagOk = {[_player, _boat] call ANC_fnc_hasLine && {abs (speed _boat) < 8} && {count ([_boat] call ANC_fnc_shoreFind) > 0}};

// Raft-Up or Tether to one boat: Tether if either boat is a dinghy (no cleats to raft with), otherwise Raft-Up
private _raftStart = {
    params ["_boat", "_player", "_o", ["_want", "raft"]];
    // what was chosen - but a dinghy can only be tethered
    private _kind = "tether";
    [_o] call ANC_fnc_addBoatHandlers;
    _boat setVariable ["ANC_mode", _kind];
    _boat setVariable ["ANC_state", "rafting"];
    [_boat, _player, _o, _kind] spawn ANC_fnc_raft;
};

private _start = {
    params ["_choice"];
    (_boat getVariable ["ANC_pending", [[], objNull]]) params ["_pAim", "_pTarget"];
    if (_choice in ANC_providers) exitWith {[_boat, _player, _pAim, _pTarget] call ((ANC_providers get _choice) select 2)};
    switch (_choice) do {
        case "anchor";
        case "kedge": {_boat setVariable ["ANC_mode", _choice]; [_boat, _player, _pAim] spawn ANC_fnc_anchorDeploy};
        case "moor":  {_boat setVariable ["ANC_mode", "moor"]; _boat setVariable ["ANC_state", "mooring"]; [_boat, _player] spawn ANC_fnc_moor};
        case "raftoff": {
            // let go of a raft-up / tether - from the boat that made the lines fast, or from the other end
            private _m = _boat getVariable ["ANC_mode", ""];
            private _rl = _boat getVariable ["ANC_raftLink", []];
            private _tether = (_rl param [1, ""]) isEqualTo "tether";
            if (_m in ["raft", "tether"]) then {
                [_boat] call ANC_fnc_cleanup;
            } else {
                if (count _rl >= 5) then {
                    private _o = _rl select 0;
                    if (!isNull _o && {(_o getVariable ["ANC_mode", ""]) in ["raft", "tether"]}) then {[_o] call ANC_fnc_cleanup} else {[_boat, _o] call ANC_fnc_setRaftLink};
                };
            };
            (["Rafted off.", "Untethered."] select _tether) call _say;
        };
        case "raft";
        case "tether": {
            private _rt = [_boat, _player] call ANC_fnc_raftTargets;
            if (count _rt == 0) exitWith {"No boat within 10 m to raft up or tether to." call _say};
            // one boat in reach: that one. Several: a list to choose from, as for tow lines (ANC_fnc_raftMenu ->
            // "raftPick"). Raft-Up: only boats it can raft up to (no dinghies); Tether: any
            if (_choice isEqualTo "raft") then {_rt = _rt select {!((_boat call ANC_fnc_isDinghy) || {(_x select 0) call ANC_fnc_isDinghy})}};
            if (count _rt == 0) exitWith {"No boat within 10 m to raft up to." call _say};
            _boat setVariable ["ANC_raftChoice", _choice];
            if (count _rt > 1) exitWith {
                _boat setVariable ["ANC_raftCands", _rt apply {_x select 0}];
                [[_boat, _rt, _choice], "raftMenu", _player] call ANC_fnc_remote;
            };
            [_boat, _player, (_rt select 0) select 0] spawn ANC_fnc_xlTether;
        };
        case "shore_bow";
        case "shore_stern": {_boat setVariable ["ANC_mode", "shore"]; _boat setVariable ["ANC_state", "flying"]; [_boat, _player, _pAim, ["bow", "stern"] select (_choice isEqualTo "shore_stern")] spawn ANC_fnc_shoreThrow};
        case "tow_bow";
        case "tow_stern";
        case "towed_bow";
        case "towed_stern": {[_boat, _player, _pTarget, _pAim, _choice] spawn ANC_fnc_towDeploy};
    };
};

switch (_action) do {
    case "toggle": {
        if (isNull _boat || {!alive _boat} || {!(_player in crew _boat)}) exitWith {};
        private _mode = _boat getVariable ["ANC_mode", ""];

        if (_mode isEqualTo "") exitWith {
            _boat setVariable ["ANC_pending", [_aim, _target]];
            private _list = call _options;
            if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Shift+R on %1: options %2 | Heaving line: on you %3, in boat %4 | shore within 20 m %5 | dock within 20 m %6 | speed %7",
                typeOf _boat, _list apply {_x select 1}, "ANC_HeavingLine" in (items _player), "ANC_HeavingLine" in (itemCargo _boat),
                count ([_boat, _aim] call ANC_fnc_shoreFind) > 0, count ([_boat] call ANC_fnc_findDock) > 0, round (speed _boat)]};
            switch (count _list) do {
                case 0: {
                    if ((_boat call ANC_fnc_isSubmersible) && {!(_boat call ANC_fnc_isSurfaced)}) then {"Surface first to moor." call _say};
                };
                case 1: {[(_list select 0) select 1] call _start};
                default {[[_boat, _list], "menu", _player] call ANC_fnc_remote};
            };
        };

        if (_mode in ANC_providers) exitWith {[_boat, _player] call ((ANC_providers get _mode) select 3)};

        private _state = _boat getVariable ["ANC_state", ""];
        if (_mode isEqualTo "tow") exitWith {"The tow line is out - release it with the tow line key ({tow})." call _say};
        if (_mode isEqualTo "shore") exitWith {"The rope bag is out - bring it back with {tow}." call _say}; // the rope bag is on the tow line key
        // rafted up / tethered: let go
        if (_mode in ["raft", "tether"]) exitWith {
            if (_state isEqualTo "rafted") then {
                [[_boat, [[["Raft Off", "Untether"] select (_mode isEqualTo "tether"), "raftoff"]], ["Rafted up", "Tethered"] select (_mode isEqualTo "tether")], "menu", _player] call ANC_fnc_remote;
            } else {
                "Still making fast." call _say;
            };
        };
        if (_mode isEqualTo "moor") exitWith {
            if (_state isEqualTo "moored") then {
                [[_boat, [["Cast off", "castoff"], ["Moor", "remoor"]], "Moored"], "menu", _player] call ANC_fnc_remote;
            } else {
                "Still mooring." call _say;
            };
        };
        if (_state in ["fixed", "hanging", "kedgePaying"]) then {
            [_boat, _player] call ANC_fnc_anchorRaise;
        } else {
            // (MK) still going down (dropped by mistake?): it stops where it is and is weighed from there
            if (_state isEqualTo "lowering") exitWith {_boat setVariable ["ANC_stopLower", _player]};
            // (MK) and the other way: being weighed (by mistake?) - it's let go again, from the bow
            if (_state isEqualTo "reeling" && {(_boat getVariable ["ANC_mode", ""]) in ["anchor", "kedge"]}) exitWith {
                private _arMode = _boat getVariable ["ANC_mode", "anchor"];
                [_boat] call ANC_fnc_cleanup;
                _boat setVariable ["ANC_mode", _arMode, true];
                [_boat, _player] spawn ANC_fnc_anchorDeploy;
            };
            (["The anchor is busy.", "Already weighing anchor. {haul} / {payout} take over by hand."] select (_state isEqualTo "reeling")) call _say;
        };
    };

    case "choose": {
        if (isNull _boat || {!alive _boat} || {!(_player in crew _boat)}) exitWith {};
        // from the tow line key's menu
        if (_arg isEqualTo "towline") exitWith {call _towOffer};
        // from the tow line key's menu: tether to a boat; release one of the boat's lines
        if (_arg isEqualTo "tether") exitWith {["tether"] call _start};
        if ((_arg select [0, 4]) isEqualTo "rel_") exitWith {
            private _id = _arg select [4];
            if (!isNil "ANC_xLines" && {_id in ANC_xLines}) then {
                private _what = [_id, _boat, false] call ANC_fnc_xlLabel;
                [_id, ""] call ANC_fnc_xlRelease;
                (format ["Let go: %1.", _what]) call _say;
            };
        };
        // from the line menu (Ctrl+Page Down): which line the haul keys work on
        if ((_arg select [0, 5]) isEqualTo "line_") exitWith {
            private _id = _arg select [5];
            _boat setVariable ["ANC_activeLine", _id, true];
            (format ["Haul keys: %1.", if (_id isEqualTo "main") then {_boat getVariable ["ANC_mainLabel", "anchor / mooring"]} else {[_id, _boat] call ANC_fnc_xlLabel}]) call _say;
        };
        if (_arg in ["shore_bow", "shore_stern"]) exitWith {
            if ((_boat getVariable ["ANC_mode", ""]) isEqualTo "" && {call _bagOk}) then {[_arg] call _start} else {"You can't throw the rope bag now - it needs shore within 20 m, a Heaving line aboard and under 8 km/h." call _say};
        };
        // Tow line choice.
        if (_arg in ["tow_bow", "tow_stern", "towed_bow", "towed_stern"]) exitWith {
            (_boat getVariable ["ANC_pending", [[], objNull]]) params ["", "_pTarget"];
            if ([_pTarget] call _towTarget) then {[_arg] call _start} else {"That vehicle is out of reach now, or has enemies aboard." call _say};
        };
        // Raft Off / Untether - from the boat that made the lines fast, or from the other end
        if (_arg isEqualTo "raftoff") exitWith {["raftoff"] call _start};
        // Moored: cast off, or re-moor.
        if (_arg in ["castoff", "remoor"]) exitWith {
            if !((_boat getVariable ["ANC_mode", ""]) isEqualTo "moor" && {(_boat getVariable ["ANC_state", ""]) isEqualTo "moored"}) exitWith {};
            if (_arg isEqualTo "castoff") then {
                [_boat] call ANC_fnc_cleanup;
                "Cast off." call _say;
            } else {
                [_boat, _player] spawn ANC_fnc_remoor;
            };
        };
        if !((_boat getVariable ["ANC_mode", ""]) isEqualTo "") exitWith {};
        if ((call _options) findIf {(_x select 1) isEqualTo _arg} == -1) exitWith {};
        [_arg] call _start;
    };

    case "towKey": {
        // Its own key, so anchoring near another boat can never throw a tow line by mistake. A menu: throw a tow line,
        // the rope bag, tether to a boat, and let go of any of the boat's lines. Only a tow line to throw: straight to it.
        if (isNull _boat || {!alive _boat} || {!(_player in crew _boat)}) exitWith {};
        private _mode = _boat getVariable ["ANC_mode", ""];
        // the rope bag is out: bring it back (this key looks after the rope bag)
        if (_mode isEqualTo "shore") exitWith {
            if ((_boat getVariable ["ANC_state", ""]) in ["loose", "held", "tied"]) then {[_boat, _player] spawn ANC_fnc_shoreRetrieve} else {"Wait a moment." call _say};
        };
        _boat setVariable ["ANC_pending", [_aim, _target]];
        private _list = [];
        private _canTow = count (([_boat, _player, true] call ANC_fnc_towCandidates) select 0) > 0;
        if (_canTow) then {_list pushBack ["Throw a tow line", "towline"]};
        if (_mode isEqualTo "" && {call _bagOk}) then {
            _list pushBack [_ownLabel get "shore_bow", "shore_bow"];
            _list pushBack [_ownLabel get "shore_stern", "shore_stern"];
        };
        if (abs (speed _boat) < 8 && {_boat call ANC_fnc_isSurfaced} && {count ([_boat, _player] call ANC_fnc_raftTargets) > 0}) then {_list pushBack ["Tether to a boat", "tether"]};
        {_list pushBack [format ["Let go: %1", [_x select 0, _boat] call ANC_fnc_xlLabel], "rel_" + (_x select 0)]} forEach (_boat getVariable ["ANC_xl", []]);
        if (count _list == 0) exitWith {call _towOffer};
        if (count _list == 1 && {_canTow}) exitWith {call _towOffer};
        [[_boat, _list, "Lines"], "menu", _player] call ANC_fnc_remote;
    };
    case "lineMenu": {
        // Ctrl+Page Down: which line the haul keys (Shift+Page Down / Up) work on.
        if (isNull _boat || {!alive _boat} || {!(_player in crew _boat)}) exitWith {};
        private _mode = _boat getVariable ["ANC_mode", ""];
        private _list = [];
        if !(_mode isEqualTo "") then {
            private _lbl = switch (_mode) do {
                case "moor": {"Mooring lines"};
                case "kedge": {"Kedge anchor cable"};
                case "shore": {"Rope bag line"};
                default {"Anchor rope / chain"};
            };
            _boat setVariable ["ANC_mainLabel", _lbl];
            _list pushBack [_lbl, "line_main"];
        };
        {_list pushBack [[_x select 0, _boat] call ANC_fnc_xlLabel, "line_" + (_x select 0)]} forEach ((_boat getVariable ["ANC_xl", []]) select {(_x select 1) isEqualTo "tow"});
        if (count _list == 0) exitWith {"No lines out to haul in or pay out." call _say};
        [[_boat, _list, "Haul keys work on"], "menu", _player] call ANC_fnc_remote;
    };
    case "raftPick": {
        // a boat picked from the Raft-Up / Tether list
        if (isNull _boat || {!alive _boat} || {!(_player in crew _boat)} || {!(_arg isEqualType 0)}) exitWith {};
        private _o = (_boat getVariable ["ANC_raftCands", []]) param [_arg, objNull];
        if ((([_boat, _player] call ANC_fnc_raftTargets) findIf {(_x select 0) isEqualTo _o}) == -1) exitWith {"That boat is out of reach now (10 m), or has enemies aboard." call _say};
        [_boat, _player, _o] spawn ANC_fnc_xlTether;
    };

    case "towPick": {
        // A vehicle picked from the tow list: now Tow or Towed.
        if (isNull _boat || {!alive _boat} || {!(_player in crew _boat)} || {!(_arg isEqualType 0)}) exitWith {};
        private _pick = ((_boat getVariable ["ANC_towCands", []]) param [_arg, []]) param [0, objNull];
        if !([_pick] call _towTarget) exitWith {"That vehicle is out of reach now, or has enemies aboard." call _say};
        _boat setVariable ["ANC_pending", [[], _pick]];
        [[_boat, [["Tow - line to their bow", "tow_bow"], ["Tow - line to their stern", "tow_stern"], ["Towed - line from my bow", "towed_bow"], ["Towed - line from my stern", "towed_stern"]], "Tow line"], "menu", _player] call ANC_fnc_remote;
    };

    // ---- Shore line actions by people on foot (scroll menu) ----
    case "shoreThrowLand": {[_player, _boat] spawn ANC_fnc_shoreThrowLand};
    case "shorePick":      {[_player] call ANC_fnc_shorePick};
    case "bagGet":         {[_player, _boat] call ANC_fnc_bagGet}; // Get Bag
    case "bagStow":        {[_player] call ANC_fnc_bagStow}; // Bag in Boat
    case "shoreDrop":      {[_player] call ANC_fnc_shoreDrop};
    case "shoreTie":       {[_player] call ANC_fnc_shoreTie};
    case "shoreTakeBack":  {[_player] call ANC_fnc_shoreTakeBack};
    case "shoreThrowSea":  {[_player, _aim] spawn ANC_fnc_shoreThrowSea}; // into the sea
    case "shoreHaulSea":   {[_player] call ANC_fnc_shoreHaulSea};

    case "winch": {
        if !(_arg isEqualType 0) exitWith {};
        // On foot: whoever is holding a provider's rope (e.g. the rope bag) controls it.
        private _handled = false;
        {
            private _b = [_player] call (_y select 5);
            if (!isNull _b) exitWith {_handled = true; [_b, _player, _arg] call (_y select 4)};
        } forEach ANC_providers;
        if (_handled) exitWith {};

        // Holding a shore line ashore.
        private _held = _player getVariable ["ANC_holdingBoat", objNull];
        if (!isNull _held) exitWith {[_held, _player, _arg] call ANC_fnc_shoreWinch};

        if (isNull _boat || {_boat isKindOf "CAManBase"} || {!(_player in crew _boat)}) exitWith {};
        // A tow line or tether chosen for the haul keys (or the last one thrown): straight to it, whatever else is out.
        private _act = _boat getVariable ["ANC_activeLine", ""];
        if (_act != "" && {_act != "main"} && {((_boat getVariable ["ANC_xl", []]) findIf {(_x select 0) isEqualTo _act}) >= 0}) exitWith {[_boat, _player, _arg, _aim] call ANC_fnc_winch};
        if ((_boat getVariable ["ANC_mode", ""]) isEqualTo "shore") exitWith {[_boat, _player, _arg] call ANC_fnc_shoreWinch};
        private _mode = _boat getVariable ["ANC_mode", ""];
        if (_mode in ANC_providers) exitWith {[_boat, _player, _arg] call ((ANC_providers get _mode) select 4)};
        if (_mode isEqualTo "" && {count (_boat getVariable ["ANC_xl", []]) == 0}) exitWith {"Nothing deployed." call _say};
        if (_mode in ["raft", "tether"]) exitWith {"The lines to the other boat are made fast." call _say};
        [_boat, _player, _arg, _aim] call ANC_fnc_winch;	// (MK) _aim carries the step: [metres]
    };
};
