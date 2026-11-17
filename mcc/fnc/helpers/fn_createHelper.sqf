//==================================================================MCC_fnc_createHelper=======================================================================================
// Create ingame UI helper for interacted objects
//===============================================================================================================================================================================
#define MCC_HELPER "UserTexture1m_F"


params ["_object", "_text"];

if (!isServer) exitWith {};

if (isnil "_object") exitWith {};
if (isnull _object || !isServer) exitWith {};

_helper = MCC_HELPER createVehicle [0,0,0]; [_helper] call MCCMK_fnc_genTag;
_helper attachto [_object,[0,0,1]];
_helper setVariable ["MCC_helperText",_text,true];

while {alive _object} do {sleep 2};
deletevehicle _helper;
