// A config picture, only if the file really exists - many objects carry a placeholder ("picturething") or nothing,
// which Arma reports as "Picture ... not found". Otherwise the fallback icon. [path, fallback]
params [["_p", "", [""]], ["_fb", "\a3\ui_f\data\igui\cfg\simpletasks\types\box_ca.paa", [""]]];
if (_p == "") exitWith {_fb};
if (fileExists _p || {fileExists (_p + ".paa")}) exitWith {_p};
_fb
