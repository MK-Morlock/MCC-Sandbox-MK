// Are resource costs off right now? While a campaign runs: "Resources - campaign" = Free; otherwise "Resources -
// without a campaign" = Free.
if (missionNamespace getVariable ["MCCMK_campaignSetupDone", false]) then {(missionNamespace getVariable ["MCCMK_resCampaign", 0]) == 1} else {(missionNamespace getVariable ["MCCMK_resSandbox", 0]) == 2}
