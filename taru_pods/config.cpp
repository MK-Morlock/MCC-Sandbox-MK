class CfgPatches
{
	class mcc_taru_pods
	{
		units[] = {"MCC_B_Heli_Transport_04_F", "MCC_B_Heli_Transport_04_black_F", "MCC_B_Pod_Heli_Transport_04_bench_F", "MCC_B_Pod_Heli_Transport_04_bench_black_F", "MCC_B_Pod_Heli_Transport_04_covered_F", "MCC_B_Pod_Heli_Transport_04_covered_black_F", "MCC_B_Pod_Heli_Transport_04_medevac_F", "MCC_B_Pod_Heli_Transport_04_medevac_black_F", "MCC_B_Pod_Heli_Transport_04_ammo_F", "MCC_B_Pod_Heli_Transport_04_ammo_black_F", "MCC_B_Pod_Heli_Transport_04_fuel_F", "MCC_B_Pod_Heli_Transport_04_fuel_black_F", "MCC_B_Pod_Heli_Transport_04_repair_F", "MCC_B_Pod_Heli_Transport_04_repair_black_F", "MCC_B_Pod_Heli_Transport_04_box_F", "MCC_B_Pod_Heli_Transport_04_box_black_F", "MCC_O_Heli_Transport_04_F", "MCC_O_Heli_Transport_04_black_F", "MCC_O_Pod_Heli_Transport_04_bench_F", "MCC_O_Pod_Heli_Transport_04_bench_black_F", "MCC_O_Pod_Heli_Transport_04_covered_F", "MCC_O_Pod_Heli_Transport_04_covered_black_F", "MCC_O_Pod_Heli_Transport_04_medevac_F", "MCC_O_Pod_Heli_Transport_04_medevac_black_F", "MCC_O_Pod_Heli_Transport_04_ammo_F", "MCC_O_Pod_Heli_Transport_04_ammo_black_F", "MCC_O_Pod_Heli_Transport_04_fuel_F", "MCC_O_Pod_Heli_Transport_04_fuel_black_F", "MCC_O_Pod_Heli_Transport_04_repair_F", "MCC_O_Pod_Heli_Transport_04_repair_black_F", "MCC_O_Pod_Heli_Transport_04_box_F", "MCC_O_Pod_Heli_Transport_04_box_black_F", "MCC_I_Heli_Transport_04_F", "MCC_I_Heli_Transport_04_black_F", "MCC_I_Pod_Heli_Transport_04_bench_F", "MCC_I_Pod_Heli_Transport_04_bench_black_F", "MCC_I_Pod_Heli_Transport_04_covered_F", "MCC_I_Pod_Heli_Transport_04_covered_black_F", "MCC_I_Pod_Heli_Transport_04_medevac_F", "MCC_I_Pod_Heli_Transport_04_medevac_black_F", "MCC_I_Pod_Heli_Transport_04_ammo_F", "MCC_I_Pod_Heli_Transport_04_ammo_black_F", "MCC_I_Pod_Heli_Transport_04_fuel_F", "MCC_I_Pod_Heli_Transport_04_fuel_black_F", "MCC_I_Pod_Heli_Transport_04_repair_F", "MCC_I_Pod_Heli_Transport_04_repair_black_F", "MCC_I_Pod_Heli_Transport_04_box_F", "MCC_I_Pod_Heli_Transport_04_box_black_F", "MCCMK_Zeus_Taru_Accrocher", "MCCMK_Zeus_Taru_Arrimer", "MCCMK_Zeus_Taru_Desarrimer", "MCCMK_Zeus_Taru_Desarrimage_Assaut", "MCCMK_Zeus_Taru_Decrocher_Parachuter", "MCCMK_Zeus_Taru_Allonger_Max", "MCCMK_Zeus_Taru_Allonger", "MCCMK_Zeus_Taru_Raccourcir_Max", "MCCMK_Zeus_Taru_Raccourcir", "MCC_E_Pod_Heli_Transport_04_ammo_black_F", "MCC_E_Pod_Heli_Transport_04_box_black_F", "MCC_E_Pod_Heli_Transport_04_fuel_black_F", "MCC_E_Pod_Heli_Transport_04_repair_black_F"};
		weapons[] = {};
		requiredVersion = 1.00;
		requiredAddons[] = {"A3_Data_F_Tank_Loadorder", "A3_Sounds_F", "A3_UI_F", "A3_UI_F_Curator", "A3_Functions_F", "A3_Functions_F_Curator", "A3_Modules_F", "A3_Modules_F_Curator", "A3_Air_F_Heli", "mcc_sandbox"};
		author = "MCC Sandbox MK";
		name = "MCC Sandbox MK - Taru Pod Mod";
	};
};
class CfgFactionClasses {
	class MCCMK_Taru_Pod_mod {
		displayname = "Taru Pod Mod (XENO)";
		priority = 8;
		side = 7;
		portrait = "mcc_taru_pods\Images\xeno_64_1.paa";
	};
};
class CfgFunctions {
	class MCCMK_Taru_Pod_Mod {
		tag = "MCCMK_Taru";
		class Taru_Pod_Mod {
			file = "mcc_taru_pods\Functions";
			class Action_Accrochage;
			class Action_Allonger_Cordes;
			class Action_Arrimage;
			class Action_Couper_Parachute;
			class Action_Creation_Parachute;
			class Action_Decrochage;
			class Action_Desarrimage;
			class Action_Desarrimage_Assaut;
			class Action_Gestion_Cordes;
			class Action_Parachutage_Pilote;
			class Action_Raccourcir_Cordes;
			class CBA_Option_Init {
				postInit = 1;
			};
			class Settings_Init {
				preInit = 1;
			};
			class Ace_Actions_Init {
				postInit = 1;
			};
			class ASL_Nacelle;
			class Condition_Action_Arrimage_ASL;
			class Action_Arrimage_ASL;
			class Condition_Action_Allonger_Cordes;
			class Condition_Action_Arrimage;
			class Condition_Action_Desarrimage;
			class Condition_Action_Ouverture_Parachute_Nacelle;
			class Condition_Action_Parachutage_Pilote;
			class Condition_Action_Raccourcir_Cordes;
			class Gestion_Vitesse_Corde;
			class Messages;
			class Module_Zeus_Accrocher;
			class Module_Zeus_Arrimer;
			class Module_Zeus_Decrocher_Parachuter;
			class Module_Zeus_Desarrimage_Assaut;
			class Module_Zeus_Desarrimer;
			class Module_Zeus_Gestion_Cordes;
			class Recherche_Objet;
			class Traitement_Longueur_Cordes;
			class Transmission_Sons;
			class Veille_Descente_Nacelle;
			class Veille_Init;
			class Veille_Nacelle_Deshelitreuiller;
			class Veille_Nacelle_Detruite;
			class Veille_Nacelle_Helitreuiller;
			class Veille_Nacelle_Localite;
			class Veille_Parachutage_Auto;
			class Verification_Acces_Roles;
			class Verification_Interactions_Ace;
			class Verification_Objet_Helitreuiller_Est_Arrimable;
			class Verification_Objet_Est_Arrimer;
		};
	};
};
class CfgSounds {
	class MCCMK_Helitreuillage_Moteur_Desarrimage_Exterieur {
		name = "Desarrimage exterieur";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_engineDownEXT.wss", 1, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Moteur_Desarrimage_Interieur {
		name = "Desarrimage interieur";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_engineDownINT.wss", 1.2000000476837158, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Moteur_Arrimage_Exterieur {
		name = "Arrimage exterieur";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_engineUpEXT.wss", 1, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Moteur_Arrimage_Interieur {
		name = "Arrimage interieur";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_engineUpINT.wss", 1.2000000476837158, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Desarrimage_Exterieur {
		name = "Desarrimage";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_1hookUnlock.wss", 1, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Desarrimage_Interieur {
		name = "Desarrimage";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_1hookUnlock.wss", 2, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Arrimage_Exterieur {
		name = "Arrimage";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_1hooklock.wss", 1, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Arrimage_Interieur {
		name = "Arrimage";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_1hooklock.wss", 2, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Decrochage {
		name = "DÃ©crochage";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_4hooksUnlock.wss", 1, 1, 500};
		titles[] = {};
	};
	class MCCMK_Helitreuillage_Accrochage {
		name = "Accrochage";
		sound[] = {"A3\Sounds_F\vehicles\air\noises\SL_4hookslock.wss", 1, 1, 500};
		titles[] = {};
	};
	class MCCMK_Chute_Libre {
		name = "Chute libre";
		sound[] = {"A3\Sounds_F\characters\ingame\parachute\freefall2.wss", 1, 1};
		titles[] = {};
	};
	class MCCMK_Parachute_Ouverture {
		name = "Ouverture du parachute";
		sound[] = {"A3\Sounds_F\characters\ingame\parachute\parachute_open.wss", 1, 1};
		titles[] = {};
	};
	class MCCMK_Parachute_Fermeture {
		name = "Fermeture du parachute";
		sound[] = {"A3\Sounds_F\characters\ingame\parachute\parachute_landing.wss", 1, 1};
		titles[] = {};
	};
};
class CfgEditorCategories
{
	class MCC_EdCat_TaruPodMod {displayName = "Taru Pod Mod";};
};
class CfgEditorSubcategories
{
	class MCC_EdSubcat_TaruPodMod {displayName = "Pods";};	// (MK) Taru Pod Mod > Pods (it read Taru Pod Mod > Taru Pod Mod)
};
class CfgVehicles
{

