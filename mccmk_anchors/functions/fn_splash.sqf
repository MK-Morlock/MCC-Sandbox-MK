/*
    ANC_fnc_splash  (97; every computer)
    - a small splash and its sound where a thrown bag goes into the water. [positionASL]
*/
params ["_p"];
if (!hasInterface) exitWith {};
// (the game's own water-impact particles and a splash sound, where they exist)
if (isClass (configFile >> "CfgCloudlets" >> "ImpactWater")) then {
    private _s = "#particlesource" createVehicleLocal (ASLToAGL _p);
    _s setParticleClass "ImpactWater";
    _s setPosASL _p;
    [_s] spawn {params ["_s"]; sleep 0.4; deleteVehicle _s};
};
private _snd = "A3\Sounds_F\environment\objects\water\water_splash_small_2.wss";
if (fileExists _snd) then {playSound3D [_snd, objNull, false, _p, 2, 1, 80]};
