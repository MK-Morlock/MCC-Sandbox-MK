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

