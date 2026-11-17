/*
    ANC_fnc_commMenu  (client)
    A 0-8 Communication menu order (Anchor, Weigh anchor, Moor, Cast off, Throw line ashore) for the boats of the
    units you've selected (F-keys) or the High Command groups you've selected.
*/
params ["_order"];
private _boats = [player] call ANC_fnc_commBoats;
if (count _boats == 0) exitWith {hintSilent "Select units in a boat (F-keys) or High Command groups in boats first."};
{[[_x, _order, player], "aiOrder", 2] call ANC_fnc_remote} forEach _boats;
