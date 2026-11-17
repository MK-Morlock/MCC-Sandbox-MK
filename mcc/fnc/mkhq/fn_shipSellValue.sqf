// What a ship sells for: 60% of what was paid for a bought ship, 40% of its price for one placed in Eden / for free
// (the same Addon Options as vehicles: MCCMK_sellBought / MCCMK_sellSeized), reduced by hull damage when "Sell value
// counts damage" is on. [ship]  ->  [ammo, supply, fuel, bought?]
params [["_ship", objNull, [objNull]]];
private _paid = _ship getVariable ["MCCMK_shipPaid", []];
private _bought = (count _paid) == 3;
private _price = if (_bought) then {_paid} else {(([_ship getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 1)};
private _pct = (missionNamespace getVariable [["MCCMK_sellSeized", "MCCMK_sellBought"] select _bought, [40, 60] select _bought]) / 100;
if (missionNamespace getVariable ["MCCMK_sellDamage", true]) then {_pct = _pct * (((_ship getVariable ["MCCMK_hull", 1]) max 0) min 1)};
_price params [["_s", 0], ["_a", 0], ["_f", 0]];
[floor (_a * _pct), floor (_s * _pct), floor (_f * _pct), _bought]
