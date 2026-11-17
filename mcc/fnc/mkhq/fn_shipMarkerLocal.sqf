params [["_id", "", [""]], ["_pos", [0, 0], [[]]], ["_txt", "", [""]]];
if (!hasInterface || {_id == ""}) exitWith {};
if (_txt == "") exitWith {deleteMarkerLocal _id};
if ((markerType _id) == "") then {
	createMarkerLocal [_id, _pos];
	_id setMarkerTypeLocal "b_naval";
	_id setMarkerColorLocal (["ColorOPFOR", "ColorBLUFOR", "ColorIndependent", "ColorCivilian"] param [[east, west, independent, civilian] find playerSide, "ColorBLUFOR"]);
	_id setMarkerSizeLocal [0.8, 0.8];
};
_id setMarkerPosLocal _pos;
_id setMarkerTextLocal _txt;
