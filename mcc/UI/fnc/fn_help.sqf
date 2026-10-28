//==================================================================MCC_fnc_help===============================================================================================
// Display tooltip
//==================================================================================================================================================================================

private _control = controlNull;
private _open = false;
private _multiplierW = 0;
private _multiplierH = 0;
private _pos = [];
private _posX = 0;
private _posY = 0;
private _posW = 0;
private _posH = 0;
private _helpText = "";
private _text = "";
disableSerialization;

_control	= (_this select 0) select 0;
_open  		= _this select 1;
_multiplierW = (_this select 2) select 0;
_multiplierH = (_this select 2) select 1;
_helpText 	= _this select 3;

_pos = ctrlPosition _control;
_posX = _pos select 0;
_posY = _pos select 1;

if (_open) then
{
	_text = "";
	switch (_helpText) do
		{
			case ("console") :
			{
				_text = _text +"<t size='0.8'>* Right click on a squad icon to inspect it</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Live feed: right click a squad icon on the map, then press 'Live Feed' in the panel that opens to watch through that squad leader (or his vehicle)</t><br/><br/>";
				_text = _text +"<t size='0.8'>* While inspecting a squad you can take control over a UAV by clicking 'Take Control' button</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Draw a box around groups to select several or individually select groups by holding Ctrl and clicking on a squad's icon</t><br/><br/>";
				_text = _text +"<t size='0.8'>* You can create group squads together by pressing Ctrl + 1-9 keys, press 1-9 key to quickly select the squads again</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Issue orders by double clicking the map or create a quick waypoint by holding Ctrl + double click the map</t>"
			};
			case ("squadDialog") :
			{
				_text = _text + "<a underline='true' href='http://mccsandbox.wikia.com/wiki/Squad_Dialog'>Wiki:&#160;Squad&#160;Dialog</a>"
			};

			case ("mccmain") :
			{
				_text = _text +"<t size='0.8'>* Right click on a squad icon to inspect it</t><br/><br/>";
				_text = _text +"<t size='0.8'>* While inspecting a squad you can assign its behaviour or number of respawns</t><br/><br/>";
				_text = _text +"<t size='0.8'>* While inspecting a squad you can cache the group or give it to a player to control (Commander Console)</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Draw a box around groups to select several or individually select groups by holding Ctrl and clicking on a squad's icon</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Issue orders by double clicking the map or create a quick waypoint by holding Ctrl + double click the map</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Delete selected groups by pressing the Delete key</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Use the group management section below to control units inside the group</t><br/><br/>";
				_text = _text +"<t size='0.8'>* Press Alt + left mouse button to open the 3D editor</t>"
			};
		};

	_posW = (_pos select 2)*_multiplierW;
	_posH = (_pos select 3)*_multiplierH;

	_control ctrlSetPosition [_posX,_posY,_posW,_posH];
	_control ctrlCommit 0;
	waituntil {ctrlCommitted _control};
	_control ctrlRemoveAllEventHandlers "MouseEnter";
	_control ctrlAddeventhandler ["MouseExit",format ["[_this, false,%1,'%2'] spawn MCC_fnc_help",[_multiplierW,_multiplierH],_helpText]];
	_control ctrlSetStructuredText parseText _text;
	//MCC console (?): the rounded button is only under the small (?), so the open help gets its own panel
	if (_helpText in ["mccmain", "console"]) then {_control ctrlSetBackgroundColor [0.11,0.12,0.13,0.96]};
}
else
{
	_posW = (_pos select 2)/_multiplierW;
	_posH = (_pos select 3)/_multiplierH;

	_control ctrlSetPosition [_posX,_posY,_posW,_posH];
	_control ctrlCommit 0;
	waituntil {ctrlCommitted _control};
	_control ctrlRemoveAllEventHandlers "MouseExit";
	_control ctrlAddeventhandler ["MouseEnter",format ["[_this, true,%1,'%2'] spawn MCC_fnc_help",[_multiplierW,_multiplierH],_helpText]];
	if (_helpText in ["mccmain", "console"]) then {
		_control ctrlSetBackgroundColor [0,0,0,0];	//back on the rounded button
		_control ctrlSetStructuredText parseText "";	//the centred (?) label under it shows again
	} else {
		_control ctrlSetStructuredText parseText "?";
	};
};

