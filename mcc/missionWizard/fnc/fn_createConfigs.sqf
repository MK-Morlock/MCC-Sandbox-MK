//====================================================MCC_fnc_createConfigs=================================================================================================
// Create the faction classes from configs
// Example:[_faction] call MCC_fnc_createConfigs;
// 	_faction		STRING faction string
// Return - nothing
//=============================================================================================================================================================================
private _Cfgside = configNull;
private _i = 0;
private _j = 0;
private _Cfgfaction = configNull;
private _k = 0;
private _Cfgtype = configNull;
private _cfgname = "";
private _CfgfactionName = "";
private _groupName = "";
private _groupDisplayname = "";
private _CfgGroup = configNull;
private _cfgentry = "";
params [["_faction", "OPF_F", [""]], ["_mode", 2, [0]]];

//Create the groups type array
#define CONFIG (configFile >> "CfgGroups" )
MCC_MWGroupArrayMen = [];			//vehicleClass = "Men";
MCC_MWGroupArrayMenDiver = []; 		// vehicleClass = "MenDiver";
MCC_MWGroupArrayMenRecon = []; 		// vehicleClass = "MenRecon";
MCC_MWGroupArrayMenSniper = []; 	// vehicleClass = "MenSniper";
MCC_MWGroupArrayMenSupport = []; 	// vehicleClass = "MenSupport";
MCC_MWGroupArrayMenStory = []; 		//  vehicleClass = "MenStory";

MCC_MWGroupArrayCar = []; 			// vehicleClass = "Car";
MCC_MWGroupArrayArmored = []; 		// vehicleClass = "Armored";
MCC_MWGroupArrayAir = []; 			// vehicleClass = "Air";
MCC_MWGroupArrayAutonomous = []; 	// vehicleClass = "Autonomous";
MCC_MWGroupArraySupport = []; 		// vehicleClass = "Support";

