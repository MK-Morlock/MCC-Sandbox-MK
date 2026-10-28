#define MCC_3DCargoGen 8018
#define ALLGEAR_IDD 8500
#define BOXGEAR_IDD 8501
#define GEARCLASS_IDD 8502
#define BOXPRESET_IDD 8503
#define BOXPRESETNAME_IDD 8504

class MCC_3DCargoGenControls:MCC_RscControlsGroup
{
	idc = MCC_3DCargoGen;
	moving = 1;
	x = 0.195 * safezoneW + safezoneX;
	y = 0.214111 * safezoneH + safezoneY;
	w = 0.401042 * safezoneW;
	h = 0.505803 * safezoneH;

	class Controls
	{
		class  MCC_3DCargoGenFrame : MCC_RscText 
		{
			idc = -1; 
			colorBackground[] = {0,0,0,0.6};
			moving = 1;
			w = 0.401042 * safezoneW;
			h = 0.505803 * safezoneH;
			text = "";
		};
		
		class allGearBackground : MCC_RscText 
		{
			idc = -1;
			colorBackground[] = {0.11,0.12,0.13,0.96};
			colorText[] = { 1, 1, 1, 0 };
			text = "";
			moving = 1;
			x = 0.00572965 * safezoneW;
			y = 0.0769698 * safezoneH;
			w = 0.171875 * safezoneW;
			h = 0.38485 * safezoneH;			
		};
		
		class boxGearBackground : MCC_RscText 
		{
			idc = -1;
			colorBackground[] = {0.11,0.12,0.13,0.96};
			colorText[] = { 1, 1, 1, 0 };
			x = 0.217709 * safezoneW;
			y = 0.0769698 * safezoneH;
			w = 0.177604 * safezoneW;
			h = 0.38485 * safezoneH;
			text = "";
		};
		
	 //========================================= Controls========================================
		class allGearList: MCC_RscListBox 
		{
			idc = ALLGEAR_IDD;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			
			x = 0.00572965 * safezoneW;
			y = 0.0769698 * safezoneH;
			w = 0.171875 * safezoneW;
			h = 0.38485 * safezoneH;
		};
		
		class boxGearList: MCC_RscListBox 
		{
			idc = BOXGEAR_IDD;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			
			x = 0.217709 * safezoneW;
			y = 0.0769698 * safezoneH;
			w = 0.177604 * safezoneW;
			h = 0.38485 * safezoneH;			
		};
		
