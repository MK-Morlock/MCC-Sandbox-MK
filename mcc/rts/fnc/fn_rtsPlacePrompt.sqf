disableSerialization;
params [["_name", "", [""]], ["_valid", true, [true]]];
private _disp = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
if (isNull _disp) exitWith {};
private _ctrl = _disp displayCtrl 9137;
if (isNull MCC_CONST_PLACEHOLDER) exitWith {_ctrl ctrlShow false};
if (_name != "") then {_ctrl setVariable ["MCC_placeName", _name]};
private _state = if (_valid) then {"<t color='#7FF0B4'>Clear to build</t>"} else {"<t color='#FF7A68'>Blocked: slope, objects or outside the base area</t>"};
_ctrl ctrlSetStructuredText parseText format [
	"<t align='center'><t font='RobotoCondensedBold' color='#FFFFFF'>Placing: %1</t>   %2<br /><t color='#C3D0DA' size='0.85'>Mouse wheel: rotate (Shift: faster)   |   Left click: build   |   Right click: cancel</t></t>",
	_ctrl getVariable ["MCC_placeName", ""], _state
];
_ctrl ctrlShow true;
