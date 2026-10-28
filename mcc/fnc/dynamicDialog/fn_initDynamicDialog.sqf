/*=================================================================MCC_fnc_initDynamicDialog==================================================================================
  init the dynamic dialog
  Parameter(s):
     0: STRING - Dialog Tittle
     1: ARRAY  - Dialog option can by either
                   1. ARRAY of ARRAYS (combo boxs) containing the question text and the option's text in an array examp [["question1",["Option1","option2"]],["question2",["Option1","option2"]]]
                   2. ARRAY of ARRAYS (combo boxs) like above but can have the options var as an array containing the option text + picture path [["question1",[["Option1","option1pic.paa"],"option2"]],["question2",["Option1","option2"]]]
                   3. BOOLEAN will create a checkbox example: ["question1",flase]
                   4. INTEGER will create a slider with max number as given example ["question1",10] wiil create a slider with up to 10
                   5. STRING will create an open text box
                   Optional 3rd element: tooltip. Optional 4th element (combo boxes): index selected when the dialog opens (default 0)

     Example ["My dialog",[["question1",["Option1","option2"]],["question2",["Option1","option2"]],["question3",["Option1","option2"]]],"MCC_fnc_artillery"] call MCC_fnc_initDynamicDialog
*/

private _ok = false;
private _display = controlNull;
private _ctrlBackground = controlNull;
private _ctrlTitle = controlNull;
private _ctrlButtonOK = controlNull;
private _ctrlButtonCancel = controlNull;
private _ctrlButtonCustom = controlNull;
private _ctrlBackgroundPos = [];
private _ctrlTitlePos = [];
private _ctrlButtonOKPos = [];
private _ctrlButtonCancelPos = [];
private _ctrlButtonCustomPos = [];
private _ctrlTitleOffsetY = 0;
private _ctrlContent = controlNull;
private _ctrlContentPos = [];
private _ctrlContentOffsetY = 0;
private _posY = 0;
disableSerialization;

#define IDC_OK  10007
#define IDC_CANCEL 2
#define IDC_BASE 100
#define DEFAULT_WIDTH (11*(((safezoneW / safezoneH) min 1.2)/40))
#define DEFAULT_HEIGHT (1*((((safezoneW / safezoneH) min 1.2)/1.2)/25))

params [
    ["_title","",[""]],
    ["_array",[],[[]]],
    ["_infoText","",[""]]
];

//avoid double
if (tolower str (findDisplay 1031982) != "no display") exitWith {[]};

_ok = createDialog ("MCC_DynamicDialog" call MCC_fnc_dialogName);
waitUntil {dialog};

_display = findDisplay 1031982;
_ctrlBackground = _display displayctrl 10001;
_ctrlTitle = _display displayctrl 10002;
_ctrlContent = _display displayctrl 10003;
_ctrlButtonOK = _display displayctrl IDC_OK;
_ctrlButtonCancel = _display displayctrl IDC_CANCEL;
_ctrlButtonCustom = _display displayctrl 10006;

missionNamespace setVariable ["MCC_DynamicDialogOK",false];
_ctrlButtonOK ctrlSetEventHandler ["ButtonClick", "missionNamespace setVariable ['MCC_DynamicDialogOK', true];"];

_ctrlBackgroundPos = ctrlposition _ctrlBackground;
_ctrlTitlePos = ctrlposition _ctrlTitle;
_ctrlContentPos = ctrlposition _ctrlContent;
_ctrlButtonOKPos = ctrlposition _ctrlButtonOK;
_ctrlButtonCancelPos = ctrlposition _ctrlButtonCancel;
_ctrlButtonCustomPos = ctrlposition _ctrlButtonCustom;

_ctrlTitleOffsetY = (_ctrlBackgroundPos select 1) - (_ctrlTitlePos select 1) - (_ctrlTitlePos select 3);
_ctrlContentOffsetY = (_ctrlContentPos select 1) - (_ctrlBackgroundPos select 1);

_posY = (_ctrlContentPos select 1) - (_ctrlBackgroundPos select 1);

//Set tittle
_ctrlTitle ctrlSetText _title;
_ctrlTitle ctrlCommit 0;

