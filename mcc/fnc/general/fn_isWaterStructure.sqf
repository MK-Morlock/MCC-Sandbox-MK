params [["_b", objNull, [objNull]]];
if (isNull _b) exitWith {false};
private _n = toLower ((typeOf _b) + " " + ((getModelInfo _b) select 0));
((["pier", "jetty", "bridge", "dock", "wharf", "quay", "pontoon", "boardwalk", "molo"] findIf {(_n find _x) >= 0}) >= 0) || {surfaceIsWater (getPosWorld _b)}
