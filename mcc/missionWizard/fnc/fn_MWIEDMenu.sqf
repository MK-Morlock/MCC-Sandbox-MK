#define MCC_CHARGE "DemoCharge_Remote_Mag"

params [["_ied", objNull, [objNull]], ["_choice", "", [""]]];
if (isNull _ied || {!hasInterface}) exitWith {};

switch (_choice) do {

	case "manual": {
		if !(_ied getVariable ["armed", false]) exitWith {};
		[_ied, true] spawn MCC_fnc_bdStart;
	};

	case "safe": {
		if !(_ied getVariable ["armed", false]) exitWith {};
		private _fake = _ied getVariable ["fakeIed", objNull];
		if (isNull _fake) exitWith {};
		private _key = (actionKeysNames ["Action", 1]) splitString """" joinString "";
		if (_key == "") then {_key = "the action key"};
		if ((player getVariable ["MCC_MWIEDSafeTarget", objNull]) isEqualTo _fake) exitWith {hint format ["Hold %1 at the IED to disarm it", _key]};
		player setVariable ["MCC_MWIEDSafeTarget", _fake];
		[
			_fake,
			"Disarm IED",
			"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa",
			"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa",
			"(alive _target) && {(_this distance _target) < 4} && {((_target getVariable ['realIed', objNull]) getVariable ['armed', false])}",
			"(alive _target) && {(_this distance _target) < 4}",
			{},
			{},
			{
				params ["_target", "_caller"];
				player setVariable ["MCC_MWIEDSafeTarget", objNull];
				private _real = _target getVariable ["realIed", objNull];
				if (!isNull _real && {_real getVariable ["armed", false]}) then {
					_real setVariable ["armed", false, true];
					hint "IED disarmed";
				};
			},
			{},
			[],
			10,
			10,
			true,
			false
		] call BIS_fnc_holdActionAdd;
		hint format ["Hold %1 at the IED to disarm it", _key];
	};

	case "random": {
		if !(_ied getVariable ["armed", false]) exitWith {};
		[player, _ied, "random"] spawn MCC_fnc_interactIED;
	};

	case "charge": {
		if (({_x == MCC_CHARGE} count magazines player) == 0) exitWith {hint "You have no demo charge"};
		player removeMagazine MCC_CHARGE;
		["Placing Charge", 10] call MCC_fnc_interactProgress;
		private _c4 = "DemoCharge_Remote_Ammo_Scripted" createVehicle position player;
		player addAction ["<t color=""#FF0000"">Detonate Charge</t>", {
			player removeAction (_this select 2);
			((_this select 3) select 0) setDamage 1;
			((_this select 3) select 1) setvariable ["iedTrigered",true,true];
		}, [_c4, _ied]];
	};
};
