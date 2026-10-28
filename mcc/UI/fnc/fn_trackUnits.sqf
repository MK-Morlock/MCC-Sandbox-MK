//==================================================================MCC_fnc_trackUnits===========================================================================================
//Track units on the given map display
// Example: [] call MCC_fnc_trackUnits;
//==============================================================================================================================================================================
private "_leader";
private "_markerColor";
private _mapsize = 0;
private "_group";
private _texture = "";
private "_unit";
params ["_map"];

{
	_group = _x;
	_leader = (leader _group);
	_markerColor = (side  _x) call bis_fnc_sideColor;

	{
		_unit = _x;

		if (vehicle _unit == _unit || ((vehicle _unit != _unit) && (_unit == driver vehicle _unit))) then {
			_texture = gettext (configfile >> "CfgVehicles" >> typeof (vehicle _unit) >> "Icon");
			_mapsize = if ((vehicle _unit) == _unit) then {20} else {30};

			if (isPlayer _unit) then {_markerColor = [1, 0, 1,0.8]};

			_map drawIcon [
				_texture,
				_markerColor,
				getpos _unit,
				_mapsize,
				_mapsize,
				direction vehicle _unit
			];

			if (_x != leader _group) then
			{
				_map drawLine [
					getpos _unit,
					getpos (leader _group),
					[0,0,1,0.8]
				];
			};



			if (!isnil "MCC_3D_CAM" && {missionNamespace getVariable ["MCC_3D_GUI", true]}) then
			{
				if((MCC_3D_CAM distance vehicle _unit)<1000) then
				{
					private "_size";
					_bbr = boundingBoxReal vehicle _unit;
					_p1 = _bbr select 0;
					_p2 = _bbr select 1;
					_maxHeight = abs ((_p2 select 2) - (_p1 select 2));

					_size = (0.7 - ((MCC_3D_CAM distance vehicle _unit) * 0.0005)) max 0;

					if (_size > 0) then
					{
						drawIcon3D [
							_texture,
							_markerColor,
							[(getpos vehicle _unit) select 0, (getpos vehicle _unit) select 1, ((getpos vehicle _unit) select 2) + _maxHeight],
							_size,
							_size,
							getdir (vehicle _unit)
						];

						if (_x != leader _group) then
						{
							drawLine3D [
								[(getpos vehicle _unit) select 0, (getpos vehicle _unit) select 1, ((getpos vehicle _unit) select 2) + _maxHeight],
								[(getpos vehicle (leader _group)) select 0, (getpos vehicle(leader _group)) select 1, ((getpos vehicle (leader _group)) select 2) + _maxHeight],
								[0.3,0.5,1,0.45]
							];
						};
					};
				};
			};
		};
	} foreach (units _group);

} foreach allgroups;
