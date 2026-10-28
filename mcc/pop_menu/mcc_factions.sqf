private _mcc_config = configNull;
private _mcc_faction_idx = 0;
private _mcc_sides = [];
private _unitCfg = configNull;
private _cfgname = configNull;
private _cfgdisplayname = "";
private _side = 0;
private _sidename = "";
_mcc_config 		= configFile >> "CfgFactionClasses";
_mcc_faction_idx 	= 0;
_mcc_sides      	= ["EAST","WEST","GUER","CIV"];
u_factions			= [];
U_FACTIONSCIV 		= [];

for "_i" from 0 to ((count _mcc_config) - 1) do
{

  _unitCfg = (_mcc_CONFIG select _i);

	// Factions without a "side" entry used to read as 0 = EAST (e.g. some USMC mod factions); MCC_fnc_factionSide
	// falls back to the side of the factions units. Factions with no number side and no units are still skipped.
	_side = if (isClass _unitCfg && {getText (_unitCfg >> "displayName") != ""}) then {[configName _unitCfg, true] call MCC_fnc_factionSide} else {-1};
	if (_side >= 0) then
	{
	   _cfgname        = (configName(_unitcfg));

		_cfgdisplayname = (gettext(_unitCfg >> "displayname"));
		_sidename       = (_mcc_sides select _side);

	   //-------------------------------------------------------------------
		if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["factions: [%1] - [%2] - [%3] - [%4] - [%5]", _unitCfg, _cfgname, _cfgdisplayname, _side, _sidename]};  //DEBUG
	   //-------------------------------------------------------------------

		U_FACTIONS set [_mcc_faction_idx,[_cfgdisplayname, _sidename, _cfgname ]];
		if (_sidename == "CIV") then {
			U_FACTIONSCIV pushBack [_cfgdisplayname, _sidename, _cfgname];

			//Init faction groups and units to save time
		};
		_mcc_faction_idx = _mcc_faction_idx + 1;

	};
};