// Do completed missions pay resources right now? Only when the current mode is On ("Original MCC" pays nothing - the
// mission maker hands resources out; "Free" needs none).
if (missionNamespace getVariable ["MCCMK_campaignSetupDone", false]) then {(missionNamespace getVariable ["MCCMK_resCampaign", 0]) == 0} else {(missionNamespace getVariable ["MCCMK_resSandbox", 0]) == 0}
