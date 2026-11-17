params [["_o", objNull, [objNull]], ["_force", false, [true]]];
if (!isServer || {isNull _o}) exitWith {};
if (!_force && {!(missionNamespace getVariable ["MCCMK_campaignSetupDone", false])}) exitWith {};
if (isNil "MCCMK_tileCells") exitWith {};
private _side = _o getVariable ["side", _o getVariable ["MCC_side", sideUnknown]];
if !(_side in [west, east, resistance]) exitWith {};
private _hq = [_o] call MCCMK_fnc_isHQ;
[getPos _o, [500, 1000] select _hq, _side, 0.2] call MCC_fnc_campaignPaintMarkers;
["INFO", "campaignProtect", "%1 %2 at grid %3: %4 m painted for %5", [["F.O.B.", "HQ"] select _hq, _o getVariable ["mcc_fob_name", _o getVariable ["MCC_LHDDisplayName", typeOf _o]], mapGridPosition _o, [500, 1000] select _hq, _side]] call MCC_fnc_log;
