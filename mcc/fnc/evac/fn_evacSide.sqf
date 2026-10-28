private _cs = switch (toLower (missionNamespace getVariable ["mcc_sidename", "west"])) do {case "east": {east}; case "guer": {resistance}; case "civ": {civilian}; default {west}};
private _ps = (allPlayers - entities "HeadlessClient_F") apply {side group _x};
if (_cs in _ps) then {_cs} else {side group player}
