private _hostage = objNull;
private _init = "";
#define	MCC_UNTIE_ICON "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa"

_hostage = _this;

removeallweapons _hostage;
dostop _hostage;
if (MCC_isACE) then {
	 [_hostage, true] call ACE_captives_fnc_setHandcuffed;
} else {
	_hostage allowFleeing 0;
	_hostage disableAI "MOVE";
	_hostage setVariable ["MCC_disarmed",true,true];
	removeallweapons _hostage;
	_hostage setcaptive true;
	_init = "_this switchmove 'Acts_ExecutionVictim_Loop';";
	["MCC_fnc_setVehicleInit", [[netID _hostage,_hostage], _init, false], 0, true] call MCC_fnc_secRemote;
	/*[_hostage, "Hold %1 to interact"] remoteExec ["MCC_fnc_createHelper", 2, false];*/
};

[
	_hostage,
	format ["Untie %1",name _hostage],
	MCC_UNTIE_ICON,
	MCC_UNTIE_ICON,
	"(alive _target) && (_target distance _this < 5) && !(_target getVariable ['MCC_hostageFreed',false])",
	"(alive _target) && (_target distance _this < 5)",
	{
		//Start action
		[name _target,"Oh thank you, Please hurry up!"] remoteExec ["BIS_fnc_showSubtitle", _caller];
	},
	{},
	{
		//Success
		if (MCC_isACE && {_target getVariable ["ace_captives_isHandcuffed", false]}) then {
			[_target, false] remoteExecCall ["ACE_captives_fnc_setHandcuffed", _target];
		};
		_null = [_target, player, 0,[0]] execVM format ["%1mcc\general_scripts\hostages\hostage.sqf",MCC_path];
		[name _target,"Thank you!"] remoteExec ["BIS_fnc_showSubtitle", _caller];
	},
	{
		//When stopped
		[name _target,"Why did you stopped?"] remoteExec ["BIS_fnc_showSubtitle", _caller];
	},
	[],
	3,
	0,
	true,
	false
] remoteExec ["bis_fnc_holdActionAdd", 0, _hostage];



