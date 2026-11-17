/*
	MCCMK_fnc_creditKeySet - where Valor is kept (server). "" = not kept: everyone starts at 50 each session. A campaign
	sets it from its campaign ID (a new campaign, a new ID; "Load from DB", the saved one); a mission without a campaign
	sets it when its persistent saving is switched on. Changing it reloads every player's Valor from the new place.
	[key]
*/
params [["_key", "", [""]]];
if (!isServer) exitWith {};
MCCMK_creditKey = _key;
MCCMK_creditMap = createHashMap;
MCCMK_creditLast = createHashMap;
MCCMK_creditRestored = [];
["INFO", "credits", "Valor kept under: %1", [["(not kept - starts at 50)", _key] select (_key != "")]] call MCC_fnc_log;
{[_x] call MCCMK_fnc_creditRestore} forEach (allPlayers - (entities "HeadlessClient_F"));
