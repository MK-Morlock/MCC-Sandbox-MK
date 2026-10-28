params [["_class", "", [""]], ["_pos", [], [[]]]];
if (count _pos < 2) then {_pos = getPosATL player};
if (!isNil "MCC_3D_cleanup" && {!isNil "MCC_3D_CAM"}) then {[false] call MCC_3D_cleanup};

MCC_3Dterminate = false;
MCC_3DterminateNoMCC = false;
MCC_preview3DClass = _class;
missionNamespace setVariable ["MCC_3dEditorAllowDialog", _class == ""];
MCC_3D_dir = round (getDir player);
z3DHight = 0;
MCC_3D_shift = false;
MCC_3D_ctrl = false;
MCC_3D_park = [[0, 0, 0], 0, false];
MCC_3D_delTarget = objNull;
MCC_3D_delTime = -10;
MCC_3D_delObjs = [];
MCC_3D_delSingle = false;
MCC_3D_hover = objNull;
if (isNil "MCC_3D_undoStack") then {MCC_3D_undoStack = []};
MCC_3D_msg = "";
MCC_3D_GUI = true;
MCC_3D_previewParts = [];
MCC_3D_previewName = "";
MCC_3D_physics = false;
MCC_3D_radius = 1;
MCC_3D_blocked = objNull;
MCC_3D_ghost = [0, 0, 0];
MCC_3D_ghostQuads = [];
MCC_3D_ehs = [];
MCC_3D_mehs = [];
if (isNil "MCC_align3D" || {!(MCC_align3D isEqualType true)}) then {MCC_align3D = true};
MCC_3D_rmbTime = -1;
MCC_3D_nvg = [4, 3] select (sunOrMoon < 0.5);

MCC_3D_clearPreview = {
	{deleteVehicle (_x select 0)} forEach MCC_3D_previewParts;
	MCC_3D_previewParts = [];
	Object3D = nil;
};

MCC_3D_newPart = {
	params [["_cls", "", [""]]];
	if (_cls == "" || {!isClass (configFile >> "CfgVehicles" >> _cls)}) exitWith {objNull};
	private _o = _cls createVehicleLocal [0, 0, 1000];
	if (isNull _o) then {_o = createSimpleObject [_cls, [0, 0, 1000], true]};
	if (isNull _o) exitWith {objNull};
	_o enableSimulation false;
	_o allowDamage false;
	_o
};

