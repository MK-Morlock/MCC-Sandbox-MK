params [["_veh", objNull, [objNull]], ["_kind", "", [""]], ["_title", "", [""]], ["_desc", "", [""]], ["_icon", "", [""]], ["_side", west, [west]]];
private _send = true;
if (!isNull _veh && {_kind != ""}) then {
	private _key = format ["MCC_notice_%1", _kind];
	if (_veh getVariable [_key, false]) then {_send = false} else {_veh setVariable [_key, true, true]};
};
if (_send) then {[_title, 5, _desc, _icon, [1, 1, 1, 1]] remoteExec ["MCC_fnc_consoleBanner", _side]};
