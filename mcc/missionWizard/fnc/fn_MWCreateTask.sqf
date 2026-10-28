/*================================================MCC_fnc_MWCreateTask====================================================================================================
// Find the mission Wizard's center
// Example:[_obj,_task,_preciseMarker] call MCC_fnc_MWCreateTask;
// _obj = position, objectice position
//_task = string, objective type
//_preciseMarker = Boolean, true - precise task marker
// Return - [taskName,Task pos]
//===================================================================================================================================================================*/
private _stringName = "";
private _stringDescription = "";
private _pos = [];
private _objectName = "";
private _missionTime = [];
private _missionIntel = [];
private _missionWherabouts = [];
private _pic = "";
private _sides = [];
private _taskId = "";
private _taskType = "";

_this params [
  ["_obj",objNull,[objNull]],
  ["_pos",[],[[]]],
  ["_task","",[""]],
  ["_preciseMarker",false,[false]],
  ["_side",sideLogic,[sideLogic]],
  ["_maxObjectivesDistance",400,[400]]
];

//define contesting sides
_sides = [east,west,resistance] - [_side];

//Global defines for briefings.
_missionTime =
   [
     "This morning",
     "Last night",
     "Yesterday",
     "A few days ago",
     "Last week"
   ];

_missionIntel =
   [
     "From gathered intel",
     "According to satellite photos",
     "According to intel from a local informant",
     "According to info from High Command"
   ];

_missionWherabouts =
   [
      "in this location",
      "in this area",
      "somewhere in this area",
      "close to this location",
      "around here"
   ];

if (_pos isEqualTo []) then {_pos = getPos _obj};
if (count _pos ==2) then {_pos set [2,0]};
private _objRealPos = +_pos;

//Area markers are moved off the objective on purpose (search the area) - original MCC behaviour.
//Clear Area is not moved: its circle is the area that has to be cleared.
if (!_preciseMarker && {_task != "clear_area"}) then {
	_pos =  [(_pos select 0) + (random 300 - random 300),(_pos select 1) + (random 300 - random 300),(_pos select 2)];
};

// RPT: where the objective really is vs where its task marker is (Area markers are offset on purpose)
["INFO", "fn_MWCreateTask", "objective %1: %2 at %3 - task marker at %4 (%5 m away, %6 marker)", [_task, if (isNull _obj) then {"(no object)"} else {typeOf _obj}, _objRealPos apply {round _x}, _pos apply {round _x}, round (_objRealPos distance2D _pos), ["area", "precise"] select _preciseMarker]] call MCC_fnc_log;
_pic = "";

