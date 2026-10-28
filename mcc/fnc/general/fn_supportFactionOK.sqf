/*================================================================== MCC_fnc_supportFactionOK ==================================================================
	Support menus (CAS, Supply Drop, Artillery, Evac, Gunship) cannot be used while a civilian faction is selected in the
	MCC console: civilians have no aircraft or artillery to call. Shows a message asking for another faction.
	<OUT>	BOOL true when the selected faction may call support
==============================================================================================================================================================*/
private _sideName = toUpper (missionNamespace getVariable ["mcc_sidename", ""]);
private _faction = missionNamespace getVariable ["mcc_faction", ""];
private _isCiv = _sideName in ["CIV", "CIVILIAN"] || {getNumber (configFile >> "CfgFactionClasses" >> _faction >> "side") == 3};
if (_isCiv) then {
	["Civilian factions cannot call support (CAS, Supply Drop, Artillery, Evac, Gunship). Choose another faction in the Faction list."] call MCC_fnc_hintBrief;
};
!_isCiv
