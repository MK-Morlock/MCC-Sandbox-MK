//Returns the control, the pressed button, the x and y coordinates and the state of Shift, Ctrl and Alt.
private "_ctrl";
private "_button";
private "_posX";
private "_posY";
private "_shift";
private "_ctrlKey";
private "_alt";
private _mccdialog = controlNull;
private _html = "";
private _comboBox = controlNull;
private "_displayname";
private "_index";
private "_3dCommander";
#define mcc_playerConsole_IDD 2993
#define mcc_playerConsole2_IDD 5000
#define mcc_playerConsole3_IDD 5010

#define MCC_CONSOLEINFOTEXT 9150
#define MCC_CONSOLEINFOLIVEFEED 9151
#define MCC_CONSOLEINFOUAVCONTROL 9162

#define MCC_CONSOLEWPBCKGR 9157
#define MCC_CONSOLEWPCOMBO 9158
#define MCC_CONSOLEWPFORMATIONCOMBO 9166
#define MCC_CONSOLEWPSPEEDCOMBO 9167
#define MCC_CONSOLEWPBEHAVIORCOMBO 9168

#define MCC_CONSOLEWPADD 	9159
#define MCC_CONSOLEWPREPLACE 9160
#define MCC_CONSOLEWPCLEAR 9161
#define MCC_CONSOLEWPCANCEL 9169

disableSerialization;
MCC_doubleClicked = true;
MCCMK_ccDblClickTime = diag_tickTime;
["end"] call MCCMK_fnc_wpChain;
params ["_params"];

_ctrl = _params select 0;
_button = _params select 1;
_posX = _params select 2;
_posY = _params select 3;
_shift = _params select 4;
_ctrlKey = _params select 5;
_alt = _params select 6;