MCC_MWGroupArrayShip = []; 			// vehicleClass = "Ship";
MCC_MWGroupArraySubmarine = []; 	// vehicleClass = "Submarine";
MCC_MWGroupArrayStatic = []; 		// vehicleClass = "Static";

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

								if (((configname(configFile >> "CfgFactionClasses" >> _faction) == configname(_cfgfaction)) || ((getText (_CfgGroup >> "faction")) == (configname(configFile >> "CfgFactionClasses" >> _faction))) || getText (_CfgGroup >> "faction") == _faction)) then
								{
									//Work around to get units faction before putting them to types
									_groupName 		  = configname(_CfgGroup );
									_groupDisplayname = getText (_CfgGroup >> "name");
									_cfgentry = format ["configFile >> ""CfgGroups"" >>""%1"">>""%2"">>""%3"">>""%4""",(configname (_Cfgside)),(configname (_Cfgfaction)),(configname (_Cfgtype)),(configname (_CfgGroup))];

									if (_mode < 2 && {(("isClass _x" configClasses _CfgGroup) findIf {!([getText (_x >> "vehicle"), _faction, _mode] call MCC_fnc_contentAllowed)}) >= 0}) then {continue};
									private _man = 0;
									private _diver = 0;
									private _recon = 0;
									private _sniper = 0;
									private _menSupport = 0;
									private _story = 0;
									private _car = 0;
									private _armored = 0;
									private _air = 0;
									private _extreme = [];
									private _simulation = "";
									private _autonomos = 0;
									private _carSuppory = 0;
									private _ship = 0;
									private _submarine = 0;
									private _static = 0;
									private _CfgUnit = configNull;
									private _unitName = "";
									private _unitClass = "";
									private _count = 0;
									_man = 0;
									_diver = 0;
									_recon = 0;
									_sniper = 0;
									_menSupport = 0;
									_story = 0;
									_car = 0;
									_armored = 0;
									_air = 0;
									_autonomos = 0;
									_carSuppory = 0;
									_ship = 0;
									_submarine = 0;
									_static = 0;
									_count = 0;

									for "_n" from 0 to ((count _CfgGroup) - 1) do	//Lets scan the units and see who is who
									{
										_CfgUnit = (_CfgGroup select _n);
										if (isClass(_CfgUnit)) then
										{
												_unitName 	= getText (_CfgUnit >> "vehicle");
												_unitClass 	= [_unitName] call MCC_fnc_unitCategory;	//mod vehicleClass names mapped to MCCs (GitHub #48)
												_simulation	= tolower (getText (configfile >> "CfgVehicles" >> _unitName  >> "simulation"));
												_count = _count + 1;
												//Search by vehicleClass
												if (_unitClass in ["Men","MenDiver","MenRecon","MenSniper","MenSupport","MenStory","Car","Armored","Air","Autonomous","Support","Ship","Submarine","Static"]) then
												{
													switch (_unitClass) do
													{
														case "Men":
														{
															_man = _man +1;
														};
														case "MenDiver":
														{
															_diver = _diver +1;
														};
														case "MenRecon":
														{
															_recon = _recon +1;
														};
														case "MenSniper":
														{
															_sniper = _sniper +1;
														};
														case "MenSupport":
														{
															_menSupport = _menSupport +1;
														};
														case "MenStory":
														{
															_story = _story +1;
														};
														case "Car":
														{
															_car = _car +1;
														};
														case "Armored":
														{
															_armored = _armored +1;
														};
														case "Air":
														{
															_air = _air +1;
														};
														case "Autonomous":
														{
															_autonomos = _autonomos +1;
														};
														case "Support":
														{
															_carSuppory = _carSuppory +1;
														};
														case "Ship":
														{
															_ship = _ship +1;
														};
														case "Submarine":
														{
															_submarine = _submarine +1;
														};
														case "Static":
														{
															_static = _static +1;
														};
													};
												}
												else //no vehicleClass go to simulate
												{
													switch (true) do
													{
														case (_simulation in ["soldier"]):
														{
															_man = _man +1;
														};

														case (_simulation in ["car","carx","motorcycle","motorcyclex"]):
														{
															_car = _car +1;
														};

														case (_simulation in ["tank","tankx"]):
														{
															_armored = _armored +1;
														};

														case (_simulation in ["helicopter","helicopterx","helicopterrtd","airplane","airplanex"]):
														{
															_air = _air +1;
														};

														case (_simulation in ["ship","shipx","helicopterrtd","airplane","airplanex"]):
														{
															_ship = _ship +1;
														};

														case (_simulation in ["submarinex"]):
														{
															_submarine = _submarine +1;
														};
													};
												};
											};
										};

										//If we have a vehicle
										if (_static > 0) exitWith {MCC_MWGroupArrayStatic pushBack [_groupName,_count,_cfgentry]};
										if (_submarine > 0) exitWith {MCC_MWGroupArraySubmarine pushBack [_groupName,_count,_cfgentry]};
										if (_ship > 0) exitWith {MCC_MWGroupArrayShip pushBack [_groupName,_count,_cfgentry]};
										if (_carSuppory > 0) exitWith {MCC_MWGroupArraySupport pushBack [_groupName,_count,_cfgentry]};
										if (_autonomos > 0) exitWith {MCC_MWGroupArrayAutonomous pushBack [_groupName,_count,_cfgentry]};
										if (_air > 0) exitWith {MCC_MWGroupArrayAir pushBack [_groupName,_count,_cfgentry]};
										if (_armored > 0) exitWith {MCC_MWGroupArrayArmored pushBack [_groupName,_count,_cfgentry]};
										if (_car > 0) exitWith {MCC_MWGroupArrayCar pushBack [_groupName,_count,_cfgentry]};

										//If we have men
										_extreme = [[_man,_diver,_recon,_sniper,_menSupport,_story],1] call BIS_fnc_findExtreme;
										if (_extreme == _man) exitWith {MCC_MWGroupArrayMen pushBack [_groupName,_count,_cfgentry]};
										if (_extreme == _diver) exitWith {MCC_MWGroupArrayMenDiver pushBack [_groupName,_count,_cfgentry]};
										if (_extreme == _recon) exitWith {MCC_MWGroupArrayMenRecon pushBack [_groupName,_count,_cfgentry]};
										if (_extreme == _sniper) exitWith {MCC_MWGroupArrayMenSniper pushBack [_groupName,_count,_cfgentry]};
										if (_extreme == _menSupport) exitWith {MCC_MWGroupArrayMenSupport pushBack [_groupName,_count,_cfgentry]};
										if (_extreme == _story) exitWith {MCC_MWGroupArrayMenStory pushBack [_groupName,_count,_cfgentry]};
								};
							};
						};
					};
				};
			};
		};
	};
};
if (_mode < 2) then {
	private _names = ["MCC_MWGroupArrayMen", "MCC_MWGroupArrayMenDiver", "MCC_MWGroupArrayMenRecon", "MCC_MWGroupArrayMenSniper", "MCC_MWGroupArrayMenSupport", "MCC_MWGroupArrayMenStory", "MCC_MWGroupArrayCar", "MCC_MWGroupArrayArmored", "MCC_MWGroupArrayAir", "MCC_MWGroupArrayAutonomous", "MCC_MWGroupArraySupport", "MCC_MWGroupArrayShip", "MCC_MWGroupArraySubmarine", "MCC_MWGroupArrayStatic"];
	private _kept = _names apply {+(missionNamespace getVariable [_x, []])};
	[_faction, 2] call MCC_fnc_createConfigs;
	{
		private _f = _kept select _forEachIndex;
		if (count _f > 0 || {count (missionNamespace getVariable [_x, []]) == 0}) then {missionNamespace setVariable [_x, _f]} else {["INFO", "MCC_fnc_createConfigs", "%1: nothing left in %2 with the content filter - using all content", [_faction, _x]] call MCC_fnc_log};
	} forEach _names;
};
