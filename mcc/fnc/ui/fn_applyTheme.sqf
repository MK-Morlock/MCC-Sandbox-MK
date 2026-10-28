/*================================================================== MCC_fnc_applyTheme ==================================================================
	MCC look (VBS4 style) for controls made by script from the game's own control classes (RscText, RscButton, RscCombo,
	RscEdit, RscCheckbox ...): the dynamic dialog (settings pages, campaign and Zeus dialogs) and MCC message boxes.
	Windows defined in config get the same look from MCC's base classes (mcc\dialogs\mcc_dialogs.hpp: MCC_RscText,
	MCC_RscButton, MCC_RscListbox, MCC_RscCombo ...), so they need nothing here.

	<IN>	0: DISPLAY  the window
			1: ARRAY    (optional) only these controls
==============================================================================================================================================================*/
#define CT_STATIC 0
#define CT_BUTTON 1
#define CT_EDIT 2
#define CT_SLIDER 3
#define CT_COMBO 4
#define CT_LISTBOX 5
#define CT_TOOLBOX 6
#define CT_CHECKBOXES 7
#define CT_TREE 12
#define CT_STRUCTURED_TEXT 13
#define CT_SHORTCUTBUTTON 16
#define CT_XSLIDER 43
#define CT_CHECKBOX 77
#define CT_LISTNBOX 102

disableSerialization;
params [["_display", displayNull], ["_only", []]];
if (isNull _display) exitWith {};

//Palette (VBS4) - the same as the MCC base classes
private _field  = [0.07, 0.08, 0.09, 0.95];
private _button = [0.22, 0.24, 0.26, 1];
private _text   = [0.88, 0.89, 0.90, 1];
private _accent = [0.77, 0.51, 0.08, 1];

{
	private _c = _x;
	private _type = ctrlType _c;
	private _cls = toLower ctrlClassName _c;
	if !("consolekey" in _cls) then {
		if (_cls find "mcc_" != 0 && {_type in [CT_STATIC, CT_BUTTON, CT_EDIT, CT_COMBO, CT_LISTBOX, CT_LISTNBOX, CT_TREE, CT_SHORTCUTBUTTON, CT_STRUCTURED_TEXT]}) then {
			_c ctrlSetFont "RobotoCondensed";	//the MCC font
		};
		switch (true) do {
			case (_type == CT_STATIC && {_cls in ["rsctext", "ctrlstatic"]}): {_c ctrlSetTextColor _text};
			case (_type in [CT_BUTTON, CT_SHORTCUTBUTTON] && {_cls find "mcc_" != 0}): {
				_c ctrlSetBackgroundColor _button;
				_c ctrlSetTextColor _text;
				_c ctrlSetActiveColor _accent;
			};
			case (_type in [CT_EDIT, CT_COMBO, CT_LISTBOX, CT_LISTNBOX, CT_TREE] && {_cls find "mcc_" != 0}): {
				_c ctrlSetBackgroundColor _field;
				_c ctrlSetTextColor _text;
				_c ctrlSetActiveColor _accent;
			};
			case (_type in [CT_SLIDER, CT_XSLIDER]): {_c ctrlSetActiveColor _accent};
			case (_type in [CT_TOOLBOX, CT_CHECKBOXES, CT_CHECKBOX]): {_c ctrlSetActiveColor _accent};
		};
	};
} forEach (if (count _only > 0) then {_only} else {allControls _display});
