/*=================================================================MCC_fnc_baseActionEntered==============================================================================
//	hovering over a base icon
//  Parameter(s):
//     _ctrl: CONTROL
//     _ctrlText: STRING
//=======================================================================================================================================================================*/
private "_ctrl";
private _ctrlPic = controlNull;
private "_ctrlText";
private "_disp";
private "_text";
private _res = [];
private "_action";
private _cfgtext = [];
private "_cfgName";
private _reqText = "";
private _req = [];
private "_cfgFile";
private _radius = 0;
private _cfg = configNull;
disableSerialization;

_ctrl = (_this select 0) select 0;
_cfgFile = _this select 1;

_disp = uiNamespace getVariable "MCC_LOGISTICS_BASE_BUILD";
_radius = 200;

_cfgName = missionNamespace getVariable [format ["MCC_ctrlData_%1", ctrlIDC _ctrl],""];
_cfg = if (isClass (missionconfigFile >> _cfgFile >> _cfgName)) then {(missionconfigFile >> _cfgFile >> _cfgName)} else {(configFile >> _cfgFile >> _cfgName)};

//Action or building?
_cfgtext = [getText (_cfg >> "displayName"),getText (_cfg >> "descriptionShort")];
_res = getArray (_cfg >> "resources");
_req = getArray (_cfg >> "requiredBuildings");

//Required buildings
_reqText = "";
{
	if !([_x, (MCC_ConsoleGroupSelected select 0), _radius] call MCC_fnc_CheckBuildings) then {
		_reqText = _reqText + "<br /><t color='#FF7A68'>  - ";
		_reqText = _reqText + (if (MCC_isMode) then
		                {
		                 	getText (configFile >> "cfgRtsBuildings" >> (format ["MCC_rts_%1%2",_x select 0,_x select 1]) >> "displayName");
						}
						else
						{
							getText (missionconfigFile >> "cfgRtsBuildings" >> (format ["MCC_rts_%1%2",_x select 0,_x select 1]) >> "displayName");
						});
		_reqText = _reqText + "</t>";
	};
} forEach _req;

//If we don't have all the needed facilities around let the player know
_text = if (_reqText != "") then {
	 format ["<t font='RobotoCondensedBold' size='1.2' color='#FFFFFF'>%1</t><br /><t color='#C3D0DA'>%2</t><br /><t color='#FF7A68'>Requires:</t>%3",(_cfgtext select 0),(_cfgtext select 1),_reqText];
} else {
	 format ["<t font='RobotoCondensedBold' size='1.2' color='#FFFFFF'>%1</t><br /><t color='#C3D0DA'>%2</t>",(_cfgtext select 0),(_cfgtext select 1)];
};

//Populate Resources
for [{_i= 121},{_i <= 127},{_i = _i + 2}] do
{
	_ctrl 		= (_disp displayCtrl _i);
	_ctrlPic	= (_disp displayCtrl (_i-1));
	if (count _res > 0) then
	{
		_action = _res select 0;
		_res set [0,-1];
		_res = _res - [-1];

		_ctrl ctrlShow true;
		_ctrlPic ctrlShow true;

		_ctrl ctrlSetText str(_action select 1);
		_ctrlPic ctrlSetText (format["%1data\Icon%2.paa",MCC_path,(_action select 0)]);
		_ctrlPic ctrlSetTextColor (switch (toLower (_action select 0)) do {
			case "ammo": {[0.9, 0, 0, 1]};
			case "repair": {[0, 0.5, 0.9, 1]};
			case "fuel": {[0, 0.9, 0.5, 1]};
			case "food": {[0.77, 0.51, 0.08, 1]};
			case "med": {[0, 0.9, 0.9, 1]};
			default {[1, 1, 1, 1]};
		});

		if ([playerSide, _action] call MCC_fnc_CheckRes) then {
			_ctrl ctrlSetTextColor [1,1,1,1]
		}
		else
		{
			_ctrl ctrlSetTextColor [1,0,0,1]
		};
		_ctrl ctrlCommit 0;
	}
	else
	{
		_ctrl ctrlShow false;
		_ctrlPic ctrlShow false;
	};
};

private _short = [];
private _have = call compile format ["MCC_res%1", playerSide];
{
	_x params [["_rn", "", [""]], ["_amt", 0, [0]]];
	private _ri = ["ammo", "repair", "fuel", "food", "med"] find (toLower _rn);
	if (_ri >= 0 && {(_have select _ri) < _amt}) then {
		_short pushBack format ["%1 %2", [floor (_amt - (_have select _ri))] call MCC_fnc_formatNumber, ["Ammo", "Repair", "Fuel", "Food", "Medical"] select _ri];
	};
} forEach getArray (_cfg >> "resources");
if (count _short > 0) then {_text = _text + format ["<br /><t color='#FF7A68'>Short: %1</t>", _short joinString ", "]};
private _gainTxt = (getArray (_cfg >> "gain")) apply {format ["<img color='%4' image='%1data\Icon%2.paa' /> %3", MCC_path, _x select 0, _x select 1, ["#FFFFFF", "#E60000", "#0080E6", "#00E680", "#C48214", "#00E6E6"] select ((["ammo", "repair", "fuel", "food", "med"] find (toLower (_x select 0))) + 1)]};
if (count _gainTxt > 0) then {_text = _text + "<br />" + (_gainTxt joinString "  ")};
//Add text
(_disp displayCtrl 150) ctrlSetStructuredText parseText _text;