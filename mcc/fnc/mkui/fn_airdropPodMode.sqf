/*
	MCCMK_fnc_airdropPodMode - the MCC console's Supply Drop panel, Taru Pod (the third insertion choice): shows the pod
	controls (which pod, Parachute / Winch, smoke, the parachute height) and hides the crate ones, or back. The pod and the delivery are remembered.
	[on]
*/
disableSerialization;
params [["_on", false, [false]]];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (isNil "MCCMK_adMem") then {MCCMK_adMem = createHashMap};
MCCMK_adMem set ["pod", _on];
// the crate controls: aircraft filters and list, search, type and class lists, heights, smoke
{(_d displayCtrl _x) ctrlShow !_on} forEach [1031, 1032, 1038, 1039, 1040, 1041, 1042, 1044, 1045, 1046, 1047, 1048, 1049, 1104, 1105, 1106, 1107, 1108, 1109, 1110];
private _mode = missionNamespace getVariable ["MCC_airdropIsParachute", 0];
for "_i" from 1033 to 1036 do {(_d displayCtrl _i) ctrlShow (!_on && {_mode == 0})};	// the drop list: parachute only
// the pod controls
{(_d displayCtrl _x) ctrlShow _on} forEach [1112, 1114, 1116];
//(MK) laid out like the crate lists (two lists side by side, the height under its title, smoke beside it): no labels
{(_d displayCtrl _x) ctrlShow false} forEach [1111, 1113, 1115];
// the parachute height: Parachute only
private _para = _on && {(MCCMK_adMem getOrDefault ["podMethod", 0]) == 0};
{(_d displayCtrl _x) ctrlShow _para} forEach [1117, 1118];
// (MK) the lists filled and set to the remembered choices once (when first shown)
if (_on && {lbSize (_d displayCtrl 1112) == 0}) then {
	private _c = _d displayCtrl 1112;
	{_c lbAdd (_x select 1)} forEach (call MCCMK_fnc_podInfo);
	_c lbSetCurSel (((MCCMK_adMem getOrDefault ["podType", 0]) max 0) min ((lbSize _c) - 1));
	(_d displayCtrl 1114) lbSetCurSel ((MCCMK_adMem getOrDefault ["podMethod", 0]) min 1);
	(_d displayCtrl 1116) cbSetChecked (MCCMK_adMem getOrDefault ["podSmoke", true]);
	private _hc = _d displayCtrl 1118;
	private _hts = [40, 50, 75, 100, 120, 150, 200, 300, 400, 500];
	{private _i = _hc lbAdd format ["%1 m", _x]; _hc lbSetValue [_i, _x]} forEach _hts;
	_hc lbSetCurSel ((_hts find (MCCMK_adMem getOrDefault ["podHeight", 120])) max 0);
};
