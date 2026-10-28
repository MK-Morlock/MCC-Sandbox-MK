//Add Event handlers (also called by the Medic System module when it turns the system on later - see MCC_fnc_medicEnableXEH)
if (missionNamespace getvariable ["MCC_medicSystemEnabled",false]) then {
	[] call MCC_fnc_medicEnableXEH;
};
