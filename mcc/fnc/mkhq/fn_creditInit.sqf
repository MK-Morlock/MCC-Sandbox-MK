if (isServer) then {
	MCCMK_creditRestored = [];
	if (isNil "MCCMK_creditKey") then {MCCMK_creditKey = ""};	//(MK) not kept until a campaign or the mission's saving sets it
	addMissionEventHandler ["HandleDisconnect", {
		params ["_u", "_id", "_uid", "_name"];
		if (_uid != "" && {_uid in MCCMK_creditRestored}) then {[_uid, _name, _u getVariable ["MCC_valorPoints", 50]] call MCCMK_fnc_creditStore};
		MCCMK_creditRestored = MCCMK_creditRestored - [_uid];
		false
	}];
	// Every 30 s: credits that CHANGED are stored; the profile is written to disk at most every 5 minutes, and only
	// when something changed (writing the whole profile every 30 s made the game hitch), and when the mission ends.
	MCCMK_creditLast = createHashMap;
	MCCMK_creditDirty = false;
	MCCMK_creditSaveAt = 0;
	MCCMK_creditFlush = {
		if (MCCMK_creditDirty && {!(missionNamespace getVariable ["MCC_dbDeferSave", false])} && {!(missionNamespace getVariable ["MCC_iniDBenabled", false])}) then {saveProfileNamespace};
		MCCMK_creditDirty = false;
		MCCMK_creditSaveAt = time + 300;
	};
	addMissionEventHandler ["Ended", {call MCCMK_creditFlush}];
	addMissionEventHandler ["MPEnded", {call MCCMK_creditFlush}];
	[] spawn {
		while {true} do {
			sleep 30;
			private _defer = missionNamespace getVariable ["MCC_dbDeferSave", false];
			MCC_dbDeferSave = true;
			{
				private _uid = getPlayerUID _x;
				private _v = _x getVariable ["MCC_valorPoints", 50];
				if (_uid in MCCMK_creditRestored && {(MCCMK_creditLast getOrDefault [_uid, -1e9]) != _v}) then {
					[_uid, name _x, _v] call MCCMK_fnc_creditStore;
					MCCMK_creditLast set [_uid, _v];
					MCCMK_creditDirty = true;
				};
			} forEach allPlayers;
			MCC_dbDeferSave = _defer;
			if (MCCMK_creditDirty && {time >= MCCMK_creditSaveAt}) then {call MCCMK_creditFlush};
		};
	};
};
if (hasInterface) then {
	[] spawn {
		waitUntil {sleep 0.5; !isNull player && {getPlayerUID player != ""}};
		sleep 2;
		[player] remoteExec ["MCCMK_fnc_creditRestore", 2];
		player addEventHandler ["Respawn", {
			params ["_new", "_old"];
			if (!isNull _old) then {_new setVariable ["MCC_valorPoints", _old getVariable ["MCC_valorPoints", 50], true]};
		}];
	};
};
