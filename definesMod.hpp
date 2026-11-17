#define MCCPATH "\mcc_sandbox_mod\"
#define MCCVersion "(r33)"
#define MCCMODE true

class RscMapControl;
class RscText;
class RscControlsGroup;
class RscControlsGroupNoScrollbars;
//class RscButtonMenu;
class RscShortcutButton;
class RscAttributeText;
class RscCombo;
class RscCheckBox;
class TabSide;
class BLUFOR;
class OPFOR;
class Independent;
class Civilian;
class GroupList;
class UnitList;

//--------------------------Dialogs----------------------------------------------------
#include "\mcc_sandbox_mod\mcc\dialogs\mcc_dialogs.hpp"
#include "\mcc_sandbox_mod\mcc\dialogs\mcc_buttons3D.hpp"
#include "\mcc_sandbox_mod\mcc\dialogs\mcc_dialogVariants.hpp"
#include "\mcc_sandbox_mod\mcc\dialogs\mcc_dialogVariants2.hpp"
#include "\mcc_sandbox_mod\mcc\dialogs\mcc_3dMap.hpp"
#include "\mcc_sandbox_mod\mcc\Dialogs\mcc_groupsGen.hpp"
#include "\mcc_sandbox_mod\mcc\Dialogs\MCC_FrontLineDialog.hpp"

//----Console-----------------
#include "\mcc_sandbox_mod\mcc\Dialogs\mcc_consoleDialogVariants.hpp"
#include "\mcc_sandbox_mod\mcc\Dialogs\mcc_playerConsoleLoading.hpp"

//----PDA-----------------
#define MCCBTN_S MCC_RscButtonRoundSmall
#define MCCBTN_R MCC_RscButtonRound
#define MCCDLG_NAME MCC_SQLPDA
#include "\mcc_sandbox_mod\mcc\Dialogs\sqlPDA\mcc_SQLPDA.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#define MCCBTN_S MCC_RscButtonRoundSmall3D
#define MCCBTN_R MCC_RscButtonRound3D
#define MCCDLG_NAME MCC_SQLPDAButtons
#include "\mcc_sandbox_mod\mcc\Dialogs\sqlPDA\mcc_SQLPDA.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R

//----Mission Wizard-----------------

//----Curator-----------------
#include "\mcc_sandbox_mod\mcc\Dialogs\mcc_curatorInitDefines.hpp"
#include "\mcc_sandbox_mod\mcc\Dialogs\mcc_curatorInit.hpp"

//----Key Settings-----------------

//--------------------------------CP------------------------------------------------
#define CPPATH "\mcc_sandbox_mod\"
#define CPVersion "0.1"

#include "\mcc_sandbox_mod\mcc\roleSelection\cfg.hpp"

//--------------------------Campaign----------------------------------------------------
#define MCCBTN_S MCC_RscButtonRoundSmall
#define MCCBTN_R MCC_RscButtonRound
#define MCCDLG_NAME MCC_VEHICLESPAWNER
#include "\mcc_sandbox_mod\mcc\Dialogs\campaign\mcc_vehicleSpawner.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#define MCCBTN_S MCC_RscButtonRoundSmall3D
#define MCCBTN_R MCC_RscButtonRound3D
#define MCCDLG_NAME MCC_VEHICLESPAWNERButtons
#include "\mcc_sandbox_mod\mcc\Dialogs\campaign\mcc_vehicleSpawner.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R

//--------------------------Dynamic dialog--------------------------
#include "\mcc_sandbox_mod\mcc\dialogs\mcc_assetsDialogVariants.hpp"


//--------------------------Others----------------------------------------------------
#include "\mcc_sandbox_mod\bon_artillery\dialog\ArtilleryVariants.hpp"
#include "\mcc_sandbox_mod\hcam\hcam.hpp"
#include "\mcc_sandbox_mod\spectator\spectating.hpp"

//--------------------------features----------------------------------------------------
#include "\mcc_sandbox_mod\mcc\login\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\rts\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\bombDefuse\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\survive\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\interaction\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\LHD\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\vehicles\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\logistics\cfg.hpp"
#include "\mcc_sandbox_mod\mcc\medic\cfg.hpp"

//--------------------------Cfg----------------------------------------------------
class CfgFunctions
{
	#include "\mcc_sandbox_mod\gaia\cfgFunctions.hpp"

