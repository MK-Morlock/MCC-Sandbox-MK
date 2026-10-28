#define MCC_CONSOLE_AC_VISION_TEXT 5013
//Gunship feed: Regular / N/V / Thermal (MCC_fnc_feedVision; the choice is kept for next time)
playSound "nvSound";
MCC_ConsoleACCameraMod = _this select 1;
MCC_ConsoleACvision = ["rendertarget8", MCC_ConsoleACCameraMod, "ac"] call MCC_fnc_feedVision;
ctrlSetText [MCC_CONSOLE_AC_VISION_TEXT, MCC_ConsoleACvision];
