/*
	MCCMK_fnc_rtsNetTilt - a camouflage net laid along the slope, so all its poles reach the ground: its "up" turned to the
	terrain's slope (keeping its heading), then lowered or raised until its middle sits on the ground.
	[net, anchor, [dir, up] in the anchor's space, attached (true: attachTo the anchor; false: a free preview object)]
*/
params [["_net", objNull, [objNull]], ["_anchor", objNull, [objNull]], ["_vec", [[0, 1, 0], [0, 0, 1]], [[]]], ["_attached", true, [true]]];
if (isNull _net || {isNull _anchor}) exitWith {};
private _wpos = getPosWorld _net;
private _nW = surfaceNormal _wpos;
private _dW = _anchor vectorModelToWorld (_vec select 0);
private _right = vectorNormalized (_dW vectorCrossProduct _nW);
private _dirW = vectorNormalized (_nW vectorCrossProduct _right);
private _bottom = ((boundingBoxReal _net) select 0) select 2;
private _drop = (getTerrainHeightASL _wpos) - ((_wpos select 2) + _bottom);
if (_attached) then {
	_net attachTo [_anchor, _anchor worldToModel (ASLToAGL (_wpos vectorAdd [0, 0, _drop]))];
	_net setVectorDirAndUp [_anchor vectorWorldToModel _dirW, _anchor vectorWorldToModel _nW];
} else {
	_net setPosWorld (_wpos vectorAdd [0, 0, _drop]);
	_net setVectorDirAndUp [_dirW, _nW];
};
