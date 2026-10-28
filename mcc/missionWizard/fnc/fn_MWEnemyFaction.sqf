/*================================================================== MCC_fnc_MWEnemyFaction ==================================================================
	The Mission Generator's own enemy faction (MCC_MWEnemyFaction), separate from the MCC console faction, which is the
	player's side for supports and spawning. Chosen in the Mission Generator window (Rival Faction) or on the Assets page.
	Starting value, the first time it is asked for:
		1. the Enemy Faction of the (Settings) Mission Generator module (MCC_MWStartFaction), if set
		2. otherwise a faction of the side opposite the player: CSAT (OPF_F) / NATO (BLU_F) where loaded, else the first
		   faction of that side in the console list
	<OUT>	STRING faction class name ("" if the faction list is not ready yet)
==============================================================================================================================================================*/
private _list = missionNamespace getVariable ["U_FACTIONS", []];
private _cur = missionNamespace getVariable ["MCC_MWEnemyFaction", ""];
if (_cur != "" && {(_list findIf {toLower (_x select 2) == toLower _cur}) >= 0}) exitWith {_cur};
if (count _list == 0) exitWith {""};

private _pick = missionNamespace getVariable ["MCC_MWStartFaction", ""];
if (_pick == "" || {(_list findIf {toLower (_x select 2) == toLower _pick}) < 0}) then {
	//side numbers: 0 east, 1 west, 2 independent, 3 civilian
	private _mySide = [faction player] call MCC_fnc_factionSide;
	private _enemySide = [0, 1, 0, 0] select _mySide;		//west and others fight east; east fights west
	private _preferred = ["OPF_F", "BLU_F", "OPF_F", "OPF_F"] select _mySide;
	_pick = if ((_list findIf {toUpper (_x select 2) == _preferred}) >= 0) then {_preferred} else {
		private _i = _list findIf {([_x select 2] call MCC_fnc_factionSide) == _enemySide};
		if (_i >= 0) then {(_list select _i) select 2} else {(_list select 0) select 2}
	};
};
MCC_MWEnemyFaction = _pick;
_pick
