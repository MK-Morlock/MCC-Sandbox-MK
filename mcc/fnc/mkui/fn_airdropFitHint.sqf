params [["_carrier", "", [""]], ["_fit", [], [[]]]];
private _fmt = {
	private _s = str (round _this);
	private _o = "";
	private _k = 0;
	for "_i" from ((count _s) - 1) to 0 step -1 do {
		if (_k > 0 && {_k mod 3 == 0}) then {_o = "," + _o};
		_o = (_s select [_i, 1]) + _o;
		_k = _k + 1;
	};
	_o
};
private _nm = getText (configFile >> "CfgVehicles" >> _carrier >> "displayName");
hint (if ((_fit param [3, 0]) > 0) then {
	format ["Does not fit in the %1: %2 (%3 of %4 kg used)", _nm, _fit select 1, (_fit select 2) call _fmt, (_fit select 3) call _fmt]
} else {
	format ["Does not fit in the %1: %2", _nm, _fit param [1, ""]]
});
