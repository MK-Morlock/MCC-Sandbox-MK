/*
    ANC_fnc_xlRelease  (server)
    Lets go of one extra line (tow line or tether): the rope comes away, its pull stops on both vehicles, and the haul
    keys go back to the boat's other lines. [id, message for both crews ("" = none)]
*/
params [["_id", "", [""]], ["_msg", "", [""]]];
if (isNil "ANC_xLines" || {!(_id in ANC_xLines)}) exitWith {};
private _r = ANC_xLines get _id;
ANC_xLines deleteAt _id;
private _rope = _r get "rope";
if (!isNull _rope) then {ropeDestroy _rope};
{
    if (!isNull _x) then {
        [_x] call ANC_fnc_xlSync;
        if ((_x getVariable ["ANC_activeLine", ""]) isEqualTo _id) then {_x setVariable ["ANC_activeLine", "", true]};
        if (_msg != "" && {alive _x}) then {[_x, _msg] call ANC_fnc_tellBoat};
    };
} forEach [_r get "a", _r get "b"];
