#include "dialogs\mcc_logisticsBaseBuild.hpp"
#define MCCBTN_S MCC_RscButtonRoundSmall
#define MCCBTN_R MCC_RscButtonRound
#define MCCDLG_NAME MCC_rtsMainBox
#include "dialogs\rtsMainBox.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#define MCCBTN_S MCC_RscButtonRoundSmall3D
#define MCCBTN_R MCC_RscButtonRound3D
#define MCCDLG_NAME MCC_rtsMainBoxButtons
#include "dialogs\rtsMainBox.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R

class cfgRtsBuildings
{
	#include "cfgRtsBuildings.hpp"
};

class cfgRtsActions
{
	#include "cfgRtsActions.hpp"
};

class cfgRtsVehiclesActions
{
	#include "cfgRtsVehiclesActions.hpp"
};

class cfgRtsNonBuildingsActions
{
	#include "cfgRtsNonBuildingsActions.hpp"
};

class cfgMCCRtsGroups
{
	#include "cfgMCCRtsGroups.hpp"
};

class CfgMCCRtsAirdrops
{
	#include "CfgMCCRtsAirdrops.hpp"
};

class cfgRtsMissions
{
	#include "cfgRtsMissions.hpp"
};