//Set the control groups
private _controlTittle = controlNull;
private _control = controlNull;
private _index = 0;
private _ctrls = [];
_ctrls = [];
{
    _x params [
        ["_question","",[""]],
        ["_options","",[[],true,0,""]],
        ["_tooltip","",[""]],
        ["_default",0,[0,true,""]]
    ];
    if (_default isEqualType true) then {_default = [0, 1] select _default};
    if (_default isEqualType "") then {_default = parseNumber _default};

    //tittle
    _controlTittle = _display ctrlCreate ["MCC_RscText", -1,_ctrlContent];
    _controlTittle ctrlSetPosition [0, _posY, DEFAULT_WIDTH, DEFAULT_HEIGHT];
    _controlTittle ctrlSetText _question;
    _controlTittle ctrlCommit 0;

    //If the option is an array then create a combobox
    if (typeName _options == typeName []) then {
        //combo
        _control = _display ctrlCreate ["MCC_RscCombo", IDC_BASE + _forEachIndex,_ctrlContent];
        _control ctrlSetPosition [DEFAULT_WIDTH*1.1, _posY, DEFAULT_WIDTH, DEFAULT_HEIGHT];
        _control ctrlCommit 0;

        {
            //do we have combo box with pic
            if (typeName _x == typeName []) then {
                _index = _control lbAdd (_x select 0);
                _control lbsetpicture [_index, (_x select 1)];
            } else {
                 _control lbAdd _x;
            };

        } forEach _options;

        _control lbSetCurSel ((_default max 0) min ((lbSize _control) - 1));
    };

    //If the option is boolean
    if (typeName _options == typeName true) then {
        //combo
        //Standard Arma checkbox (the editor one), kept square: the old one was stretched to a wide box, which made its
        //picture blurry
        _control = _display ctrlCreate ["ctrlCheckbox", IDC_BASE + _forEachIndex,_ctrlContent];
        if (isNull _control) then {_control = _display ctrlCreate ["RscCheckbox", IDC_BASE + _forEachIndex,_ctrlContent]};
        private _cbH = DEFAULT_HEIGHT;
        private _cbW = _cbH * (pixelW / pixelH);
        _control ctrlSetPosition [DEFAULT_WIDTH*1.1, _posY, _cbW, _cbH];
        _control cbSetChecked  _options;
        _control ctrlCommit 0;
    };

    //If the option is number create slider
    if (typeName _options == typeName 1) then {
        //combo
        _control = _display ctrlCreate ["MCC_RscXSliderH", IDC_BASE + _forEachIndex,_ctrlContent];
        _control ctrlSetPosition [DEFAULT_WIDTH*1.1, _posY, DEFAULT_WIDTH, DEFAULT_HEIGHT];
        _control sliderSetRange [0, _options];
        _control sliderSetPosition (if (count _x > 3) then {(_default max 0) min _options} else {_options/2});	//optional 4th element: start value
        _control ctrlSetEventHandler ["SliderPosChanged", "(_this select 0) ctrlSetTooltip str floor (_this select 1)"];
        _control ctrlCommit 0;
    };

    //If the option is an empty string create a text box
    if (typeName _options == typeName "") then {
        _control = _display ctrlCreate ["RscEdit", IDC_BASE + _forEachIndex,_ctrlContent];
        _control ctrlSetPosition [DEFAULT_WIDTH*1.1, _posY, DEFAULT_WIDTH, DEFAULT_HEIGHT];
        _control ctrlCommit 0;
    };

    _control ctrlSetTooltip _tooltip;
    _ctrls pushBack _control;
    _posY = _posY + DEFAULT_HEIGHT*1.2;
} forEach _array;

//Set the frame
_posH = ((_posY + _ctrlContentOffsetY) min 0.9) * 0.5;

_ctrlTitlePos set [1,(0.5 - _posH) - (_ctrlTitlePos select 3) - _ctrlTitleOffsetY];
_ctrlTitle ctrlsetposition _ctrlTitlePos;
_ctrlTitle ctrlcommit 0;

_ctrlContentPos set [1,0.5 - _posH];
_ctrlContentPos set [3,_posH * 2];
_ctrlContent ctrlsetposition _ctrlContentPos;
_ctrlContent ctrlcommit 0;

