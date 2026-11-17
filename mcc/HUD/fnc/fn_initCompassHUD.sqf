/*=================================================================MCC_fnc_initCompassHUD================================================================================
  Init HUD Compass
  IN <>
    Nothing
*/

private _compassTeamMates = false;
if (!hasInterface || isDedicated) exitWith {};

waituntil {!(IsNull (findDisplay 46))};
sleep 1;
if (missionNamespace getVariable ["MCC_initCompassHUD",false]) exitWith {};
missionNamespace setVariable ["MCC_initCompassHUD",true];

if (isnull (uiNamespace getVariable ["MCC_hud",objNull])) then {
    (["MCC_hud"] call BIS_fnc_rscLayer) cutRsc ["MCC_hud", "PLAIN"];
};

_compassTeamMates = param [0,true,[true]];
uiNamespace setVariable ["MCC_HuD_compassTeamMates",_compassTeamMates];
uiNamespace setVariable ["MCC_hudHdg", nil];

private _d = uiNamespace getVariable "MCC_hud";
private _grp = _d displayCtrl 10;
private _w = 0.46;
private _h = 0.068;
_grp ctrlSetPosition [0.5 - _w / 2, safeZoneY + safeZoneH - _h - 0.001, _w, _h];
_grp ctrlCommit 0;

for "_k" from 0 to 26 do {
    private _c = _d ctrlCreate ["RscText", 2000 + _k, _grp];
    _c ctrlSetText "";
    _c ctrlShow false;
};
for "_k" from 0 to 8 do {
    private _c = _d ctrlCreate ["RscStructuredText", 2100 + _k, _grp];
    _c ctrlShow false;
};
private _ci = _d ctrlCreate ["RscText", 2200, _grp];
_ci ctrlSetText "";
_ci ctrlSetBackgroundColor [1, 1, 1, 1];
_ci ctrlSetPosition [(round ((_w / 2) / pixelW)) * pixelW - pixelW, 0.024, 2 * pixelW, 0.024];
_ci ctrlCommit 0;
private _rd = _d ctrlCreate ["RscStructuredText", 2201, _grp];
_rd ctrlSetPosition [_w / 2 - 0.04, 0.048, 0.08, 0.02];
_rd ctrlCommit 0;

