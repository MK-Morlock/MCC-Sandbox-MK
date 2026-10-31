/*==================================MCC_fnc_ModuleObjective_F=======================================================

================================================================================================================*/
params [
	["_module",objNull,[objNull]],
	["_state","init",["",[]]]
];

//If we came from the module we get an array so convert it to string
if !(typeName _state isEqualTo typeName "") then {
	_state = "init";
};

switch (tolower _state) do
{
	case "init":
	{
		//Started once only: by the module framework or directly by the Mission Generator (whichever comes first)
		if (_module getVariable ["MCC_objInitStarted", false]) exitWith {};
		_module setVariable ["MCC_objInitStarted", true];
		waitUntil {_module getVariable ["updated",false] && time > 0};
		_module setvariable ["bis_fnc_curatorAttachObject_object",(_module getVariable ["AttachObject_object",_module])];
		[_module,"update"] spawn MCC_fnc_ModuleObjective_F;
	};

	case "update":
	{

		private _owners = _module getVariable ["RscAttributeOwners",true];
		private _taskName = _module getVariable ["taskName",""];
		private _taskText = _module getVariable ["RscAttributeTaskDescription",["","",""]];
		private _taskDestination = _module getVariable ["showMarker",position _module];
		private _taskState = _module getVariable ["RscAttributeTaskState","created"];
		private _taskPriority = _module getVariable ["proiority",0];
		private _taskNotification = _module getVariable ["notification",true];
		private _taskType = _module getVariable ["taskType","target"];
		private _alwaysVisible = _module getVariable ["show3d",true];

		//Custom Tasks fnc
		if (_module getVariable ["MCCcustomTaskInit",true]) then {
			_module setVariable ["MCCcustomTaskInit",false];


			[_module] spawn MCC_fnc_customTasks;

			//Capture point fnc
    		if (_taskType in ["attack","deffend"]) then {
    			[_module] spawn MCC_fnc_moduleCapturePoint;
    		};
		};

		//Add Task
		0 = [_taskName,_owners,_taskText,_taskDestination,_taskState,_taskPriority,_taskNotification,true,_taskType,_alwaysVisible] call bis_fnc_setTask;

		//RPT: did the task get created, and where is its marker
		private _tid = if (_taskName isEqualType []) then {_taskName param [0, ""]} else {_taskName};
		["INFO", "fn_ModuleObjective_F", "task %1 (%2) for %3: exists %4, destination %5, state %6", [_tid, _taskType, _owners, _tid call BIS_fnc_taskExists, _tid call BIS_fnc_taskDestination, _taskState]] call MCC_fnc_log;

		/*
		[["child2","parent3"],true,["text","Head","bosy2"],position player,"created",0,true,true,"target",true] call bis_fnc_setTask;
		*/

		sleep 5;

		if ((_module getVariable ["RscAttributeTaskState","created"]) isEqualTo _taskState) then {
			_module setVariable ["updated",false,true];
		} else {
			_module setVariable ["updated",true,true];
		};

		//Pending
		waitUntil {(isNull _module) || (_module getvariable ["updated",false])};

		//Update Task
		if (_module getvariable ["updated",false]) exitWith {
			[_module,"update"] spawn MCC_fnc_ModuleObjective_F;
		};

		//Delete Task
		if (isNull _module && (_taskName call bis_fnc_taskExists)) then {
			if !(_taskName call bis_fnc_taskCompleted) then {
				if (typeName _taskName == typeName []) then {
					(_taskName select 0) call bis_fnc_deleteTask
				} else {
					_taskName call bis_fnc_deleteTask
				};
			};
		};
	};
};


