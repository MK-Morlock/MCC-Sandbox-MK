params [["_units", [], [[]]], ["_positions", [], [[]]]];
{
	if (_forEachIndex < count _units) then {
		private _unit = _units select _forEachIndex;
		if (_x isEqualType [] && {count _x >= 2}) then {
			_unit doMove _x;
			_unit setSpeedMode "FULL";
			_unit spawn {
				sleep 5;
				waitUntil {unitReady _this};
				_this disableAI "MOVE";
				while {unitReady leader _this} do {sleep 1};
				_this enableAI "MOVE";
			};
		};
	};
} forEach _positions;
