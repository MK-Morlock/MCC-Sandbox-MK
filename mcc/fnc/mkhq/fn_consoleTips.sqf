disableSerialization;
params [["_mode", "apply", [""]], ["_v", -1, [0]]];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (_mode == "toggle") then {
	profileNamespace setVariable ["MCCMK_consoleTips", _v == 1];
};
private _on = profileNamespace getVariable ["MCCMK_consoleTips", false];
if (isNull _d) exitWith {};
private _box = _d displayCtrl 9172;
if (_mode == "init") then {
	_box cbSetChecked _on;
	if !(_d getVariable ["MCCMK_tipsLoop", false]) then {
		_d setVariable ["MCCMK_tipsLoop", true];
		_d spawn {
			disableSerialization;
			while {!isNull _this} do {
				if !(profileNamespace getVariable ["MCCMK_consoleTips", false]) then {["apply"] call MCCMK_fnc_consoleTips};
				sleep 1;
			};
		};
	};
};
{
	if (_x != _box) then {
		if (_on) then {
			private _t = _x getVariable ["MCCMK_tip", ""];
			if (_t != "" && {(ctrlTooltip _x) == ""}) then {_x ctrlSetTooltip _t};
		} else {
			private _t = ctrlTooltip _x;
			if (_t != "") then {
				_x setVariable ["MCCMK_tip", _t];
				_x ctrlSetTooltip "";
			};
		};
	};
} forEach (allControls _d);
if (_mode == "toggle" && {_on}) then {[] call MCC_fnc_consoleTheme};
