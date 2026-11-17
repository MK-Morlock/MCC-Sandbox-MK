/*
	MCCMK_fnc_pileAction - every computer: the Repack crate action on what a broken-down crate left on the ground.
	[pile]
*/
params [["_h", objNull, [objNull]]];
if (isNull _h || {!hasInterface}) exitWith {};
_h addAction ["<t color='#FFE1A0'>Repack crate</t>", {[_this select 0] call MCCMK_fnc_crateRepack}, nil, 1.5, true, true, "",
	"(_target getVariable ['MCCMK_crate', []]) isNotEqualTo [] && {(_this distance _target) < 4}", 4];