_ctrlBackgroundPos set [1,0.5 - _posH];
_ctrlBackgroundPos set [3,_posH * 2];
_ctrlBackground ctrlsetposition _ctrlBackgroundPos;
_ctrlBackground ctrlcommit 0;

_ctrlButtonOKPos set [1,0.5 + _posH + _ctrlTitleOffsetY];
_ctrlButtonOK ctrlsetposition _ctrlButtonOKPos;
_ctrlButtonOK ctrlcommit 0;

_ctrlButtonCancelPos set [1,0.5 + _posH + _ctrlTitleOffsetY];
_ctrlButtonCancel ctrlsetposition _ctrlButtonCancelPos;
_ctrlButtonCancel ctrlcommit 0;

_ctrlButtonCustomPos set [1,0.5 + _posH + _ctrlTitleOffsetY];
_ctrlButtonCustom ctrlsetposition _ctrlButtonCustomPos;
_ctrlButtonCustom ctrlsetText "";
_ctrlButtonCustom ctrlcommit 0;
_ctrlButtonCustom ctrlShow false;

//Set info text
if (_infoText != "") then {
    private _sizeH = ((count toArray _infoText)/50)* ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25);
    _ctrlInfoTextBckgPos = ctrlPosition _ctrlBackground;
    _ctrlInfoTextBckgPos set [1,0.6 + _posH + _ctrlTitleOffsetY];
    _ctrlInfoTextBckgPos set [3,_sizeH];
    _controlTittle = _display ctrlCreate ["RscText", -1];
    _controlTittle ctrlSetPosition _ctrlInfoTextBckgPos;
    _controlTittle ctrlSetBackgroundColor [0,0,0,0.7];
    _controlTittle ctrlCommit 0;

    _ctrlInfoText = _display ctrlCreate ["RscStructuredText", -1];
    _ctrlInfoText ctrlSetPosition _ctrlInfoTextBckgPos;
    _ctrlInfoText ctrlSetStructuredText parsetext _infoText;
    _ctrlInfoText ctrlCommit 0;
};

//MCC look: settings pages, campaign and Zeus dialogs
private _winTop = (_ctrlTitlePos select 1) - 0.012;
private _winBottom = (_ctrlButtonOKPos select 1) + (_ctrlButtonOKPos select 3) + 0.015;
private _winPos = +_ctrlBackgroundPos;
_winPos set [0, (_winPos select 0) - 0.006];
_winPos set [2, (_winPos select 2) + 0.012];
_winPos set [1, _winTop];
_winPos set [3, _winBottom - _winTop];
_ctrlBackground ctrlSetPosition _winPos;
_ctrlBackground ctrlCommit 0;
_ctrlTitle ctrlSetBackgroundColor [0, 0, 0, 0];

[_display] call MCC_fnc_applyTheme;

//wait till the dialog is canceled or confirmed
waitUntil {(missionNamespace getVariable ["MCC_DynamicDialogOK",false]) || (tolower str (findDisplay 1031982) == "no display")};

//get the resaults
private _resaults = [];
private _ctrl = controlNull;
_resaults = [];

//if cancel exit
if !(missionNamespace getVariable ["MCC_DynamicDialogOK",false]) exitWith {_resaults};

{
    _ctrl = _x;
    //class name dropped every yes/no answer (Mission Settings then failed with "3 elements provided, 5 expected")
    switch (ctrlType _ctrl) do {
        case 4: {_resaults pushBack (lbCurSel _ctrl)};          //combo
        case 77: {_resaults pushBack (cbChecked _ctrl)};        //checkbox
        case 43: {_resaults pushBack (sliderPosition _ctrl)};   //slider
        case 3: {_resaults pushBack (sliderPosition _ctrl)};
        case 2: {_resaults pushBack (ctrlText _ctrl)};          //edit
    };
} forEach _ctrls;

//if ok
if (!isNull (findDisplay 1031982)) then {(findDisplay 1031982) closeDisplay 1};	//only this page (closeDialog 0 also closed the window under it after Cancel)

_resaults;