/*
    ANC_fnc_speeds
    Real-life rates for letting go and hauling in, in m/s: [lower, haul]
      Dinghy / small boat, by hand:            lower 1.0, haul 0.5  (30 m/min)
      Boats 8-12 m, small windlass:            lower 1.0, haul 0.4  (24 m/min)
      12-50 m, chain windlass:                 lower 2.0, haul 0.3  (18 m/min)
      Ships over 50 m (let go under brake):    lower 3.0, haul 0.15 (9 m/min,
                                               the standard minimum for ship windlasses)
      Landing craft kedge winch:               haul 0.25 (15 m/min)
    Hauling is multiplied by the "Weighing anchor speed" setting (x1, x5, x10, x15, x20 - default - or x30). Lowering
    always uses the real rate.
*/
params [["_boat", objNull, [objNull]], ["_isKedge", false, [false]]];
private _length = (_boat call ANC_fnc_boatGeometry) select 6;
private _mult = [1, 5, 10, 15, 20, 30] select (((missionNamespace getVariable ["ANC_windlassSpeed", 4]) min 5) max 0);
private _s = switch (true) do {
    case (_isKedge):                                  {[6, 0.25]};
    case (_boat isKindOf "Rubber_duck_base_F");
    case (_length < 8):                               {[1, 0.5]};
    case (_length < 12):                              {[1, 0.4]};
    case (_length < 50):                              {[2, 0.3]};
    default                                           {[3, 0.15]};
};
[_s select 0, (_s select 1) * _mult]
