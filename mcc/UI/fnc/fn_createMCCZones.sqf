//==================================================================MCC_fnc_createMCCZones===============================================================================================
//Create MCC zones local
// Example: [] call MCC_fnc_createMCCZones;
//==================================================================================================================================================================================
private _zone = "";
private _markerlabel = "";

{
	private _thisZonePos = mcc_zone_pos param [_x, []];
	if (_thisZonePos isEqualTo [-5000,-5000,0]) then {continue};	//zone of a deleted generated mission
	if (count _thisZonePos != 3 && count _thisZonePos != 2) then {
		// mcc_zone_pos/size/dir can develop gaps relative to MCC_zones_numbers (e.g. via
		// array `set` leaving nil entries at skipped indices) - skip rather than pass a
		// malformed position to createMarkerLocal, which requires exactly 2 or 3 elements.
		continue;
	};
	_zone = createMarkerLocal [str _x, _thisZonePos];
	_zone setMarkerShapeLocal "RECTANGLE";
	_zone setMarkerColorLocal "colorBlack";
	_zone setMarkerBrushLocal "Solid";
	_zone setMarkerAlphalocal 0.2;
	_zone setMarkerDirLocal (mcc_zone_dir param [_x, 0]);
	_zone setMarkerSizeLocal (mcc_zone_size param [_x, [50,50]]);

	_markerlabel = createMarkerLocal [(format["LABEL_%1",_x]), _thisZonePos];
	_markerlabel setMarkerShapeLocal "ICON";
	(format["LABEL_%1",_x]) setMarkerTypeLocal "mil_join";
	(format["LABEL_%1",_x]) setMarkerTextLocal str _x;
	(format["LABEL_%1",_x]) setMarkerColorLocal "ColorRed";
} foreach (missionNamespace getVariable ["MCC_zones_numbers",[]]);

// Zones are only shown while the MCC console is open (it shows them on open and hides them on close). The mission generator calls this
// after generating, which used to leave every zone drawn on the mission maker's normal map ("zones left behind that can't be deleted").
if (isNull (findDisplay 2994)) then {
	{str _x setMarkerAlphaLocal 0; (format["LABEL_%1",_x]) setMarkerAlphaLocal 0;} foreach (missionNamespace getVariable ["MCC_zones_numbers",[]]);
};


