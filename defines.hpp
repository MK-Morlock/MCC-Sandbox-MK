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