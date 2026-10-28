//==================================================================  MCC_fnc_makeMarker =======================================================

disableSerialization;


params ["_case", "_color", "_size", "_shape", "_brush", "_type", "_text", "_pos", "_dir"];

if (isnil "_text") exitWith {};
if (_text == "") exitWith {};

if (isnil "_dir") then {_dir = 0};

mcc_safe=mcc_safe + FORMAT ['	_case=%1;
								_color="%2";
								_size=%3;
								_shape = "%4";
								_brush="%5";
								_type="%6";
								_text="%7";
								_pos = %8;
								_dir = %9;
								[_case, _color, _size, _shape, _brush, _type, _text, _pos, _dir] call MCC_fnc_makeMarker;
								'
								,_case
								,_color
								,_size
								,_shape
								,_brush
								,_type
								,_text
								,_pos
								,_dir
							   ];

if (isNil "MCC_activeMarkers") then {
	MCC_activeMarkers = [];
};

switch (_case) do {
	case 0:		//Create Marker
	{
		if (markershape _text != "") then
		{
			deleteMarker _text;
			MCC_activeMarkers = MCC_activeMarkers - [_text];
		};

		createMarker [_text, _pos];
		_text setMarkerColor _color;
		_text setMarkerType  _type;
		_text setmarkertext _text;
		_text setmarkerdir _dir;
		MCC_activeMarkers pushBack _text;
	};

   case 1:	//Create Brush
   {
		if (markershape _text != "") then {
			deleteMarker _text;
			MCC_activeMarkers = MCC_activeMarkers - [_text];
		};

		createMarker [_text, _pos];
		_text setMarkerColor _color;
		_text setMarkerSize _size;
		_text setMarkerShape  _shape;
		_text setMarkerBrush  _brush;
		_text setmarkerdir _dir;
		MCC_activeMarkers pushBack _text;
	};

    case 2: //Delete
	{
		deleteMarker _text;
		MCC_activeMarkers = MCC_activeMarkers - [_text];
	};
};

publicVariable "MCC_activeMarkers";