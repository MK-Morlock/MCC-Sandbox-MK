/*======================================================== MCC_fnc_assignCurator =========================================================
	Give a player MCC's Zeus (MCC_curator). SERVER.

	A player can only own one Zeus. MCC used to take the player off whatever Zeus he already had (e.g. a Game Master module
	set to "All addons, including unofficial") and put him on MCC's own Zeus, which only knows the mission's addons - so
	modded factions "disappeared" from Zeus and people's Zeus settings were "overwritten". Now a player who already owns
	another Zeus keeps it (MCC's own features use every Zeus); MCC's Zeus is only handed out to players without one.

	<IN>	_this: OBJECT player
==========================================================================================================================================*/
private _unit = _this;
if (_unit isEqualType []) then {_unit = _unit param [0, objNull]};
if (!isServer) exitWith {_unit remoteExec ["MCC_fnc_assignCurator", 2]};
if (isNull _unit || {isNil "MCC_curator"}) exitWith {};
if !(missionNamespace getVariable ["MCC_giveZeus", true]) exitWith {["INFO", "fn_assignCurator", "MCC's Zeus not given to %1 - 'Give MCC's Zeus' setting is off", [name _unit]] call MCC_fnc_log;};

private _own = getAssignedCuratorLogic _unit;
if (!isNull _own && {_own != MCC_curator}) exitWith {
	["INFO", "fn_assignCurator", "%1 keeps his own Zeus (%2) - MCC's Zeus not assigned", [name _unit, _own]] call MCC_fnc_log;
};

// MCC's Zeus: everything the mission's other Zeus modules can place, plus the mission's active addons
MCC_curator addCuratorAddons activatedAddons;
{MCC_curator addCuratorAddons (curatorAddons _x)} forEach (allCurators - [MCC_curator]);

unassignCurator MCC_curator;
_unit assignCurator MCC_curator;
