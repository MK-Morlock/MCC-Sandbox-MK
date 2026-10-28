//================================================================MCC_fnc_buildSpawnPoint=============================================================================
//Create a spawn point to the given side - SERVER ONLY
// Example: [pos, dir, side,size,destructable] remoteExec ["MCC_fnc_buildSpawnPoint", false, false];
// pos: Array, position
// dir; number, direction
// side: string, "west", "east" or "GUER"
// size: string  "FOB" or  "HQ"
// destructable: Boolean
// animate: Boolean
// construct: Boolean
//======================================================================================================================================================================
private "_side";
private _size = "";
private _destructable = false;
private "_building";
private _dummy = objNull;
private _sphere = objNull;
private "_dir";
private _animate = false;
private _flag = nil;
private "_flagTex";
private _name = "";
private "_logic";
private "_pos";
private _construct = false;
private _teleport = 0;
private _enableHud = false;
private _mode = "";

#define	MCC_ANCHOR	"Box_FIA_Support_F"

if ((typeName (_this select 0)) == "OBJECT") then {
	_logic			= _this select 0;
	_pos			= getpos _logic;
	_dir			= getdir _logic;

	// Module values can arrive as text ("1") or booleans depending on how the mission stores them
	private _fnc_num = {params ["_v", "_d"]; if (_v isEqualType "") then {_v = parseNumber _v}; if (_v isEqualType true) then {_v = [0, 1] select _v}; if !(_v isEqualType 0) then {_v = _d}; _v};
	private _fnc_bool = {params ["_v", "_d"]; if (_v isEqualType "") then {_v = (toLower _v) in ["true", "1"]}; if (_v isEqualType 0) then {_v = _v != 0}; if !(_v isEqualType true) then {_v = _d}; _v};

	_side 			= ([_logic getvariable ["side",1], 1] call _fnc_num) call bis_fnc_sideType;	//default BLUFOR, like the module
	_size 			= _logic getvariable ["size","FOB"];
	if !(_size isEqualType "") then {_size = "FOB"};
	_size 			= toUpper _size;
	_destructable	= [_logic getvariable ["distractable",true], true] call _fnc_bool;
	_animate		= false;
	_construct 		= ([_logic getvariable ["construct",0], 0] call _fnc_num) == 1;
	_teleport 		= [_logic getVariable ["teleportAtStart",1], 1] call _fnc_num;
	_enableHud		= [_logic getVariable ["hud",false], false] call _fnc_bool;
	_mode			= _logic getVariable ["mode","init"];

} else {
	_pos			= _this select 0;
	_dir			= _this select 1;
	_side 			= _this select 2;
	_size 			= toupper (_this select 3);
	_destructable	= param [4,false,[false]];
	_animate		= param [5,false,[false]];
	_construct 		= param [6, false, [false]];
	_teleport 		= param [7, 1, [0]];
	_enableHud		= param [8, false, [false]];
	_mode			= param [9, "init", [""]];
};

//--------------------Default flags (Role selection)-------------------------------------------------------
if (isnil "CP_flagWest") then {CP_flagWest = "\a3\Data_f\Flags\flag_nato_co.paa"};
if (isnil "CP_flagEast") then {CP_flagEast = "\a3\Data_f\Flags\flag_CSAT_co.paa"};
if (isnil "CP_flagGUER") then {CP_flagGUER = "\a3\Data_f\Flags\flag_AAF_co.paa"};

#define REQUIRE_MEMBERS 3
#define	MCC_HQ_BaseItem	"UserTexture10m_F"
#define	MCC_FOB_BaseItem	"Land_TBox_F"

if (typeName _side == "STRING") then {
	_side = switch (toupper _side) do
			{
				case "WEST":		{west};
				case "EAST":		{east};
				case "GUER":	{resistance};
				default     	{civilian};
			};
};

