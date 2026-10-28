//Made by Shay_Gman (c) 09.11

//Medical: only when MCC's medical system is in use (not with ACE medical); otherwise say so and stay here
if ((_this select 0) == 3 && {(missionNamespace getVariable ["MCC_isACE", false]) || {!(missionNamespace getVariable ["MCC_medicSystemEnabled", false])}}) exitWith {
	["Medical system not active (MCC medical is off, or ACE medical is used)"] call MCC_fnc_hintBrief;
};

//The page opens over the Mission Settings window, which is there again when the page closes (closing and reopening
//it showed the console for a moment)

private _logic = "logic" createVehiclelocal [0,0,0];

private _page = switch (_this select 0) do
{
	case 0:	{[_logic] spawn MCC_fnc_missionSettings};
	case 1:	{[_logic] spawn MCC_fnc_inGameUICurator};
	case 2:	{[_logic] spawn MCC_fnc_settingsCover};
	case 3:	{[_logic] spawn MCC_fnc_settingsMedical};
	case 4:	{[_logic] spawn MCC_fnc_missionSettingsRS};
	case 5:	{[_logic] spawn MCC_fnc_GAIASettings};
};
