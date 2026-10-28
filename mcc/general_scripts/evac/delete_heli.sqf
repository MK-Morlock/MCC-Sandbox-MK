#define MCC_EVAC_SELECTED 42
disableSerialization;
private _evac = [];
private _evacVehicles = [];
params ["_type"];
_evacVehicles = missionNamespace getvariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide],[]];
if ((lbCurSel MCC_EVAC_SELECTED) < 0 || {(lbCurSel MCC_EVAC_SELECTED) >= count _evacVehicles}) exitWith {};
_evac = _evacVehicles select (lbCurSel MCC_EVAC_SELECTED);

switch (_type) do
{
	case 0:
	{
		if (!alive driver _evac) exitWith {};
		hint "pilot deleted";
	};
	case 1:
	{
		if (alive driver _evac) exitWith {};
		hint "pilot respawned";
	};
	case 2:
	{
		if (!alive _evac) exitWith {};
		hint "Pilot & Chopper deleted";
	};

};

if (MCC_capture_state) then
{
	MCC_capture_var = MCC_capture_var + FORMAT ['
						[%1, objectFromNetId "%2"] remoteExec ["MCC_fnc_evacDelete", 2, false];
						'
						,_type
						,netId _evac
						];
}
else
{
	[_type, _evac] remoteExec ["MCC_fnc_evacDelete", 2, false];
};
;

