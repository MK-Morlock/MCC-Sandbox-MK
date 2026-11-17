/*
    ANC_fnc_pullSpeed  (where the boat is local - from ANC_fnc_rodeTick, 20 times a second)
    How fast a boat pulled by its shore line (rope bag line) moves - from FORCES, nothing else:
      pull    the people holding the line: "Pulling force per person" x how many are on it. The line stretches as they lean into
              it: the pull builds up over its first metre of stretch (a slack line pulls nothing) and is at full strength from 1 m.
      drag    on the water: the water's drag on the hull (1/2 x 1025 kg/m3 x 0.8 x its wetted frontal area x speed squared),
              times the "Water drag" setting (100 % = real water); on the ground: the ground's grip on the hull (a
              third of its weight for an inflatable, half for a hard hull), times the "Ground friction" setting (100 %
              = real sand).
      mass    the boat and everyone aboard (90 kg each).
    The boat speeds up while the pull beats the drag and slows when it doesn't: it settles at the pace of whoever is
    pulling, with the line just stretched enough to pull it along. Stop pulling and the drag slows it to a stop.
    [boat, stretch (m past the line's length), time step, on the ground]  ->  speed towards the puller (m/s)
*/
params ["_boat", "_st", "_dt", "_onGround"];
private _m = ((getMass _boat) max 50) + (90 * ({alive _x} count crew _boat));
private _people = (count (_boat getVariable ["ANC_shoreHolders", []])) max 1;
private _F = _people * (missionNamespace getVariable ["ANC_pullForce", 4000]) * ((_st min 1) max 0);
private _v = _boat getVariable ["ANC_pullV", 0];
if ((time - (_boat getVariable ["ANC_pullVT", -10])) > 0.5) then {_v = 0};
private _drag = if (_onGround) then {
    private _mu = [0.5, 0.3] select (_boat call ANC_fnc_isDinghy);
    _mu * _m * 9.81 * ((((missionNamespace getVariable ["ANC_groundDrag", 100]) / 100) max 0) min 1)
} else {
    private _area = 0.3 * ((_m / 400) ^ (2 / 3));
    0.5 * 1025 * 0.8 * _area * _v * _v * ((((missionNamespace getVariable ["ANC_waterDrag", 100]) / 100) max 0) min 1)
};
if (_v < 0.02 && {_F <= _drag}) then {
    _v = 0; // held: the pull doesn't beat the ground's grip
} else {
    _v = (_v + (((_F - _drag) / _m) * _dt)) max 0;
};
_v = _v min 10;
_boat setVariable ["ANC_pullV", _v];
_boat setVariable ["ANC_pullVT", time];
_v
