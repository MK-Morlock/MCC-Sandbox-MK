//Enable MCC Radio System
[
    "MCC_VonRadio",
    "CHECKBOX",
   	["Enable MCC Radio System","Radio system uses default ArmA Voice Over IP"],
    "MCCMK Radio",
    false,
    true,
    {
    	[] remoteExec ["MCC_fnc_vonRadio",0];
    }
] call CBA_Settings_fnc_init;

//Global radio distance
[
    "MCC_vonRadioDistanceGlobal",
    "SLIDER",
   	"Global Radio Distance",
    ["MCCMK Radio", "Distance"],
    [1000, 5000, 2000, 0],
    true
] call CBA_Settings_fnc_init;


//Global side distance
[
    "MCC_vonRadioDistanceSide",
    "SLIDER",
   	"Side Radio Distance",
    ["MCCMK Radio", "Distance"],
    [3000, 7000, 5000, 0],
    true
] call CBA_Settings_fnc_init;

//Commander side distance
[
    "MCC_vonRadioDistanceCommander",
    "SLIDER",
   	"Commander Radio Distance",
    ["MCCMK Radio", "Distance"],
    [8000, 20000, 12000, 0],
    true
] call CBA_Settings_fnc_init;

//Group side distance
[
    "MCC_vonRadioDistanceGroup",
    "SLIDER",
   	"Group Radio Distance",
    ["MCCMK Radio", "Distance"],
    [300, 1000, 2500, 0],
    true
] call CBA_Settings_fnc_init;

//Kick hot mic
[
    "MCC_vonRadioKickIdle",
    "CHECKBOX",
   	["Kick Hot Mic","Kicks a player with a hot mic after some time"],
    ["MCCMK Radio", "Anti-Abuse"],
    false,
    true
] call CBA_Settings_fnc_init;

//Hot mic: time before kick (MK: it used the group radio distance variable, so the two settings fought)
[
    "MCC_vonRadioKickIdleTime",
    "SLIDER",
   	"Time Before Kick",
    ["MCCMK Radio", "Anti-Abuse"],
    [5, 60, 30, 0],
    true
] call CBA_Settings_fnc_init;