//===============================================================MCC_fnc_rtsBuildUIContainer==============================================================================
//	Upgrad building
//  Parameter(s):
//     	_ctrl: CONTROL
//		_res: resources Needed
//========================================================================================================================================================================
private "_obj";
private _consType = "";
private _constLevel = 0;
private _availableActions = [];
private "_disp";
private "_action";
private _pic = "";
private _res = [];
private _req = [];
private _elec = 0;
private _cnd = "";
private _online = false;
private "_elecOn";
private _constType = "";
private _fnc = "";
private _cfg = configNull;
private _vars = [];
disableSerialization;
params ["_ctrl"];
_disp = ctrlParent _ctrl;

if (count MCC_ConsoleGroupSelected <=0) exitWith {};

//Get vars
(_this select 1) params [
	["_var1","",[""]],
	["_var2","",[""]],
	["_var3","",[""]]
];


_obj = MCC_ConsoleGroupSelected select 0;
_consType = _obj getVariable ["mcc_constructionItemType","hq"];
_constLevel = _obj getVariable ["mcc_constructionItemTypeLevel",1];
_availableActions = [];

//electricity
_elecOn = missionNamespace getVariable [format ["MCC_rtsElecOn_%1", playerSide],false];

_constType 	= format ["MCC_rts_%1%2",_consType,_constLevel];

_cfg = if (isClass(missionconfigFile >> _var1)) then {(missionconfigFile >> _var1)} else {(configFile >> _var1)};
_availableActions = getArray (_cfg >> _constType >> _var2);
_elec = getNumber (_cfg >> _constType >> "needelectricity");

//Add back button
for "_i" from 0 to 11 do {
	if (count _availableActions <= _i) then {_availableActions set [_i,""]};
};
_availableActions set [11, ["MCC_rts_rtsBuildUIContainerBack", "MCC_rts_rtsFortUIContainerBack"] select (toLower _var2 == "fortifications")];	//Exit Build Menu / Exit Fortifications Menu

//Populate actions
_cfg = if (isClass(missionconfigFile >> _var3)) then {(missionconfigFile >> _var3)} else {(configFile >> _var3)};

for "_i" from 9101 to 9112 do
{
	_ctrl = (_disp displayCtrl _i);
	if (count _availableActions > 0) then
	{
		//Resize array
		_action = _availableActions select 0;
		_availableActions set [0,-1];
		_availableActions = _availableActions - [-1];

		//Get CFG
		_pic = getText (_cfg >> _action >> "picture");
		_res = getArray (_cfg >> _action >> "resources");
		_req = getArray (_cfg >> _action >> "requiredBuildings");
		_fnc = getText (_cfg >> _action >> "actionFNC");
		_cnd = getText (_cfg >> _action >> "condition");
		_vars = getArray (_cfg >> _action >> "variables");

		_ctrl ctrlShow true;
		_ctrl ctrlSetText ([_pic] call MCC_fnc_rtsWidePic);
		missionNamespace setVariable [format ["MCC_ctrlData_%1", ctrlIDC _ctrl],_action];

		//Now let see if we enable the contorl
		_available = true;
		{
			_available = [_x, _obj, 300] call MCC_fnc_CheckBuildings;
			if (!_available) exitWith {};
		} foreach _req;

		//condition
		if (_available && _cnd !="") then {
			_available = call compile _cnd;
		};

		//Do we have the resources
		if (_available) then
		{
			{
				_available = [playerSide, _x] call MCC_fnc_checkRes;
				if (!_available) exitWith {};
			} foreach _res;
		};

		_online = true;
		if (_elec == 1 && ! _elecOn) then {_online = false};

		if (_available && _online) then
		{
			_ctrl ctrlSetTextColor ([_action, 1] call MCC_fnc_rtsTileColor);
		}
		else
		{
			_ctrl ctrlSetTextColor ([_action, 0.4] call MCC_fnc_rtsTileColor);
		};

		//remove
		_ctrl ctrlRemoveAllEventHandlers "MouseButtonClick";
		_ctrl ctrlRemoveAllEventHandlers "MouseHolding";
		_ctrl ctrlRemoveAllEventHandlers "MouseExit";

		//add EH
		if (_available && _online) then {_ctrl ctrlAddEventHandler ["MouseButtonClick",format ["[_this select 0, '%1', '%2', %3] spawn %4",_action , str playerside,_vars, _fnc]]};
		_ctrl ctrlAddEventHandler ["MouseHolding",format ["[_this,'%1'] call MCC_fnc_baseActionEntered",_var3]];
		_ctrl ctrlAddEventHandler ["MouseExit",format ["[_this,'%1'] call MCC_fnc_baseActionExit",_action]];
	}
	else
	{
		_ctrl ctrlShow false;
	};
};
[] call MCC_fnc_rtsUISync;
