/*
    ANC_fnc_slingBlock
    - why a boat cannot be sling loaded now, or "" if it can.
      moored            - ANC_moorOn, or ANC_mode "moor"
      tow line is out   - ANC_towLink (either end of a tow), or ANC_mode "tow"
      shore line is out - ANC_shoreData (a heaving line / throw bag out), or ANC_mode "shore"
      anchored          - ANC_force (an anchor's pull), ANC_endObj (the anchor), or ANC_mode "anchor" / "kedge"
    Params: [vehicle]   Returns: "it's moored" / "it's anchored" / "its tow line is out" / "its shore line is out" / ""
*/
params [["_v", objNull]];
if (isNull _v || {!(_v isKindOf "Ship")}) exitWith {""};
private _mode = toLower (_v getVariable ["ANC_mode", ""]);
switch (true) do {
    case ((_v getVariable ["ANC_moorOn", false]) || {_mode == "moor"}): {"it's moored"};
    case ((count (_v getVariable ["ANC_xl", []])) > 0): {"it has a tow line or tether on it"};
    case ((count (_v getVariable ["ANC_shoreData", []])) == 5 || {_mode == "shore"}): {"its shore line is out"};
    case ((_v getVariable ["ANC_force", false]) || {!isNull (_v getVariable ["ANC_endObj", objNull])} || {_mode in ["anchor", "kedge"]}): {"it's anchored"};
    default {""};
}
