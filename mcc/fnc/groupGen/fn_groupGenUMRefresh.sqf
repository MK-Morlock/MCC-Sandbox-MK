//===================================================================MCC_fnc_groupGenUMRefresh=========================================================================================
// Refresh the group gen units lists
// Example:[] call MCC_fnc_groupGenUMRefresh
//==============================================================================================================================================================================
#define MCC_UM_LIST 3069
disableSerialization;

private _mccdialog = displayNull;
private _group = grpNull;
private _index = 0;

//If we are messing with the list do not refresh
if (isnil "MCC_UMFocus") then {MCC_UMFocus = false};
if (MCC_UMFocus) exitWith {};

MCC_UMunitsNames = [];
UMgroupNames = [];

_mccdialog =  (uiNamespace getVariable "MCC_groupGen_Dialog");
_comboBox = _mccdialog displayCtrl MCC_UM_LIST;
lbClear _comboBox;

if (false) exitWith
{
	if (MCC_UMUnit==0) then
	{
		{
			if (alive _x) then	//unit
			{
				_displayname = format ["(Player) - %1",name _x];
				_index = lbAdd [MCC_UM_LIST,_displayname];
				MCC_UMunitsNames = MCC_UMunitsNames + [_x];
			};
		} forEach (allPlayers - entities "HeadlessClient_F");
	}
	else
	{
		{
			if (isPlayer (leader _x)) then	//group
			{
				_displayname = format ["(Players) - %1",_x];
				_index = lbAdd [MCC_UM_LIST,_displayname];
				UMgroupNames = UMgroupNames + [_x];
			};
		} forEach  allgroups;
	};
};

if (isnil "MCC_GroupGenGroupSelected") exitWith {};

if (MCC_UMUnit==0) then
{
	{
		_group = _x;
		{
			if (alive _x && {["shows", _x] call MCC_fnc_consoleFilter}) then
			{
				_displayname = if (isPlayer _x) then
								{
									format ["(Player) - %1",name _x];
								}
								else
								{
									getText (configFile >> "cfgVehicles" >> typeof (vehicle _x) >> "displayName");
								};

				if ((_x != vehicle _x) && ((driver (vehicle _x))==_x)) then {_displayname = format ["%1 (Driver)",_displayname]};
				if ((_x != vehicle _x) && ((gunner (vehicle _x))==_x)) then {_displayname =  format ["%1 (Gunner)",_displayname]};
				if ((_x != vehicle _x) && ((commander (vehicle _x))==_x)) then {_displayname =  format ["%1 (Commander)",_displayname]};
				_index = lbAdd [MCC_UM_LIST,_displayname];
				MCC_UMunitsNames = MCC_UMunitsNames + [_x];
			};
		} forEach units _group;
	} foreach MCC_GroupGenGroupSelected;
}
else
{
	{
		if (["shows", leader _x] call MCC_fnc_consoleFilter) then
		{
			_displayname =  format ["%1", _x];
			if (isPlayer leader _x) then {_displayname = format ["(Players) - %1",_displayname]};
			_index = lbAdd [MCC_UM_LIST,_displayname];
			UMgroupNames = UMgroupNames + [_x];
		};
	} forEach  MCC_GroupGenGroupSelected;
};

//Keep the selection: the list is rebuilt every few seconds, which used to drop the highlight while the selection
//stayed in MCC_selectedUnits (or the other way round) - HALO then said "no group selected". The rows of what is
//selected are highlighted again; whatever is no longer in the list is dropped from the selection.
private _rowsOf = [MCC_UMunitsNames, UMgroupNames] select (MCC_UMUnit != 0);
private _keep = (missionNamespace getVariable ["MCC_selectedUnits", []]) select {(_rowsOf find _x) >= 0};
MCC_selectedUnits = _keep;
{_comboBox lbSetSelected [_rowsOf find _x, true]} forEach _keep;
