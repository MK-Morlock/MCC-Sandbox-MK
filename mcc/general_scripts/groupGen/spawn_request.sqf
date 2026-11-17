//Made by Shay_Gman (c) 09.10
#define groupGen_IDD 2994

#define UNIT_TYPE 3010
#define UNIT_CLASS 3011
#define MCC_GGUNIT_TYPE 3012
#define MCC_GGUNIT_EMPTY 3016
#define MCC_GGUNIT_BEHAVIOR 3030

private _mccdialog = controlNull;
private _comboBox = controlNull;
private _nul = [];
private _spawnType = "";
private _classtype = nil;
private _groupArray = [];
private _zonePos = nil;
disableSerialization;

params ["_type"];

_mccdialog = findDisplay groupGen_IDD;
MCC_groupBroadcast = [];
//(MK) Empty "Yes" read from the console window's own control: "lbCurSel <number>" / ctrlShow follow whichever window
// Arma treats as active, which with MK's console isn't always this one.
private _emptyCtrl = _mccdialog displayCtrl MCC_GGUNIT_EMPTY;
MCC_isEmpty = (!isNull _emptyCtrl) && {(lbCurSel _emptyCtrl) == 1} && {(count MCC_groupGenCurrenGroupArray) == 0};
["INFO", "spawn_request", "Empty: %1 (box %2, unit list %3 entries)", [MCC_isEmpty, if (isNull _emptyCtrl) then {"not found"} else {lbCurSel _emptyCtrl}, count MCC_groupGenCurrenGroupArray]] call MCC_fnc_log;

//If we got here while loading a mission break it
if mcc_isloading exitWith {};

//Delayed spawn
mcc_delayed_spawn = if (cbChecked  (_mccdialog displayctrl 3022)) then {true} else {false};
mcc_caching = if (cbChecked  (_mccdialog displayctrl 3023)) then {true} else {false};

//Group category of the Branch row, by its config name (MCC_fnc_spawnLists stores it on the row); "" for single units.
private _gTypeName = "";
if ((lbCurSel MCC_GGUNIT_TYPE) == 1) then {
	private _bRow = lbCurSel UNIT_TYPE;
	_gTypeName = (_mccdialog displayCtrl UNIT_TYPE) lbData _bRow;
	if (_gTypeName == "") then {_gTypeName = ((missionNamespace getVariable ["MCC_groupTypes", []]) param [_bRow, [""]]) select 0};
};

