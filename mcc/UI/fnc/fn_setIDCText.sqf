//==================================================================MCC_fnc_setIDCText=====================================================================================
// [_idc,_txt,_time,_sound] call MCC_fnc_setIDCText
//	<IN>
//	_idc		INTEGER - IDC number
//	_txt		STRING	- Text to show
//	_time		INTEGER - time untill fade -1 to never
//	_sound		BOOLEAN - true for sound
//==============================================================================================================================================================
private _idc = 0;
private _txt = "";
private _time = 0;
private _sound = false;
disableSerialization;
_idc =  _this param [0, -1, [0]];
_txt =  _this param [1, "", [""]];
_time =  _this param [2, -1, [0]];
_sound =  _this param [3, false, [false]];

if (_idc == -1 || _txt == "") exitWith {};

if (_sound) then {playSound "communicationMenuItemAdded"};
ctrlSetText [_idc,_txt];

if (_time !=-1) then {
	sleep _time;
	ctrlSetText [_idc,""];
};
