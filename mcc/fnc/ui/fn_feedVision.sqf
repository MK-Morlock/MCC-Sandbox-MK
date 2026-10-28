/*================================================================== MCC_fnc_feedVision ==================================================================
	One place for the view mode of every MCC video feed (UAV / cruise missile, gunship, console unit feed, live feed):
	Arma's own modes only, as Arma UAV feeds use them. The choice is saved per kind of feed, so each feed opens in the mode
	last chosen for it.
	<IN>	0: STRING render target, e.g. "rendertarget9"
			1: NUMBER mode: 0 Regular, 1 night vision, 2 thermal (white hot)
			2: STRING feed kind for the saved choice: "uav", "ac", "unit", "live" ("" = do not save)
	<OUT>	STRING label for the feed text: "VIDEO", "N/V", "WHOT"
==============================================================================================================================================================*/
params [["_rt", "", [""]], ["_mode", 0, [0]], ["_kind", "", [""]]];
_mode = (_mode max 0) min 2;
if (_rt != "") then {_rt setPiPEffect ([[0], [1], [2]] select _mode)};
if (_kind != "") then {profileNamespace setVariable ["MCC_feedVision_" + _kind, _mode]};
["VIDEO", "N/V", "WHOT"] select _mode
