private _ok = false;

params ["_type"]; 								//Switch we are opening the console or the other options

closedialog 0; 
waituntil {!dialog};

switch (_type) do
	{
		case 1:	
		{ 
			_ok = createDialog ("MCC_playerConsole" call MCC_fnc_dialogName);
		};
		
		case 2:	
		{ 
			_ok = createDialog ("MCC_playerConsole2" call MCC_fnc_dialogName);
		};
		
		case 3:	
		{ 
			_ok = createDialog ("MCC_playerConsole3" call MCC_fnc_dialogName);
		};
	};

if (!_ok) then {hint "Failed to open dialog"};
	