/*================================================================= MCC_fnc_addComponentsACE =================================================================
Builds the ACE "Components" child actions: one toggle per component returned by MCC_fnc_addComponentsACECondition.
Internal use only (ACE insertChildren: [_target, _player, _params])
==============================================================================================================================================================
*/
params [
	["_target", objNull, [objNull]],
	["_player", objNull, [objNull]],
	["_params", [], [[]]]
];

private _vehicle = vehicle _player;
private _children = [];

{
	private _source = configName _x;
	private _isOn = (_vehicle animationSourcePhase _source) > 0.5;
	_children pushBack [
		[
			format ["MCC_component_%1", _source],
			format ["%1 (%2)", getText (_x >> "displayName"), ["off", "on"] select _isOn],
			"",
			{
				params ["", "_player", "_args"];
				_args params ["_source"];
				private _veh = vehicle _player;
				_veh animateSource [_source, [1, 0] select ((_veh animationSourcePhase _source) > 0.5)];
			},
			{true},
			{},
			[_source]
		] call ace_interact_menu_fnc_createAction,
		[],
		_vehicle
	];
} forEach ([_vehicle] call MCC_fnc_addComponentsACECondition);

_children
