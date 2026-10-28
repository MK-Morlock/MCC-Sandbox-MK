disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (isNil "MCC_airDropArray") then {MCC_airDropArray = []};
if ((missionNamespace getVariable ["MCC_airdropIsParachute", 0]) != 0) exitWith {};
private _c = _d displayCtrl 1032;
private _i = lbCurSel _c;
private _cl = if (_i >= 0) then {_c lbData _i} else {""};
private _n = count MCC_airDropArray;
private _live = (missionNamespace getVariable ["MCCMK_adLive", false]) && {_n > 0};
if (_live && {(MCC_airDropArray select (_n - 1)) == _cl}) exitWith {[] call MCCMK_fnc_airdropShowList};
if (_live) then {MCC_airDropArray = MCC_airDropArray select [0, _n - 1]};
MCCMK_adLive = false;
if (_cl != "") then {
	private _cAir = _d displayCtrl 1038;
	private _carrier = if (lbCurSel _cAir >= 0) then {_cAir lbData (lbCurSel _cAir)} else {""};
	private _fit = if (_carrier == "") then {[true]} else {[_carrier, MCC_airDropArray + [_cl]] call MCCMK_fnc_airdropFit};
	if (_fit select 0) then {
		MCC_airDropArray = MCC_airDropArray + [_cl];
		MCCMK_adLive = true;
	} else {
		[_carrier, _fit] call MCCMK_fnc_airdropFitHint;
	};
};
[] call MCCMK_fnc_airdropShowList;
