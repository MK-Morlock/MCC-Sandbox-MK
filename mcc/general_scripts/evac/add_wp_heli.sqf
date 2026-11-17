#define MCC_SANDBOX2_IDD (uiNamespace getVariable "MCC_groupGen_Dialog")
#define MCC_EVAC_TYPE 40
#define MCC_EVAC_CLASS 41
#define MCC_EVAC_SELECTED 42
#define MCC_EVAC_INSERTION 43
#define MCC_EVAC_FLIGHTHIGHT 44

private _point1 = [];
private _convoy_wp1 = "";
private _flyInHight = 0;
private _landing = 0;
private _evac = [];
private _evacVehicles = [];
_evacVehicles = missionNamespace getvariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide],[]];
if !mcc_isloading then
{
	if (mcc_missionmaker == (name player)) then
	{
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

		["Left click on the map to add one WP"] call MCC_fnc_hintBrief;
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

		["Markers placed"] call MCCMK_fnc_hint;
		if ((lbCurSel MCC_EVAC_SELECTED) == -1) exitWith {};

		_evac = _evacVehicles select (lbCurSel MCC_EVAC_SELECTED);

		//Incase we moving helicopter
		if (_evac iskindof "helicopter") then
		{
			_flyInHight =  MCC_evacFlyInHight_array select (lbCurSel MCC_EVAC_FLIGHTHIGHT) select 1;
			MCC_evacFlyInHight_index = lbCurSel MCC_EVAC_FLIGHTHIGHT;
		}
		else
		{
			_flyInHight= 5000;
		};

		_landing = [MCC_EVAC_INSERTION] call MCCMK_fnc_evacLandingIndex;	//(MK) by its text: the lists differ

		if (MCC_capture_state) then
		{
			MCC_capture_var = MCC_capture_var + FORMAT ['
								[[%1], %2, %3,[%4, %5]] remoteExec ["MCC_fnc_evacMove", 2, false];'
								,_point1
								,_flyInHight
								,_landing
								,netid (_evacVehicles  select (lbCurSel MCC_EVAC_SELECTED))
								,_evacVehicles  select (lbCurSel MCC_EVAC_SELECTED)
								];
		}
		else
		{
			[[_point1], _flyInHight, _landing, [netid _evac,_evac]] remoteExec ["MCC_fnc_evacMove", _evac, false];
		};
	}
	else
	{
		player globalchat "Access Denied";
	};
};
