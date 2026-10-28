#define MCCBTN_S MCC_RscButtonRoundSmall
#define MCCBTN_R MCC_RscButtonRound
#define MCCDLG_NAME MCC_SaveLoadScreen
#include "mcc_saveLoadScreen.hpp"
#undef MCCDLG_NAME
#define MCCDLG_NAME MCCMWDialog
#include "mcc_MWMainDialog.hpp"
#undef MCCDLG_NAME
#define MCCDLG_NAME missionSettings
#include "mcc_missionSettings.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#define MCCBTN_S MCC_RscButtonRoundSmall3D
#define MCCBTN_R MCC_RscButtonRound3D
#define MCCDLG_NAME MCC_SaveLoadScreenButtons
#include "mcc_saveLoadScreen.hpp"
#undef MCCDLG_NAME
#define MCCDLG_NAME MCCMWDialogButtons
#include "mcc_MWMainDialog.hpp"
#undef MCCDLG_NAME
#define MCCDLG_NAME missionSettingsButtons
#include "mcc_missionSettings.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