	class MCC
	{
		tag = "MCC";
		#include "\mcc_sandbox_mod\mcc\cfg\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\login\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\rts\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\cfg\modules\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\cfg\curator\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\undercover\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\bombDefuse\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\survive\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\HUD\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\assets\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\roleSelection\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\interaction\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\radio\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\AAS\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\missionWizard\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\helpers\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\helicopters\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\ambient\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\LHD\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\compositions\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\vehicles\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\logistics\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\UI\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\medic\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\roads\cfgFunctions.hpp"
		#include "\mcc_sandbox_mod\mcc\ai\cfgFunctions.hpp"
	};
	class MCCMK
	{
		tag = "MCCMK";
		class squad
		{
			file = "\mcc_sandbox_mod\mcc\fnc\squad";
			class unitJob {};
			class jobInfo {};
			class groupType {};
			class factionGroups {};
			class buildSquad {};
			class vehicleProfile {};
			class matchVehicle {};
			class factionVehicles {};
			class factionVehicle {};
			class pickVehicle {};
			class preloadFaction {};
		};
		class ui
		{
			file = "\mcc_sandbox_mod\mcc\fnc\mkui";
			class missionStatusHUD {};
			class supportLine {};
			class strikeMarker {};
			class airdropList {};
			class airdropPodMode {};
			class supplyAircraft {};
			class supplyAutoHeli {};
			class airdropAirList {};
			class airdropFit {};
			class classMass {};
			class airdropFitHint {};
			class airdropShowList {};
			class airdropLive {};
			class paradropPanel {};
			class paradropPick {};
			class paradropOpen {};
			class casAircraft {};
			class casAirList {};
			class panelRemember {};
		};
		class air
		{
			file = "\mcc_sandbox_mod\mcc\fnc\mkair";
			class aircraftRamp {};
			class aircraftDoors {};
		};
		class ai
		{
			file = "\mcc_sandbox_mod\mcc\fnc\mkai";
			class inKeepOutZone {};
			class crossesKeepOut {};
		};
		class tiles
		{
			file = "\mcc_sandbox_mod\mcc\fnc\mktiles";
			class tileQueue {};
			class tileRequest {};
			class tileSnapshot {};
			class tileBuildLocal {};
			class tileUpdateLocal {};
			class tilesInRadius {};
		};
		class hq
		{
			file = "\mcc_sandbox_mod\mcc\fnc\mkhq";
			class spawnPoints {};
			class isHQ {};
			class makeHQ {};
			class makeHQCan {};
			class makeHQConfirm {};
			class makeHQPick {};
			class campaignProtect {};
			class hqActionLocal {};
			class boardState {};
			class shipBoardUnits {};
			class climbAboard {};
			class boardBoat {};
			class boardSit {};
			class teamReady {};
			class boatsAlongside {};
			class boatLabel {};
			class boatChoiceClear {};
			class boatChoice {};
			class bringAboard {};
			class boatChildren {};
			class shipRadarLocal {};
			class shipRadar {};
			class shipWeaponInfo {};
			class shipMaintCost {};
			class shipWeaponSpawn {};
			class shipMaintLoop {};
			class shipMaint {};
			class shipStatusMsg {};
			class shipStatus {};
			class hullParts {};
			class hullHitInit {};
			class hullDamage {};
			class shipSink {};
			class navalCan {};
			class navalCost {};
			class navalPanel {};
			class navalFire {};
			class factionAssets {};
			class sarCan {};
			class sarRun {};
			class boatHere {};
			class edgePos {};
			class navalRoute {};
			class navalBaseSite {};
			class navalContact {};
			class navalBaseMarker {};
			class radarRange {};
			class navalAir {};
			class navalBase {};
			class ancActive {};
			class resFree {};
			class resRewards {};
			class resFreeLoop {postInit = 1;};
			class podCost {};
			class podInfo {};
			class podClasses {};
			class podRequest {};
			class podExit {};
			class supplyPod {};
			class podPickup {};
			class podPickupInit {postInit = 1;};
			class evacTaruCheck {};
			class factionPilot {};
			class recrew {};
			class factionRole {};
			class factionCrew {};
			class safePic {};
			class consoleThemes {};
			class tileDraw {};
			class zonesPersonalApply {};
			class zonesOpacity {};
			class rtsGroupPanel {};
			class helipadLights {};
			class padPreview {};
			class crateAmmoSet {};
			class pileAction {};
			class crateRepack {};
			class cargoTargets {};
			class cargoViV {};
			class cargoStow {};
			class crateFrac {};
			class isSupplyTruck {};
			class truckBedPoint {};
			class isCargoTruck {};
			class crateOnTruck {};
			class crateLoadOn {};
			class crateAdjust {};
			class vivTargets {};
			class crateSlots {};
			class airPatrol {};
			class boatPatrol {};
			class isArmedBoat {};
			class armedBoatFallback {};
			class crewFix {};
			class activeAOs {};
			class turnAwayPoint {};
			class cargoViVUnload {};
			class vivActionsInit {postInit = 1;};
			class taruPodActions {postInit = 1;};
			class supplyCheckInit {postInit = 1;};
			class droneDowned {};
			class hideBodyInit {postInit = 1;};
			class aceMenus {};
			class aceMode {};
			class scrollMenus {};
			class droneSightings {};
			class worldCleanup {postInit = 1;};
			class wcVehicle {};
			class wcCrate {};
			class wcMine {};
			class safeRoute {};
			class taruPickup {};
			class pickupGo {};
			class pickupClient {};
			class casMaxLoad {};
			class lzSpots {};
			class fastRopeRun {};
			class fastRopeInsert {};
			class mapEdgeExit {};
			class dropMarks {};
			class dropDots {};
			class dropDone {};
			class airIcons {postInit = 1;};
			class hcCommander {postInit = 1;};
			class airLandedHold {};
			class heliRopePos {};
			class heliRopeHold {};
			class heliDoorsAll {};
			class heliDoorWatch {};
			class heliWaterLand {};
			class heliWaterHold {};
			class heliWaterEnd {};
			class rampOrDoors {};
			class supportAir {};
			class boatDmgGuard {};
			class garage3D {};
			class genTag {};
			class genRun {};
			class aiBoatLoad {};
			class boatDrop {};
			class bayMirror {};
			class evacLandingIndex {};
			class heliWaterLandWp {};
			class heliWaterDescent {};
			class wpJob {};
			class wpJobRun {};
			class wpPlan {};
			class wpLabel {};
			class wpCan {};
			class consoleTips {};
			class zoneToggle {};
			class infoToggle {};
			class spawnAnchor {};
			class sideFold {};
			class scopeFactions {};
			class scopeClasses {};
			class spawnScopeLists {};
			class spawnScopeSet {};
			class wpCombos {};
			class wpEnd {};
			class wpChain {};
			class wpChainDraw {};
			class fltRepair {};
			class canFloat {};
			class spawnStartRefresh {};
			class heliWaterCrew {};
			class heliStateText {};
			class heliHoverAtMove {};
			class boatCarrier {};
			class garageOpen {};
			class garageButton {};
			class garageSync {};
			class garageApply {};
			class garageReselect {};
			class evacLabel {};
			class iconWithWp {};
			class mapIntel {postInit = 1;};
			class floatary {postInit = 1;};
			class floatLeak {};
			class floatScuttle {};
			class floatLoad {};
			class sarSource {};
			class sarSpawnPos {};
			class sarHome {};
			class sarSeat {};
			class sarClimbLocal {};
			class sarClimbReq {};
			class sarRope {};
			class floatFill {};
			class ropeLib {postInit = 1;};
			class ropeAIUp {};
			class ropeUp {};
			class ropeSquadUp {};
			class ropeDescend {};
			class ropeExtract {};
			class heliHold {};
			class heliLeave {};
			class heliGlide {};
			class heliHoverAt {};
			class hoverCombo {};
			class swimFaster {postInit = 1;};
			class jetNudge {postInit = 1;};
			class pools {};
			class pool {};
			class poolPick {};
			class poolJob {};
			class poolOwn {};
			class airTrack {};
			class factionFamily {};
			class clearBodies {};
			class rtsClearBodies {};
			class creditKeySet {};
			class creditGen {};
			class dropCleanup {postInit = 1;};
			class classSource {};
			class factionFilter {};
			class classRow {};
			class classSearch {};
			class rtsNetTilt {};
			class salvageCost {};
			class civMinimum {};
			class salvageInit {postInit = 1;};
			class salvageAction {};
			class salvageCan {};
			class salvageDone {};
			class clearWrecks {};
			class rtsClearWrecks {};
			class podSpawnList {};
			class rtsPodCost {};
			class rtsPodMenu {};
			class rtsPodPlace {};
			class shipAboard {};
			class shipSellValue {};
			class shipSellConfirm {};
			class shipRemove {};
			class shipSell {};
			class shipPreview {};
			class threatsInit {postInit = 1;};
			class planeReverseInit {postInit = 1;};
			class boardingActions {};
			class boardShipOrder {};
			class boardUnits {};
			class sellCheck {};
			class sellTarget {};
			class sellValue {};
			class sellConfirm {};
			class sellVehicle {};
			class creditStore {};
			class creditGet {};
			class creditRestore {};
			class creditAdd {};
			class confirmPanel {};
			class shipCfg {};
			class shipPosCheck {};
			class shipPick {};
			class shipPickConfirm {};
			class shipBuyMenu {};
			class boatBuyMenu {};
			class mwFactionSearch {};
			class factionBox {};
			class factionBoxClick {};
			class hint {};
			class airPatrolCaps {};
			class airPatrolList {};
			class apConsoleInfo {};
			class consoleFolder {};
			class view3D {};
			class feedDist {};
			class vdFor {};
			class shipCanCommand {};
			class shipBuy {};
			class shipArriving {};
			class shipMarkerLocal {};
			class shipFade {};
			class shipMove {};
			class isMissionMaker {};
			class lhdUndo {};
			class shipWeapons {};
			class shipTraverse {};
			class shipShape {};
			class shipDraw {};
			class shipDraw3D {};
			class shipEdenInit {};
			class crossTarget {};
			class crossShip {};
			class shipMarkersInit {postInit = 1;};
			class creditInit {postInit = 1;};
			class wellDeckPart {};
			class wellDeck {};
			class bayBlocked {};
			class boardingInit {postInit = 1;};
		};
	};
};