//Case we are spawning a cfg Group
if ((lbCurSel MCC_GGUNIT_TYPE) == 1) then
{
	//Paratroopers
	if ((_gTypeName =="Reinforcement") && !(_type==0)) exitWith
	{
		//Check if zone exists before trying to spawn paratroopers without making a zone first
		if (count mcc_zone_pos == 0) exitWith {["Create a zone first"] call MCCMK_fnc_hint};

		_selectedZoneNr = ["number"] call MCC_fnc_zoneList;
		_zonePos = mcc_zone_pos select _selectedZoneNr;
		if ( (count mcc_zone_pos <= _selectedZoneNr ) || { isnil "_zonePos" } ) exitWith {["Create a zone first"] call MCCMK_fnc_hint};
		mcc_spawnname = (call MCCMK_fnc_classRow);    //MCCR14 remove
		mcc_spawntype="Reinforcement";
		mcc_classtype = "Reinforcement";
		mcc_spawnfaction = mcc_faction;

		click = false;

		[parseText format["<br/>--------------------------<br/>
		<br/><t size='1.2' color='#33CC00'>Left click on the map to set start location (direction) of reinforcement</t><br/>
		<br/>--------------------------<br/>"]] call MCCMK_fnc_hint;

		onMapSingleClick "mcc_spawn_dir = _pos;
		click = true;
		onMapSingleClick """";" ;

		waitUntil {(click)};
		hintsilent "";
		click = false;
	};

	//Garrison
	if ((_gTypeName =="Garrison")  && !(_type==0)) exitWith
	{
		private _center = [];
		private _radius = 0;
		private _action = 0;
		private _intanse = 0;
		private _faction = "";

		//Failsafe incase we trying to spawn something without making a zone first
		if (count mcc_zone_pos == 0) exitWith {["Create a zone first"] call MCCMK_fnc_hint};

		_center = (mcc_zone_pos select (mcc_zone_number));
		_radius = (((mcc_zone_size select (mcc_zone_number))select 0) + ((mcc_zone_size select (mcc_zone_number)) select 1))/2;
		_faction = getText (configFile >> "CfgVehicles" >> (U_GEN_SOLDIER select 0 select 1) >> "faction");

		switch (call MCCMK_fnc_classRow) do
		{
			case 0:	//Light
			{
				_action 	= 0;
				_intanse 	= 0.2;
			};

			 case 1:	//Light -vehicles
			{
				_action 	= 1;
				_intanse 	= 0.2;
			};

			 case 2:	//Heavy
			{
				_action 	= 0;
				_intanse 	= 1;
			};

			 case 3:	//Heavy -vehicles
			{
				_action 	= 1;
				_intanse 	= 1;
			};
		};

		if (MCC_capture_state) then
		{
			MCC_capture_var = MCC_capture_var + FORMAT ['
				[%1,%2,%3,%4,"%5","%6"] remoteExec ["MCC_fnc_garrison", 0, false];;
				'
				,_center
				,_radius
				,_action
				,_intanse
				,_faction
				,mcc_sidename
				];
		}
		else
		{
				//*/
				mcc_safe = mcc_safe + FORMAT ['
				[%1,%2,%3,%4,"%5","%6"] remoteExec ["MCC_fnc_garrison", 0, false];;
				'
				,_center
				,_radius
				,_action
				,_intanse
				,_faction
				,mcc_sidename
				];
				[_center,_radius,_action,_intanse,_faction,mcc_sidename] remoteExec ["MCC_fnc_garrison", 0, false];
				//*/
		};
	};

	mcc_spawntype="GROUP";

	//Custom
	if (_gTypeName =="Custom") then {
		_comboBox = _mccdialog displayCtrl UNIT_CLASS;
		_classtype = MCC_customGroupsSave select (call compile (_comboBox lbData (lbCurSel UNIT_CLASS)));
		if (isnil "_classtype") exitWIth {};

		MCC_groupBroadcast  = (_classtype select 2);

		mcc_classtype = _classtype select 1;
		mcc_spawnname = _classtype select 3;
		mcc_spawnfaction = _classtype select 2;
		mcc_spawndisplayname = _classtype select 3;
	}
	else
	{
		//Find the chosen group in the group list by its name. The list is built when the group type changes, so after a
		//faction change or with a remembered choice it can be missing or belong to another list; it is then built again
		//for the current faction and type.
		private _gSel = call MCCMK_fnc_classRow;	//(MK) its place in the full list (the list can be narrowed by the search)
		private _gTxt = lbText [UNIT_CLASS, lbCurSel UNIT_CLASS];
		if (isNil "MCC_groupArray" || {_gSel >= count MCC_groupArray} || {(format ["%1 (%2 Units)", (MCC_groupArray select _gSel) param [3, ""], (MCC_groupArray select _gSel) param [4, ""]]) != _gTxt}) then {
			MCC_groupArray = [mcc_sidename,mcc_faction, _gTypeName,"LAND"] call mcc_make_array_grps;
		};
		private _gi = MCC_groupArray findIf {(format ["%1 (%2 Units)", _x param [3, ""], _x param [4, ""]]) == _gTxt};
		if (_gi < 0) then {_gi = _gSel};
		if (_gi < 0 || {_gi >= count MCC_groupArray}) exitWith {["Choose the group again in the Spawn panel"] call MCCMK_fnc_hint};
		_classtype	= (MCC_groupArray select _gi) select 2;
		if (isnil "_classtype") exitWIth {};

		MCC_groupBroadcast = _classtype;

		mcc_classtype = (MCC_groupArray select _gi) select 0;
		mcc_spawnname = (MCC_groupArray select _gi) select 1;
		mcc_spawnfaction = (MCC_groupArray select _gi) select 2;
		mcc_spawndisplayname = (MCC_groupArray select _gi) select 3;
	};
}
else		//Case we are spawning a unit
{
	//Case we are spawning a unit with out a group.
	if (count MCC_groupGenCurrenGroupArray == 0) then
	{
		_groupArray = [];
		switch (lbCurSel UNIT_TYPE) do		//Which unit do we want
		{
		   case 0:	//Infantry
			{
				_groupArray = U_GEN_SOLDIER;
				mcc_spawntype="MAN";
			};

			case 1:	//Car
			{
				_groupArray = U_GEN_CAR;
				mcc_spawntype="VEHICLE";
			};

			case 2:	//Tank
			{
				_groupArray = U_GEN_TANK;
				mcc_spawntype="VEHICLE";
			};

			case 3:	//Motorcycle
			{
				_groupArray = U_GEN_MOTORCYCLE;
				mcc_spawntype="VEHICLE";
			};

			case 4:	//Helicopter
			{
				_groupArray = U_GEN_HELICOPTER;
				mcc_spawntype="VEHICLE";
			};

			case 5:	//Aircraft
			{
				_groupArray = U_GEN_AIRPLANE;
				mcc_spawntype="VEHICLE";
			};

			case 6:	//Ship
			{
				_groupArray = U_GEN_SHIP;
				mcc_spawntype="VEHICLE";
			};

			case 7:	//AMMO
			{
				_groupArray = U_AMMO;
				mcc_spawntype="AMMO";
			};
		};

		if ((lbCurSel UNIT_CLASS) != -1) then
		{
			_classtype	= (_groupArray select (call MCCMK_fnc_classRow)) select 1;
			MCC_groupBroadcast = [_classtype];

			mcc_classtype = (_groupArray select (call MCCMK_fnc_classRow)) select 0;
			mcc_spawnname = (_groupArray select (call MCCMK_fnc_classRow)) select 1;
			mcc_spawnfaction = (_groupArray select (call MCCMK_fnc_classRow)) select 2;
			mcc_spawndisplayname = (_groupArray select (call MCCMK_fnc_classRow)) select 3;
		};
	}
	else
	{
		MCC_groupBroadcast = MCC_groupGenCurrenGroupArray;
	};
};

//Spawn in mouse Click
if ((_type==0) && ((!(_gTypeName in ["Reinforcement","Garrison"]) && (lbCurSel MCC_GGUNIT_TYPE) == 1) ||(lbCurSel MCC_GGUNIT_TYPE) == 0)) then
{
	if (typeName MCC_groupBroadcast != "STRING") then
	{
		if (count MCC_groupBroadcast == 0) exitWIth {systemchat "Cannot spawn an empty group"};
	};

	mcc_spawnbehavior = (MCC_spawn_behaviors select ((lbCurSel MCC_GGUNIT_BEHAVIOR) max 0)) select 1;
	MCC_behavior_index = (lbCurSel MCC_GGUNIT_BEHAVIOR) max 0;
	[(if ((toLower mcc_spawnbehavior) in ["bis", "bisd", "bisp"]) then {"click map to spawn - Hold Ctrl for multiple times"} else {"click map to spawn - Hold Ctrl for multiple times" + toString [10] + "(Aggressive, Defensive and Fortify only apply to Spawn in zone: placed by click, the group behaves as None)"})] call MCCMK_fnc_hint;
	missionNameSpace setVariable ["MCC_spawnEnabled",true];
}
//Spawn to zone
else
{
	//Failsafe NO group selected
	if ((lbCurSel UNIT_CLASS) == -1) exitWith {systemchat "Cannot spawn an empty group"};

	//Failsafe incase we trying to spawn something without making a zone first
	if (count mcc_zone_pos == 0) exitWith {["Create a zone first"] call MCCMK_fnc_hint};

	//Failsafe in case we trying to spawn something without making a zone first
	_selectedZoneNr = ["number"] call MCC_fnc_zoneList;
	_zonePos = mcc_zone_pos select _selectedZoneNr;
	if ( (count mcc_zone_pos <= _selectedZoneNr ) || { isnil "_zonePos" } ) exitWith {["Create a zone first"] call MCCMK_fnc_hint};

	mcc_spawnwithcrew = (MCC_spawn_empty select (((lbCurSel ((findDisplay groupGen_IDD) displayCtrl MCC_GGUNIT_EMPTY)) max 0) min 1)) select 1;	//let's add the behavior/awerness (MK: from the console window's own control)
	MCC_empty_index = (((lbCurSel ((findDisplay groupGen_IDD) displayCtrl MCC_GGUNIT_EMPTY)) max 0) min 1);

	mcc_spawnbehavior = (MCC_spawn_behaviors select (lbCurSel MCC_GGUNIT_BEHAVIOR)) select 1;
	MCC_behavior_index = (lbCurSel MCC_GGUNIT_BEHAVIOR);

	mcc_awareness = "default";

	_nul=[4] execVM MCC_path + "mcc\general_scripts\mcc_SpawnStuff.sqf";
};

