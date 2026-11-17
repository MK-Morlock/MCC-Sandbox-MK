#define MCCPATH ""
#define MCCVersion "(r29)"


//--------------------------Dialogs----------------------------------------------------
#include "mcc\dialogs\mcc_dialogs.hpp"
#include "mcc\dialogs\mcc_buttons3D.hpp"

#include "mcc\dialogs\mcc_dialogVariants.hpp"
#include "mcc\dialogs\mcc_dialogVariants2.hpp"
#include "mcc\dialogs\mcc_3dMap.hpp"
#include "mcc\Dialogs\mcc_groupsGen.hpp"
#include "mcc\Dialogs\MCC_FrontLineDialog.hpp"

//----Console-----------------
#include "mcc\Dialogs\mcc_consoleDialogVariants.hpp"
#include "mcc\Dialogs\mcc_playerConsoleLoading.hpp"

//----PDA-----------------
#define MCCBTN_S MCC_RscButtonRoundSmall
#define MCCBTN_R MCC_RscButtonRound
#define MCCDLG_NAME MCC_SQLPDA
#include "mcc\Dialogs\sqlPDA\mcc_SQLPDA.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#define MCCBTN_S MCC_RscButtonRoundSmall3D
#define MCCBTN_R MCC_RscButtonRound3D
#define MCCDLG_NAME MCC_SQLPDAButtons
#include "mcc\Dialogs\sqlPDA\mcc_SQLPDA.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R

//----Mission Wizard-----------------

//----Curator-----------------
#include "mcc\Dialogs\mcc_curatorInitDefines.hpp"
#include "mcc\Dialogs\mcc_curatorInit.hpp"

//----Key Settings-----------------

//---- test I should delete it at the end
#include "mcc\dialogs\test.hpp"
//--------------------------------CP------------------------------------------------

#define CPPATH ""
#define CPVersion "0.1"

#include "mcc\roleSelection\cfg.hpp"

//--------------------------Campaign----------------------------------------------------
#define MCCBTN_S MCC_RscButtonRoundSmall
#define MCCBTN_R MCC_RscButtonRound
#define MCCDLG_NAME MCC_VEHICLESPAWNER
#include "mcc\Dialogs\campaign\mcc_vehicleSpawner.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#define MCCBTN_S MCC_RscButtonRoundSmall3D
#define MCCBTN_R MCC_RscButtonRound3D
#define MCCDLG_NAME MCC_VEHICLESPAWNERButtons
#include "mcc\Dialogs\campaign\mcc_vehicleSpawner.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R

//--------------------------Dynamic dialog--------------------------

//--------------------------Others----------------------------------------------------
#include "bon_artillery\dialog\ArtilleryVariants.hpp"
#include "spectator\spectating.hpp"

//--------------------------features----------------------------------------------------
#include "mcc\login\cfg.hpp"
#include "mcc\rts\cfg.hpp"
#include "mcc\bombDefuse\cfg.hpp"
#include "mcc\survive\cfg.hpp"
#include "mcc\interaction\cfg.hpp"
#include "mcc\LHD\cfg.hpp"
#include "mcc\vehicles\cfg.hpp"
#include "mcc\logistics\cfg.hpp"

//--------------------------Cfg----------------------------------------------------
class CfgFunctions
{
	#include "gaia\cfgFunctions.hpp"

	class MCC
	{
		tag = "MCC";
		#include "mcc\cfg\cfgFunctions.hpp"
		#include "mcc\login\cfgFunctions.hpp"
		#include "mcc\rts\cfgFunctions.hpp"
		#include "mcc\cfg\modules\cfgFunctions.hpp"
		#include "mcc\cfg\curator\cfgFunctions.hpp"
		#include "mcc\undercover\cfgFunctions.hpp"
		#include "mcc\bombDefuse\cfgFunctions.hpp"
		#include "mcc\survive\cfgFunctions.hpp"
		#include "mcc\HUD\cfgFunctions.hpp"
		#include "mcc\roleSelection\cfgFunctions.hpp"
		#include "mcc\interaction\cfgFunctions.hpp"
		#include "mcc\radio\cfgFunctions.hpp"
		#include "mcc\AAS\cfgFunctions.hpp"
		#include "mcc\missionWizard\cfgFunctions.hpp"
		#include "mcc\helpers\cfgFunctions.hpp"
		#include "mcc\helicopters\cfgFunctions.hpp"
		#include "mcc\ambient\cfgFunctions.hpp"
		#include "mcc\LHD\cfgFunctions.hpp"
		#include "mcc\vehicles\cfgFunctions.hpp"
		#include "mcc\logistics\cfgFunctions.hpp"
		#include "mcc\UI\cfgFunctions.hpp"
		#include "mcc\roads\cfgFunctions.hpp"
	};
	class MCCMK
	{
		tag = "MCCMK";
		class squad
		{
			file = "mcc\fnc\squad";
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
			file = "mcc\fnc\mkui";
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
			file = "mcc\fnc\mkair";
			class aircraftRamp {};
			class aircraftDoors {};
		};
		class ai
		{
			file = "mcc\fnc\mkai";
			class inKeepOutZone {};
			class crossesKeepOut {};
		};
		class tiles
		{
			file = "mcc\fnc\mktiles";
			class tileQueue {};
			class tileRequest {};
			class tileSnapshot {};
			class tileBuildLocal {};
			class tileUpdateLocal {};
			class tilesInRadius {};
		};
		class hq
		{
			file = "mcc\fnc\mkhq";
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
		#include "mcc\cfg\cfgRemoteExec.hpp"
		#include "mcc\radio\cfgRemoteExec.hpp"
		#include "mcc\AAS\cfgRemoteExec.hpp"
	};
};

class CfgObjectCompositions
{
	#include "mcc\cfg\CfgObjectCompositions.hpp"
};

class CfgMusic
{
	#include "mcc\cfg\CfgMusic.hpp"
};

class CfgSounds
{
	#include "mcc\cfg\CfgSounds.hpp"
	#include "mcc\ambient\CfgSounds.hpp"
	#include "mcc\radio\CfgSounds.hpp"
};

class CfgNotifications
{
	#include "mcc\cfg\CfgNotifications.hpp"
};

class CfgMarkers
{
	#include "mcc\cfg\CfgMarkers.hpp"
};



class RscTitles
{
	#include "mcc\dialogs\mcc_broadcastRsc.hpp"
	titles[]={"img"};

	class img
	{
		idd=-1;
		movingEnable=0;
		duration=5;
		fadein=2;
        fadeout = 1;
		name="img";
		controls[]={"GR"};

		class GR : MCC_RscPicture
		{
			style=48;
			text= "title.jpg";
			sizeEx = 0.4;
			x=0.25;
            y=0.3;
            w=0.5;
            h=0.4;
        };
	};

	#include "mcc\dialogs\mcc_InteractionRsc.hpp"
	#include "mcc\dialogs\compass.hpp"
	#include "mcc\dialogs\mcc_3dPanel.hpp"
	#include "mcc\dialogs\mcc_3dObject.hpp"
	#include "mcc\dialogs\sqlPDA\MCC_SQLPDA_rsc.hpp"
	#include "mcc\survive\dialogs\mcc_rscSurviveStats.hpp"
	#include "mcc\HUD\cfg.hpp"

	//----medic-----------------
	#include "mcc\medic\dialogs\mcc_uncMain.hpp"
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