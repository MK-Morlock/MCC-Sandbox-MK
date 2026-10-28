//==================================================================MCC_fnc_PDAcreatemarker===============================================================================================
// Example:[_question, _header , _variable] call MCC_fnc_PDAcreatemarker;
//==================================================================================================================================================================================
#define MCC_HELPER "UserTexture1m_F"

private "_mark";
private _helpersArray = [];
private _helper = objNull;
params ["_markerName", "_path", "_pos", "_type", "_text", "_time", "_color"];


_mark = createmarkerlocal [_markerName,_pos];
_markerName setmarkertypelocal format ["%1%2", _path, _type];
_markerName setmarkerTextlocal _text;
_markerName setmarkercolorlocal _color;

_helper = MCC_HELPER createVehicle _pos;
_helper setpos _pos;
_helper setVariable ["icon",format ["%1%2", _path, _type]];

_helpersArray = missionNamespace getVariable ["MCC_knownTargetsTags",[]];
_helpersArray pushBack _helper;
missionNamespace setVariable ["MCC_knownTargetsTags",_helpersArray];


[_markerName, _helper] spawn {
	private "_helper";
	private _helpersArray = [];
	sleep 120;
		//deleteMarker
		deletemarkerlocal (_this select 0);

		//deleteHelper
		_helper = (_this select 1);
		deleteVehicle _helper;
		_helpersArray = missionNamespace getVariable ["MCC_knownTargetsTags",[]];

		for "_i" from 0 to (count _helpersArray)-1 step 1 do {
			if (isNull (_helpersArray select _i)) then {
				_helpersArray set [_i,-1];
			};
		};

		_helpersArray = _helpersArray - [-1];
		missionNamespace setVariable ["MCC_knownTargetsTags",_helpersArray];
};