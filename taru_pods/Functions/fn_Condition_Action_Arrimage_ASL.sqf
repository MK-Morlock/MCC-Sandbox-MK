params [["_v", objNull, [objNull]], ["_mode", "", [""]]];
if (isNil "ASL_Is_Supported_Vehicle") exitWith {false};
if (!isNull (getSlingLoad _v)) exitWith {false};
if (count (_v getVariable ["ASL_Ropes", []]) == 0) exitWith {false};
if ((_v getVariable ["MCCMK_Info_Taru", ""]) isEqualTo "Arrimage") exitWith {false};
private _p = [_v] call MCCMK_Taru_fnc_ASL_Nacelle;
if (isNull _p || {!isNull (attachedTo _p)}) exitWith {false};
if !(MCCMK_Taru_Pod_Mod_Action_Arrimage_Disponible) exitWith {false};
if !([] call MCCMK_Taru_fnc_Verification_Acces_Roles) exitWith {false};
[_mode] call MCCMK_Taru_fnc_Verification_Interactions_Ace
