//==================================================================MCC_fnc_openArtillery===============================================================================================
// Request player or AI to drop off a cargo group in a specific place - shold run localy on the requestor
// Example:[] call MCC_fnc_requestDropOff
//=================================================================================================================================================================================
private _ok = false;

closedialog 0;
waituntil {!dialog};
_ok = createDialog ("ArtilleryDialog" call MCC_fnc_dialogName);