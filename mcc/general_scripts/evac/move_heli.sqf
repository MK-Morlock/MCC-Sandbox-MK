#define MCC_SANDBOX2_IDD (uiNamespace getVariable "MCC_groupGen_Dialog")
#define MCC_EVAC_TYPE 40
#define MCC_EVAC_CLASS 41
#define MCC_EVAC_SELECTED 42
#define MCC_EVAC_INSERTION 43
#define MCC_EVAC_FLIGHTHIGHT 44

private _point1 = [];
private _point2 = [];
private _point3 = [];
private _convoy_wp1 = "";
private _convoy_wp2 = "";
private _convoy_wp3 = "";
private _flyInHight = 0;
private _landing = 0;
private _evac = [];
private _evacVehicles = [];

if !mcc_isloading then	{

	deletemarkerlocal "evac_marker1";
	deletemarkerlocal "evac_marker2";
	deletemarkerlocal "evac_marker3";

	if (([MCC_EVAC_INSERTION] call MCCMK_fnc_evacLandingIndex) == 7) exitWith {
		if ((lbCurSel MCC_EVAC_SELECTED) == -1) exitWith {};
		private _paraEvac = (missionNamespace getvariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide],[]]) param [lbCurSel MCC_EVAC_SELECTED, objNull];
		if (isNull _paraEvac || {!(_paraEvac isKindOf "Helicopter")}) exitWith {["Paradrop needs a helicopter"] call MCCMK_fnc_hint};
		private _paraHeight = MCC_evacFlyInHight_array select (lbCurSel MCC_EVAC_FLIGHTHIGHT) select 1;
		MCC_evacFlyInHight_index = lbCurSel MCC_EVAC_FLIGHTHIGHT;
		private _line = ["wait"] call MCC_fnc_evacParaLine;
		if (count _line < 2) exitWith {["No drop line drawn"] call MCCMK_fnc_hint};
		[_line, _paraHeight, 7, [netid _paraEvac,_paraEvac], [[0, 0], [1, -1]] select ((lbCurSel 549) == 1)] remoteExec ["MCC_fnc_evacMove", _paraEvac, false];
	};

	["Left click on the map to put the 1st WP"] call MCC_fnc_hintBrief;
	click = false;
	onMapSingleClick "point1 = _pos;
	click = true;
	onMapSingleClick """";" ;

	waitUntil {(click)};
	click = false;
	_convoy_wp1 = createMarkerLocal ["evac_marker1",point1];
	_convoy_wp1 setMarkerTypeLocal "mil_dot";
	_convoy_wp1 setMarkerSizeLocal [0.5, 0.5];
	_convoy_wp1 setMarkertextLocal "1";

	_convoy_wp1 setMarkerColorLocal "ColorBlue";
	_point1 =getmarkerpos "evac_marker1";
	sleep 0.5;

	["Left click on the map to put the 2nd WP"] call MCC_fnc_hintBrief;

	onMapSingleClick "point2 = _pos;
	click = true;
	onMapSingleClick """";" ;

	waitUntil {(click)};
	click = false;
	_convoy_wp2 = createMarkerLocal ["evac_marker2",point2];
	_convoy_wp2 setMarkerTypeLocal "mil_dot";
	_convoy_wp2 setMarkerSizeLocal [0.5, 0.5];
	_convoy_wp2 setMarkertextLocal "2";

	_convoy_wp2 setMarkerColorLocal "ColorBlue";
	_point2 =getmarkerpos "evac_marker2";
	sleep 0.5;

	["Left click on the map to put the 3rd WP"] call MCC_fnc_hintBrief;

	onMapSingleClick "point3 = _pos;
	click = true;
	onMapSingleClick """";" ;

	waitUntil {(click)};
	click = false;
	_convoy_wp3 = createMarkerLocal ["evac_marker3",point3];
	_convoy_wp3 setMarkerTypeLocal "mil_dot";
	_convoy_wp3 setMarkerSizeLocal [0.5, 0.5];
	_convoy_wp3 setMarkertextLocal "3";

	_convoy_wp3 setMarkerColorLocal "ColorBlue";
	_point3 =getmarkerpos "evac_marker3";
	sleep 0.5;

	["Markers placed"] call MCCMK_fnc_hint;
	if ((lbCurSel MCC_EVAC_SELECTED) == -1) exitWith {};

	_evacVehicles = missionNamespace getvariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide],[]];
	_evac = _evacVehicles select (lbCurSel MCC_EVAC_SELECTED);
	if (_evac iskindof "helicopter") then	{							//Incase we moving helicopter
		_flyInHight =  MCC_evacFlyInHight_array select (lbCurSel MCC_EVAC_FLIGHTHIGHT) select 1;
		MCC_evacFlyInHight_index = lbCurSel MCC_EVAC_FLIGHTHIGHT;
		} else {_flyInHight= 5000};
	_landing = [MCC_EVAC_INSERTION] call MCCMK_fnc_evacLandingIndex;	//(MK) by its text: the lists differ

	if (MCC_capture_state) then
		{
		MCC_capture_var = MCC_capture_var + FORMAT ['
							[%1, %2, %3, [netid %4,%4]] remoteExec ["MCC_fnc_evacMove", 2, false];
							'
							,[_point1, _point2, _point3]
							,_flyInHight
							,_landing
							,_evac
							];
		} else
			{
			[[_point1, _point2, _point3], _flyInHight, _landing,[netid _evac,_evac]] remoteExec ["MCC_fnc_evacMove", _evac, false];
			};
};
