params [["_ship", objNull, [objNull]]];
if (isNull _ship) exitWith {};
[_ship] spawn {
	params ["_ship"];
	sleep 3;
	{
		if (isNil {_x getVariable "MCCMK_hullEH"}) then {
			_x setVariable ["MCCMK_hullShip", _ship];
			_x setVariable ["MCCMK_hullEH", _x addEventHandler ["HitPart", {
				private _h = _this select 0;
				_h params ["_part", "_shooter", "_proj", "", "", "", "_ammo"];
				if !(local _shooter || {isNull _shooter && {isServer}}) exitWith {};
				_ammo params [["_hit", 0], ["_ind", 0], "", ["_expl", 0]];
				if (_expl <= 0 && {_hit < 100}) exitWith {};
				[_part getVariable ["MCCMK_hullShip", objNull], _hit + _ind, side group _shooter] remoteExec ["MCCMK_fnc_hullDamage", 2];
			}]];
		};
	} forEach ([_ship] call MCCMK_fnc_hullParts);
};
