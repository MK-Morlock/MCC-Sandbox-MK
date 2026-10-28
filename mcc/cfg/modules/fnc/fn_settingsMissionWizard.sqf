/*=========================================================== MCC_fnc_settingsMissionWizard ========================================================================

		Sets default variables for the mission wizard feature of MCC
*/

_module = param [0, objNull, [objNull]];
if (isNull _module) exitWith {deleteVehicle _module};

//Starting factions for the console / Mission Generator (empty = leave as it was: first in the list)
{
	_x params ["_attr", "_var"];
	private _f = _module getVariable [_attr, ""];
	if (_f isEqualType "" && {_f != ""}) then {missionNamespace setVariable [_var, _f]};
} forEach [["enemyFaction", "MCC_MWStartFaction"], ["civFaction", "MCC_MWStartCivFaction"]];
//The Enemy Faction is where the Mission Generator's own enemy faction starts (MCC_fnc_MWEnemyFaction); the console
//faction stays the player's side
if (!isNil "MCC_MWStartFaction") then {MCC_MWEnemyFaction = MCC_MWStartFaction};

//# Players for the Mission Generator slider (0 = leave it)
private _mwPlayers = _module getVariable ["players", 0];
if (_mwPlayers isEqualType "") then {_mwPlayers = parseNumber _mwPlayers};
if (_mwPlayers isEqualType 0 && {_mwPlayers > 0}) then {MCC_MWPlayersSession = round _mwPlayers};

private "_varClases";
private "_synced";
private "_varName";

_varName = switch (_module getvariable ["VariableName",0]) do
			{
				case 0:	{"MCC_MWHVT"};
				case 1:	{"MCC_MWRadio"};
				case 2:	{"MCC_MWFuelTanks"};
				case 3:	{"MCC_MWTanks"};
				case 4:	{"MCC_MWAir"};
				case 5:	{"MCC_MWcache"};
				case 6:	{"MCC_MWradar"};
				case 7:	{"MCC_MWIntelObjects"};
				case 8:	{"MCC_MWIED"};
				case 9:	{"MCC_MWAA"};
				case 10:	{"MCC_MWArtillery"};

				default	{"MCC_MWHVT"};
			};
_varClases = call compile (_module getvariable ["VariableClass","[]"]);

waituntil {missionNamespace getVariable ["MCC_initDone",false]};

if (isNil "_varClases") then {
	_varClases = [];
};

if (typeName _varClases != typeName []) then {
	_varClases = [];
};

//The server builds the list and shares it (synced objects are deleted there, so clients could not see them)
if (!isServer) exitWith {};

//Who synced with the module
_synced = synchronizedobjects _module;

{
	_varClases pushBack (typeof vehicle _x);
	deleteVehicle _x;
} forEach _synced;

//Apply the list. This step was missing (also in the original MCC), so the module never changed anything.
//Only when the module was actually set up for it - Variable Class edited away from its default or objects synced -
//so a module placed just for # Players does not override a list set in the CBA settings.
private _defaultClasses = ["b_officer_f","o_officer_f","i_officer_f","c_nikos"];
private _edited = (count _synced > 0) || {!((_varClases apply {toLower _x}) isEqualTo _defaultClasses)};
_varClases = _varClases select {_x isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _x)}};
_varClases = _varClases arrayIntersect _varClases;

if (_edited && {count _varClases > 0}) then {
	missionNamespace setVariable [_varName, _varClases, true];
	["INFO", "fn_settingsMissionWizard", "Mission Generator list %1 set to %2", [_varName, _varClases]] call MCC_fnc_log;
} else {
	if (_edited) then {["WARN", "fn_settingsMissionWizard", "Mission Generator list %1 not changed: no valid classes", [_varName]] call MCC_fnc_log};
};

