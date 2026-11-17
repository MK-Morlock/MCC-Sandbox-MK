params [["_ship", objNull, [objNull]]];
private _best = 0;
{
	if (!isNull _x) then {
		{
			if ((getText (_x >> "componentType")) == "ActiveRadarSensorComponent") then {_best = _best max (getNumber (_x >> "AirTarget" >> "maxRange"))};
		} forEach ("isClass _x" configClasses (configOf _x >> "Components" >> "SensorsManagerComponent" >> "Components"));
	};
} forEach (_ship getVariable ["MCCMK_weapons", []]);
if (_best <= 0) then {_best = 8000};
_best
