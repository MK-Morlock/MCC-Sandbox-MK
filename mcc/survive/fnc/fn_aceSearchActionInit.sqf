/*================================================================= MCC_fnc_aceSearchActionInit ==============================================================
	ACE: adds survival modes Search to ACEs interaction menu (the menu for the object you look at), GitHub #46.
	Where Search appears is chosen by the CBA setting ACE: Search action in (MCC_aceSearchMenu):
		0 = Self-interaction (original), 1 = Interaction menu, 2 = Both.
	The interaction menu only works on objects that have a class (most placed props, Arma 3 terrain props). Terrain objects
	without a class (common on Arma 2 / CUP maps) cannot get ACE actions at all, so use Both there.
	Runs locally on each client, once.
==============================================================================================================================================================*/
if (!hasInterface || {!isClass (configFile >> "CfgPatches" >> "ace_interact_menu")}) exitWith {};
if (!isNil "MCC_aceSearchActionAdded") exitWith {};
MCC_aceSearchActionAdded = true;
waitUntil {time > 0 && {!isNil "ace_interact_menu_fnc_createAction"}};

private _action = [
	"MCC_survivalSearch",
	"Search",
	"\A3\ui_f\data\map\markers\military\unknown_CA.paa",
	{[_target] spawn MCC_fnc_searchSurvivalObject},
	{
		(missionNamespace getVariable ["MCC_aceSearchMenu",0]) > 0
		&& {missionNamespace getVariable ["MCC_surviveModAllowSearch",false]}
		&& {!(_target isKindOf "CAManBase")}
		&& {isNull attachedTo _target}
		&& {([_target] call MCC_fnc_survivalObjectType) != ""}
	},
	{},
	[],
	[0,0,0],
	4
] call ace_interact_menu_fnc_createAction;

{
	[_x, 0, [], _action, true] call ace_interact_menu_fnc_addActionToClass;
} forEach ["Static", "Thing", "AllVehicles"];

["INFO", "MCC_fnc_aceSearchActionInit", "ACE interaction-menu Search action added", []] call MCC_fnc_log;
