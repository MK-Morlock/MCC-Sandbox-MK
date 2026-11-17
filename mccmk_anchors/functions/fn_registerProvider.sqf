/*
    ANC_fnc_registerProvider  (every computer, preInit)
    Lets another mod add its own rope option to the Anchors menu and keys. Used by the Paddle Mod fix to add the
    Zodiac rope bag.

    [id, label, availableCode, startCode, reelCode, winchCode, carrierBoatCode, cleanupCode]
        call ANC_fnc_registerProvider;

      availableCode   {params ["_boat"]; true/false}       offered for this boat?
      startCode       {params ["_boat", "_player", "_aimASL", "_target"]}
                                                           deploy (server); aimASL is where the player was looking
      reelCode        {params ["_boat", "_player"]}       bring it back (server)
      winchCode       {params ["_boat", "_player", "_m"]} Shift+Page Down / Page Up, metres (server)
      carrierBoatCode {params ["_player"]; boat or objNull} boat whose rope this
                                                           person holds on foot
      cleanupCode     {params ["_boat"]}                  boat destroyed / deleted

    While its rope is out, the provider sets _boat setVariable ["ANC_mode", id] and clears it ("") when everything is
    put away.
*/
params ["_id", "_label", "_available", "_start", "_reel", "_winch", "_carrierBoat", "_cleanup"];
if (isNil "ANC_providers") then {ANC_providers = createHashMap};
ANC_providers set [_id, [_label, _available, _start, _reel, _winch, _carrierBoat, _cleanup]];