switch (_mode) do
{
	case "initHUDLocal":
	{
		//HUD
		if (hasInterface && !(missionNamespace getVariable ["MCC_SpawnPointEnabled",false])) then {
			missionNamespace setVariable ["MCC_SpawnPointEnabled",true];

			waitUntil {alive player && time > 1};
			//Create structures Icons
			["MCC_HQhud", "onEachFrame",
			{
				private _text = "";
				private _color = [];
				private _texture = "";
				private "_pos";
				_pos = missionNamespace getVariable [format ["MCC_START_%1",playerSide],[0,0,0]];
				_text 	= "HQ";
				_texture = "n_installation" call bis_fnc_textureMarker;;
				_color = [playerSide] call bis_fnc_sidecolor;
				_color set [3,1-(((player distance _pos)/1000)) max 0];
				_text = _text + format [" %1 m",floor (player distance _pos)];

				drawIcon3D [
								_texture,
								_color,
								[_pos select 0,_pos select 1,(_pos select 2)+5],
								1,
								1,
								0,
								_text,
								1,
								0.04,
								"PuristaMedium"
							];

			}] call BIS_fnc_addStackedEventHandler;
		};
	};

	case "init":
	{
		if !(isServer) exitWith {};

		if (_enableHud) then {
			[_pos,_dir,_side,_size,_destructable,_animate,_construct,_teleport,_enableHud,"initHUDLocal"] remoteExec ["MCC_fnc_buildSpawnPoint", 0];
		};

		//animate the process of building a FOB
		if (_animate) then {
			//Phase 1
			private _anchor = "";
			private _prop = objNull;
			private "_class";
			private "_modelWorld";
			private _objects = [];
			private "_propPos";
			private _newObjects = [];
			private "_anchorPos";
			private "_time";
			_anchor = "Land_PaperBox_closed_F" createvehicle _pos;

			_objects = [];
			{
				_class = _x select 0;
				_modelWorld = _x select 1;
				_prop = _class createvehicle (_anchor modelToworld _modelWorld);
				_objects set [count _objects, _prop];
			} foreach [["Land_PaperBox_closed_F",[4,0,0]],["Land_PaperBox_closed_F",[-4,0,0]],["Land_PaperBox_closed_F",[0,-4,0]]];

			_finished = false;
			_newObjects = [];
			_time = floor diag_ticktime;
			while {!_finished} do
			{
				sleep 1;
				if (_time !=  floor diag_ticktime) then
				{
					_time = floor diag_ticktime;

					//How many players from my side are near
					_nearby = {alive _x && {side _x == _side}} count (getPosATL _anchor nearEntities ["CAManBase", 50]);

					if (count _objects == 0) then
					{
						_finished = true;
						deletevehicle _anchor;
						{deletevehicle _x; sleep 1} foreach _newObjects;
					};

					if ((_time % 20 == 0) && _nearby > REQUIRE_MEMBERS && count _objects > 0) then
					{
						if (typeof _anchor == "Land_PaperBox_closed_F") then
						{
							_anchorPos = getposATL _anchor;
							deletevehicle _anchor;
							_anchor = "Land_FishingGear_01_F" createvehicle _anchorPos;
						}
						else
						{
							_prop = _objects select 0;
							_propPos = getposATL _prop;
							deletevehicle _prop;
							_prop = "Land_Sacks_heap_F" createvehicle _propPos;
							_newObjects set [count _newObjects, _prop];
							_objects set [0,-1];
							_objects = _objects - [-1];
						};
					};
				};
			};
		};

		if (_construct) then {
			_null = [_pos, _dir , "MCC_rts_hq1", 0, _side] spawn MCC_fnc_construct_base;
		};

		_building = if (_size == "FOB") then {MCC_FOB_BaseItem} else {MCC_HQ_BaseItem};
		_flagTex = switch (_side) do {
			case west:	{CP_flagWest};
			case east:	{CP_flagEast};
			case resistance:	{CP_flagGUER};
			default	{CP_flagGUER};
		};

		_dummy = _building createvehicle _pos;
		_dummy setdir _dir;

		//For LHD
		if (surfaceIsWater _pos) then {
			_dummy setPosASL _pos;
		};

		_dummy setVariable ["mcc_delete",false,true];

		_flag = "FlagPole_F" createvehicle _pos;
		sleep 0.5;
		_flag setFlagTexture _flagTex;

		//For LHD
		if (surfaceIsWater _pos) then {
			_flag setPosASL _pos;
		};

		_dummy setvariable ["type",_size,true];
		_dummy setvariable ["side",_side,true];
		_dummy setvariable ["mcc_flag",_flag,true];
		_dummy setVariable ["mcc_delete",false,true];
		_dummy setVariable ["teleport",_teleport,true];
		missionNamespace setVariable [format ["MCC_%1_BUILDING",_side],_dummy];
		publicVariable format ["MCC_%1_BUILDING",_side];

		//If is FOB
		if (_size == "FOB") then {
			//Attach flag
			_flag attachto [_dummy,[2.5,0,2]];
			_box = MCC_ANCHOR createvehicle _pos;
			_box setdir _dir;
			_box setVariable ["mcc_delete",false,true];
			_box setVariable ["mcc_mainBoxSide",_side,true];
			_box setVariable ["MCC_kitSelect",["all"],true];
			_box attachto [_dummy,[-3.5,0,-0.8]];
			[_side, _box] call MCC_fnc_makeObjectVirtualBox;

			//Only destroyable with satchel or demo charges
			_dummy addEventHandler ["handledamage",{
											if ((_this select 4) in ["SatchelCharge_Remote_Ammo","DemoCharge_Remote_Ammo","DemoCharge_Remote_Ammo_Scripted","SatchelCharge_Remote_Ammo_Scripted"]) then
											{
												private "_obj";
												private _mark = "";
												private _flag = nil;
												private "_side";
												_obj = _this select 0;
												_obj setVariable ["dead",true,true];
												_mark = _obj getVariable ["mcc_fob_name",""];
												_side = _obj getVariable ["side",civilian];

												[[], compile format ['deleteMarker "%1";',_mark]] remoteExec ["call", _side, false];

												_flag = _obj getVariable ["mcc_flag",objnull];
												if (!isnil "_flag") then
												{
													deletevehicle _flag;
												};
												deletevehicle _obj;
												1
											};
												}];

			_name = format ["FOB_%1",["MCC_fob_counter",1] call bis_fnc_counter];
			_dummy setvariable ["mcc_fob_name",_name, true];

			//Create marker
			[[_name], _pos, "colorGreen", "loc_Bunker",_name,false] remoteExec ["BIS_fnc_markerCreate", _side, false];
		} else {
			//Not destroyable
			_dummy addEventHandler ["handledamage",{0}];

			//Make it as  medic area
			_dummy spawn MCC_fnc_medicArea;
		};

		// Side start position (MCC_START_<SIDE>) - used by Mission Wizard, RTS, logistics, HUD, respawn.
		// A MAIN start location always sets it. An F.O.B sets it only if the side has no start position yet,
		// so a mission with just one F.O.B-type Start Location module (the module's default Type) still works.
		private _startVar = format ["MCC_START_%1",_side];
		if (_side in [west, east, resistance] && {_size != "FOB" || {isNil {missionNamespace getVariable _startVar}}}) then {
			missionNameSpace setVariable [_startVar,_pos];
			publicVariable _startVar;
			["INFO", "fn_buildSpawnPoint", "%1 start position set from %2 start location at %3", [_side, _size, _pos]] call MCC_fnc_log;
		} else {
			if !(_side in [west, east, resistance]) then {
				["WARN", "fn_buildSpawnPoint", "start location at %1 has an unrecognised side (%2) - not used as a start position", [_pos, _side]] call MCC_fnc_log;
			} else {
				["INFO", "fn_buildSpawnPoint", "%1 %2 added at %3 (side start position already set)", [_side, _size, _pos]] call MCC_fnc_log;
			};
		};

		if (!_destructable) then {
			_sphere = MCC_HQ_BaseItem createvehicle (getpos _dummy);
			_sphere setpos (getpos _dummy);
			_sphere setVariable ["mcc_delete",false,true];
		};

		[_side, _dummy] call BIS_fnc_addRespawnPosition;
	};
};