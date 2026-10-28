#define MCC_CONSOLE_VISION_TEXT 9111
//UAV / cruise missile feed: Regular / N/V / Thermal (MCC_fnc_feedVision; the choice is kept for next time)
MCC_ConsoleUAVCameraMod = _this select 1;
playSound "nvSound";
MCC_ConsoleUAVvision = ["rendertarget9", MCC_ConsoleUAVCameraMod, "uav"] call MCC_fnc_feedVision;
ctrlSetText [MCC_CONSOLE_VISION_TEXT, MCC_ConsoleUAVvision];
