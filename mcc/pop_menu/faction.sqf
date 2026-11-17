#define MCC_FACTION 8008
MCC_mcc_screen = _this select 0;
//(MK) the list can be narrowed (side buttons, search - MCCMK_fnc_factionFilter): each row carries its faction's number in
// U_FACTIONS (lbData); without one, the row number is the faction's number. Nothing changes while the list is refilled.
if (uiNamespace getVariable ["MCCMK_factionFilling", false]) exitWith {};
private _fRow = lbCurSel MCC_FACTION;
if (_fRow < 0) exitWith {};
private _fData = lbData [MCC_FACTION, _fRow];
private _fIdx = if (_fData == "") then {_fRow} else {parseNumber _fData};

if (MCC_faction_index != _fIdx) then	{
	mcc_sidename = (U_FACTIONS select _fIdx) select 1;
	mcc_faction = (U_FACTIONS select _fIdx) select 2; player setVariable ["MCCMK_faction", mcc_faction, true];
	MCC_faction_index = _fIdx;
	[MCC_mcc_screen != 2] call mcc_fnc_faction_choice;	//(MK) from the MCC console: refreshed in place, not closed and reopened
	if (!isNull (findDisplay 2994)) then {isNil {["sync"] call MCC_fnc_spawnLists}};
};