//is 3d commander online?
_3dCommander = !(isnull (uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD",displayNull]));

//Define which control
if (MCC_Console1Open) then {_mccdialog = findDisplay mcc_playerConsole_IDD};
if (MCC_Console2Open) then {_mccdialog = findDisplay mcc_playerConsole2_IDD};
if (MCC_Console3Open) then {_mccdialog = findDisplay mcc_playerConsole3_IDD};

//Close Group info control
if ((_button == 0) && (count (missionNamespace getVariable ["MCC_ConsoleGroupSelected",[]]) > 0) && !_ctrlKey && !_3dCommander)  then {
	//worldPos
	MCC_ConsoleWPpos = _ctrl ctrlMapScreenToWorld [_posX,_posY];
	MCC_consoleWPHidden = [ctrlShown (_mccdialog displayCtrl MCC_CONSOLEINFOTEXT), ctrlShown (_mccdialog displayCtrl MCC_CONSOLEINFOLIVEFEED), ctrlShown (_mccdialog displayCtrl MCC_CONSOLEINFOUAVCONTROL)];
	ctrlShow [MCC_CONSOLEINFOTEXT,false];
	ctrlShow [MCC_CONSOLEINFOLIVEFEED,false];
	ctrlShow [MCC_CONSOLEINFOUAVCONTROL,false];

	//Reveal WP  Bckgr
	(_mccdialog displayctrl MCC_CONSOLEWPBCKGR) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPBCKGR,true];
	(_mccdialog displayctrl MCC_CONSOLEWPBCKGR) ctrlCommit 0;
	private _mkAir = ((missionNamespace getVariable ["MCC_ConsoleGroupSelected", []]) findIf {!isNull _x && {(vehicle (leader _x)) isKindOf "Air"}}) >= 0;
	uiNamespace setVariable ["MCCMK_ccFlyOn", _mkAir];
	private _mkBy = [0.150, 0.181] select _mkAir;
	(_mccdialog displayctrl MCC_CONSOLEWPBCKGR) ctrlSetPosition [_posX, _posY,0.15 * safezoneW,([0.18, 0.211] select _mkAir) * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPBCKGR) ctrlCommit 0.1;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPBCKGR)};
	_html = "<t font='puristaMedium' color='#818960' size='1' shadow='1' align='left' underline='true'>Waypoints:</t><br/>";
	//_html = _html + "<t color='#fefefe' size='0.9' shadow='1' align='left' underline='false'>Type: </t><br/>";
	(_mccdialog displayctrl MCC_CONSOLEWPBCKGR) ctrlSetStructuredText parseText _html;

	//Reveal WP  Combo
	(_mccdialog displayctrl MCC_CONSOLEWPCOMBO) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPCOMBO,true];
	(_mccdialog displayctrl MCC_CONSOLEWPCOMBO) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPCOMBO) ctrlSetPosition [_posX + (0.005 * safezoneW), _posY + (0.025 * safezoneH),0.14 * safezoneW,0.03 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPCOMBO) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPCOMBO)};

	//Fill WP types
	_comboBox = _mccdialog displayCtrl MCC_CONSOLEWPCOMBO;
	lbClear _comboBox;
	private _wpGroups = missionNamespace getVariable ["MCC_ConsoleGroupSelected", []];
	private _wpRules = ["all","all","foot","all","all","all","veh","all","cargo","pass","pass","all","all","all","support","foot","all","heli","heli","arty","air","taru","taru","taru","taru","all","all","boat","all","all","all","foot", "carrier", "carrier", "boat", "carrierboat", "carrierboat", "boat"];
	private _fnc_wpCan = {
		params ["_rule"];
		if (_rule == "all") exitWith {true};
		(_wpGroups findIf {
			private _us = (units _x) select {alive _x};
			private _vs = [];
			{if (vehicle _x != _x) then {_vs pushBackUnique (vehicle _x)}} forEach _us;
			!(switch (_rule) do {
				case "foot": {(_us findIf {vehicle _x == _x}) >= 0};
				case "veh": {count _vs > 0};
				case "cargo": {(_vs findIf {getNumber (configOf _x >> "transportSoldier") > 0}) >= 0};
				case "pass": {(_vs findIf {count (fullCrew [_x, "cargo"]) > 0}) >= 0};
				case "support": {(_vs findIf {private _c = configOf _x; (getNumber (_c >> "transportRepair") > 0) || {getNumber (_c >> "transportFuel") > 0} || {getNumber (_c >> "transportAmmo") > 0} || {getNumber (_c >> "attendant") > 0}}) >= 0};
				case "heli": {(_vs findIf {_x isKindOf "Helicopter" || {_x isKindOf "VTOL_Base_F"}}) >= 0};
				case "air": {(_vs findIf {_x isKindOf "Air"}) >= 0};
				case "arty": {(_vs findIf {getNumber (configOf _x >> "artilleryScanner") == 1}) >= 0};
				case "taru": {(_vs findIf {((toLower typeOf _x) find "heli_transport_04") >= 0}) >= 0};
				case "boat": {(_vs findIf {_x isKindOf "Ship"}) >= 0};
				case "carrier": {(_vs findIf {[_x] call MCCMK_fnc_boatCarrier && {!(_x isKindOf "Plane")}}) >= 0};	//(MK) a helicopter that can carry a boat
				case "carrierboat": {(_vs findIf {[_x] call MCCMK_fnc_boatCarrier && {!isNull ([_x] call MCCMK_fltAttached)}}) >= 0};	//(MK) ... with a boat aboard
				default {true};
			})
		}) < 0
	};
	private _wpNames = ["Move", "Destroy", "Get In", "Search & Destroy", "Join Group", "Join Group As Leader", "Get Out", "Cycle Waypoints", "Load", "Unload", "Troops Unload", "Hold", "Sentry"
			   ,"Guard","Support","Get In Nearest","Dismiss","Helicopter - Land","Helicopter - Get in","Artillery - Fire Mission","Loiter","Taru - Pick up pod","Taru - Winch drop pod","Taru - Parachute pod","Taru - Release pod","HALO","Paradrop","Board ship","Pod drop","Winch drop","Fast-rope","Rope extraction", "Water landing (engine on)", "Water landing (engine off)", "Boat pickup", "Boat drop (landed)", "Boat drop (low hover)", "Boat - Load into helicopter"];
	// Shown in the MCC console's order - the troop drops together: ..., Pod drop, Winch drop, HALO, Paradrop, Board ship
	// (each keeps its own number, which is what the waypoint code goes by).
	{
		private _i = _x;
		if ([_wpRules select _i] call _fnc_wpCan) then {
			_index = _comboBox lbAdd (_wpNames select _i);
			_comboBox lbSetValue [_index, _i];
		};
	} forEach ([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24] + [28, 29, 25, 26, 30, 31, 27] + [32, 33, 34, 35, 36, 37]);
	[_comboBox, "MCC_ccWpType"] call MCC_fnc_consoleListMemory;

	//Reveal WP  Formation Combo
	(_mccdialog displayctrl MCC_CONSOLEWPFORMATIONCOMBO) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPFORMATIONCOMBO,true];
	(_mccdialog displayctrl MCC_CONSOLEWPFORMATIONCOMBO) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPFORMATIONCOMBO) ctrlSetPosition [_posX + (0.005 * safezoneW), _posY + (0.057 * safezoneH),0.14 * safezoneW,0.03 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPFORMATIONCOMBO) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPFORMATIONCOMBO)};
	(_mccdialog displayCtrl MCC_CONSOLEWPFORMATIONCOMBO) setVariable ["MCCMK_wpReal", false];

	//Fill WP  Formation
	[_mccdialog] call MCC_fnc_consoleWpFormationFill;

	//Reveal WP  Speed Combo
	(_mccdialog displayctrl MCC_CONSOLEWPSPEEDCOMBO) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPSPEEDCOMBO,true];
	(_mccdialog displayctrl MCC_CONSOLEWPSPEEDCOMBO) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPSPEEDCOMBO) ctrlSetPosition [_posX + (0.005 * safezoneW), _posY + (0.088 * safezoneH),0.14 * safezoneW,0.03 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPSPEEDCOMBO) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPSPEEDCOMBO)};

	//Fill WP  Speed

	//Reveal WP  Behavior Combo
	(_mccdialog displayctrl MCC_CONSOLEWPBEHAVIORCOMBO) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPBEHAVIORCOMBO,true];
	(_mccdialog displayctrl MCC_CONSOLEWPBEHAVIORCOMBO) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPBEHAVIORCOMBO) ctrlSetPosition [_posX + (0.005 * safezoneW), _posY + (0.118 * safezoneH),0.14 * safezoneW,0.03 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPBEHAVIORCOMBO) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPBEHAVIORCOMBO)};
	[_mccdialog] call MCC_fnc_consoleWpFormationFill;

	private _mkFly = _mccdialog displayCtrl 9219;
	["fill", [_mkFly, "fly", MCC_ConsoleGroupSelected, "Fly height: "]] call MCCMK_fnc_wpCombos;
	_mkFly ctrlSetPosition [_posX + (0.005 * safezoneW), _posY + (0.149 * safezoneH),0.14 * safezoneW,0.03 * safezoneH];
	_mkFly ctrlCommit 0;
	private _mkWt = (_mccdialog displayCtrl MCC_CONSOLEWPCOMBO) lbValue (lbCurSel (_mccdialog displayCtrl MCC_CONSOLEWPCOMBO));
	_mkFly ctrlShow (_mkAir && {!(_mkWt in [25, 26, 27, 28, 29, 30, 31, 34])});

	//Fill WP  Behavior

	(_mccdialog displayctrl MCC_CONSOLEWPCANCEL) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPCANCEL,true];
	(_mccdialog displayctrl MCC_CONSOLEWPCANCEL) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPCANCEL) ctrlSetPosition [_posX + (0.005 * safezoneW), _posY + (_mkBy * safezoneH),0.033 * safezoneW,0.024 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPCANCEL) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPCANCEL)};

	//Reveal WP  Button - ADD
	(_mccdialog displayctrl MCC_CONSOLEWPADD) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPADD,true];
	(_mccdialog displayctrl MCC_CONSOLEWPADD) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPADD) ctrlSetPosition [_posX + (0.041 * safezoneW), _posY + (_mkBy * safezoneH),0.033 * safezoneW,0.024 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPADD) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPADD)};

	//Reveal WP  Button - REPLACE
	(_mccdialog displayctrl MCC_CONSOLEWPREPLACE) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPREPLACE,true];
	(_mccdialog displayctrl MCC_CONSOLEWPREPLACE) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPREPLACE) ctrlSetPosition [_posX + (0.077 * safezoneW), _posY + (_mkBy * safezoneH),0.033 * safezoneW,0.024 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPREPLACE) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPREPLACE)};

	//Reveal WP  Button - CLEAR
	(_mccdialog displayctrl MCC_CONSOLEWPCLEAR) ctrlSetPosition [_posX,_posY,0,0];
	ctrlShow [MCC_CONSOLEWPCLEAR,true];
	(_mccdialog displayctrl MCC_CONSOLEWPCLEAR) ctrlCommit 0;
	(_mccdialog displayctrl MCC_CONSOLEWPCLEAR) ctrlSetPosition [_posX + (0.113 * safezoneW), _posY + (_mkBy * safezoneH),0.032 * safezoneW,0.024 * safezoneH];
	(_mccdialog displayctrl MCC_CONSOLEWPCLEAR) ctrlCommit 0;
	waituntil {ctrlCommitted (_mccdialog displayctrl MCC_CONSOLEWPCLEAR)};
};

if (_3dCommander) then {
	private _cam = objNull;
	private "_hight";
	private "_pos";
	_cam = missionNamespace getVariable ["MCC_CONST_CAM",objNull];
	if !(isNull _cam) then {
		_hight = (getpos _cam) select 2;
		_pos = _ctrl ctrlmapscreentoworld [_posX,_posY];
		_pos set [2,_hight];
		MCC_CONST_CAM setpos _pos;
	};
};

MCC_doubleClicked = false;