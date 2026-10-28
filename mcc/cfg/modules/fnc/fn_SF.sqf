
//******************************************************************************************
//==========================================================================================
//=		 						 Shay-Gman MCC_fnc_SF
//=					                            13.01.2012
//==========================================================================================
//******************************************************************************************
private _null = [];
private "_synced";

params ["_logic"];
_logic setpos [1000,10,0];
_synced = synchronizedobjects _logic;		//Who synced with the module

if (player in _synced)then {
	//Action key
	 hcam_Key = (_logic getvariable ["hcam_actionKey",1]);

	player setVariable ["MCC_fnc_SFLogic",_logic];

	while { !alive player || isnil "MCC_path"} do {sleep 1};
	_null = [] execVM MCC_path + "hcam\hcam_init.sqf";
	player setVariable ["mcc_sf",true,true];
	sleep 1;
	waituntil {!(IsNull (findDisplay 46))};

	private _answer = nil;
	if (profileNamespace getVariable ["MCC_tutorialSF",true]) then
	{
		_answer = ["<t font='RobotoCondensedBold'>You have just been assigned as Special Forces member</t>"
					+"<br/><img size='9' img image='"+MCC_path+"data\sf.paa' />"
					+format ["<br/>You can access your group helmet camera using <t font='RobotoCondensedBold'><t underline='true'>User key %1</t></t> key.",hcam_Key]
					+format ["<br/>Press <t font='RobotoCondensedBold'><t underline='true'>Shift + User key %1</t></t> to change video size.",hcam_Key]
					+format ["<br/>Press <t font='RobotoCondensedBold'><t underline='true'>Ctrl + User key %1</t></t> to change to thermal or night vision.",hcam_Key]
					+format ["<br/>Press <t font='RobotoCondensedBold'><t underline='true'>Alt + User key %1</t></t> to turn camera off.",hcam_Key]
					+"<br/><br/>Do you want to show this message in the future?","MCC Special Forces","No","Yes"] call MCC_fnc_messageBox;

		waituntil {!isnil "_answer"};

		if (_answer) exitWith
		{
			profileNamespace setVariable ["MCC_tutorialSF",false];
		};
	};
};