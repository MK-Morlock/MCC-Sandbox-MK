// Commander console Airdrop panel: a Taru supply pod. Parachute or Winch, then the usual click-and-drag line (target
// and the direction it comes in from). [pod index 0-4]
params [["_i", 0, [0]]];
((call MCCMK_fnc_podInfo) param [_i, ["box", "Logistics"]]) params ["_kind", "_label"];
private _m = ["Parachute", "Cancel", "Winch"] call MCC_fnc_choiceBar;
if (_m == "") exitWith {};
private _cost = [_i] call MCCMK_fnc_podCost;
if !(call MCCMK_fnc_resFree) then {
	private _r = missionNamespace getVariable [format ["MCC_res%1", playerSide], [0, 0, 0, 0, 0]];
	if ((_r select 0) < (_cost select 0) || {(_r select 1) < (_cost select 1)} || {(_r select 2) < (_cost select 2)} || {(_r select 4) < (_cost select 3)}) exitWith {["Not enough resources for that pod."] call MCCMK_fnc_hint; _m = ""};
};
if (_m == "") exitWith {};
MCCMK_podReq = [_i, [0, 1] select (_m == "right")];
MCC_spawnkind = ["MCCMK_TARUPOD"];
MCC_planeType = [str playerSide];
MCCMK_consolePending = [];
MCC_CASrequestMarker = true;
[format ["%1 pod: left click on the map, hold and drag to mark where it goes and the direction the Taru comes in from.", _label]] call MCCMK_fnc_hint;
