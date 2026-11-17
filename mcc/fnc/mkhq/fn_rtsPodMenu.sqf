// (MK) RTS "Taru pods" (the Aerial Workshop): choose a pod, then click the ground in the base to place it (within 150 m of
// the workshop; right-click cancels). Same look as the Buy ship window.
disableSerialization;
params [["_ctrl", controlNull, [controlNull]]];
private _parent = if (isNull _ctrl) then {findDisplay 46} else {ctrlParent _ctrl};
private _free = call MCCMK_fnc_resFree;
private _kinds = ["medevac", "repair", "ammo", "fuel", "box", "bench", "covered"];
private _d = _parent createDisplay "RscDisplayEmpty";
private _btnC = ["MCC_RscButtonRound", "MCC_RscButtonRound3D"] select (profileNamespace getVariable ["MCC_consoleButtons", false]);
private _fs = ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8;
private _rowH = 0.03 * safezoneH;
private _gap = 0.006 * safezoneH;
private _panW = 0.30 * safezoneW;
private _panH = (0.105 * safezoneH) + (count _kinds) * (_rowH + _gap);
private _panX = safezoneX + (safezoneW - _panW) / 2;
private _panY = safezoneY + (safezoneH - _panH) / 2;
private _pad = 0.012 * safezoneW;
private _bg = _d ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_panX, _panY, _panW, _panH];
_bg ctrlSetBackgroundColor [0.08, 0.09, 0.1, 0.95];
_bg ctrlCommit 0;
private _ti = _d ctrlCreate ["RscStructuredText", -1];
_ti ctrlSetPosition [_panX + _pad, _panY + 0.012 * safezoneH, _panW - 2 * _pad, 0.05 * safezoneH];
_ti ctrlSetFontHeight _fs;
_ti ctrlSetStructuredText parseText "<t size='1.15' font='RobotoCondensedBold'>Taru pods</t><br/><t size='1' color='#aaaaaa'>Choose a pod, then click the ground in the base to place it.</t>";
_ti ctrlCommit 0;
uiNamespace setVariable ["MCCMK_podMenuParent", _parent];
{
	private _kind = _x;
	([_kind] call MCCMK_fnc_rtsPodCost) params ["_label", "_cost"];
	private _can = _free || {(_cost findIf {!([playerSide, _x] call MCC_fnc_checkRes)}) < 0};
	private _costTxt = if (_free) then {toString [8734]} else {(_cost apply {format ["%1 %2", _x select 1, ["Ammo", "Supply", "Fuel", "Food", "Meds"] param [["ammo", "repair", "fuel", "food", "med"] find (_x select 0), _x select 0]]}) joinString ", "};
	private _b = _d ctrlCreate [_btnC, 7950 + _forEachIndex];
	_b ctrlSetPosition [_panX + _pad, _panY + 0.068 * safezoneH + _forEachIndex * (_rowH + _gap), _panW - 2 * _pad, _rowH];
	_b ctrlSetFontHeight _fs;
	_b ctrlSetText format ["%1  -  %2", _label, _costTxt];
	_b ctrlEnable _can;
	if (!_can) then {_b ctrlSetTooltip "Not enough resources"};
	_b setVariable ["MCCMK_kind", _kind];
	_b ctrlAddEventHandler ["ButtonClick", {
		params ["_c"];
		MCCMK_podPlaceKind = _c getVariable ["MCCMK_kind", "box"];
		(ctrlParent _c) closeDisplay 1;
		private _rts = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
		if (isNull _rts) exitWith {};
		["Click the ground inside the base to place the pod (right-click cancels)."] call MCCMK_fnc_hint;
		if (!isNil "MCCMK_podPlaceEH") then {_rts displayRemoveEventHandler ["MouseButtonDown", MCCMK_podPlaceEH]};
		MCCMK_podPlaceEH = _rts displayAddEventHandler ["MouseButtonDown", {
			params ["_disp", "_btn"];
			if !(_btn in [0, 1]) exitWith {false};
			_disp displayRemoveEventHandler ["MouseButtonDown", MCCMK_podPlaceEH];
			MCCMK_podPlaceEH = nil;
			if (_btn == 1) exitWith {["Pod placing cancelled."] call MCCMK_fnc_hint; false};
			private _wp = screenToWorld getMousePosition;
			private _cam = missionNamespace getVariable ["MCC_CONST_CAM", objNull];
			[MCCMK_podPlaceKind, _wp, if (isNull _cam) then {0} else {getDir _cam}, player, missionNamespace getVariable ["MCC_selectedRtsObject", objNull]] remoteExec ["MCCMK_fnc_rtsPodPlace", 2];
			false
		}];
	}];
	_b ctrlCommit 0;
} forEach _kinds;
private _no = _d ctrlCreate [_btnC, -1];
_no ctrlSetPosition [_panX + _panW - _pad - 0.07 * safezoneW, _panY + _panH - 0.038 * safezoneH, 0.07 * safezoneW, 0.028 * safezoneH];
_no ctrlSetFontHeight _fs;
_no ctrlSetText "Cancel";
_no ctrlAddEventHandler ["ButtonClick", {(ctrlParent (_this select 0)) closeDisplay 2}];
_no ctrlCommit 0;
