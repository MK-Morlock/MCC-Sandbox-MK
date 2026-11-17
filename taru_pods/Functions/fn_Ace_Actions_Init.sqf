if (!hasInterface || {!isClass (configFile >> "CfgPatches" >> "ace_interact_menu")}) exitWith {};
private _fnc_add = {
	params ["_class", "_path", "_name", "_title", "_icon", "_statement", "_condition"];
	private _a = [_name, _title, _icon, _statement, _condition] call ace_interact_menu_fnc_createAction;
	[_class, 1, _path, _a, true] call ace_interact_menu_fnc_addActionToClass;
};
private _t = "Heli_Transport_04_base_F";
private _p = ["ACE_SelfActions", "MCCMK_Taru_Pod_Mod"];
[_t, ["ACE_SelfActions"], "MCCMK_Taru_Pod_Mod", "Taru Pod Mod", "", {}, {!isNull getSlingLoad vehicle player}] call _fnc_add;
[_t, _p, "MCCMK_Arrimer", localize "STR_MCCMK_Taru_Pod_Mod_Action_Arrimer", "\mcc_taru_pods\Images\arrimer.paa",
	{[vehicle player] remoteExec ["MCCMK_Taru_fnc_Action_Arrimage", vehicle player]}, {[vehicle player, "SelfActions"] call MCCMK_Taru_fnc_Condition_Action_Arrimage}] call _fnc_add;
[_t, _p, "MCCMK_Desarrimer", localize "STR_MCCMK_Taru_Pod_Mod_Action_Desarrimer", "\mcc_taru_pods\Images\desarrimer.paa",
	{[vehicle player] remoteExec ["MCCMK_Taru_fnc_Action_Desarrimage", vehicle player]}, {[vehicle player, "SelfActions", "Desarrimage"] call MCCMK_Taru_fnc_Condition_Action_Desarrimage}] call _fnc_add;
[_t, _p, "MCCMK_Desarrimage_Assaut", localize "STR_MCCMK_Taru_Pod_Mod_Action_Desarrimage_Assaut", "\mcc_taru_pods\Images\desarrimer.paa",
	{[vehicle player] remoteExec ["MCCMK_Taru_fnc_Action_Desarrimage_Assaut", vehicle player]}, {[vehicle player, "SelfActions", "Desarrimage dassaut"] call MCCMK_Taru_fnc_Condition_Action_Desarrimage}] call _fnc_add;
[_t, _p, "MCCMK_Allonger", localize "STR_MCCMK_Taru_Pod_Mod_Allonger", "\mcc_taru_pods\Images\cordes_plus_10.paa",
	{[vehicle player] remoteExec ["MCCMK_Taru_fnc_Action_Allonger_Cordes", vehicle player]}, {[vehicle player, "SelfActions", 10] call MCCMK_Taru_fnc_Condition_Action_Allonger_Cordes}] call _fnc_add;
[_t, _p, "MCCMK_Allonger_Max", localize "STR_MCCMK_Taru_Pod_Mod_Allonger_Max", "\mcc_taru_pods\Images\100.paa",
	{[vehicle player, 100] remoteExec ["MCCMK_Taru_fnc_Action_Allonger_Cordes", vehicle player]}, {[vehicle player, "SelfActions", 100] call MCCMK_Taru_fnc_Condition_Action_Allonger_Cordes}] call _fnc_add;
[_t, _p, "MCCMK_Raccourcir", localize "STR_MCCMK_Taru_Pod_Mod_Action_Raccourcir", "\mcc_taru_pods\Images\cordes_moins_10.paa",
	{[vehicle player] remoteExec ["MCCMK_Taru_fnc_Action_Raccourcir_Cordes", vehicle player]}, {[vehicle player, "SelfActions", "De 10"] call MCCMK_Taru_fnc_Condition_Action_Raccourcir_Cordes}] call _fnc_add;
[_t, _p, "MCCMK_Raccourcir_Max", localize "STR_MCCMK_Taru_Pod_Mod_Action_Raccourcir_Max", "\mcc_taru_pods\Images\10.paa",
	{[vehicle player, 10] remoteExec ["MCCMK_Taru_fnc_Action_Raccourcir_Cordes", vehicle player]}, {[vehicle player, "SelfActions", "A 10"] call MCCMK_Taru_fnc_Condition_Action_Raccourcir_Cordes}] call _fnc_add;
[_t, _p, "MCCMK_Parachuter", localize "STR_MCCMK_Taru_Pod_Mod_Action_Parachuter", "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa",
	{[vehicle player] remoteExec ["MCCMK_Taru_fnc_Action_Parachutage_Pilote", vehicle player]}, {[vehicle player, "SelfActions"] call MCCMK_Taru_fnc_Condition_Action_Parachutage_Pilote}] call _fnc_add;
[_t, ["ACE_SelfActions"], "MCCMK_Arrimer_ASL", "Dock the Pod (ASL ropes)", "\mcc_taru_pods\Images\arrimer.paa",
	{[vehicle player] remoteExec ["MCCMK_Taru_fnc_Action_Arrimage_ASL", vehicle player]}, {[vehicle player, "SelfActions"] call MCCMK_Taru_fnc_Condition_Action_Arrimage_ASL}] call _fnc_add;
private _n = "Pod_Heli_Transport_04_crewed_base_F";
private _q = ["ACE_SelfActions", "MCCMK_Taru_Pod_Mod_Nacelle"];
[_n, ["ACE_SelfActions"], "MCCMK_Taru_Pod_Mod_Nacelle", "Taru Pod Mod", "", {}, {((vehicle player) getVariable ["MCCMK_Info_Nacelle", ""]) isNotEqualTo ""}] call _fnc_add;
[_n, _q, "MCCMK_Principal", localize "STR_MCCMK_Taru_Pod_Mod_UserAction_Deployer_Parachute_Principal", "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa",
	{[player, "Déployer principal"] remoteExec ["MCCMK_Taru_fnc_Action_Creation_Parachute", vehicle player]}, {[vehicle player, "SelfActions", "Déployer principal"] call MCCMK_Taru_fnc_Condition_Action_Ouverture_Parachute_Nacelle}] call _fnc_add;
[_n, _q, "MCCMK_Secours", localize "STR_MCCMK_Taru_Pod_Mod_UserAction_Deployer_Parachute_Secours", "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa",
	{[player, "Déployer secondaire"] remoteExec ["MCCMK_Taru_fnc_Action_Creation_Parachute", vehicle player]}, {[vehicle player, "SelfActions", "Déployer secondaire"] call MCCMK_Taru_fnc_Condition_Action_Ouverture_Parachute_Nacelle}] call _fnc_add;
[_n, _q, "MCCMK_Couper", localize "STR_MCCMK_Taru_Pod_Mod_UserAction_Couper_Parachute", "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa",
	{[player, "Détacher"] remoteExec ["MCCMK_Taru_fnc_Action_Couper_Parachute", vehicle player]}, {[vehicle player, "SelfActions", "Détacher"] call MCCMK_Taru_fnc_Condition_Action_Ouverture_Parachute_Nacelle}] call _fnc_add;
