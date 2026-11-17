#define MCC_SANDBOX2_IDD (uiNamespace getVariable "MCC_groupGen_Dialog")
#define MCC_EVAC_TYPE 40
#define MCC_EVAC_CLASS 41
#define MCC_EVAC_SELECTED 42
#define MCC_EVAC_INSERTION 43
#define MCC_EVAC_FLIGHTHIGHT 44

disableSerialization;
private _evacArray = [];
private _mccdialog = 0;
private _option = 0;
private _type = 0;
private _comboBox = controlNull;
private _vehicleDisplayName = "";
private _displayname = "";
private _index = 0;
private _countVehicles = 0;
_mccdialog = MCC_SANDBOX2_IDD;


if !mcc_isloading then
{
	if (mcc_missionmaker == (name player)) then
	{
		_option = _this select 0;
		_type 	= lbCurSel MCC_EVAC_TYPE;
		switch (_type) do		//Which evac do we want
		{
			case 0:			//Choppers
			{
				_evacArray = U_GEN_HELICOPTER;
			};
			case 1:			//Vehicles
			{
				_evacArray = U_GEN_CAR;
			};
			case 2:			//Tracked
			{
				_evacArray = U_GEN_TANK;
			};
			case 3:			//Ships
			{
				_evacArray = U_GEN_SHIP;
			};
		};

		MCCEvacHeliType = (_mccdialog displayCtrl MCC_EVAC_CLASS) lbData (lbCurSel MCC_EVAC_CLASS);
		MCCEvacSide = call MCC_fnc_evacSide;
		if (MCCEvacHeliType == "") exitWith {["No vehicle of this type for that faction"] call MCCMK_fnc_hint};

		//Spawn on LHD
		if (_option == 0) then
		{
			if (MCCLHDSpawned) then
			{
				["Evac Vehicle spawned on LHD"] call MCCMK_fnc_hint;
				_pos = getmarkerpos "pos4";
				[MCCEvacHeliType, _pos, false, 0, MCCEvacSide, missionNamespace getVariable ["MCCMK_evacFaction", ""]] remoteExec ["MCC_fnc_evacSpawn", 2, false];
				mcc_safe = mcc_safe + FORMAT ["
											['%1',%2, false, 0, %3, '%4'] remoteExec ['MCC_fnc_evacSpawn', 2, false];
											"
											, MCCEvacHeliType
											, _pos
											, MCCEvacSide call BIS_fnc_sideID
											, missionNamespace getVariable ["MCCMK_evacFaction", ""]
											];
			}
			else
			{
				["LHD is not available, evac chopper can't be spawned"] call MCCMK_fnc_hint
			};
		};

		//Spawn on land
		if (_option == 1) then
		{
			if (missionNamespace getVariable ["MCC_evacSpawnPending", false]) exitWith {onMapSingleClick ""; MCC_evacSpawnPending = false; ["Evac spawn cancelled"] call MCCMK_fnc_hint};
			MCC_evacSpawnPending = true;
			["Click on the map to spawn the evac vehicle (right-click to cancel)"] call MCCMK_fnc_hint;
			onMapSingleClick " 	hint ""Evac Vehicle spawned."";
								MCC_evacSpawnPending = false;
								[MCCEvacHeliType, _pos, false, 0, MCCEvacSide, missionNamespace getVariable [""MCCMK_evacFaction"", """"]] remoteExec [""MCC_fnc_evacSpawn"", 2, false];
								mcc_safe=mcc_safe + FORMAT ['
									[""%1"",%2, false, 0, %3, ""%4""] remoteExec [""MCC_fnc_evacSpawn"", 2, false];
									sleep 1;'
									, MCCEvacHeliType
									, _pos
									, MCCEvacSide call BIS_fnc_sideID
									, missionNamespace getVariable [""MCCMK_evacFaction"", """"]
									];
								onMapSingleClick """";
								";
		};

	}
	else
	{
		player globalchat "Access Denied"
	};
};

