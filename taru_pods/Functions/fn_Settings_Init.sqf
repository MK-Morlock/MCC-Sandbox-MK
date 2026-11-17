if (isNil "CBA_Settings_fnc_init") exitWith {MCCMK_Taru_Pod_Mod_Action_Par_Ace = false};
[
	"MCCMK_Taru_Pod_Mod_Action_Par_Ace",
	"CHECKBOX",
	["Taru Pod Mod - use ACE interaction", "The Taru Pod Mod's Taru and pod actions in ACE self-interaction instead of the scroll menu (only when ACE is loaded). Server-wide."],
	"MCCMK General",
	false,
	true
] call CBA_Settings_fnc_init;
