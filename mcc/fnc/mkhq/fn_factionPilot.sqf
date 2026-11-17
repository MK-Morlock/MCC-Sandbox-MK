// A faction's own helicopter pilot class (its jobs table - MCCMK_fnc_pools); the side's vanilla helicopter pilot only as
// a last resort. Cached. [faction, side]  ->  class
params [["_fac", "", [""]], ["_side", west, [west]]];
private _fallback = ["B_Helipilot_F", "O_helipilot_F", "I_helipilot_F"] param [[west, east, resistance] find _side, "B_Helipilot_F"];
if (_fac == "") exitWith {_fallback};
//(MK) from the faction's jobs table (MCCMK_fnc_pools); the side's vanilla pilot only if the faction has no soldiers at all
private _pick = [_fac, "Pilot"] call MCCMK_fnc_poolJob;
[_pick, _fallback] select (_pick == "")
