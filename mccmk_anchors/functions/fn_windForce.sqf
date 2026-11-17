/*
    ANC_fnc_windForce
    Wind force on a boat, in newtons: 1/2 x air density x (wind speed relative to the boat)^2 x above-water area
    facing the wind (broadside-on catches more than end-on). Same physics as the wind drift.
    [boat]           - with the current Arma 3 wind
    [boat, speed]    - for a given wind speed (m/s), boat broadside and still
*/
params [["_boat", objNull, [objNull]], ["_forSpeed", -1, [0]]];
(_boat call ANC_fnc_boatGeometry) params ["", "", "", "_halfW", "", "_topZ", "_length", "_zWater"];
private _freeboard = ((_topZ - _zWater) max 0.2) min (_length * 0.3);
if (_forSpeed >= 0) exitWith {0.5 * 1.225 * _forSpeed * _forSpeed * _length * _freeboard * 0.8};

private _w = wind;
private _wH = [_w select 0, _w select 1, 0];
if (vectorMagnitude _wH < 0.1) exitWith {0};
private _wDir = vectorNormalized _wH;
private _heading = vectorDir _boat;
_heading set [2, 0];
private _broad = abs (((vectorNormalized _heading) vectorCrossProduct _wDir) select 2);
private _area = ((_length * _broad) + ((_halfW * 2) * (1 - _broad))) * _freeboard * 0.8;
private _rel = ((vectorMagnitude _wH) - ((velocity _boat) vectorDotProduct _wDir)) max 0;
0.5 * 1.225 * _rel * _rel * _area
