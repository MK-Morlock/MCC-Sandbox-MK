private _Cfgside = configNull;
private _i = 0;
private _j = 0;
private _Cfgfaction = configNull;
private _k = 0;
private _Cfgtype = configNull;
private _cfgname = "";
private _factionDisplayName = "";
private _CfgfactionName = "";
private _CfgGroup = configNull;
params [
	["_refresh",true,[true]]
];

MCC_groupTypes = [];
if (isNil "mcc_faction") exitWith {};
//Create the groups type array
#define CONFIG (configFile >> "CfgGroups" )

_factionDisplayName = getText (configFile >> "CfgFactionClasses" >> MCC_faction >> "displayName");

for "_i" from 0 to ((count CONFIG) - 1)  do
{
	_Cfgside = (CONFIG select _i);
	if (isClass(_cfgside)) then
	{
		for "_j" from 0 to ((count _Cfgside) - 1) do
		{
			_Cfgfaction = (_cfgside select _j);
			if (isClass(_cfgfaction)) then
			{
				_CfgfactionName	= getText (_cfgfaction >> "name");
				for "_k" from 0 to ((count _Cfgfaction) - 1) do
				{
					_Cfgtype = (_cfgfaction select _k);
					if (isClass(_cfgtype)) then
					{
						_cfgname 		= configname(_cfgtype );
						_cfgDisplayname = getText (_Cfgtype >> "name");
						_check = true;
						for "_l" from 0 to ((count _cfgtype) - 1) do //Let's divide the groups
						{
							_CfgGroup = (_cfgtype select _l);

							if (isClass(_CfgGroup)) then
							{

								if (((configname(configFile >> "CfgFactionClasses" >> MCC_faction) == configname(_cfgfaction)) || ((getText (_CfgGroup >> "faction")) == (configname(configFile >> "CfgFactionClasses" >> MCC_faction))) || getText (_CfgGroup >> "faction") == MCC_faction)) then
								{
									//Work around to get units faction before putting them to types
									if (_check) then
									{
										MCC_groupTypes set [count MCC_groupTypes, [_cfgname,_cfgDisplayname]];
										_check = false;
									};
								};
							};
						};
					};
				};
			};
		};
	};
};

//Add this two for general stuff
MCC_groupTypes set [count MCC_groupTypes, ["Reinforcement","Reinforcement"]];
MCC_groupTypes set [count MCC_groupTypes, ["Garrison","Garrison"]];
MCC_groupTypes set [count MCC_groupTypes, ["Custom","Custom"]];

GEN_INFANTRY   		= [mcc_sidename,mcc_faction,(MCC_groupTypes select 0) select 0,"LAND"]   call mcc_make_array_grps;

// Create the units
// Load the different units into the arrays above
U_GEN_SHIP 			= [];
U_GEN_AIRPLANE		= [];
U_GEN_HELICOPTER 	= [];
U_GEN_TANK 			= [];
U_GEN_MOTORCYCLE	= [];
U_GEN_CAR			= [];
U_GEN_SOLDIER    	= [];

call mcc_make_array_units;

// Load DOC -> Dynamic Object Compositions

GEN_DOC1 = [];
GEN_DOC1 = [mcc_faction,0]  call mcc_make_array_comp;

//Asset preset of this faction (console Assets page)
if (hasInterface && {!isNil "MCC_fnc_assetsData"} && {isNil "MCC_assetsFirstApply"}) then {MCC_assetsFirstApply = true; ["apply", [call MCC_fnc_MWEnemyFaction]] call MCC_fnc_assetsData};	//presets follow the Mission Generator enemy faction

//if not refresh exit now
if (!_refresh) exitWith {};

 //If it's not first time refresh the menu
if (!(missionNamespace getVariable ["mcc_firstTime",true])) then {
	while {dialog} do {closeDialog 0};
	nul=[nil,nil,nil,nil,0] execVM MCC_path + "mcc\Dialogs\mcc_PopupMenu.sqf";
} else {
	missionNamespace setVariable ["mcc_firstTime",false];
};
