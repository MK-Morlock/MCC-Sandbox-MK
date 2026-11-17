/*
    ANC_fnc_rodeInfo
    What a boat of this size would really carry: [type, maximum length]
      Zodiac-type dinghies - small anchor on 60 m of line
      under 8 m   - rope, 30 m
      8-12 m      - rope, 60 m
      12-24 m     - chain, 100 m
      24-50 m     - chain, 165 m  (6 shackles)
      over 50 m   - chain, 275 m  (10 shackles)
      landing craft (kedge) - wire, 100 m (under 20 m) or 200 m
    Typical figures; real boats vary.
*/
params [["_boat", objNull, [objNull]], ["_isKedge", false, [false]]];
private _length = (_boat call ANC_fnc_boatGeometry) select 6;
if (_isKedge) exitWith {["wire", [100, 200] select (_length >= 20)]};
if (_boat isKindOf "Rubber_duck_base_F") exitWith {["rope", 60]};
switch (true) do {
    case (_length < 8):  {["rope", 30]};
    case (_length < 12): {["rope", 60]};
    case (_length < 24): {["chain", 100]};
    case (_length < 50): {["chain", 165]};
    default {["chain", 275]};
};
