disableSerialization;
params [["_grid", [], [[]]]];
private _side = side group player;
private _laser = laserTarget (vehicle player);
if (isNull _laser) then {_laser = laserTarget player};
private _tgt = if (!isNull _laser) then {getPosASL _laser} else {_grid};
private _d = (findDisplay 46) createDisplay "RscDisplayEmpty";
uiNamespace setVariable ["MCCMK_navalTgt", [_tgt, _laser]];
private _btnC = ["MCC_RscButtonRound", "MCC_RscButtonRound3D"] select (profileNamespace getVariable ["MCC_consoleButtons", false]);
private _opts = [];
if (count _tgt > 1) then {
	{
		private _s = _x;
		if (!isNull _s && {(_s getVariable ["MCC_side", sideUnknown]) isEqualTo _side} && {!(_s getVariable ["MCCMK_sinking", false])}) then {
			{
				private _w = _x;
				if (!isNull _w && {alive _w}) then {
					private _kind = ["", "gun", "vls"] select ((["B_Ship_Gun_01_F", "B_Ship_MRLS_01_F"] find typeOf _w) + 1);
					// only the weapons switched on in Ship status
					if (_kind == "gun" && {!(_s getVariable ["MCCMK_navalGuns", false])}) then {_kind = ""};
					if (_kind == "vls" && {!(_s getVariable ["MCCMK_navalVLS", false])}) then {_kind = ""};
					if (_kind != "") then {
						private _why = "";
						private _cd = (_s getVariable [format ["MCCMK_navalCD_%1", _kind], 0]) - serverTime;
						if (_kind == "vls" && {isNull _laser}) then {_why = "needs a laser target"};
						if (_kind == "gun" && {!(_tgt inRangeOfArtillery [[_w], currentMagazine _w])}) then {_why = "out of range"};
						if (_kind == "vls" && {(_s distance2D _tgt) > 25000}) then {_why = "out of range"};
						if ((count (magazinesAllTurrets _w select {(_x select 2) > 0})) == 0) then {_why = "no ammunition - rearm"};
						if (_cd > 0) then {_why = format ["ready in %1", [_cd, "MM:SS"] call BIS_fnc_secondsToString]};
						([_kind] call MCCMK_fnc_navalCost) params ["_cost"];
						_opts pushBack [_s, _w, _kind, _why, _cost];
					};
				};
			} forEach (_s getVariable ["MCCMK_weapons", []]);
		};
	} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
};
uiNamespace setVariable ["MCCMK_navalOpts", _opts];
private _n = (count _opts) min 6;
private _rowH = 0.036 * safezoneH; private _gap = 0.008 * safezoneH;
private _panW = 0.40 * safezoneW;
private _panH = (0.16 * safezoneH) + (_n max 1) * (_rowH + _gap);
private _panX = safezoneX + (safezoneW - _panW) / 2;
private _panY = safezoneY + (safezoneH - _panH) / 2;
private _pad = 0.012 * safezoneW;
private _bg = _d ctrlCreate ["RscText", -1]; _bg ctrlSetPosition [_panX, _panY, _panW, _panH]; _bg ctrlSetBackgroundColor [0.08, 0.09, 0.1, 0.95]; _bg ctrlCommit 0;
private _ti = _d ctrlCreate ["RscStructuredText", -1];
_ti ctrlSetPosition [_panX + _pad, _panY + 0.012 * safezoneH, _panW - 2 * _pad, 0.07 * safezoneH];
_ti ctrlSetStructuredText parseText format ["<t size='1.25' font='PuristaMedium'>Naval fire support</t><br/><t size='0.85' color='#aaaaaa'>%1</t>", switch (true) do {
	case (!isNull _laser): {format ["Target: laser, grid %1", mapGridPosition _tgt]};
	case (count _tgt > 1): {format ["Target: grid %1 (gun only - lase the target for missiles)", mapGridPosition _tgt]};
	default {"No target: lase it, or pick a grid on the map (gun only)."};
}];
_ti ctrlCommit 0;
if (_opts isEqualTo [] && {count _tgt > 1}) then {
	private _t = _d ctrlCreate ["RscStructuredText", -1];
	_t ctrlSetPosition [_panX + _pad, _panY + 0.09 * safezoneH, _panW - 2 * _pad, _rowH];
	_t ctrlSetStructuredText parseText "<t size='0.9' color='#ff9944'>None of your ships can fire on this target.</t>";
	_t ctrlCommit 0;
};
{
	_x params ["_s", "_w", "_kind", "_why", "_cost"];
	private _b = _d ctrlCreate [_btnC, 8100 + _forEachIndex];
	_b ctrlSetPosition [_panX + _pad, _panY + 0.09 * safezoneH + _forEachIndex * (_rowH + _gap), _panW - 2 * _pad, _rowH];
	_b ctrlSetText format ["%1, %2: %3%4", _s getVariable ["MCC_LHDDisplayName", "Ship"], ["Gun, 5 rounds HE", "VLS, 1 cruise missile"] select (_kind == "vls"), if (call MCCMK_fnc_resFree) then {toString [8734]} else {format ["%1 Ammo%2", _cost select 0, ["", format [" + %1 Fuel", _cost select 1]] select ((_cost select 1) > 0)]}, ["", format ["  (%1)", _why]] select (_why != "")];
	_b ctrlEnable (_why == "");
	_b ctrlAddEventHandler ["ButtonClick", {
		params ["_c"];
		((uiNamespace getVariable ["MCCMK_navalOpts", []]) param [(ctrlIDC _c) - 8100, []]) params ["_s", "_w", "_kind"];
		(uiNamespace getVariable ["MCCMK_navalTgt", [[], objNull]]) params ["_tgt", "_laser"];
		(ctrlParent _c) closeDisplay 1;
		[_s, _w, _kind, _tgt, _laser, player] remoteExec ["MCCMK_fnc_navalFire", 2];
	}];
	_b ctrlCommit 0;
} forEach (_opts select [0, _n]);
private _gb = _d ctrlCreate [_btnC, -1];
_gb ctrlSetPosition [_panX + _pad, _panY + _panH - 0.046 * safezoneH, 0.13 * safezoneW, 0.034 * safezoneH];
_gb ctrlSetText "Pick grid on map";
_gb ctrlAddEventHandler ["ButtonClick", {
	(ctrlParent (_this select 0)) closeDisplay 2;
	[] spawn {
		openMap [true, false];
		MCCMK_navalPick = [];
		onMapSingleClick "MCCMK_navalPick = _pos; onMapSingleClick ''; openMap [false, false]; true";
		waitUntil {sleep 0.2; (MCCMK_navalPick isNotEqualTo []) || {!visibleMap}};
		onMapSingleClick "";
		if (MCCMK_navalPick isNotEqualTo []) then {[AGLToASL MCCMK_navalPick] call MCCMK_fnc_navalPanel};
	};
}];
_gb ctrlCommit 0;
private _no = _d ctrlCreate [_btnC, -1];
_no ctrlSetPosition [_panX + _panW - _pad - 0.09 * safezoneW, _panY + _panH - 0.046 * safezoneH, 0.09 * safezoneW, 0.034 * safezoneH];
_no ctrlSetText "Cancel";
_no ctrlAddEventHandler ["ButtonClick", {(ctrlParent (_this select 0)) closeDisplay 2}];
_no ctrlCommit 0;
