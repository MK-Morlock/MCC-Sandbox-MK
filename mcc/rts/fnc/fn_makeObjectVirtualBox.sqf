//=================================================================MCC_fnc_makeObjectVirtualBox==================================================================================
//  Make an object to act as a virtuall shared box for the given side - run where the box is local
// example [west, _object] call MCC_fnc_makeObjectVirtualBox
//  Parameter(s):
//     0: _side - SIDE side for whom the object will serve as a shared box
//     1: _object - OBJECT vehicle that will serve as the actuall box
//==============================================================================================================================================================================
private "_side";
private _boxName = "";
private "_box";
private _boxArray = [];
private _object = objNull;
_side = _this param [0, west];
_object = _this param [1, objNull, [objNull]];

if (isNull _object) exitWith {};

_boxName = format ["MCC_rtsMainBox%1",_side];
_box = missionNamespace getVariable [_boxName,objNull];

//Get the box gear
if !(isNull _box) then {
    _boxArray = _box getvariable ["MCC_virtual_cargo",[[],[],[],[]]];
} else {
    _boxArray = [[],[],[],[]];
};

clearItemCargoGlobal _object;
clearMagazineCargoGlobal _object;
clearWeaponCargoGlobal _object;
clearBackpackCargoGlobal _object;
_object setVariable ["MCC_virtual_cargo",_boxArray,true];
// The vault opened at this object is the side's shared virtual box (see MCC_fnc_mainBoxInit), not this object's real
// cargo. Without this, items sold to the vault went into the objects real cargo and could be taken back for free
// through the normal inventory, farming valor points.
_object setVariable ["MCC_virtualBoxSide",_side,true];
[_object,"Hold %1 to open"] remoteExec ["MCC_fnc_createHelper", 2, false];