MCC_fnc_compHudEVH = {
    private _d = uiNamespace getVariable ["MCC_hud", displayNull];
    if (isNull _d) exitWith {};
    private _w = 0.46;
    private _half = 60;
    private _sc = (_w / 2) / _half;
    private _cx = _w / 2;
    private _fade = {params ["_o"]; 1 - ((((abs _o) - 40) / 20) max 0)};

    private _c0 = positionCameraToWorld [0, 0, 0];
    private _cv = (positionCameraToWorld [0, 0, 10]) vectorDiff _c0;
    private _hr = ((_cv select 0) atan2 (_cv select 1) + 360) mod 360;
    private _prev = uiNamespace getVariable ["MCC_hudHdg", _hr];
    private _df = (((_hr - _prev) + 540) mod 360) - 180;
    private _hd = if (abs _df > 25) then {_hr} else {(_prev + _df * 0.45 + 360) mod 360};
    uiNamespace setVariable ["MCC_hudHdg", _hd];

    private _base = (floor (_hd / 5)) * 5;
    for "_k" from 0 to 26 do {
        private _a = _base + (_k - 13) * 5;
        private _off = (((_a - _hd) + 540) mod 360) - 180;
        private _c = _d displayCtrl (2000 + _k);
        if (abs _off > _half) then {_c ctrlShow false} else {
            private _am = (round _a + 720) mod 360;
            private _len = if (_am mod 45 == 0) then {0.016} else {if (_am mod 15 == 0) then {0.011} else {0.007}};
            private _lw = [1, 2] select (_am mod 90 == 0);
            private _x = (round ((_cx + _off * _sc) / pixelW)) * pixelW - (floor (_lw / 2)) * pixelW;
            _c ctrlSetPosition [_x, 0.028, _lw * pixelW, _len];
            _c ctrlSetBackgroundColor [1, 1, 1, 0.92 * ([_off] call _fade)];
            _c ctrlShow true;
            _c ctrlCommit 0;
        };
    };

    private _b15 = (floor (_hd / 15)) * 15;
    for "_k" from 0 to 8 do {
        private _a = _b15 + (_k - 4) * 15;
        private _off = (((_a - _hd) + 540) mod 360) - 180;
        private _c = _d displayCtrl (2100 + _k);
        if (abs _off > (_half - 4)) then {_c ctrlShow false} else {
            private _am = (round _a + 720) mod 360;
            private _card = _am mod 45 == 0;
            private _t = switch (_am) do {
                case 0: {"N"}; case 45: {"NE"}; case 90: {"E"}; case 135: {"SE"};
                case 180: {"S"}; case 225: {"SW"}; case 270: {"W"}; case 315: {"NW"};
                default {str _am};
            };
            _c ctrlSetStructuredText parseText format ["<t align='center' font='%1' size='%2' color='#ffffff' shadow='1'>%3</t>", ["RobotoCondensedLight", "RobotoCondensed"] select _card, [0.62, 0.72] select _card, _t];
            _c ctrlSetFade (1 - ([_off] call _fade));
            _c ctrlSetPosition [_cx + _off * _sc - 0.03, 0.002, 0.06, 0.026];
            _c ctrlShow true;
            _c ctrlCommit 0;
        };
    };
    private _rd = _d displayCtrl 2201;
    private _hs = str ((round _hd) mod 360);
    while {count _hs < 3} do {_hs = "0" + _hs};
    _rd ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensedLight' size='0.6' color='#ffffff' shadow='1'>%1</t>", _hs];

    private _wpPos = waypointPosition [group player, currentWaypoint group player];
    private _m = _d displayCtrl 14;
    if !(_wpPos isEqualTo [0, 0, 0]) then {
        private _off = ((((_c0 getDir _wpPos) - _hd) + 540) mod 360) - 180;
        _off = (_off max -_half) min _half;
        _m ctrlSetPosition [_cx + _off * _sc - 0.006, 0.048, 0.012, 0.016];
        _m ctrlShow true;
        _m ctrlCommit 0;
    } else {
        _m ctrlShow false;
    };

    private _used = [];
    if (uiNamespace getVariable ["MCC_HuD_compassTeamMates", true]) then {
        {
            if (_x != player && {alive _x}) then {
                private _idc = 1000 + _forEachIndex;
                private _c = _d displayCtrl _idc;
                if (isNull _c) then {_c = _d ctrlCreate ["RscPicture", _idc, _d displayCtrl 10]};
                _used pushBack _idc;
                private _icon = switch (true) do {
                    case (_x == leader player): {"iconManLeader"};
                    case (((getNumber (configFile >> "CfgVehicles" >> typeOf _x >> "attendant")) == 1) || {(toLower (_x getVariable ["CP_role", ""])) == "corpsman"}): {"iconManMedic"};
                    default {getText (configFile >> "CfgVehicles" >> typeOf _x >> "icon")};
                };
                private _col = switch (assignedTeam _x) do {
                    case "RED": {[0.9, 0.25, 0.25, 1]};
                    case "GREEN": {[0.3, 0.85, 0.3, 1]};
                    case "BLUE": {[0.35, 0.55, 1, 1]};
                    case "YELLOW": {[0.95, 0.85, 0.3, 1]};
                    default {[1, 1, 1, 1]};
                };
                private _off = ((((_c0 getDir _x) - _hd) + 540) mod 360) - 180;
                if (abs _off > _half) then {_c ctrlShow false} else {
                    private _s = ((1 - ((player distance _x) / 300 min 1)) * 0.016) max 0.009;
                    _c ctrlSetText (getText (configFile >> "CfgVehicleIcons" >> _icon));
                    _c ctrlSetTextColor [_col select 0, _col select 1, _col select 2, [_off] call _fade];
                    _c ctrlSetPosition [_cx + _off * _sc - _s / 2, 0.048, _s, _s * (4 / 3)];
                    _c ctrlShow true;
                    _c ctrlCommit 0;
                };
            };
        } forEach (units player);
    };
    {if !(_x in _used) then {ctrlDelete (_d displayCtrl _x)}} forEach (uiNamespace getVariable ["MCC_hud_compassUnits", []]);
    uiNamespace setVariable ["MCC_hud_compassUnits", _used];
};

["MCC_fnc_compHudEVH", "onEachFrame", "MCC_fnc_compHudEVH"] call BIS_fnc_addStackedEventHandler;
