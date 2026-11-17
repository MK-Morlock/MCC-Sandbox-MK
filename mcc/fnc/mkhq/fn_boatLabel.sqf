params [["_b", objNull, [objNull]], ["_ship", objNull, [objNull]]];
private _m = _ship worldToModel (getPos _b);
format ["%1, %2 side, %3 m, %4 seats", getText (configOf _b >> "displayName"), ["starboard", "port"] select ((_m select 0) < 0), round (_b distance2D player), count ((fullCrew [_b, "", true]) select {isNull (_x select 0)})]
