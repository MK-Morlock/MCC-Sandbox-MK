class CfgPatches {
	class MCCMK_Anchors {
		name = "MCC Sandbox MK - Anchors";
		author = "Patch for personal use";
		units[] = {};
		weapons[] = {"ANC_HeavingLine"};
		requiredVersion = 2.140000104904175;
		versionStr = "1";
		requiredAddons[] = {"mcc_sandbox","cba_main","cba_xeh","A3_Weapons_F","3DEN","A3_Boat_F_Boat_Transport_01","A3_Ui_F"};
	};
};
class CfgFunctions {
	class ANC {
		tag = "ANC";
		class anchors {
			file = "\mccmk_anchors\functions";
			class addBoatHandlers {
			};
			class adjustPoints {
			};
			class aiOrder {
			};
			class aiPause {
			};
			class aiWatch {
			};
			class anchorDeploy {
			};
			class anchorModel {
			};
			class anchorRaise {
			};
			class anchorSet {
			};
			class bagMove {
			};
			class bagRest {
			};
			class boatGeometry {
			};
			class boatInitLine {
			};
			class cleanup {
			};
			class commBoats {
			};
			class commMenu {
			};
			class deckPoint {
			};
			class digIn {
			};
			class doAnchor {
			};
			class doCastOff {
			};
			class doLineAshore {
			};
			class doMoor {
			};
			class doOrder {
			};
			class doWeigh {
			};
			class driftInit {
			};
			class driftTick {
			};
			class dumpCommands {
			};
			class editorBoats {
			};
			class findDock {
			};
			class hasLine {
			};
			class hullPoint {
			};
			class hullSidePoint {
			};
			class info {
			};
			class isAground {
			};
			class isDinghy {
			};
			class isDock {
			};
			class isLandingCraft {
			};
			class isPaddleBoat {
			};
			class isSubmersible {
			};
			class isSurfaced {
			};
			class isZodiac {
			};
			class lineBoats {
			};
			class lineModel {
			};
			class loadPoints {
			};
			class logSteering {
			};
			class logTurning {
			};
			class makeHelper {
			};
			class menu {
			};
			class moor {
			};
			class moorLayout {
			};
			class moorWatchdog {
			};
			class notify {
			};
			class pointFor {
			};
			class postInit {
			};
			class registerProvider {
			};
			class remoor {
			};
			class rodeInfo {
			};
			class rodeTick {
			};
			class savePoint {
			};
			class server {
			};
			class setMoorLines {
			};
			class setRode {
			};
			class setShore {
			};
			class setTowLink {
			};
			class settings {
			};
			class act {
			};
			class aceMenus {
			};
			class shoreActions {
			};
			class shoreDrop {
			};
			class shoreFind {
			};
			class shoreFly {
			};
			class shoreFollow {
			};
			class shoreLists {
			};
			class shorePick {
			};
			class shorePost {
			};
			class shoreRetrieve {
			};
			class shoreStart {
			};
			class shoreBoatEnd {
			};
			class shoreRopeKeep {
			};
			class groundCanMove {
			};
			class pullSpeed {
			};
			class saveBoatPoints {
			};
			class hullOutline {
			};
			class hullGap {
			};
			class hullDist {
			};
			class notice {
			};
			class setRaftLink {
			};
			class raftTargets {
			};
			class raft {
			};
			class raftMenu {
			};
			class raftHold {
			};
			class raftBreak {
			};
			class raftAttach {
			};
			class raftWatchdog {
			};
			class listMenu {
			};
			class boatNear {
			};
			class boatPick {
			};
			class boardMenu {
			};
			class cargoSnap {
			};
			class cargoFill {
			};
			class cargoMove {
			};
			class cargoRows {
			};
			class cargoUI {
			};
			class cargoRefresh {
			};
			class boatLabel {
			};
			class keys {
			};
			class cargoLoad {
			};
			class itemName {
			};
			class pushNear {
			};
			class pushBoat {
			};
			class bagNear {
			};
			class bagGet {
			};
			class bagStow {
			};
			class cargoDump {
			};
			class reattach {
			};
			class remote {
			};
			class rxInit {
			};
			class shoreTakeBack {
			};
			class shoreThrow {
			};
			class shoreThrowBag {
			};
			class shoreThrowLand {
			};
			class shoreThrowSea {
			};
			class shoreHaulSea {
			};
			class splash {
			};
			class shoreTie {
			};
			class shoreWatch {
			};
			class shoreWinch {
			};
			class speeds {
			};
			class tellBoat {
			};
			class towCandidates {
			};
			class towDeploy {
			};
			class xlSync {
			};
			class xlAdd {
			};
			class xlRelease {
			};
			class xlDrop {
			};
			class xlLabel {
			};
			class xlFree {
			};
			class xlWatch {
			};
			class xlTether {
			};
			class xlTypeBetween {
			};
			class anchorVisual {
			};
			class deadHelm {
			};
			class wake {
			};
			class sleep {
			};
			class towMenu {
			};
			class towMinLen {
			};
			class towPoint {
			};
			class towRelease {
			};
			class watchdog {
			};
			class winch {
			};
			class windForce {
			};
			class slingBlock {
			};
			class slingGuard {
			};
			class builtIn {
			};
			class wpScript {
			};
		};
	};
};
class CfgNotifications {
	class ANC_Notice {
		title = "Anchors";
		iconPicture = "\A3\ui_f\data\igui\cfg\simpleTasks\types\boat_ca.paa";
		description = "%1";
		priority = 5;
		duration = 4;
	};
};
class RscListBox;
class ANC_RscListBoxDrag : RscListBox {
	canDrag = 1;
};
class ANC_CargoDialog {
	idd = 47101;
	movingEnable = 0;
	enableSimulation = 1;
	class controlsBackground {
	};
	class controls {
	};
};
class Extended_PreInit_EventHandlers {
	class Anchors_main {
		init = "call ANC_fnc_settings; call ANC_fnc_rxInit";
	};
};
class Extended_PostInit_EventHandlers {
	class Anchors_main {
		init = "if (call MCCMK_fnc_ancActive) then {call ANC_fnc_driftInit}";
		clientInit = "if (call MCCMK_fnc_ancActive) then {call ANC_fnc_postInit}";
	};
};
class CfgWeapons {
	class CBA_MiscItem;
	class CBA_MiscItem_ItemInfo;
	class ANC_HeavingLine : CBA_MiscItem {
		scope = 2;
		scopeArsenal = 2;
		scopeCurator = 2;
		author = "Anchors";
		displayName = "Heaving line";
		descriptionShort = "A light throwing line with a weighted end. Throw it from the shore to a boat (scroll menu, within 20 m), or from a boat to the shore. One comes with every boat.";
		picture = "\mccmk_anchors\data\heavingline_ca.paa";
		model = "\A3\Structures_F_Heli\Items\Tools\Rope_01_F.p3d";
		hiddenSelections[] = {"camo_1"};
		hiddenSelectionsTextures[] = {"\a3\data_f\proxies\rope\data\rope_co.paa"};
		class ItemInfo : CBA_MiscItem_ItemInfo {
			mass = 26;
		};
	};
};
class CfgVehicles {
	class Boat_F;
	class Rubber_duck_base_F;
	class Rescue_duck_base_F : Rubber_duck_base_F {
		rudderForceCoef = 0.25;
		enginePower = 24.5;
		thrustDelay = 1.5;
		waterLinearDampingCoefX = 1.2000000476837158;
	};
	class I_C_Boat_Transport_01_F : Rubber_duck_base_F {
		rudderForceCoef = 0.25;
		enginePower = 24.5;
		thrustDelay = 1.5;
		waterLinearDampingCoefX = 1.2000000476837158;
	};
	class I_G_Boat_Transport_01_F : Rubber_duck_base_F {
		rudderForceCoef = 0.25;
		enginePower = 24.5;
		thrustDelay = 1.5;
		waterLinearDampingCoefX = 1.2000000476837158;
	};
	class I_Boat_Transport_01_F : Rubber_duck_base_F {
		rudderForceCoef = 0.25;
		enginePower = 24.5;
		thrustDelay = 1.5;
		waterLinearDampingCoefX = 1.2000000476837158;
	};
	class B_Boat_Transport_01_F : Rubber_duck_base_F {
		rudderForceCoef = 0.25;
		enginePower = 24.5;
		thrustDelay = 1.5;
		waterLinearDampingCoefX = 1.2000000476837158;
	};
	class O_Boat_Transport_01_F : Rubber_duck_base_F {
		rudderForceCoef = 0.25;
		enginePower = 24.5;
		thrustDelay = 1.5;
		waterLinearDampingCoefX = 1.2000000476837158;
	};
	class O_T_Boat_Transport_01_F : Rubber_duck_base_F {
		rudderForceCoef = 0.25;
		enginePower = 24.5;
		thrustDelay = 1.5;
		waterLinearDampingCoefX = 1.2000000476837158;
	};
};
class Extended_InitPost_EventHandlers {
	class Ship {
		class Anchors_heavingLine {
			serverInit = "if (call MCCMK_fnc_ancActive) then {_this call ANC_fnc_boatInitLine}";
		};
	};
};
class CfgCommunicationMenu {
	class ANC_cmAnchor {
		text = "Anchor";
		submenu = "";
		expression = "['anchor'] call ANC_fnc_commMenu";
		icon = "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\transport_ca.paa";
		cursor = "";
		enable = "1";
		removeAfterExpressionCall = 0;
	};
	class ANC_cmWeigh : ANC_cmAnchor {
		text = "Weigh anchor";
		expression = "['weigh'] call ANC_fnc_commMenu";
	};
	class ANC_cmMoor : ANC_cmAnchor {
		text = "Moor";
		expression = "['moor'] call ANC_fnc_commMenu";
	};
	class ANC_cmCastOff : ANC_cmAnchor {
		text = "Cast off";
		expression = "['castoff'] call ANC_fnc_commMenu";
	};
	class ANC_cmLineAshore : ANC_cmAnchor {
		text = "Throw line ashore";
		expression = "['lineAshore'] call ANC_fnc_commMenu";
	};
};
class CfgWaypoints {
	class Anchors {
		displayName = "Anchors";
		class ANC_wpAnchor {
			displayName = "Anchor";
			tooltip = "The boat goes here, stops and drops anchor.";
			file = "\mccmk_anchors\functions\fn_wpAnchor.sqf";
			icon = "\a3\3DEN\Data\CfgWaypoints\Scripted_ca.paa";
		};
		class ANC_wpMoor : ANC_wpAnchor {
			displayName = "Moor";
			tooltip = "The boat goes here, stops and moors to a dock within 20 m.";
			file = "\mccmk_anchors\functions\fn_wpMoor.sqf";
		};
		class ANC_wpLineAshore : ANC_wpAnchor {
			displayName = "Throw line ashore";
			tooltip = "The boat goes here, stops and throws a heaving line to the shore within 20 m.";
			file = "\mccmk_anchors\functions\fn_wpLineAshore.sqf";
		};
		class ANC_wpWeigh : ANC_wpAnchor {
			displayName = "Weigh anchor";
			tooltip = "Weighs anchor (or casts off), then carries on to the next waypoint.";
			file = "\mccmk_anchors\functions\fn_wpWeigh.sqf";
		};
		class ANC_wpKedge : ANC_wpAnchor {
			displayName = "Kedge anchor (landing craft)";
			tooltip = "Landing craft: drops the stern anchor here at any speed and carries straight on to the next waypoint (the beach), paying out cable. Use Weigh anchor later to haul off the beach.";
			file = "\mccmk_anchors\functions\fn_wpKedge.sqf";
		};
		class ANC_wpCastOff : ANC_wpAnchor {
			displayName = "Cast off";
			tooltip = "Casts off (or weighs anchor), then carries on to the next waypoint.";
			file = "\mccmk_anchors\functions\fn_wpCastOff.sqf";
		};
	};
};
class Cfg3DEN {
	class Object {
		class AttributeCategories {
			class ANC_Attributes {
				displayName = "Anchors";
				collapsed = 1;
				class Attributes {
					class ANC_startMode {
						displayName = "At mission start";
						tooltip = "What this boat does when the mission starts. Overrides the 'Boats placed in the mission' setting.";
						property = "ANC_startMode";
						control = "Combo";
						expression = "_this setVariable ['ANC_startMode', _value];";
						defaultValue = "0";
						typeName = "NUMBER";
						condition = "objectVehicle";
						class Values {
							class Global {
								name = "Use the global setting";
								value = 0;
							};
							class Drift {
								name = "Drift with the wind";
								value = 1;
							};
							class Stay {
								name = "Stay put until boarded / ordered";
								value = 2;
							};
							class Anchor {
								name = "Anchor";
								value = 3;
							};
							class Moor {
								name = "Moor (or anchor if no dock within 20 m)";
								value = 4;
							};
						};
					};
				};
			};
		};
	};
};