MCC_3D_makePreview = {
	params [["_cls", "", [""]], ["_type", "", [""]]];
	[] call MCC_3D_clearPreview;
	MCC_3D_physics = false;
	MCC_3D_previewName = "";
	if (_cls == "") exitWith {[] call MCC_3D_panel};
	if (toUpper _type == "DOC") exitWith {
		private _data = [];
		private _file = format ["%1mcc\general_scripts\docobject\%2.sqf", MCC_path, _cls];
		if (fileExists _file) then {_data = call compile preprocessFileLineNumbers _file};
		if !(_data isEqualType []) then {_data = []};
		[_data, missionNamespace getVariable ["mcc_spawndisplayname", _cls]] call MCC_3D_makePreviewParts;
	};
	if (true) then {
		private _o = objNull;
		if (toUpper _type == "MINES") then {
			private _model = getText (configFile >> "CfgVehicles" >> _cls >> "model");
			if ((_model select [0, 1]) == "\") then {_model = _model select [1]};
			if (_model != "" && {!(".p3d" in toLower _model)}) then {_model = _model + ".p3d"};
			if (_model != "") then {_o = createSimpleObject [_model, [0, 0, 1000], true]};
		} else {
			_o = [_cls] call MCC_3D_newPart;
		};
		if (isNull _o) then {
			_o = "Sign_Arrow_Direction_F" createVehicleLocal [0, 0, 1000];
			_o enableSimulation false;
		};
		MCC_3D_previewParts pushBack [_o, [0, 0, 0], 0, false, boundingBoxReal _o];
		MCC_3D_physics = (_cls isKindOf "AllVehicles") || {_cls isKindOf "ThingX"} || {_cls isKindOf "ReammoBox_F"};
		MCC_3D_previewName = getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
		if (MCC_3D_previewName == "") then {MCC_3D_previewName = _cls};
		MCC_preview3DClass = _cls;
		[] call MCC_3D_cargoToPreview;
	};
	Object3D = if (count MCC_3D_previewParts > 0) then {(MCC_3D_previewParts select 0) select 0} else {nil};
	MCC_3D_radius = 1;
	{
		_x params ["_o", "_rel"];
		MCC_3D_radius = MCC_3D_radius max ((vectorMagnitude [_rel select 0, _rel select 1, 0]) + ((boundingBoxReal _o) select 2));
	} forEach MCC_3D_previewParts;
	MCC_3D_msg = "";
	[] call MCC_3D_panel;
};

MCC_3D_makePreviewParts = {
	params [["_data", [], [[]]], ["_name", "", [""]]];
	[] call MCC_3D_clearPreview;
	MCC_3D_physics = false;
	{
		_x params [["_t", "", [""]], ["_rel", [0, 0, 0], [[]]], ["_azi", 0, [0]]];
		private _o = [_t] call MCC_3D_newPart;
		if (!isNull _o) then {
			private _bb = boundingBoxReal _o;
			private _tilt = !(_o isKindOf "AllVehicles") && {(((_bb select 1) select 2) - ((_bb select 0) select 2)) < 3};
			MCC_3D_previewParts pushBack [_o, [_rel param [0, 0], _rel param [1, 0], _rel param [2, 0]], _azi, _tilt, _bb];
		};
	} forEach _data;
	MCC_3D_previewName = _name;
	Object3D = if (count MCC_3D_previewParts > 0) then {(MCC_3D_previewParts select 0) select 0} else {nil};
	MCC_3D_radius = 1;
	{
		_x params ["_o", "_rel"];
		MCC_3D_radius = MCC_3D_radius max ((vectorMagnitude [_rel select 0, _rel select 1, 0]) + ((boundingBoxReal _o) select 2));
	} forEach MCC_3D_previewParts;
	MCC_3D_msg = "";
	[] call MCC_3D_panel;
};

MCC_3D_quad = {
	params ["_bb", "_cx", "_cy", "_d", ["_m", 0.3]];
	private _a = _bb select 0;
	private _b = _bb select 1;
	[[(_a select 0) - _m, (_a select 1) - _m], [(_b select 0) + _m, (_a select 1) - _m], [(_b select 0) + _m, (_b select 1) + _m], [(_a select 0) - _m, (_b select 1) + _m]] apply {
		[_cx + ((_x select 0) * cos _d) + ((_x select 1) * sin _d), _cy - ((_x select 0) * sin _d) + ((_x select 1) * cos _d)]
	}
};

MCC_3D_overlap = {
	params ["_qa", "_qb"];
	private _sep = false;
	{
		private _q = _x;
		for "_i" from 0 to 1 do {
			private _p1 = _q select _i;
			private _p2 = _q select (_i + 1);
			private _ax = (_p1 select 1) - (_p2 select 1);
			private _ay = (_p2 select 0) - (_p1 select 0);
			private _pa = _qa apply {((_x select 0) * _ax) + ((_x select 1) * _ay)};
			private _pb = _qb apply {((_x select 0) * _ax) + ((_x select 1) * _ay)};
			if (((selectMax _pa) < (selectMin _pb)) || {(selectMax _pb) < (selectMin _pa)}) exitWith {_sep = true};
		};
		if (_sep) exitWith {};
	} forEach [_qa, _qb];
	!_sep
};

MCC_3D_cargoApplies = {
	!isNil "MCC_3D_cargo" && {!isNil "MCC_3D_cargoClass"} && {MCC_3D_cargoClass == (missionNamespace getVariable ["mcc_spawnname", ""])} && {MCC_3D_cargoClass == MCC_preview3DClass}
};

MCC_3D_cargoCount = {
	private _n = 0;
	{_n = _n + ((_x param [1, []]) call {private _s = 0; {_s = _s + _x} forEach _this; _s})} forEach MCC_3D_cargo;
	_n
};

MCC_3D_cargoInit = {
	params [["_init", "", [""]]];
	if !([] call MCC_3D_cargoApplies) exitWith {_init};
	if ("MCC_fnc_boxGenerator" in _init) exitWith {_init};
	private _c = MCC_3D_cargo;
	_init + format [";if (isServer) then {clearMagazineCargoGlobal _this; clearWeaponCargoGlobal _this; clearItemCargoGlobal _this; clearBackpackCargoGlobal _this; [_this, %1, %2, %3, %4] remoteExec ['MCC_fnc_boxGenerator', _this, false];};", _c select 0, _c select 1, _c select 2, _c select 3]
};

MCC_3D_cargoToPreview = {
	if !([] call MCC_3D_cargoApplies) exitWith {};
	if (count MCC_3D_previewParts == 0) exitWith {};
	private _o = (MCC_3D_previewParts select 0) select 0;
	clearWeaponCargo _o;
	clearMagazineCargo _o;
	clearItemCargo _o;
	clearBackpackCargo _o;
	MCC_3D_cargo params ["_w", "_m", "_i", "_b"];
	{_o addWeaponCargo [_x, (_w select 1) select _forEachIndex]} forEach (_w select 0);
	{_o addMagazineCargo [_x, (_m select 1) select _forEachIndex]} forEach (_m select 0);
	{_o addItemCargo [_x, (_i select 1) select _forEachIndex]} forEach (_i select 0);
	{_o addBackpackCargo [_x, (_b select 1) select _forEachIndex]} forEach (_b select 0);
};

MCC_3D_panel = {
	disableSerialization;
	private _d = uiNamespace getVariable ["MCC_3DPanel", displayNull];
	if (isNull _d) exitWith {};
	private _key = {format ["<t color='#E8EEF3' font='RobotoCondensedBold'>%1</t>  <t color='#A9BCCB'>%2</t><br/>", _this select 0, _this select 1]};
	private _t = "<t font='RobotoCondensedBold' size='1.15' color='#FFFFFF'>3D EDITOR</t><br/>";
	_t = _t + format ["<t color='#A9BCCB'>Object: </t><t color='#FFFFFF'>%1</t><br/>", [MCC_3D_previewName, "none - press X"] select (MCC_3D_previewName == "")];
	_t = _t + format ["<t color='#A9BCCB'>Rotation: </t>%1°    <t color='#A9BCCB'>Height: </t>%2 m<br/>", round MCC_3D_dir, (round (z3DHight * 10)) / 10];
	_t = _t + format ["<t color='#A9BCCB'>Align to terrain: </t>%1<br/>", ["<t color='#FF7A68'>Off</t>", "<t color='#7FF0B4'>On</t>"] select MCC_align3D];
	_t = _t + format ["<t color='#A9BCCB'>Behaviour: </t>%1    <t color='#A9BCCB'>Commandable: </t>%2<br/>",
		["Hold position", "None (Arma default)", "BIS Defence", "BIS Patrol"] param [(["hold", "bis", "bisd", "bisp"] find (missionNamespace getVariable ["MCC_3D_beh", "hold"])) max 0, "Hold position"],
		["No", "Yes"] select (missionNamespace getVariable ["MCC_3D_cmd", false])];
	if ([] call MCC_3D_cargoApplies) then {_t = _t + format ["<t color='#A9BCCB'>Cargo: </t>custom (%1 items)<br/>", [] call MCC_3D_cargoCount]};
	_t = _t + "<br/>";
	{_t = _t + (_x call _key)} forEach [
		["X", "Menu - choose an object"], ["Space", "Place"], ["Right-click", "Release the object"],
		["Ctrl+X", "Undo last"], ["Wheel", "Rotate (Shift: 15°)"], ["Ctrl+Wheel", "Height (Shift: 1 m)"],
		["T", "Align to terrain"], ["Delete", "Delete the highlighted object"],
		["Shift+Delete", "Delete a whole composition (press twice)"], ["Ctrl+Z", "Undo last delete"]
	];
	_t = _t + "<br/>";
	{_t = _t + (_x call _key)} forEach [
		["M", "Map - click to move the camera"], ["Hold Alt", "Minimap - double-click to move"],
		["N", "Vision mode"], ["H", "Hide panel"], ["Tab / Esc", "Close"]
	];
	if (MCC_3D_msg != "") then {_t = _t + format ["<br/><t color='#F2B544'>%1</t>", MCC_3D_msg]};
	(_d displayCtrl 1) ctrlSetStructuredText parseText _t;
};

MCC_3D_update = {
	if (isNil "MCC_3D_CAM" || {isNil "MCC_dummyObject"} || {isNull MCC_dummyObject}) exitWith {};
	if (MCC_3Dterminate || MCC_3DterminateNoMCC || !alive player) exitWith {[!MCC_3DterminateNoMCC] call MCC_3D_cleanup};
	private _p = getPosATL MCC_dummyObject;
	private _c = [_p select 0, _p select 1, z3DHight];
	if (MCC_3D_park select 2) then {
		if (time > (MCC_3D_park select 1) || {(_c distance2D (MCC_3D_park select 0)) > 8}) then {MCC_3D_park set [2, false]};
	};
	private _hit = objNull;
	MCC_3D_ghostQuads = [];
	if (count MCC_3D_previewParts > 0) then {
		private _a0 = MCC_3D_dir;
		{
			_x params ["_o", "_rel", "_azi", "_tilt", ["_bb", []]];
			if (count _bb >= 2) then {
				private _rx = ((cos _a0) * (_rel select 0)) + ((sin _a0) * (_rel select 1));
				private _ry = ((cos _a0) * (_rel select 1)) - ((sin _a0) * (_rel select 0));
				MCC_3D_ghostQuads pushBack ([_bb, (_c select 0) + _rx, (_c select 1) + _ry, _a0 + _azi] call MCC_3D_quad);
			};
		} forEach MCC_3D_previewParts;
		private _skip = MCC_3D_previewParts apply {_x select 0};
		private _list = (nearestObjects [_c, ["LandVehicle", "Air", "Ship", "StaticWeapon", "ThingX", "ReammoBox_F"], MCC_3D_radius + 30]) select {
			!(_x in _skip) && {(_x distance2D _c) < (MCC_3D_radius + ((boundingBoxReal _x) select 2))}
		};
		{
			private _obj = _x;
			private _bbo = boundingBoxReal _obj;
			private _qo = [_bbo, 0, 0, 0, 0] call MCC_3D_quad;
			_qo = _qo apply {private _w = _obj modelToWorld [_x select 0, _x select 1, 0]; [_w select 0, _w select 1]};
			if ((MCC_3D_ghostQuads findIf {[_x, _qo] call MCC_3D_overlap}) >= 0) exitWith {_hit = _obj};
		} forEach _list;
	};
	if !(_hit isEqualTo MCC_3D_blocked) then {
		MCC_3D_blocked = _hit;
		if (isNull _hit) then {
			if ((MCC_3D_msg select [0, 9]) == "Too close") then {MCC_3D_msg = ""};
		} else {
			private _n = getText (configOf _hit >> "displayName");
			if (_n == "") then {_n = typeOf _hit};
			MCC_3D_msg = format ["Too close to %1 - move away to place", _n];
		};
		[] call MCC_3D_panel;
	};
	MCC_3D_ghost = _c;
	private _parked = (MCC_3D_park select 2) || {!isNull _hit};
	private _a = MCC_3D_dir;
	{
		_x params ["_o", "_rel", "_azi", "_tilt"];
		if (_parked) then {
			_o setPosASL [0, 0, 1000];
		} else {
			private _rx = ((cos _a) * (_rel select 0)) + ((sin _a) * (_rel select 1));
			private _ry = ((cos _a) * (_rel select 1)) - ((sin _a) * (_rel select 0));
			private _pp = [(_c select 0) + _rx, (_c select 1) + _ry, (_c select 2) + (_rel select 2)];
			_o setPosATL _pp;
			_o setDir (_a + _azi);
			if (MCC_align3D || _tilt) then {_o setVectorUp (surfaceNormal _pp)} else {_o setVectorUp [0, 0, 1]};
		};
	} forEach MCC_3D_previewParts;
	private _hov = objNull;
	if (count MCC_3D_previewParts == 0) then {
		private _from = AGLToASL (positionCameraToWorld [0, 0, 0]);
		private _to = AGLToASL (positionCameraToWorld [0, 0, 1500]);
		{
			private _o = _x select 2;
			if (!isNull (_x select 3)) then {_o = _x select 3};
			if ([_o] call MCC_3D_deletable) exitWith {_hov = _o};
		} forEach (lineIntersectsSurfaces [_from, _to, MCC_dummyObject, objNull, true, 8, "VIEW", "GEOM"]);
		if (isNull _hov) then {
			private _near = (nearestObjects [_c, [], 2.5]) select {[_x] call MCC_3D_deletable};
			if (count _near > 0) then {_hov = _near select 0};
		};
	};
	if !(_hov isEqualTo MCC_3D_hover) then {
		MCC_3D_hover = _hov;
		if (!isNull _hov) then {
			private _n = getText (configOf _hov >> "displayName");
			if (_n == "") then {_n = typeOf _hov};
			MCC_3D_msg = format ["%1 - press Delete to remove it%2", _n, ["", " (Shift+Delete: whole composition)"] select (count ([_hov] call MCC_3D_groupOf) > 1)];
		} else {
			if (((MCC_3D_msg find " - press Delete to remove it") > 0)) then {MCC_3D_msg = ""};
		};
		[] call MCC_3D_panel;
	};
	"MCC_3DeditorMarker" setMarkerPosLocal [(getPosATL MCC_3D_CAM) select 0, (getPosATL MCC_3D_CAM) select 1];
	"MCC_3DeditorMarker" setMarkerDirLocal (getDir MCC_3D_CAM);
};

MCC_3D_onMouse = {
	if (isNil "MCC_3D_CAM" || {isNil "MCC_dummyObject"}) exitWith {};
	disableSerialization;
	MCC_3D_CAM camSetTarget MCC_dummyObject;
	MCC_3D_CAM camCommit 0;
	private _compass = uiNamespace getVariable ["MCC_compass", displayNull];
	if (isNull _compass) exitWith {};
	private _camPos = positionCameraToWorld [0, 0, 7];
	private _root = if (isClass (missionConfigFile >> "RscTitles" >> "MCC_compass")) then {missionConfigFile} else {configFile};
	for "_i" from 10 to 21 do {
		private _ctrl = _compass displayCtrl _i;
		private _offset = getArray (_root >> "RscTitles" >> "MCC_compass" >> "controls" >> (ctrlClassName _ctrl) >> "offSet");
		if (count _offset == 3) then {
			_ctrl ctrlSetPosition (worldToScreen (_camPos vectorAdd _offset));
			_ctrl ctrlCommit 0;
		};
	};
	private _menu = uiNamespace getVariable ["MCC3D_Dialog", displayNull];
	if (!isNull _menu) then {
		private _s = ctrlMapScale (_menu displayCtrl 0);
		if (_s > 0) then {uiNamespace setVariable ["MCC3D_DialogMapScale", _s]};
	};
	(_compass displayCtrl 5) ctrlMapAnimAdd [0, uiNamespace getVariable ["MCC3D_DialogMapScale", 0.15], getPosATL MCC_3D_CAM];
	ctrlMapAnimCommit (_compass displayCtrl 5);
};

MCC_3D_place = {
	if (isNil "MCC_dummyObject" || {isNull MCC_dummyObject}) exitWith {};
	if (count MCC_3D_previewParts == 0) exitWith {MCC_3D_msg = "Press X and choose an object first"; [] call MCC_3D_panel};
	if (MCC_3D_park select 2) exitWith {};
	if (!isNull MCC_3D_blocked) exitWith {};
	private _p = getPosATL MCC_dummyObject;
	private _objectPos = [_p select 0, _p select 1, z3DHight];
	MCC3DValue = [_objectPos, MCC_3D_dir, MCC_align3D];
	MCC3DgotValue = true;
	if (MCC_3D_physics) then {MCC_3D_park = [_objectPos, time + 2, true]};
	MCC_3D_msg = format ["Placed: %1", MCC_3D_previewName];
	[] call MCC_3D_panel;
};

MCC_3D_findEntry = {
	params ["_obj"];
	MCC_lastSpawn findIf {
		if (_x isEqualType []) then {((_x select 0) isEqualTo _obj) || {_obj in ((_x param [1, []]) select {_x isEqualType objNull})}} else {_x isEqualTo _obj}
	}
};

MCC_3D_groupOf = {
	params ["_obj"];
	private _i = [_obj] call MCC_3D_findEntry;
	if (_i < 0) exitWith {[_obj]};
	private _e = MCC_lastSpawn select _i;
	if !(_e isEqualType []) exitWith {[_obj]};
	if (count _e != 2) exitWith {[_obj]};
	([_e select 0] + ((_e select 1) select {_x isEqualType objNull})) select {!isNull _x}
};

MCC_3D_record = {
	params ["_o"];
	private _aiCrew = (crew _o) select {!isPlayer _x && {!(_x isEqualTo _o)}};
	[typeOf _o, getPosASL _o, vectorDir _o, vectorUp _o, _o isKindOf "CAManBase", str (side group _o), (count _aiCrew) > 0]
};

MCC_3D_remember = {
	params ["_objs", "_kind"];
	private _recs = (_objs select {!isNull _x && {!isPlayer _x}}) apply {[_x] call MCC_3D_record};
	if (count _recs == 0) exitWith {};
	MCC_3D_undoStack pushBack [_recs, _kind];
	if (count MCC_3D_undoStack > 20) then {MCC_3D_undoStack deleteAt 0};
};

MCC_3D_undoDelete = {
	if (count MCC_3D_undoStack == 0) exitWith {MCC_3D_msg = "Nothing deleted to restore"; [] call MCC_3D_panel};
	private _last = MCC_3D_undoStack deleteAt ((count MCC_3D_undoStack) - 1);
	_last remoteExec ["MCC_fnc_restore3D", 2, false];
	MCC_3D_msg = format ["Restored %1 object(s)", count (_last select 0)];
	[] call MCC_3D_panel;
};

MCC_3D_deleteObject = {
	params ["_obj", ["_single", false]];
	if (isNull _obj) exitWith {};
	private _index = [_obj] call MCC_3D_findEntry;
	if (_index < 0) exitWith {
		[[_obj], ["single", "veh"] select ((((crew _obj) select {!isPlayer _x && {!(_x isEqualTo _obj)}}) isNotEqualTo []))] call MCC_3D_remember;
		{deleteVehicle _x} forEach ((crew _obj) select {!isPlayer _x});
		deleteVehicle _obj;
	};
	private _e = MCC_lastSpawn select _index;
	if (_single && {_e isEqualType []} && {count _e == 2}) exitWith {
		private _parts = ([_e select 0] + ((_e select 1) select {_x isEqualType objNull})) select {!isNull _x && {!(_x isEqualTo _obj)}};
		[[_obj], "single"] call MCC_3D_remember;
		deleteVehicle _obj;
		if (count _parts == 0) then {
			MCC_lastSpawn set [_index, -1];
			MCC_lastSpawn = MCC_lastSpawn - [-1];
		} else {
			MCC_lastSpawn set [_index, [_parts select 0, _parts select [1, (count _parts) - 1]]];
		};
		publicVariable "MCC_lastSpawn";
	};
	if (_e isEqualType []) then {
		if (count _e == 2) then {
			[[_e select 0] + ((_e select 1) select {_x isEqualType objNull}), "comp"] call MCC_3D_remember;
		} else {
			[[_e select 0], "veh"] call MCC_3D_remember;
		};
		deleteVehicle (_e select 0);
		{deleteVehicle _x} forEach ((_e param [1, []]) select {_x isEqualType objNull});
	} else {
		[[_e], "single"] call MCC_3D_remember;
		deleteVehicle _e;
	};
	if (!isNil "mcc_safe") then {
		mcc_safe = mcc_safe + format ["MCC_lastSpawn set [%1, -1]; MCC_lastSpawn = MCC_lastSpawn - [-1]; publicVariable 'MCC_lastSpawn';", _index];
	};
	MCC_lastSpawn set [_index, -1];
	MCC_lastSpawn = MCC_lastSpawn - [-1];
	publicVariable "MCC_lastSpawn";
};

MCC_3D_deletable = {
	params ["_o"];
	!isNull _o && {getObjectType _o == 8} && {!(_o in (MCC_3D_previewParts apply {_x select 0}))} && {!(_o isEqualTo MCC_dummyObject)}
	&& {!isPlayer _o} && {!(_o isEqualTo player)} && {!(_o isKindOf "Logic")} && {!(_o isKindOf "Animal")}
	&& {!((toLower getText (configOf _o >> "simulation")) in ["animal", "butterfly", "seagull", "dragonfly", "fish", "snake", "insect", "fireflies"])}
};

MCC_3D_delete = {
	params [["_shift", false]];
	if (isNil "MCC_dummyObject" || {isNull MCC_dummyObject}) exitWith {};
	if (!isNull MCC_3D_hover && {!_shift || {count ([MCC_3D_hover] call MCC_3D_groupOf) < 2}}) exitWith {
		private _h = MCC_3D_hover;
		private _hn = getText (configOf _h >> "displayName");
		if (_hn == "") then {_hn = typeOf _h};
		[_h, true] call MCC_3D_deleteObject;
		MCC_3D_hover = objNull;
		MCC_3D_delTarget = objNull;
		MCC_3D_delObjs = [];
		MCC_3D_msg = format ["Deleted %1", _hn];
		[] call MCC_3D_panel;
	};
	private _skip = (MCC_3D_previewParts apply {_x select 0}) + [MCC_dummyObject, player];
	private _near = (nearestObjects [getPosATL MCC_dummyObject, [], 6]) select {
		(getObjectType _x == 8) && {!(_x in _skip)} && {!isPlayer _x} && {!(_x isKindOf "Logic")}
		&& {!(_x isKindOf "Animal")}
		&& {!((toLower getText (configOf _x >> "simulation")) in ["animal", "butterfly", "seagull", "dragonfly", "fish", "snake", "insect", "fireflies"])}
	};
	if (_shift && {!isNull MCC_3D_hover}) then {_near = [MCC_3D_hover] + (_near - [MCC_3D_hover])};
	if (count _near == 0) exitWith {
		MCC_3D_delTarget = objNull;
		MCC_3D_delObjs = [];
		MCC_3D_msg = "Nothing to delete near the cursor";
		[] call MCC_3D_panel;
	};
	private _t = _near select 0;
	private _group = [_t] call MCC_3D_groupOf;
	private _isComp = count _group > 1;
	private _whole = _isComp && {_shift};
	if ((_t isEqualTo MCC_3D_delTarget) && {MCC_3D_delSingle isEqualTo _shift} && {time < MCC_3D_delTime + 4}) exitWith {
		[_t, !_whole] call MCC_3D_deleteObject;
		MCC_3D_delTarget = objNull;
		MCC_3D_delObjs = [];
		MCC_3D_msg = ["Deleted", format ["Deleted the composition (%1 objects)", count _group]] select _whole;
		[] call MCC_3D_panel;
	};
	MCC_3D_delTarget = _t;
	MCC_3D_delSingle = _shift;
	MCC_3D_delTime = time;
	MCC_3D_delObjs = [[_t], _group] select _whole;
	private _n = getText (configOf _t >> "displayName");
	if (_n == "") then {_n = typeOf _t};
	MCC_3D_msg = switch (true) do {
		case (_whole): {format ["Press Shift+Delete again to remove the whole composition (%1 objects)", count _group]};
		case (_isComp): {format ["Press Delete again to remove only the %1", _n]};
		default {format ["Press %1 again to remove %2", ["Delete", "Shift+Delete"] select _shift, _n]};
	};
	[] call MCC_3D_panel;
};

MCC_3D_draw = {
	if (!isNull MCC_3D_blocked && {MCC_3D_GUI}) then {
		{
			private _q = _x;
			for "_i" from 0 to 3 do {
				private _p1 = +(_q select _i);
				private _p2 = +(_q select ((_i + 1) mod 4));
				_p1 pushBack (((getTerrainHeightASL _p1) max 0) + 0.15);
				_p2 pushBack (((getTerrainHeightASL _p2) max 0) + 0.15);
				drawLine3D [ASLToAGL _p1, ASLToAGL _p2, [1, 0, 0, 1]];
			};
		} forEach MCC_3D_ghostQuads;
	};
	private _boxes = if (isNull MCC_3D_delTarget || {time > MCC_3D_delTime + 4}) then {[]} else {+MCC_3D_delObjs};
	if (!isNull MCC_3D_hover && {!(MCC_3D_hover in _boxes)}) then {_boxes pushBack MCC_3D_hover};
	{
	private _t = _x;
	if (isNull _t) then {continue};
	private _bb = boundingBoxReal _t;
	private _a = _bb select 0;
	private _b = _bb select 1;
	private _pts = [
		[_a select 0, _a select 1, _a select 2], [_b select 0, _a select 1, _a select 2], [_b select 0, _b select 1, _a select 2], [_a select 0, _b select 1, _a select 2],
		[_a select 0, _a select 1, _b select 2], [_b select 0, _a select 1, _b select 2], [_b select 0, _b select 1, _b select 2], [_a select 0, _b select 1, _b select 2]
	] apply {_t modelToWorldVisual _x};
	{
		drawLine3D [_pts select (_x select 0), _pts select (_x select 1), [1, 0, 0, 1]];
	} forEach [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]];
	} forEach _boxes;
};