switch (_task) do {
   //Hostage
   case "Secure_HVT": {
      if (side _obj != civilian) then {
         _objectName = ([_obj,"displayName"] call BIS_fnc_rankParams) + " " + name _obj;
      } else {
         _objectName = name _obj;
      };

      _stringName   = FORMAT ["Rescue %1", _objectName];

      _stringDescription =  FORMAT ["Rescue %2. <br/><br/>%1 %2 was captured by enemy forces operating in the area.<br/>%3 we believe that he is held captive %4.<br/>Find %2 and bring him home.
                              "
                             , _missionTime call BIS_fnc_selectRandom
                             , _objectName
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "a3\Missions_F_BOOTCAMP\data\img\Bootcamp_overview_CA.paa";
      _taskType = "help";
   };

   //Kill
   case "Kill_HVT": {
      if (side _obj != civilian) then {
         _objectName = ([_obj,"displayName"] call BIS_fnc_rankParams) + " " + name _obj;
      } else {
         _objectName = name _obj;
      };

      _stringName   = FORMAT ["Kill or capture %1", _objectName];
      _stringDescription =  FORMAT ["Kill or capture %2. <br/><br/>%3, HQ in their wisdom believe that %2 has been hiding %4 since %1.<br/>%2 is a most wanted HVT and should be considered armed and dangerous.<br/>Capture him if possible; if not, kill him. Either way, do not let him escape."
                             , toLower (_missionTime call BIS_fnc_selectRandom)
                             , _objectName
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
							];
      _pic = "\a3\Missions_F_Bootcamp\data\img\Boot_m04_overview_CA.paa";
      _taskType = "kill";
   };

   //destroy_tanks
   case "destroy_tanks": {
      _objectName = getText(configFile >> "CfgVehicles" >> typeof _obj >> "displayname");
      _stringName   = FORMAT ["Destroy the prototype %1", _objectName];
      _stringDescription =  FORMAT ["Destroy the prototype %2.<br/><br/>%1, HQ received intel suggesting that the enemy has obtained a prototype %2.<br/>This is a game-changer and we must eliminate it by any means necessary.<br/>%3, the vehicle is hidden %4."
                             , _missionTime call BIS_fnc_selectRandom
                             , _objectName
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\B_skirmish01_overview_CA.paa";
      _taskType = "destroy";
   };

   //destroy_aa
   case "destroy_aa": {
      _objectName = getText(configFile >> "CfgVehicles" >> typeof _obj >> "displayname");
      _stringName   = FORMAT ["Destroy %1", _objectName];
      _stringDescription =  FORMAT ["Destroy %2.<br/><br/>%1, one of our planes was shot down.<br/>HQ believes that a %2 is behind it.<br/>This threat must be eliminated.<br/>%3, the AA is operating %4. Find and destroy it, soldier."
                             , _missionTime call BIS_fnc_selectRandom
                             , _objectName
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];

      _pic = "\a3\Missions_F_EPA\data\img\B_m02_2_overview_CA.paa";
      _taskType = "destroy";
   };

   //destroy_artillery
   case "destroy_artillery": {
      _objectName = getText(configFile >> "CfgVehicles" >> typeof _obj >> "displayname");
      _stringName   = FORMAT ["Destroy %1", _objectName];
      _stringDescription =  FORMAT ["Destroy %2.<br/><br/>%1, enemy artillery began pounding our troops. This threat must be eliminated.<br/>%3, the %2 is operating %4.<br/>Find and destroy it ASAP."
                             , _missionTime call BIS_fnc_selectRandom
                             , _objectName
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\B_out2_overview_CA.paa";
      _taskType = "destroy";
  };

   //destroy_cache
   case "destroy_cache": {
      _stringName = "Destroy the enemy weapons cache";
      _stringDescription =  FORMAT ["Destroy the enemy weapons cache.<br/><br/>%2 received %1, we believe that the enemy is hiding a weapons cache %3.<br/>Destroying it will severely damage the enemy war effort.<br/>Find and destroy it ASAP."
                             , toLower (_missionTime call BIS_fnc_selectRandom)
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
        _pic = "\a3\Missions_F_EPA\data\img\B_m01_overview_CA.paa";
        _taskType = "destroy";

   };

   //destroy_fuel
   case "destroy_fuel": {
      _stringName   = "Destroy the enemy fuel depot";
      _stringDescription =  FORMAT ["Destroy the enemy fuel depot.<br/><br/>%2 received %1, we believe that the enemy have a fuel depot %3.<br/>Destroying it will severely damage the enemy war effort.<br/>Find and destroy it ASAP."
                             , toLower (_missionTime call BIS_fnc_selectRandom)
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\B_m03_overview_CA.paa";
      _taskType = "destroy";

   };

   //destroy_radio
   case "destroy_radio": {
      _stringName   = "Destroy the enemy radio tower";
      _stringDescription =  FORMAT ["Destroy the enemy radio tower.<br/><br/>%2 received %1, the enemy have a radio tower %3. They are using it to coordinate their attacks.<br/>Destroying it will severely damage the enemy war effort.<br/>Find and destroy it ASAP."
                             , toLower (_missionTime call BIS_fnc_selectRandom)
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\B_m06_overview_CA.paa";
      _taskType = "destroy";
   };

   //destroy_radar
   case "destroy_radar": {
      _stringName   = "Destroy the enemy radar";
      _stringDescription =  FORMAT ["Destroy the enemy radar.<br/><br/>%2 received %1, the enemy have a radar installation %3. They are using it to pinpoint the location of our troops.<br/>By destroying it we can regain the element of surprise.<br/>Find and destroy it ASAP."
                             , toLower (_missionTime call BIS_fnc_selectRandom)
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\A_m04_overview_CA.paa";
      _taskType = "destroy";
   };

   //pick_intel
   case "pick_intel": {
      _objectName = getText(configFile >> "CfgVehicles" >> typeof _obj >> "displayname");
      _stringName   = FORMAT ["Acquire the %1", _objectName];
      _stringDescription =  FORMAT ["Acquire Intel.<br/><br/>HQ believe that we have an opportunity to acquire top-notch information about enemy forces operating in the area.<br/>%3, the target data is in a %2, located %4.<br/>Retrieve the information and bring it back for analysis."
                             , _missionTime call BIS_fnc_selectRandom
                             , _objectName
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\A_hub02_overview_CA.paa";
      _taskType = "search";
   };

   //Download Intel
   case "downloadIntel":
   {
      _objectName = getText(configFile >> "CfgVehicles" >> typeof _obj >> "displayname");
      _stringName   = FORMAT ["Hack and download intel from %1", _objectName];
      _stringDescription =  FORMAT ["Download Intel.<br/><br/>HQ believe that we have an opportunity to acquire top-notch information about enemy forces operating in the area.<br/>%3, the target data is in a %2, located %4.<br/>Retrieve the information and bring it back for analysis."
                             , _missionTime call BIS_fnc_selectRandom
                             , _objectName
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\A_hub02_overview_CA.paa";
      _taskType = "download";
   };

   //disableIED
   case "disableIED": {
      _stringName   = "Disable IED";
      _stringDescription =  FORMAT ["Disable IED.<br/><br/>%1, enemy forces have got their hands on a massive Improvised Explosive Device (IED) %2.<br/>We must disable it before they can use it against the civilian population.<br/>Tread carefully, find the IED and disarm it."
                             , _missionIntel call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];

      _pic = "\a3\Missions_F_EPA\data\img\C_m02_overview_CA.paa";
      _taskType = "mine";
   };

   //Logistics
   case "Logistics": {
      _stringName   = "Deliver supplies";

      _stringDescription =  "Deliver supplies. <br/><br/>The local population is in need of food and water.<br/>Top brass believe that delivering these supplies is in our favor.<br/>Get the supply truck and deliver it to the designated area.";

      _pic = "a3\Missions_F_BOOTCAMP\data\img\Bootcamp_overview_CA.paa";
      _taskType = "logistic";
   };

   //clear_area
   default {
      _stringName   = "Clear Area";
      _stringDescription =  FORMAT ["Capture Area.<br/><br/>%1, enemy forces established a foothold %2.<br/>We cannot allow this to continue!<br/>Go there and kick them out!"
                             , _missionTime call BIS_fnc_selectRandom
                             , _missionWherabouts call BIS_fnc_selectRandom
                             , _stringName
                             ];
      _pic = "\a3\Missions_F_EPA\data\img\A_m02_overview_CA.paa";
      _taskType = "attack";
   };
};

private _group = grpNull;
private _vehicle = objNull;

// Objective modules go into MCCs own logic group. They used to join the group of whatever logic happened to be first
// in allMissionObjects - often another module that deletes itself (Zeus/MCC modules do), so the group could be empty or
// deleted and createUnit returned nothing: the objective spawned but had no task and no map marker, and when every
// objective failed like that the mission reported "complete" at once.
_group = missionNamespace getVariable ["MCC_MWObjectiveLogicGroup", grpNull];
if (isNull _group) then {
	_group = createGroup [sideLogic, false];
	missionNamespace setVariable ["MCC_MWObjectiveLogicGroup", _group];
};

//clear area mission
private _missionName = missionNamespace getVariable ["MCC_fnc_MWinitMission_missionName",""];

if (_task == "clear_area") then {
    _vehicle = _group createunit ["MCC_ModuleObjective_FCurator", _pos,[],0.5,"NONE"];
    _vehicle setVariable ["BIS_fnc_initModules_disableAutoActivation", false,true];
    _vehicle setVariable ["MCC_customTask",true,true];	//counted by the mission-end check straight away (MCC_fnc_customTasks sets it again later)
    _vehicle setVariable ["MCC_MWMissionId", missionNamespace getVariable ["MCC_MWCurrentMissionId", ""]];
    _taskId = str _vehicle + str (["MCC_fnc_moduleObjective_id",1] call bis_fnc_counter);
    _vehicle setvariable ["RscAttributeOwners",_sides,true];
    if (typeName _obj == "OBJECT") then {_vehicle setvariable ["AttachObject_object",_obj,true]};
    _vehicle setvariable ["RscAttributeTaskState","created", true];
    _vehicle setvariable ["taskType",_taskType,true];
    _vehicle setvariable ["taskName",if (_missionName == "") then {_taskId} else {[_taskId,_missionName]},true];	//no parent task when there is only one objective
    _vehicle setvariable ["RscAttributeTaskDescription",[_stringDescription,_stringName,_stringName],true];

    //turn the sides into strings so we can compile it
    private _sidesStr = [];
    {_sidesStr pushBack str _x} forEach _sides;

    _vehicle setvariable ["OnOwnerChange",format ["if (str (_this select 1) in %1) then {(_this select 0) enableSimulation false};", _sidesStr],true];
    _vehicle setvariable ["type",4,true];
    _vehicle setvariable ["radius",_maxObjectivesDistance,true];
    //_vehicle setvariable ["enableHUD",false];
    _vehicle setvariable ["sides",[east,west,resistance],true];
    _vehicle setvariable ["owner",_side,true];
    _vehicle setVariable ["MCC_MWClearArea", true];
    _vehicle setVariable ["MCC_MWClearEnemy", _side];

    {_x addCuratorEditableObjects [[_vehicle],false]} forEach allCurators;
    _vehicle setvariable ["updated",true,true];
    //Start the task now. Left to the module framework, objective modules created in the same moment were sometimes never
    [_vehicle, "init"] spawn MCC_fnc_ModuleObjective_F;
} else {
  //spawn task for each side
  {
    _vehicle = _group createunit ["MCC_ModuleObjective_FCurator", _pos,[],0.5,"NONE"];
    if (_task == "Logistics") then {_vehicle setPos _objRealPos};
    _vehicle setVariable ["BIS_fnc_initModules_disableAutoActivation", false,true];
    _vehicle setVariable ["MCC_customTask",true,true];	//counted by the mission-end check straight away (MCC_fnc_customTasks sets it again later)
    _vehicle setVariable ["MCC_MWMissionId", missionNamespace getVariable ["MCC_MWCurrentMissionId", ""]];
    _taskId = str _vehicle + str (["MCC_fnc_moduleObjective_id",1] call bis_fnc_counter);
    _vehicle setvariable ["RscAttributeOwners",[_x],true];
    if !(isNull _obj) then {_vehicle setvariable ["AttachObject_object",_obj,true]};
    _vehicle setvariable ["RscAttributeTaskState","created", true];
    _vehicle setvariable ["taskType",_taskType,true];
    _vehicle setvariable ["taskName",if (_missionName == "") then {_taskId} else {[_taskId,_missionName]},true];	//no parent task when there is only one objective
    _vehicle setvariable ["RscAttributeTaskDescription",[_stringDescription,_stringName,_stringName],true];

    if (!(isNull _obj) && _preciseMarker && {_task != "Logistics"}) then {
      _vehicle setvariable ["showMarker",[_obj,true],true];
       _vehicle setvariable ["show3d",true,true];
    } else {
      _vehicle setvariable ["showMarker",_pos,true];
       _vehicle setvariable ["show3d",false,true];
    };

    _vehicle setvariable ["proiority",0,true];
    _vehicle setvariable ["notification",true,true];


    {_x addCuratorEditableObjects [[_vehicle],false]} forEach allCurators;
    _vehicle setvariable ["updated",true,true];
    //Start the task now. Left to the module framework, objective modules created in the same moment were sometimes never
    [_vehicle, "init"] spawn MCC_fnc_ModuleObjective_F;
  } foreach _sides;
};

if (isNull _vehicle) then {
  ["WARN", "fn_MWCreateTask", "objective %1: could not create the task module - no task/marker for it", [_task]] call MCC_fnc_log;
};

MCC_MWObjectivesNames = [_pos,"",_stringName,_stringDescription,"",_pic,1,[],_vehicle];
publicVariable "MCC_MWObjectivesNames";