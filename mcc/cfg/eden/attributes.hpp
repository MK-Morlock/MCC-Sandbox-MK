//Eden attribute control: drop-down list of every faction that has soldiers, including mod (custom) factions.
//Used by the faction fields of the MCC modules (control = MCC_AttributeFaction). The value is the faction class
//name, as the old text fields stored it, so existing missions keep their settings.
class Cfg3DEN
{
	class EventHandlers
	{
		class MCC_startLocPreview
		{
			onMissionLoad = "[] spawn (uiNamespace getVariable ['MCC_fnc_edenStartLocPreview', {}])";
			onMissionNew = "[] spawn (uiNamespace getVariable ['MCC_fnc_edenStartLocPreview', {}])";
			onMissionPreviewEnd = "[] spawn (uiNamespace getVariable ['MCC_fnc_edenStartLocPreview', {}])";
			onTerrainNew = "[] spawn (uiNamespace getVariable ['MCC_fnc_edenStartLocPreview', {}])";
			onMissionPreview = "uiNamespace setVariable ['MCC_slPrevToken', (uiNamespace getVariable ['MCC_slPrevToken', 0]) + 1]";
		};
	};
	class Attributes
	{
		class Combo;
		class MCC_AttributeFaction: Combo
		{
			attributeLoad = "[_this, _value, 'load'] call (uiNamespace getVariable ['MCC_fnc_edenFactionCombo', {}])";
			attributeSave = "[_this, '', 'save'] call (uiNamespace getVariable ['MCC_fnc_edenFactionCombo', {''}])";
		};
		//Same, with a "(not set)" entry at the top (stores an empty value)
		class MCC_AttributeFactionOptional: Combo
		{
			attributeLoad = "[_this, _value, 'loadOptional'] call (uiNamespace getVariable ['MCC_fnc_edenFactionCombo', {}])";
			attributeSave = "[_this, '', 'save'] call (uiNamespace getVariable ['MCC_fnc_edenFactionCombo', {''}])";
		};
	};
};