MCC_3D_vision = {
	MCC_3D_nvg = (MCC_3D_nvg + 1) mod 5;
	playSound "nvSound";
	switch (MCC_3D_nvg) do {
		case 0: {camUseNVG false; true setCamUseTI 0};
		case 1: {true setCamUseTI 1};
		case 2: {true setCamUseTI 7};
		case 3: {false setCamUseTI 0; camUseNVG true};
		default {false setCamUseTI 0; camUseNVG false};
	};
	MCC_3D_msg = ["White hot", "Black hot", "Thermal", "Night vision", "Normal vision"] select MCC_3D_nvg;
	[] call MCC_3D_panel;
};

MCC_3D_toggleGUI = {
	MCC_3D_GUI = !MCC_3D_GUI;
	if (!isNil "MCC_dummyObject") then {MCC_dummyObject hideObject !MCC_3D_GUI};
	if (MCC_3D_GUI) then {
		(["MCC_compass"] call BIS_fnc_rscLayer) cutRsc ["MCC_compass", "PLAIN"];
		((uiNamespace getVariable ["MCC_compass", displayNull]) displayCtrl 5) ctrlAddEventHandler ["Draw", "_this call MCC_fnc_trackUnits;"];
		(["MCC_3DPanel"] call BIS_fnc_rscLayer) cutRsc ["MCC_3DPanel", "PLAIN"];
		[] call MCC_3D_panel;
	} else {
		(["MCC_compass"] call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
		(["MCC_3DPanel"] call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
	};
};

MCC_3D_onKeyDown = {
	params ["_disp", "_key", "_shift", "_ctrl"];
	if (_key in [42, 54]) then {MCC_3D_shift = true};
	if (_key in [29, 157]) then {MCC_3D_ctrl = true};
	if (_key in [1, 15]) exitWith {MCC_3Dterminate = true; true};
	if (_key == 57) exitWith {[] call MCC_3D_place; true};
	if (_key == 45) exitWith {
		if (_ctrl) then {
			[1] execVM (MCC_path + "mcc\general_scripts\delete\undo.sqf");
		} else {
			if ((missionNamespace getVariable ["MCC_3dEditorAllowDialog", true]) && {!dialog}) then {createDialog ("MCC3D_Dialog" call MCC_fnc_dialogName)};
		};
		true
	};
	if (_key == 20) exitWith {MCC_align3D = !MCC_align3D; [] call MCC_3D_panel; true};
	if (_key == 44 && {_ctrl}) exitWith {[] call MCC_3D_undoDelete; true};
	if (_key == 50) exitWith {if (!dialog) then {createDialog "MCC_3DMapDialog"}; true};
	if (_key == 56) exitWith {if (!dialog) then {createDialog "MCC_3DMiniMapDialog"}; true};
	if (_key == 211) exitWith {[_shift || MCC_3D_shift] call MCC_3D_delete; true};
	if (_key == 35) exitWith {[] call MCC_3D_toggleGUI; true};
	if (_key in (actionKeys "NightVision")) exitWith {[] call MCC_3D_vision; true};
	false
};

MCC_3D_onKeyUp = {
	params ["_disp", "_key"];
	if (_key in [42, 54]) then {MCC_3D_shift = false};
	if (_key in [29, 157]) then {MCC_3D_ctrl = false};
	false
};

MCC_3D_onWheel = {
	params ["_disp", "_z"];
	if (_z == 0) exitWith {false};
	private _s = [-1, 1] select (_z > 0);
	if (MCC_3D_ctrl) then {
		z3DHight = ((z3DHight + (_s * ([0.1, 1] select MCC_3D_shift))) max 0) min 500;
	} else {
		MCC_3D_dir = (MCC_3D_dir + (_s * ([2, 15] select MCC_3D_shift)) + 360) mod 360;
	};
	[] call MCC_3D_panel;
	true
};

MCC_3D_moveTo = {
	params [["_p", [], [[]]]];
	if (count _p < 2 || {isNil "MCC_3D_CAM"} || {isNil "MCC_dummyObject"}) exitWith {};
	private _d = getDir MCC_3D_CAM;
	MCC_dummyObject setPosATL [_p select 0, _p select 1, 0];
	MCC_3D_CAM setPosATL [(_p select 0) - (25 * sin _d), (_p select 1) - (25 * cos _d), 15];
	MCC_3D_CAM camSetTarget MCC_dummyObject;
	MCC_3D_CAM camCommit 0;
};

MCC_3D_onMouseDown = {
	params ["_disp", "_button"];
	if (_button == 1) then {MCC_3D_rmbTime = diag_tickTime};
	false
};

MCC_3D_onMouseUp = {
	params ["_disp", "_button"];
	if (_button == 1 && {MCC_3D_rmbTime >= 0} && {(diag_tickTime - MCC_3D_rmbTime) < 0.3} && {count MCC_3D_previewParts > 0}) then {
		[] call MCC_3D_makePreview;
		MCC_3D_msg = "Object released";
		[] call MCC_3D_panel;
	};
	MCC_3D_rmbTime = -1;
	false
};

MCC_3D_cleanup = {
	params [["_reopen", true]];
	disableSerialization;
	private _d = findDisplay 46;
	{_d displayRemoveEventHandler [_x select 0, _x select 1]} forEach (missionNamespace getVariable ["MCC_3D_ehs", []]);
	{removeMissionEventHandler [_x select 0, _x select 1]} forEach (missionNamespace getVariable ["MCC_3D_mehs", []]);
	MCC_3D_ehs = [];
	MCC_3D_mehs = [];
	if (!isNil "MCC_3D_CAM") then {
		MCC_3D_CAM cameraEffect ["terminate", "back"];
		camDestroy MCC_3D_CAM;
		MCC_3D_CAM = nil;
	};
	camUseNVG false;
	false setCamUseTI 0;
	[] call MCC_3D_clearPreview;
	if (!isNil "MCC_dummyObject") then {deleteVehicle MCC_dummyObject; MCC_dummyObject = nil};
	(["MCC_compass"] call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
	(["MCC_3DPanel"] call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
	deleteMarkerLocal "MCC_3DeditorMarker";
	MCC_3D_delTarget = objNull;
	MCC3DRuning = false;
	MCC_mcc_screen = 2;
	hintSilent "";
	if (dialog) then {closeDialog 0};
	if (_reopen && {!MCC_3DterminateNoMCC}) then {[nil, nil, nil, nil, 0] execVM (MCC_path + "mcc\dialogs\mcc_PopupMenu.sqf")};
};

private _cam = "camconstruct" camCreate [_pos select 0, _pos select 1, ((getPosATL player) select 2) + 15];
_cam cameraEffect ["internal", "back"];
_cam camPrepareFOV 0.9;
_cam camPrepareFocus [-1, -1];
_cam camCommitPrepared 0;
cameraEffectEnableHUD true;
_cam setDir (getDir player);
[_cam, -30, 0] call BIS_fnc_setPitchBank;
_cam camCommitPrepared 0;
_cam camConstuctionSetParams [[_pos select 0, _pos select 1, 0], 200000, 500];
MCC_3D_CAM = _cam;
showCinemaBorder false;

MCC_dummyObject = "Sign_Sphere25cm_F" createVehicleLocal (screenToWorld [0.5, 0.5]);
MCC_dummyObject allowDamage false;
MCC_3D_CAM camSetTarget MCC_dummyObject;
MCC_3D_CAM camCommit 0;

createMarkerLocal ["MCC_3DeditorMarker", [(getPosATL MCC_3D_CAM) select 0, (getPosATL MCC_3D_CAM) select 1]];
"MCC_3DeditorMarker" setMarkerTypeLocal "loc_ViewTower";
"MCC_3DeditorMarker" setMarkerColorLocal "ColorBlue";

(["MCC_compass"] call BIS_fnc_rscLayer) cutRsc ["MCC_compass", "PLAIN"];
((uiNamespace getVariable ["MCC_compass", displayNull]) displayCtrl 5) ctrlAddEventHandler ["Draw", "_this call MCC_fnc_trackUnits;"];
(["MCC_3DPanel"] call BIS_fnc_rscLayer) cutRsc ["MCC_3DPanel", "PLAIN"];

if (MCC_3D_nvg == 3) then {camUseNVG true};

private _disp = findDisplay 46;
MCC_3D_ehs = [
	["KeyDown", _disp displayAddEventHandler ["KeyDown", {_this call MCC_3D_onKeyDown}]],
	["KeyUp", _disp displayAddEventHandler ["KeyUp", {_this call MCC_3D_onKeyUp}]],
	["MouseZChanged", _disp displayAddEventHandler ["MouseZChanged", {_this call MCC_3D_onWheel}]],
	["MouseButtonDown", _disp displayAddEventHandler ["MouseButtonDown", {_this call MCC_3D_onMouseDown}]],
	["MouseButtonUp", _disp displayAddEventHandler ["MouseButtonUp", {_this call MCC_3D_onMouseUp}]],
	["MouseMoving", _disp displayAddEventHandler ["MouseMoving", {_this call MCC_3D_onMouse}]],
	["MouseHolding", _disp displayAddEventHandler ["MouseHolding", {_this call MCC_3D_onMouse}]]
];
MCC_3D_mehs = [
	["EachFrame", addMissionEventHandler ["EachFrame", {call MCC_3D_update}]],
	["Draw3D", addMissionEventHandler ["Draw3D", {call MCC_3D_draw}]]
];

if (_class != "") then {[_class, "AMMO"] call MCC_3D_makePreview} else {[] call MCC_3D_panel};
