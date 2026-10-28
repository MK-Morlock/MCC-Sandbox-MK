/*\
		Front Line Init
*/

_debugCtrl = ((uiNamespace getVariable "MCC_FLDialog") displayCtrl 0);

_debugCtrl ctrlSetStructuredText parseText format["<t size='1.2' color='#33CC00'>Hold left click and on the map and drag to set the frontline</t>"];
 playsound 'MCC_pop';

MCC_DrawLine = true;

waitUntil {!(missionNamespace getVariable ["MCC_DrawLine",false])};

_lineStart = missionNamespace getVariable ["MCC_pointA",[0,0,0]];
_lineEnd = missionNamespace getVariable ["MCC_pointB",[0,0,0]];

if (_lineStart distance2d _lineEnd < 100) exitWith {
	_debugCtrl ctrlSetStructuredText parseText format["<t size='1.2' color='#33CC00'>Line to short</t>"];
 	playsound 'MCC_pop';
};

_lineCenter = [_lineStart, (_lineStart distance2d _lineEnd)/2, ([_lineStart, _lineEnd] call BIS_fnc_dirTo)] call BIS_fnc_relPos;

{
	_marker = createMarkerLocal [str _x, _x];
    _marker setMarkerTextLocal "marker" + str _foreachindex;
    _marker setMarkerShapeLocal "ICON";
    _marker setMarkerTypeLocal  "mil_marker";
    _marker setMarkerColorLocal "ColorBlue";

    _marker spawn {
    	sleep 3;
    	deleteMarker _this;
    };
} forEach [_lineStart,_lineCenter, _lineEnd];

_debugCtrl ctrlSetStructuredText parseText format["<t size='1.2' color='#33CC00'>Left click on the map to set the direction of the frontline</t>"];
playsound 'MCC_pop';

MCC_mapClick = false;

onMapSingleClick "mcc_spawn_dir = _pos;
					MCC_mapClick = true;
					onMapSingleClick """";" ;

waitUntil {missionNamespace getVariable ["MCC_mapClick",false]};

_debugCtrl ctrlSetStructuredText parseText format["<t size='1.2' color='#33CC00'>Frontline is being generated...</t>"];
playsound 'MCC_pop';