	class Helicopter_Base_F;
	class Helicopter_Base_H: Helicopter_Base_F {
		class UserActions;
		class EventHandlers;
	};
	class Heli_Transport_04_base_F: Helicopter_Base_H {
		class UserActions: UserActions {
			class Arrimer {
				condition = "[vehicle player,'UserActions'] call MCCMK_Taru_fnc_Condition_Action_Arrimage";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Action_Arrimer";
				onlyForPlayer = 0;
				position = "user";
				priority = 15;
				radius = 0.5;
				statement = "[vehicle player] remoteExec ['MCCMK_Taru_fnc_Action_Arrimage',vehicle player];";
				icon = "mcc_taru_pods\Images\arrimer.paa";
			};
			class MCCMK_Arrimer_ASL: Arrimer {
				condition = "[vehicle player,'UserActions'] call MCCMK_Taru_fnc_Condition_Action_Arrimage_ASL";
				displayName = "Dock the Pod (ASL ropes)";
				statement = "[vehicle player] remoteExec ['MCCMK_Taru_fnc_Action_Arrimage_ASL',vehicle player];";
			};
			class Desarrimer: Arrimer {
				condition = "[vehicle player,'UserActions','Desarrimage'] call MCCMK_Taru_fnc_Condition_Action_Desarrimage";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Action_Desarrimer";
				statement = "[vehicle player] remoteExec ['MCCMK_Taru_fnc_Action_Desarrimage',vehicle player];";
				priority = 15;
				icon = "mcc_taru_pods\Images\desarrimer.paa";
			};
			class Desarrimage_Assaut: Arrimer {
				condition = "[vehicle player,'UserActions','Desarrimage dassaut'] call MCCMK_Taru_fnc_Condition_Action_Desarrimage";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Action_Desarrimage_Assaut";
				statement = "[vehicle player] remoteExec ['MCCMK_Taru_fnc_Action_Desarrimage_Assaut',vehicle player];";
				icon = "mcc_taru_pods\Images\desarrimer.paa";
			};
			class Allonger: Arrimer {
				condition = "[vehicle player,'UserActions',10] call MCCMK_Taru_fnc_Condition_Action_Allonger_Cordes";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Allonger";
				statement = "[vehicle player] remoteExec ['MCCMK_Taru_fnc_Action_Allonger_Cordes',vehicle player];";
				priority = 13;
				icon = "mcc_taru_pods\Images\cordes_plus_10.paa";
			};
			class Allonger_Max: Arrimer {
				condition = "[vehicle player,'UserActions',100] call MCCMK_Taru_fnc_Condition_Action_Allonger_Cordes";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Allonger_Max";
				statement = "[vehicle player,100] remoteExec ['MCCMK_Taru_fnc_Action_Allonger_Cordes',vehicle player];";
				priority = 12;
				icon = "mcc_taru_pods\Images\100.paa";
			};
			class Raccourcir: Arrimer {
				condition = "[vehicle player,'UserActions','De 10'] call MCCMK_Taru_fnc_Condition_Action_Raccourcir_Cordes";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Action_Raccourcir";
				statement = "[vehicle player] remoteExec ['MCCMK_Taru_fnc_Action_Raccourcir_Cordes',vehicle player];";
				priority = 13;
				icon = "mcc_taru_pods\Images\cordes_moins_10.paa";
			};
			class Raccourcir_Max: Arrimer {
				condition = "[vehicle player,'UserActions','A 10'] call MCCMK_Taru_fnc_Condition_Action_Raccourcir_Cordes";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Action_Raccourcir_Max";
				statement = "[vehicle player,10] remoteExec ['MCCMK_Taru_fnc_Action_Raccourcir_Cordes',vehicle player];";
				priority = 12;
				icon = "mcc_taru_pods\Images\10.paa";
			};
			class Parachuter_Pilote: Arrimer {
				condition = "[vehicle player,'UserActions'] call MCCMK_Taru_fnc_Condition_Action_Parachutage_Pilote";
				displayName = "$STR_MCCMK_Taru_Pod_Mod_Action_Parachuter";
				statement = "[vehicle player] remoteExec ['MCCMK_Taru_fnc_Action_Parachutage_Pilote',vehicle player];";
				priority = 14;
				icon = "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa";
			};
		};
		class EventHandlers: EventHandlers {
			class MCCMK_Taru_Pod_Mod {
				init = "if (local (_this select 0)) then {[_this select 0] call MCCMK_Taru_fnc_Veille_Init;};";
			};
		};
	};
	class LandVehicle;
	class StaticWeapon: LandVehicle {
		class UserActions;
	};
	class Pod_Heli_Transport_04_crewed_base_F: StaticWeapon {
		class UserActions: UserActions {
			class Deployer_Parachute_Principal {
				displayName = "$STR_MCCMK_Taru_Pod_Mod_UserAction_Deployer_Parachute_Principal";
				condition = "[vehicle player,'UserActions','DÃ©ployer principal'] call MCCMK_Taru_fnc_Condition_Action_Ouverture_Parachute_Nacelle";
				onlyForPlayer = 1;
				position = "user";
				priority = 15;
				radius = 0.5;
				statement = "[player,'DÃ©ployer principal'] remoteExec ['MCCMK_Taru_fnc_Action_Creation_Parachute',vehicle player]";
				icon = "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa";
			};
			class Deployer_Parachute_Secours: Deployer_Parachute_Principal {
				displayName = "$STR_MCCMK_Taru_Pod_Mod_UserAction_Deployer_Parachute_Secours";
				condition = "[vehicle player,'UserActions','DÃ©ployer secondaire'] call MCCMK_Taru_fnc_Condition_Action_Ouverture_Parachute_Nacelle";
				statement = "[player,'DÃ©ployer secondaire'] remoteExec ['MCCMK_Taru_fnc_Action_Creation_Parachute',vehicle player]";
			};
			class Detacher_Parachute: Deployer_Parachute_Principal {
				displayName = "$STR_MCCMK_Taru_Pod_Mod_UserAction_Couper_Parachute";
				condition = "[vehicle player,'UserActions','DÃ©tacher'] call MCCMK_Taru_fnc_Condition_Action_Ouverture_Parachute_Nacelle";
				statement = "[player,'DÃ©tacher'] remoteExec ['MCCMK_Taru_fnc_Action_Couper_Parachute',vehicle player]";
			};
		};
	};
	class Module_F;
	class MCCMK_Zeus_Taru_Base: Module_F {
		author = "NorX Aengell";
		category = "MCCMK_Taru_Pod_mod";
		curatorCanAttach = 1;
		isGlobal = 1;
		scopeCurator = 2;
	};
	class MCCMK_Zeus_Taru_Accrocher: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Accrocher";
		function = "MCCMK_Taru_fnc_Module_Zeus_Accrocher";
		portrait = "mcc_taru_pods\Images\accrocher.paa";
	};
	class MCCMK_Zeus_Taru_Arrimer: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Arrimer";
		function = "MCCMK_Taru_fnc_Module_Zeus_Arrimer";
		portrait = "mcc_taru_pods\Images\arrimer.paa";
		picture = "mcc_taru_pods\Images\arrimer.paa";
	};
	class MCCMK_Zeus_Taru_Desarrimer: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Desarrimer";
		function = "MCCMK_Taru_fnc_Module_Zeus_Desarrimer";
		portrait = "mcc_taru_pods\Images\desarrimer.paa";
	};
	class MCCMK_Zeus_Taru_Desarrimage_Assaut: MCCMK_Zeus_Taru_Base {
		displayName = "Nacelle (DÃ©sarrimage d'assaut)";
		function = "MCCMK_Taru_fnc_Module_Zeus_Desarrimage_Assaut";
		portrait = "mcc_taru_pods\Images\desarrimer.paa";
	};
	class MCCMK_Zeus_Taru_Decrocher_Parachuter: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Decrocher_Parachuter";
		function = "MCCMK_Taru_fnc_Module_Zeus_Decrocher_Parachuter";
		portrait = "\a3\ui_f\data\gui\cfg\CommunicationMenu\supplydrop_ca.paa";
	};
	class MCCMK_Zeus_Taru_Allonger_Max: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Allonger_Max";
		function = "MCCMK_Taru_fnc_Module_Zeus_Gestion_Cordes";
		portrait = "mcc_taru_pods\Images\100.paa";
	};
	class MCCMK_Zeus_Taru_Allonger: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Allonger";
		function = "MCCMK_Taru_fnc_Module_Zeus_Gestion_Cordes";
		portrait = "mcc_taru_pods\Images\cordes_plus_10.paa";
	};
	class MCCMK_Zeus_Taru_Raccourcir_Max: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Raccourcir_Max";
		function = "MCCMK_Taru_fnc_Module_Zeus_Gestion_Cordes";
		portrait = "mcc_taru_pods\Images\10.paa";
	};
	class MCCMK_Zeus_Taru_Raccourcir: MCCMK_Zeus_Taru_Base {
		displayName = "$STR_MCCMK_Taru_Pod_Mod_Module_Zeus_Raccourcir";
		function = "MCCMK_Taru_fnc_Module_Zeus_Gestion_Cordes";
		portrait = "mcc_taru_pods\Images\cordes_moins_10.paa";
	};

	class O_Heli_Transport_04_F;
	class O_Heli_Transport_04_black_F;
	class Land_Pod_Heli_Transport_04_bench_F;
	class Land_Pod_Heli_Transport_04_bench_black_F;
	class Land_Pod_Heli_Transport_04_covered_F;
	class Land_Pod_Heli_Transport_04_covered_black_F;
	class Land_Pod_Heli_Transport_04_medevac_F;
	class Land_Pod_Heli_Transport_04_medevac_black_F;
	class Land_Pod_Heli_Transport_04_ammo_F;
	class Land_Pod_Heli_Transport_04_ammo_black_F;
	class Land_Pod_Heli_Transport_04_fuel_F;
	class Land_Pod_Heli_Transport_04_fuel_black_F;
	class Land_Pod_Heli_Transport_04_repair_F;
	class Land_Pod_Heli_Transport_04_repair_black_F;
	class Land_Pod_Heli_Transport_04_box_F;
	class Land_Pod_Heli_Transport_04_box_black_F;
	// (MK) the black cargo pods for Empty > Supplies > Storage (vanilla lists only the hex ones there; the NATO black ones
	// are BLUFOR objects, so they weren't under Empty)
	class MCC_E_Pod_Heli_Transport_04_ammo_black_F: Land_Pod_Heli_Transport_04_ammo_black_F
	{
		scope = 2;
		scopeCurator = 2;
		side = 3;
		displayName = "Taru Ammo Pod (Black)";
		author = "MCC Sandbox MK";
	};
	class MCC_E_Pod_Heli_Transport_04_box_black_F: Land_Pod_Heli_Transport_04_box_black_F
	{
		scope = 2;
		scopeCurator = 2;
		side = 3;
		displayName = "Taru Cargo Pod (Black)";
		author = "MCC Sandbox MK";
	};
	class MCC_E_Pod_Heli_Transport_04_fuel_black_F: Land_Pod_Heli_Transport_04_fuel_black_F
	{
		scope = 2;
		scopeCurator = 2;
		side = 3;
		displayName = "Taru Fuel Pod (Black)";
		author = "MCC Sandbox MK";
	};
	class MCC_E_Pod_Heli_Transport_04_repair_black_F: Land_Pod_Heli_Transport_04_repair_black_F
	{
		scope = 2;
		scopeCurator = 2;
		side = 3;
		displayName = "Taru Repair Pod (Black)";
		author = "MCC Sandbox MK";
	};
	class MCC_B_Heli_Transport_04_F: O_Heli_Transport_04_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		crew = "B_Helipilot_F";
		typicalCargo[] = {"B_Helipilot_F"};
		editorSubcategory = "EdSubcat_Helicopters";	// (MK) in the faction's own Helicopters
		displayName = "Mi-290 Taru (Hex)";
	};
	class MCC_B_Heli_Transport_04_black_F: O_Heli_Transport_04_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		crew = "B_Helipilot_F";
		typicalCargo[] = {"B_Helipilot_F"};
		editorSubcategory = "EdSubcat_Helicopters";	// (MK) in the faction's own Helicopters
		displayName = "Mi-290 Taru (Black)";
	};
	class MCC_B_Pod_Heli_Transport_04_bench_F: Land_Pod_Heli_Transport_04_bench_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Bench Pod (Hex)";
	};
	class MCC_B_Pod_Heli_Transport_04_bench_black_F: Land_Pod_Heli_Transport_04_bench_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Bench Pod (Black)";
	};
	class MCC_B_Pod_Heli_Transport_04_covered_F: Land_Pod_Heli_Transport_04_covered_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Transport Pod (Hex)";
	};
	class MCC_B_Pod_Heli_Transport_04_covered_black_F: Land_Pod_Heli_Transport_04_covered_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Transport Pod (Black)";
	};
	class MCC_B_Pod_Heli_Transport_04_medevac_F: Land_Pod_Heli_Transport_04_medevac_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Medical Pod (Hex)";
	};
	class MCC_B_Pod_Heli_Transport_04_medevac_black_F: Land_Pod_Heli_Transport_04_medevac_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Medical Pod (Black)";
	};
	class MCC_B_Pod_Heli_Transport_04_ammo_F: Land_Pod_Heli_Transport_04_ammo_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Ammo Pod (Hex)";
	};
	class MCC_B_Pod_Heli_Transport_04_ammo_black_F: Land_Pod_Heli_Transport_04_ammo_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Ammo Pod (Black)";
	};
	class MCC_B_Pod_Heli_Transport_04_fuel_F: Land_Pod_Heli_Transport_04_fuel_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Fuel Pod (Hex)";
	};
	class MCC_B_Pod_Heli_Transport_04_fuel_black_F: Land_Pod_Heli_Transport_04_fuel_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Fuel Pod (Black)";
	};
	class MCC_B_Pod_Heli_Transport_04_repair_F: Land_Pod_Heli_Transport_04_repair_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Repair Pod (Hex)";
	};
	class MCC_B_Pod_Heli_Transport_04_repair_black_F: Land_Pod_Heli_Transport_04_repair_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Repair Pod (Black)";
	};
	class MCC_B_Pod_Heli_Transport_04_box_F: Land_Pod_Heli_Transport_04_box_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Cargo Pod (Hex)";
	};
	class MCC_B_Pod_Heli_Transport_04_box_black_F: Land_Pod_Heli_Transport_04_box_black_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 1;
		faction = "BLU_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Cargo Pod (Black)";
	};
	class MCC_O_Heli_Transport_04_F: O_Heli_Transport_04_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		crew = "O_helipilot_F";
		typicalCargo[] = {"O_helipilot_F"};
		editorSubcategory = "EdSubcat_Helicopters";	// (MK) in the faction's own Helicopters
		displayName = "Mi-290 Taru (Hex)";
	};
	class MCC_O_Heli_Transport_04_black_F: O_Heli_Transport_04_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		crew = "O_helipilot_F";
		typicalCargo[] = {"O_helipilot_F"};
		editorSubcategory = "EdSubcat_Helicopters";	// (MK) in the faction's own Helicopters
		displayName = "Mi-290 Taru (Black)";
	};
	class MCC_O_Pod_Heli_Transport_04_bench_F: Land_Pod_Heli_Transport_04_bench_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Bench Pod (Hex)";
	};
	class MCC_O_Pod_Heli_Transport_04_bench_black_F: Land_Pod_Heli_Transport_04_bench_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Bench Pod (Black)";
	};
	class MCC_O_Pod_Heli_Transport_04_covered_F: Land_Pod_Heli_Transport_04_covered_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Transport Pod (Hex)";
	};
	class MCC_O_Pod_Heli_Transport_04_covered_black_F: Land_Pod_Heli_Transport_04_covered_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Transport Pod (Black)";
	};
	class MCC_O_Pod_Heli_Transport_04_medevac_F: Land_Pod_Heli_Transport_04_medevac_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Medical Pod (Hex)";
	};
	class MCC_O_Pod_Heli_Transport_04_medevac_black_F: Land_Pod_Heli_Transport_04_medevac_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Medical Pod (Black)";
	};
	class MCC_O_Pod_Heli_Transport_04_ammo_F: Land_Pod_Heli_Transport_04_ammo_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Ammo Pod (Hex)";
	};
	class MCC_O_Pod_Heli_Transport_04_ammo_black_F: Land_Pod_Heli_Transport_04_ammo_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Ammo Pod (Black)";
	};
	class MCC_O_Pod_Heli_Transport_04_fuel_F: Land_Pod_Heli_Transport_04_fuel_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Fuel Pod (Hex)";
	};
	class MCC_O_Pod_Heli_Transport_04_fuel_black_F: Land_Pod_Heli_Transport_04_fuel_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Fuel Pod (Black)";
	};
	class MCC_O_Pod_Heli_Transport_04_repair_F: Land_Pod_Heli_Transport_04_repair_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Repair Pod (Hex)";
	};
	class MCC_O_Pod_Heli_Transport_04_repair_black_F: Land_Pod_Heli_Transport_04_repair_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Repair Pod (Black)";
	};
	class MCC_O_Pod_Heli_Transport_04_box_F: Land_Pod_Heli_Transport_04_box_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Cargo Pod (Hex)";
	};
	class MCC_O_Pod_Heli_Transport_04_box_black_F: Land_Pod_Heli_Transport_04_box_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 0;
		faction = "OPF_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Cargo Pod (Black)";
	};
	class MCC_I_Heli_Transport_04_F: O_Heli_Transport_04_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		crew = "I_helipilot_F";
		typicalCargo[] = {"I_helipilot_F"};
		editorSubcategory = "EdSubcat_Helicopters";	// (MK) in the faction's own Helicopters
		displayName = "Mi-290 Taru (Hex)";
	};
	class MCC_I_Heli_Transport_04_black_F: O_Heli_Transport_04_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		crew = "I_helipilot_F";
		typicalCargo[] = {"I_helipilot_F"};
		editorSubcategory = "EdSubcat_Helicopters";	// (MK) in the faction's own Helicopters
		displayName = "Mi-290 Taru (Black)";
	};
	class MCC_I_Pod_Heli_Transport_04_bench_F: Land_Pod_Heli_Transport_04_bench_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Bench Pod (Hex)";
	};
	class MCC_I_Pod_Heli_Transport_04_bench_black_F: Land_Pod_Heli_Transport_04_bench_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Bench Pod (Black)";
	};
	class MCC_I_Pod_Heli_Transport_04_covered_F: Land_Pod_Heli_Transport_04_covered_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Transport Pod (Hex)";
	};
	class MCC_I_Pod_Heli_Transport_04_covered_black_F: Land_Pod_Heli_Transport_04_covered_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Transport Pod (Black)";
	};
	class MCC_I_Pod_Heli_Transport_04_medevac_F: Land_Pod_Heli_Transport_04_medevac_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Medical Pod (Hex)";
	};
	class MCC_I_Pod_Heli_Transport_04_medevac_black_F: Land_Pod_Heli_Transport_04_medevac_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Medical Pod (Black)";
	};
	class MCC_I_Pod_Heli_Transport_04_ammo_F: Land_Pod_Heli_Transport_04_ammo_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Ammo Pod (Hex)";
	};
	class MCC_I_Pod_Heli_Transport_04_ammo_black_F: Land_Pod_Heli_Transport_04_ammo_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Ammo Pod (Black)";
	};
	class MCC_I_Pod_Heli_Transport_04_fuel_F: Land_Pod_Heli_Transport_04_fuel_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Fuel Pod (Hex)";
	};
	class MCC_I_Pod_Heli_Transport_04_fuel_black_F: Land_Pod_Heli_Transport_04_fuel_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Fuel Pod (Black)";
	};
	class MCC_I_Pod_Heli_Transport_04_repair_F: Land_Pod_Heli_Transport_04_repair_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Repair Pod (Hex)";
	};
	class MCC_I_Pod_Heli_Transport_04_repair_black_F: Land_Pod_Heli_Transport_04_repair_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Repair Pod (Black)";
	};
	class MCC_I_Pod_Heli_Transport_04_box_F: Land_Pod_Heli_Transport_04_box_F {
		author = "MCC Sandbox MK";
		scope = 2;
		scopeCurator = 2;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Cargo Pod (Hex)";
	};
	class MCC_I_Pod_Heli_Transport_04_box_black_F: Land_Pod_Heli_Transport_04_box_black_F {
		author = "MCC Sandbox MK";
		scope = 1;	// (MK) not listed: the other livery (still usable - the Taru livery options)
		scopeCurator = 1;
		side = 2;
		faction = "IND_F";
		editorCategory = "MCC_EdCat_TaruPodMod";
		editorSubcategory = "MCC_EdSubcat_TaruPodMod";
		displayName = "Taru Cargo Pod (Black)";
	};
};
