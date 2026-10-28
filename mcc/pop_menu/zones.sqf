#define MCCZONENUMBER 1023

private _nul = [];
private _previusZone = "";
private _comboBox = controlNull;
private _displayname = "";
disableSerialization;

params ["_type", "_pos", "_size"];

//Creating a zone
if (_type == 1) exitWith
{
	mcc_zone_number = (count (missionNamespace getVariable ["MCC_zones_numbers",[]])) + 1;
	MCC_zones_numbers = (missionNamespace getVariable ["MCC_zones_numbers",[]]);
	MCC_zones_numbers set [count MCC_zones_numbers, mcc_zone_number];
	mcc_zone_markposition = _pos;
	mcc_zone_marker_X = _size select 0;
	mcc_zone_marker_Y = _size select 1;
	MCC_zone_index = mcc_zone_number-1;

	//------------------------------------------- Update ZONES --------------------------------------------------------------------------------------------------
	["fill"] call MCC_fnc_zoneList;

	waituntil {mcc_active_zone == mcc_zone_number};
	_nul=[1] execVM MCC_path +"mcc\general_scripts\mcc_make_the_marker.sqf";
};

//Updating a zone
if (_type == 2) then
{
	mcc_zone_markposition = _pos;
	mcc_zone_marker_X = _size select 0;
	mcc_zone_marker_Y = _size select 1;
	mcc_active_zone = mcc_zone_number;
	_nul=[1] execVM MCC_path +"mcc\general_scripts\mcc_make_the_marker.sqf";
};

private _znRow = ["number"] call MCC_fnc_zoneList;
if (_znRow < 1) exitWith {};
mcc_zone_number = _znRow;

mcc_zone_markername=format ["%1", mcc_zone_number];

//We selected a new zone let's gray the last one
if (mcc_active_zone != mcc_zone_number) then
{
	_previusZone = format ["%1", mcc_active_zone];
	_previusZone setMarkerColorLocal "colorBlack";
	_previusZone setMarkerBrushLocal "Solid";
	_previusZone setMarkerAlphalocal 0.2;
	MCC_zone_index = mcc_zone_number - 1;
};


//Selecting zone
if (_type == 0) then
{
	mcc_zone_markername	setMarkerColorLocal "colorYellow";
	mcc_zone_markername setMarkerBrushLocal "Solid";
	mcc_zone_markername setMarkerAlphalocal 0.2;
	mcc_active_zone = mcc_zone_number;
};
if (_type == 0) then {
	private _mwMap = (findDisplay 2989) displayCtrl 9000;
	private _prog = missionNamespace getVariable ["MCC_zoneListProg", [-1, -100]];
	MCC_zoneListProg = [-1, -100];
	private _con = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
	if (!isNull _con && {markerShape mcc_zone_markername != ""} && {!(((_prog select 0) == mcc_zone_number) && {(diag_tickTime - (_prog select 1)) < 2})}) then {
		private _zs = getMarkerSize mcc_zone_markername;
		private _zr = ((_zs select 0) max (_zs select 1)) max 150;
		{
			private _cm = _con displayCtrl _x;
			if (!isNull _cm) then {_cm ctrlMapAnimAdd [0.4, (((_zr * 6) / worldSize) max 0.02) min 1, getMarkerPos mcc_zone_markername]; ctrlMapAnimCommit _cm};
		} forEach [9000, 9010];
	};
	if (!isNull _mwMap && {markerShape mcc_zone_markername != ""}) then {
		private _zs = getMarkerSize mcc_zone_markername;
		private _zr = ((_zs select 0) max (_zs select 1)) max 150;
		_mwMap ctrlMapAnimAdd [0.4, (((_zr * 6) / worldSize) max 0.02) min 1, getMarkerPos mcc_zone_markername];
		ctrlMapAnimCommit _mwMap;
	};
};
