params [["_t", 0, [0]]];
private _parse = {
	params ["_s", "_d"];
	private _a = (_s splitString ", ") apply {parseNumber _x};
	if (count _a < count _d) then {_d} else {_a}
};
private _prices = [
	[missionNamespace getVariable ["MCCMK_shipPriceDestroyer", "1500,1000,800"], [1500, 1000, 800]],
	[missionNamespace getVariable ["MCCMK_shipPriceCarrier", "1500,600,1000"], [1500, 600, 1000]],
	[missionNamespace getVariable ["MCCMK_shipPriceSub", "800,0,400"], [800, 0, 400]],
	[missionNamespace getVariable ["MCCMK_shipPriceLHD", "2000,800,1200"], [2000, 800, 1200]]
] apply {_x call _parse};
private _depths = [missionNamespace getVariable ["MCCMK_shipDepths", "12,15,10,12"], [12, 15, 10, 12]] call _parse;
_t = (_t max 0) min 3;
[["Destroyer", "Aircraft carrier", "Submarine", "LHD"] select _t, _prices select _t, _depths select _t, [[22, 111], [56, 196], [9, 50], [30, 131]] select _t]
