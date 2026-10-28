/* ============================================ MCC_fnc_addComponentsACECondition ===========================================================================
Returns the vehicle's toggleable components (animation sources that have a display name and are
driven by "user" (garage parts: camo nets, slat armour, bumpers...) or "door" (doors, ramps, hatches)).
Used both as the ACE "Components" condition (count > 0) and by MCC_fnc_addComponentsACE to build the children,
so the menu can never show empty.

Parameter(s):
	_this select 0: OBJECT vehicle

Returns:
	ARRAY of config entries (empty if the vehicle has nothing to toggle)
=============================================================================================================================================================
*/
params [["_vehicle", objNull, [objNull]]];
if (isNull _vehicle) exitWith {[]};

// includeInherited = true: most vehicles inherit their AnimationSources from a base class
configProperties [
	configOf _vehicle >> "AnimationSources",
	"isClass _x && {getText (_x >> 'displayName') != ''} && {(toLower getText (_x >> 'source')) in ['user','door']}",
	true
]