class cfgRemoteExec {
	class Functions {
		// State of remoteExec: 0-turned off, 1-turned on, taking whitelist into account, 2-turned on, however, ignoring whitelists (default because of backward compatibility)
		mode = 2;
		// Ability to send jip messages: 0-disabled, 1-enabled (default)
		jip = 1;

		#include "\mcc_sandbox_mod\mcc\cfg\cfgRemoteExec.hpp"
		#include "\mcc_sandbox_mod\mcc\radio\cfgRemoteExec.hpp"
		#include "\mcc_sandbox_mod\mcc\AAS\cfgRemoteExec.hpp"
	};
};

class CfgObjectCompositions
{
	#include "\mcc_sandbox_mod\mcc\cfg\CfgObjectCompositions.hpp"
};

class CfgMusic
{
	#include "\mcc_sandbox_mod\mcc\cfg\CfgMusic.hpp"
};

class CfgSounds
{
	#include "\mcc_sandbox_mod\mcc\cfg\CfgSounds.hpp"
	#include "\mcc_sandbox_mod\mcc\ambient\CfgSounds.hpp"
	#include "\mcc_sandbox_mod\mcc\radio\CfgSounds.hpp"
};

class CfgNotifications
{
	#include "\mcc_sandbox_mod\mcc\cfg\CfgNotifications.hpp"
};

