params [["_m", "", [""]]];
if (!hasInterface) exitWith {};
private _d = uiNamespace getVariable ["MCCMK_statusDisp", displayNull];
if (isNull _d) exitWith {[_m] call MCCMK_fnc_hint};
(_d displayCtrl 7951) ctrlSetStructuredText parseText format ["<t align='center' size='0.9' color='#FAC775'>%1</t>", _m];
uiNamespace setVariable ["MCCMK_statusMsgT", diag_tickTime];
