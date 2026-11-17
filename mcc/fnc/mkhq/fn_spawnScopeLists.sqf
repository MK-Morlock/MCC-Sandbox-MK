params [["_faction", "", [""]]];
private _sc = missionNamespace getVariable ["MCCMK_spawnScope", ((profileNamespace getVariable ["MCCMK_spawnScope", 2]) max 0) min 5];
private _facs = [_faction, _sc] call MCCMK_fnc_scopeFactions;
if (_facs isEqualTo []) then {_facs = [_faction]};
private _cfgF = configFile >> "CfgFactionClasses";
private _lc = toLower _faction;
{
	private _kind = _x;
	private _out = [];
	{
		private _f = _x;
		private _list = +(missionNamespace getVariable [format ["MCC_faction_%1_U_GEN_%2", _f, _kind], []]);
		if (_sc < 2) then {_list = _list select {[_x select 1, _faction, _sc] call MCC_fnc_contentAllowed}};
		if ((toLower _f) != _lc) then {
			private _n = getText (_cfgF >> _f >> "displayName");
			_list = _list apply {[_x select 0, _x select 1, _x select 2, [format ["%1 [%2]", (_x select 3) select 0, _n], (_x select 3) select 1]]};
		};
		_out append _list;
	} forEach _facs;
	missionNamespace setVariable ["U_GEN_" + _kind, _out];
} forEach ["SOLDIER", "CAR", "MOTORCYCLE", "TANK", "HELICOPTER", "AIRPLANE", "SHIP"];
