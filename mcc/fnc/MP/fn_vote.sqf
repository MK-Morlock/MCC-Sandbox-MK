//==================================================================MCC_fnc_vote===============================================================================================
// Start a voting process.
// Example:[_question, _header , _variable] call MCC_fnc_vote;
// _question	 	String, rich Text - question to be shown
// _header  		String, rich text - header to be shown
// _variable		String, varibale name that will be change. 
//==================================================================================================================================================================================
private _answer = nil;
params ["_question", "_header", "_variable"];

_answer = ["<t size='0.8' align='center'>" + _question + "</t>",_header,"yes",true,true] call MCC_fnc_messageBox;	
waituntil {!isnil "_answer"};

if (_answer) exitWith
{
	[[_variable, missionNameSpace],1] remoteExec ["bis_fnc_counter", 2, false];
};
