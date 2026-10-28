//==================================================================MCC_fnc_setTime======================================================================================
// Setstime on all clients
// Example: [year, month, day, hour, minute] remoteExec ["MCC_fnc_setTime", true, false];
//	year: number, YYYY
//	month: number, MM
//	day: number, DD
//	hour: number, HH
// 	minute: number, mm
//==============================================================================================================================================================================	



params ["_time"];
setDate _time;
