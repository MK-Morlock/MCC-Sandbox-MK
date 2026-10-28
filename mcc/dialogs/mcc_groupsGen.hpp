// By: Shay_gman
// Version: 1.1 (April 2012)
#define groupGen_IDD 2994
#define MCC_MINIMAP 9000
#define MCC_MINIMAPBACK 9001
#define MCC_BACK 9002
#define MCC_FACTION 8008

#define MCCMISSIONMAKERNAME 1020
#define MCCCLIENTFPS 1021
#define MCCSERVERFPS 1022

#define MCCSTOPCAPTURE 1014

//-----------------------------------------------------------------------------
// Main dialog
//-----------------------------------------------------------------------------
#define MCCDLG_NAME mcc_groupGen
#define MCCBTN_S MCC_RscButtonRoundSmall
#define MCCBTN_R MCC_RscButtonRound
#define MCCBTN_SIDE MCC_RscSideItem
#include "mcc_groupsGenBody.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#undef MCCBTN_SIDE

#define MCCDLG_NAME mcc_groupGenButtons
#define MCCBTN_S MCC_RscButtonRoundSmall3D
#define MCCBTN_R MCC_RscButtonRound3D
#define MCCBTN_SIDE MCC_RscButtonRoundSmall3D
#include "mcc_groupsGenBody.hpp"
#undef MCCDLG_NAME
#undef MCCBTN_S
#undef MCCBTN_R
#undef MCCBTN_SIDE
