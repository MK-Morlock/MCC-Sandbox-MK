//==================================================================MCC_fnc_canAttachPod=========================================================================================
// Can we attach pod to this helicopter
// Example:[_object]  call MCC_fnc_canAttachPod;
// <IN>
//	_target:					Object- object.
//
// <OUT>
//		Boolean
//===========================================================================================================================================================================
private _player = _this param [0, objNull, [objNull]];
private _vehiclePlayer = vehicle _player;
private _attachedCargo = (ropeAttachedObjects _vehiclePlayer) select 0;
private _return = if ((_vehiclePlayer isKindOf "O_Heli_Transport_04_F") && (_player == Driver _vehiclePlayer)&& isnull(_vehiclePlayer getVariable ["MCC_attachedPod",objnull]) && (!isnil "_attachedCargo")) then {
				if (_attachedCargo isKindOf "Pod_Heli_Transport_04_base_F") then {true} else {false};
			} else {false};

_return