class RscTitles
{
	#include "\mcc_sandbox_mod\mcc\dialogs\mcc_broadcastRsc.hpp"
	#include "\mcc_sandbox_mod\mcc\dialogs\mcc_InteractionRsc.hpp"
	#include "\mcc_sandbox_mod\mcc\dialogs\compass.hpp"
	#include "\mcc_sandbox_mod\mcc\dialogs\mcc_3dPanel.hpp"
	#include "\mcc_sandbox_mod\hcam\hcam.hpp"
	#include "\mcc_sandbox_mod\mcc\dialogs\mcc_3dObject.hpp"
	#include "\mcc_sandbox_mod\mcc\dialogs\sqlPDA\MCC_SQLPDA_rsc.hpp"
	#include "\mcc_sandbox_mod\mcc\survive\dialogs\mcc_rscSurviveStats.hpp"
	#include "\mcc_sandbox_mod\mcc\HUD\cfg.hpp"

	//----medic-----------------
	#include "\mcc_sandbox_mod\mcc\medic\dialogs\mcc_uncMain.hpp"
};

class CfgDebriefing
{
	class KickRadio
	{
		title = "You were kicked";
		subtitle = "For abusing the radio";
		description = "You were kicked";
	};
};

//Groups
class CfgGroups
{
	#include "\mcc_sandbox_mod\mcc\compositions\cfgGroups.hpp"
};

#include "\mcc_sandbox_mod\mcc\cfg\cfgGroupIcons.hpp"

class cfgVehicles
{
	#include "\mcc_sandbox_mod\mcc\cfg\cfgVehicles.hpp"
};

class cfgMagazines
{
	class Default;
	class CA_Magazine: Default{};
	class HandGrenade: CA_Magazine{};
	class 1Rnd_HE_Grenade_shell;

	#include "\mcc_sandbox_mod\mcc\cfg\cfgMagazines.hpp"
};

class cfgWeapons
{
	class Default;
	class GrenadeLauncher: Default{};
	class arifle_MX_GL_F;
	class itemCore;
	class InventoryItem_Base_F;
	class Launcher_Base_F;
	#include "\mcc_sandbox_mod\mcc\cfg\cfgWeapons.hpp"
};

class CfgMarkers
{
	#include "\mcc_sandbox_mod\mcc\cfg\CfgMarkers.hpp"
};

//Extend Main menu
#include "\mcc_sandbox_mod\mcc\cfg\menuExt.hpp"

//Extend curator
#include "\mcc_sandbox_mod\mcc\cfg\curatorExt.hpp"

