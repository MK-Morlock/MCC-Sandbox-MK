/*================================================================== MCC_fnc_gunshipClass ==================================================================
	Gunship for the Gunship button (was always the vanilla AC-130 style Blackfish): a gunship of the player faction if it has
	one, otherwise the Blackfish (armed) as before.
	<OUT>	STRING class name
==============================================================================================================================================================*/
if (missionNamespace getVariable ["MCC_assetCustom_MCC_assetGunship", false]) exitWith {selectRandom (missionNamespace getVariable ["MCC_assetGunship", ["B_T_VTOL_01_armed_F"]])};	//Assets page
private _list = [faction player, "gunship"] call MCC_fnc_factionVehicles;
if (count _list > 0) then {selectRandom _list} else {"B_T_VTOL_01_armed_F"}
