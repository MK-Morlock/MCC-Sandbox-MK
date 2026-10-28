//=================================================================MCC_fnc_baseBuildBorders==============================================================================
//	Build visuals borders
//  Parameter(s):
//     _center: POSITION
//     _size: INTEGER
//======================================================================================================================================================================
#define	MCC_RTS_BORDER_MARKERS_ITEM "Sign_Sphere200cm_F"

private "_oldBorder";
private _border = [];
private _width = 0;
private _pi = 0;
private "_perimeter";
private "_wallcount";
private "_total";
private _centerObj = objNull;
private "_dir";
private "_xpos";
private "_ypos";
private "_zpos";
private _a = objNull;
disableSerialization;

params ["_center", "_size"];

if (typeName _center != typeName []) then {getpos _center};

_oldBorder = missionnamespace getvariable "MCC_CON_border";
if (!isnil "_oldBorder") then
{
	{deletevehicle _x} foreach _oldBorder;
};

missionnamespace setvariable ["MCC_CON_border",nil];

_border = [];

_width = 30;

_pi = 3.14159265358979323846;
_perimeter = (_size * _pi);
_perimeter = _perimeter + _width - (_perimeter % _width);
_size = (_perimeter / _pi);
_wallcount = _perimeter / _width * 2;
_total = _wallcount;

_centerObj = MCC_RTS_BORDER_MARKERS_ITEM createvehiclelocal _center;
_centerObj setpos _center;
_centerObj hideObject true;
_border = _border + [_centerObj];

for "_i" from 1 to _total do
{
	_dir = (360 / _total) * _i;
	_xpos = (_center select 0) + (sin _dir * _size);
	_ypos = (_center select 1) + (cos _dir * _size);
	_zpos = (_center select 2);

	_a = MCC_RTS_BORDER_MARKERS_ITEM createvehiclelocal [_xpos,_ypos,_zpos];
	_a setpos [_xpos,_ypos,0];
	_a setdir (_dir + 90);
	_a enableSimulation false;
	_a setObjectTexture [0, "#(argb,8,8,3)color(1,0,0,0.3,ca)"];
	_border = _border + [_a];
};

missionnamespace setvariable ["MCC_CON_border",_border];