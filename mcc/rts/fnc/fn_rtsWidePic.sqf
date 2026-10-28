params [["_pic", "", [""]]];
if ((count _pic) < 5 || {(toLower (_pic select [(count _pic) - 4])) != ".paa"}) exitWith {_pic};
private _wide = (_pic select [0, (count _pic) - 4]) + "_w.paa";
if (fileExists _wide) then {_wide} else {_pic}
