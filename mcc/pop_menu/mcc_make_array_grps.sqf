private _Cfgside = configNull;
private _cfgname = "";
private _cfgclass = "";
private _grp_array = [];
private _indexar = 0;
private _Cfgfaction = configNull;
private _factionClassName = "";
private _cfg = configNull;
private _unitCfg = configNull;
params ["_side", "_faction", "_type", "_classtype"];
_grp_array = [];
_indexar   = 0;

if (isNil "_faction") exitWith {};

dumtel    = 0;
dumar     = [];

//Work around to get groups by cfg name
_factionClassName = "";
_cfg = (configFile >> "CfgFactionClasses");
for "_i" from 0 to ((count _cfg) - 1) do
{
	_unitCfg = (_cfg select _i);
   if (_faction == configname(_unitCfg)) exitWith { _factionClassName = configname(_unitCfg)};
};

#define CONFIG (configFile >> "CfgGroups" )

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
				for "_k" from 0 to ((count _Cfgfaction) - 1) do
				{
					_Cfgtype = (_cfgfaction select _k);
					if (isClass(_cfgtype)) then
					{
					    _cfgname = configname(_cfgtype );
						if (_cfgname == _type) then
						{
							for "_m" from 0 to ((count _cfgtype) -1) do
							{
							   _cfgclasstype =( _cfgtype select _m);

							   if (isClass(_cfgclasstype)) then
							   {
									// Same rule the group-type list uses (mcc_faction_choice.sqf): the group's own faction, or - for mods such as S.O.G. Prairie Fire
									// whose groups have no "faction" entry - the CfgGroups faction class it sits in. Before, those types were listed but always empty,
									// so spawning showed "Cannot spawn an empty group".
									private _grpFaction = getText(_cfgclasstype >> "faction");
									if (_grpFaction == _faction || {_grpFaction == "" && {configName _Cfgfaction == _faction}}) then
									{
										_cfgname  =  getText(_cfgclasstype >> "name");

										_cfgclass = configname(_cfgclasstype );
										_cfgentry = format ["configFile >> ""CfgGroups"" >>""%1"">>""%2"">>""%3"">>""%4"" ",(configname (_Cfgside)),(configname (_Cfgfaction)),(configname (_Cfgtype)),(configname (_cfgclasstype))];

										if ( ["Diver", _cfgclass] call BIS_fnc_inString ) then
										{
											_classtype = "DIVER"; // may be spawned both at land or water
										};

										//Lets count the units in a group
										private _count = 0;
										private _CfgUnit = configNull;
										_count = 0;
										for "_n" from 0 to ((count _cfgclasstype) - 1) do
										{

										_CfgUnit = (_cfgclasstype select _n);
										if (isClass(_CfgUnit)) then
											{
												_count = _count + 1;
											};
										};

										_grp_array set[_indexar,[_classtype,_cfgclass,_cfgentry,_cfgname,_count]];
										_indexar = _indexar + 1;
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
_grp_array