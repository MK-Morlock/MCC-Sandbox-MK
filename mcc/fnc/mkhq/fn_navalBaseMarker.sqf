params [["_id", "", [""]], ["_pos", [0, 0], [[]]], ["_text", "", [""]]];
if (!hasInterface) exitWith {};
if (_text == "") exitWith {deleteMarkerLocal _id};
if ((markerType _id) == "") then {createMarkerLocal [_id, _pos]};
_id setMarkerPosLocal _pos;
_id setMarkerTypeLocal "mil_warning";
_id setMarkerColorLocal "ColorRed";
_id setMarkerTextLocal _text;