		class gearClasCombo: MCC_RscCombo
		{
			idc = GEARCLASS_IDD;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			style = MCCST_LEFT;
			colorText[] = { 1, 1, 1, 1 };
			colorSelect[] = { 1.0, 0.35, 0.3, 1 };
			colorBackground[]={0,0,0,1};
			colorSelectBackground[] = { 0, 0, 0, 1 };
			onLBSelChanged = __EVAL("[0,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			
			x = 0.0458336 * safezoneW;
			y = 0.0439828 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		
		//Tittles
		class boxGeneratorTittle: MCC_RscText 
		{
			idc = -1;
			text = "Cargo Generator:";
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			colorText[] = {0.77,0.51,0.08,1};
			colorBackground[] = {1,1,1,0};
			
			x = 0.00572965 * safezoneW;
			y = 0.0109958 * safezoneH;
			w = 0.1375 * safezoneW;
			h = 0.0226897 * safezoneH;
		};
		
		class gearClassTitle:MCC_RscText
		{
			idc = -1;
			text = "Class:";
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			colorText[] = {0.88,0.89,0.90,1};
			colorBackground[] = {1,1,1,0};
			
			x = 0.00572965 * safezoneW;
			y = 0.0439828 * safezoneH;
			w = 0.0362846 * safezoneW;
			h = 0.0226897 * safezoneH;
		};
		
		//Buttons
		class addAllButton: MCCBTN_S
		{
			idc = -1;
			text = ">>";
			onButtonClick =  __EVAL("[1,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			tooltip = "Add current weapon and 6 magazines"; 
			
			x = 0.183334 * safezoneW;
			y = 0.186927 * safezoneH;
			w = 0.0286458 * safezoneW;
			h = 0.0274893 * safezoneH;
			class TextPos {left = 0; top = "((0.0274893 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};  
		
		class addOneButton: MCCBTN_S
		{
			idc = -1;
			text = ">";
			onButtonClick =  __EVAL("[2,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			tooltip = "Add current weapon"; 
			
			x = 0.183334 * safezoneW;
			y = 0.23091 * safezoneH;
			w = 0.0286458 * safezoneW;
			h = 0.0274893 * safezoneH;
			class TextPos {left = 0; top = "((0.0274893 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};  
		
		class removeOneButtton: MCCBTN_S
		{
			idc = -1;
			text = "Clear";
			onButtonClick =  __EVAL("[3,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			
			x = 0.183334 * safezoneW;
			y = 0.274893 * safezoneH;
			w = 0.0286458 * safezoneW;
			h = 0.0274893 * safezoneH;
			class TextPos {left = 0; top = "((0.0274893 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};  
		
		class generateBoxButton: MCCBTN_S
		{
			idc = -1;
			text = "Add";
			tooltip = "Add the selected items to the object init line"; 
			onButtonClick =  __EVAL("[4,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			
			x = 0.332292 * safezoneW;
			y = 0.472816 * safezoneH;
			w = 0.0572917 * safezoneW;
			h = 0.0274893 * safezoneH;
			class TextPos {left = 0; top = "((0.0274893 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		}; 

		//Presets (GitHub #11): saved in the players profile, available in every mission
		class boxPresetCombo: MCC_RscCombo
		{
			idc = BOXPRESET_IDD;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
			style = MCCST_LEFT;
			colorText[] = { 1, 1, 1, 1 };
			colorSelect[] = { 1.0, 0.35, 0.3, 1 };
			colorBackground[]={0,0,0,1};
			colorSelectBackground[] = { 0, 0, 0, 1 };
			tooltip = "Saved cargo presets";
			x = 0.00572965 * safezoneW;
			y = 0.472816 * safezoneH;
			w = 0.095 * safezoneW;
			h = 0.0274893 * safezoneH;
		};
		class boxPresetName: MCC_RscText
		{
			idc = BOXPRESETNAME_IDD;
			type = 2;
			style = 0;
			text = "";
			tooltip = "Name for Save (empty = overwrite the selected preset)";
			colorBackground[] = {0.11,0.12,0.13,0.96};
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
			x = 0.1035 * safezoneW;
			y = 0.472816 * safezoneH;
			w = 0.081 * safezoneW;
			h = 0.0274893 * safezoneH;
		};
		class boxPresetSave: MCCBTN_S
		{
			idc = -1;
			text = "Save";
			tooltip = "Save the box's current cargo as a preset";
			onButtonClick =  __EVAL("[5,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			x = 0.1875 * safezoneW;
			y = 0.472816 * safezoneH;
			w = 0.042 * safezoneW;
			h = 0.0274893 * safezoneH;
			class TextPos {left = 0; top = "((0.0274893 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class boxPresetLoad: MCCBTN_S
		{
			idc = -1;
			text = "Load";
			tooltip = "Replace the box's cargo with the selected preset";
			onButtonClick =  __EVAL("[6,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			x = 0.2325 * safezoneW;
			y = 0.472816 * safezoneH;
			w = 0.042 * safezoneW;
			h = 0.0274893 * safezoneH;
			class TextPos {left = 0; top = "((0.0274893 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class boxPresetDelete: MCCBTN_S
		{
			idc = -1;
			text = "Delete";
			tooltip = "Delete the selected preset";
			onButtonClick =  __EVAL("[7,_this] execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_change.sqf'");
			x = 0.2775 * safezoneW;
			y = 0.472816 * safezoneH;
			w = 0.051 * safezoneW;
			h = 0.0274893 * safezoneH;
			class TextPos {left = 0; top = "((0.0274893 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
	 };
};