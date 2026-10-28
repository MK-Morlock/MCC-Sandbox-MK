//MCC console unit feed: Regular / Night Vision / Thermal (MCC_fnc_feedVision; the choice is kept for next time)
MCC_UMPIPView = _this select 1;
["rendertarget10", MCC_UMPIPView, "unit"] call MCC_fnc_feedVision;
