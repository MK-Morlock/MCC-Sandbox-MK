//==================================================================MCC_fnc_globalExecute======================================================================================
// Global execute a command on selected clients or server
// Example: [mode,code] remoteExec ["MCC_fnc_globalExecute", true, false];
// Params:
//	mode: number, 0:clients only, 1: server only 2: all clients and server
//	code: code, code to be executed
//==============================================================================================================================================================================


params ["_type", "_code"];

switch (_type) do {
	case 0:	//clients
	{
		if (!isServer) then {call _code};
	};

	case 1:	//Server
	{
		if (isServer) then {call _code};
	};

	case 2:	//all
	{
		call _code;
	};
};
