/*
	MCCMK_fnc_classSource - the mod a config class really comes from: the mod of the addon that first defined it ("" for
	the base game). configSourceMod gives whichever mod last changed the class, so a vanilla class adjusted by a DLC or a
	mod would count as theirs. [config] -> mod folder name
*/
params [["_c", configNull, [configNull]]];
private _adds = configSourceAddonList _c;
if (_adds isEqualTo []) then {configSourceMod _c} else {configSourceMod (configFile >> "CfgPatches" >> (_adds select 0))}
