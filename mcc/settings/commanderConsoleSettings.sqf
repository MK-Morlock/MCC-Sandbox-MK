// ==================== Commander Console ==========================================
//Commander Console
[
    "MCC_allowConsole",
    "CHECKBOX",
    ["Commander Console Enabled","Player can become a side commander from the MCC respawn\nscreen"],
   "MCCMK Commander Console",
    true,
    true
] call CBA_Settings_fnc_init;

//RTS
[
    "MCC_allowRTS",
    "CHECKBOX",
    ["RTS","Enable Real Time Strategy mod from the commander\nconsole, build, expand and conquer"],
    "MCCMK Commander Console",
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCC_rtsPersonnelMode",
    "LIST",
    ["Personnel that use food and bunks","Which soldiers count towards the RTS personnel limit,\nhourly food use and bunks."],
    ["MCCMK Commander Console", "RTS / Base"],
    [[0,1,2],["Players and controllable groups","Also AI in players' squads","All friendly AI on the side"],0],
    true
] call CBA_Settings_fnc_init;

//-=================================================== Air support ===---

//Commander Console Purchable airDrops
[
    "MCC_defaultSupplyDropsEnabled",
    "CHECKBOX",
    ["Purchase air drop","Commander can trade resources for air Drops - works\nonly on mission restart"],
    ["MCCMK Commander Console", "Air support"],
    true,
    true
] call CBA_Settings_fnc_init;

//AC-130 up time
[
    "MCC_ConsoleACTime",
    "SLIDER",
    ["AC-130 uptime","How long in seconds can an AC-130 stay in the air\nbefore he is RTB"],
    ["MCCMK Commander Console", "Air support"],
    [0, 1200, 360, 0],
    true
] call CBA_Settings_fnc_init;

//Commander Console Purchasable CAS
[
    "MCC_defaultCASEnabled",
    "CHECKBOX",
    ["Purchase CAS","Commander can trade resources for close air support -\nworks only on mission restart"],
    ["MCCMK Commander Console", "Air support"],
    true,
    true
] call CBA_Settings_fnc_init;

//-==================== Tracking ==================----------
//Commander Console Show units without GPS
[
    "MCC_ConsoleOnlyShowUnitsWithGPS",
    "CHECKBOX",
    ["Only show units with a GPS","Blue-force tracking: the Commander Console (and the squad\nleader PDA) shows a player-led group only when its leader\ncarries a GPS - the MCC console item counts - or a UAV terminal.\nAI groups and groups in vehicles are always shown."],
    ["MCCMK Commander Console", "Tracking"],
    true,
    true
] call CBA_Settings_fnc_init;

//Commander Show friendly WP
[
    "MCC_ConsolePlayersCanSeeWPonMap",
    "CHECKBOX",
    ["Show friendly WP","Show friendly group way points on console"],
    ["MCCMK Commander Console", "Tracking"],
    true,
    true
] call CBA_Settings_fnc_init;

//(MK) Commandable groups in the commander's High Command (MCCMK_fnc_hcCommander)
[
    "MCCMK_hcCommandable",
    "CHECKBOX",
    ["Commandable groups go to High Command", "The side's commander gets Arma's High Command of every\ncommandable AI group of his side (spawned as Commandable,\nRTS-bought, UAVs), so he can order them from the map\n(Ctrl+Space by default) as well as from the Commander\nConsole. His own and other players' squads, and GAIA\ngroups, are left out. A new commander takes them over."],
    ["MCCMK Commander Console", "Tracking"],
    true,
    true
] call CBA_Settings_fnc_init;

//(MK) a waypoint given from the MCC console (Way Points window): does the group stay commandable? (MCC's own rule takes
//it off the commander)
[
    "MCCMK_wpKeepCommandable",
    "CHECKBOX",
    ["MCC console waypoints keep groups commandable", "Off (as MCC): a waypoint given from the MCC console's Way Points\nwindow takes the group off the side's commander - it is no longer\ncommandable, leaves High Command and loses its (P).\nOn: the group takes the waypoint and stays commandable."],
    ["MCCMK Commander Console", "Tracking"],
    false,
    true
] call CBA_Settings_fnc_init;

//Commander Console Can command AI
[
    "MCC_ConsoleCanCommandAI",
    "CHECKBOX",
    ["Command AI","Commander can issue order to AI groups given to him by\nmission maker"],
    ["MCCMK Commander Console", "Tracking"],
    true,
    true
] call CBA_Settings_fnc_init;

//Live feed helmet
[
    "MCC_ConsoleLiveFeedHelmetsOnly",
    "CHECKBOX",
    ["Restrict live feed","Restrict live feed to vehicles and units wearing one of\nthe specific helmets only"],
    ["MCCMK Commander Console", "Live Feed"],
    false,
    true
] call CBA_Settings_fnc_init;

//Live feed helmet
[
    "MCC_ConsoleLiveFeedHelmets",
    "EDITBOX",
    ["Live feed helmets","Restrict live feed to vehicles and units wearing one of\nthe specific helmets only"],
    ["MCCMK Commander Console", "Live Feed"],
    '["H_HelmetB","H_HelmetB_paint","H_HelmetB_light","H_HelmetO_ocamo","H_HelmetLeaderO_ocamo","H_HelmetSpecO_ocamo","H_HelmetSpecO_blk"]',
    true,
    {
        params ["_value"];
        MCC_ConsoleLiveFeedHelmets = [_value, '["H_HelmetB","H_HelmetB_paint","H_HelmetB_light","H_HelmetO_ocamo","H_HelmetLeaderO_ocamo","H_HelmetSpecO_ocamo","H_HelmetSpecO_blk"]', "MCC_ConsoleLiveFeedHelmets"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//-=================================================== Make HQ ===---
[
    "MCC_makeHQWho",
    "LIST",
    ["Make HQ action at an F.O.B.","Who can use the Make HQ action at an F.O.B. or ship\n(and the Commander console's Make HQ button)."],
    ["MCCMK Commander Console", "Make HQ"],
    [[0,1],["Commander only","Commander and squad leaders"],0],
    true
] call CBA_Settings_fnc_init;
[
    "MCC_makeHQCostSupply",
    "SLIDER",
    ["Make HQ cost: Supply","Supply needed to make an F.O.B. the HQ. 0 = free."],
    ["MCCMK Commander Console", "Make HQ"],
    [0, 5000, 600, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCC_makeHQCostFuel",
    "SLIDER",
    ["Make HQ cost: Fuel","Fuel needed to make an F.O.B. the HQ. 0 = free."],
    ["MCCMK Commander Console", "Make HQ"],
    [0, 5000, 200, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCC_makeHQCooldown",
    "SLIDER",
    ["Make HQ cooldown (minutes)","Minimum time between two HQ moves for a side. 0 = no\ncooldown."],
    ["MCCMK Commander Console", "Make HQ"],
    [0, 60, 10, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCC_makeHQEnemyDist",
    "SLIDER",
    ["Make HQ: no enemy within (m)","The HQ cannot be moved while enemies are this close to\nthe F.O.B. or the current HQ. 0 = no check."],
    ["MCCMK Commander Console", "Make HQ"],
    [0, 1000, 300, 0],
    true
] call CBA_Settings_fnc_init;

//-=================================================== Ships ===---
[
    "MCCMK_shipPriceDestroyer",
    "EDITBOX",
    ["Destroyer price","Supply, Ammo, Fuel to buy a destroyer from the HQ\n(RTS)."],
    ["MCCMK Commander Console", "Ships"],
    "1500,1000,800",
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipPriceCarrier",
    "EDITBOX",
    ["Aircraft carrier price","Supply, Ammo, Fuel to buy an aircraft carrier from the\nHQ (RTS)."],
    ["MCCMK Commander Console", "Ships"],
    "1500,600,1000",
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipPriceSub",
    "EDITBOX",
    ["Submarine price","Supply, Ammo, Fuel to buy a submarine from the HQ\n(RTS)."],
    ["MCCMK Commander Console", "Ships"],
    "800,0,400",
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipPriceLHD",
    "EDITBOX",
    ["LHD price (CUP)","Supply, Ammo, Fuel to buy a CUP LHD from the HQ (RTS)."],
    ["MCCMK Commander Console", "Ships"],
    "2000,800,1200",
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipDepths",
    "EDITBOX",
    ["Minimum water depth (m)","Destroyer, Carrier, Submarine, LHD - depth needed under\nthe whole ship to place or move it."],
    ["MCCMK Commander Console", "Ships"],
    "12,15,10,12",
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipRange",
    "SLIDER",
    ["Ships: distance from HQ or F.O.B. (m)","A ship can only be placed or moved this close to your\nHQ or an F.O.B. 0 = anywhere at sea."],
    ["MCCMK Commander Console", "Ships"],
    [0, 20000, 3000, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipArrive",
    "SLIDER",
    ["New ship arrival time (seconds)","How long a bought ship takes to arrive."],
    ["MCCMK Commander Console", "Ships"],
    [0, 900, 120, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipMoveFuel",
    "SLIDER",
    ["Move ship: Fuel per km","Fuel cost to move a ship, per km (minimum 100). 0 =\nfree."],
    ["MCCMK Commander Console", "Ships"],
    [0, 500, 50, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipMoveTime",
    "SLIDER",
    ["Move ship: repositioning time per km (seconds)","How long a moved ship is unavailable, per km of the\nmove."],
    ["MCCMK Commander Console", "Ships"],
    [0, 300, 60, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipMoveTimeMax",
    "SLIDER",
    ["Move ship: longest repositioning time (seconds)","Upper limit for the repositioning time."],
    ["MCCMK Commander Console", "Ships"],
    [0, 1800, 600, 0],
    true
] call CBA_Settings_fnc_init;

//-=================================================== Selling vehicles ===---
[
    "MCCMK_sellBought",
    "SLIDER",
    ["Refund for bought vehicles (%)","Share of the price paid that comes back when a bought\nvehicle is sold."],
    ["MCCMK Commander Console", "Selling vehicles"],
    [0, 100, 60, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_sellSeized",
    "SLIDER",
    ["Value of seized enemy vehicles (%)","Share of a new vehicle's price paid for a seized enemy\nvehicle."],
    ["MCCMK Commander Console", "Selling vehicles"],
    [0, 100, 40, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_sellDamage",
    "CHECKBOX",
    ["Damage reduces the price","A damaged vehicle sells for less, in proportion to its\ndamage."],
    ["MCCMK Commander Console", "Selling vehicles"],
    true,
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_sellRadius",
    "SLIDER",
    ["Selling distance (m)","How close a vehicle must be to the HQ, an F.O.B., a\nvehicle shop or a ship to be sold."],
    ["MCCMK Commander Console", "Selling vehicles"],
    [5, 200, 30, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_shipGap",
    "SLIDER",
    ["Ships: gap between hulls (m)","How much water there must be between two ships when one\nis placed or moved."],
    ["MCCMK Commander Console", "Ships"],
    [0, 400, 10, 0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipMarkerDefault",
    "CHECKBOX",
    ["Show friendly ships on the map","Default for new ships: a NATO naval symbol on your\nside's map (name on hover). Each ship can be switched\nin its Ship Control menu."],
    ["MCCMK Commander Console", "Ships"],
    false,
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_deckAI",
    "LIST",
    ["AI arriving on a ship's deck","Hold until ordered: they stay where they are put until\ngiven an order.\nFree: they go to their formation spots straight away.\nFree, with automatic recovery: as Free, and anyone who\nfalls overboard is put back on deck."],
    ["MCCMK Commander Console", "Ships"],
    [[0,1,2],["Hold until ordered","Free","Free, with automatic recovery"],0],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_shipRadarDefault",
    "CHECKBOX",
    ["Ship radar and data link on at start","New ships start with radar and data link on (switch per\nship in Ship status). Radar gives warnings and a\ncontact log, but an emitting radar helps the enemy find\nyou."],
    ["MCCMK Commander Console", "Ships"],
    false,
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_shipsCanBeLost",
    "CHECKBOX",
    ["Ships can be damaged and lost","Hull damage from explosives: smoke at 50 %, crippled at\n25 %, and at 0 % a destroyer sinks and a carrier or LHD\nis disabled until repaired."],
    ["MCCMK Commander Console", "Ships"],
    true,
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_planeReverse",
    "LIST",
    ["Aircraft reversing","Hold the airbrake key with the plane stopped on the\nground to roll backwards. Off if another mod already\ndoes this."],
    "MCCMK Mechanics",
    [[0,1,2],["Everywhere","On ship decks only","Off"],0],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_navalGunCost",
    "EDITBOX",
    ["Naval gun cost","Ammo, Fuel for a 5-round salvo from a ship's gun."],
    ["MCCMK Commander Console", "Naval fire support"],
    "75,0",
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_navalVLSCost",
    "EDITBOX",
    ["Cruise missile cost","Ammo, Fuel for one VLS cruise missile."],
    ["MCCMK Commander Console", "Naval fire support"],
    "150,50",
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_navalThreats",
    "LIST",
    ["Naval threats","Campaign only. The enemy has to find your ships first:\nreconnaissance, then air strikes and boats from a\ncoastal base. Sets how aggressive the enemy is."],
    ["MCCMK Commander Console", "Naval threats"],
    [[0,1,2,3],["Off","Low","Medium","High"],1],
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_sarEnabled",
    "CHECKBOX",
    ["Search and rescue","Anyone in the water, aboard a crippled floating\naircraft or aboard a crippled boat can request a rescue\n(by helicopter): from their side's ship\nwithin 6 km, else as 'Search and rescue without a ship'."],
    ["MCCMK Commander Console", "Search and rescue"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_sarNoShip",
    "LIST",
    ["Search and rescue without a ship", "No ship of the side within 6 km - Off: no rescue.\nOut of sight: a helicopter from out of sight (about\n4.5 km), a tug from open water (about 2-3 km); home to\nthe side's nearest HQ or F.O.B."],
    ["MCCMK Commander Console", "Search and rescue"],
    [[0, 1], ["Off", "Out of sight"], 1],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_sarPickup",
    "LIST",
    ["Rescue pickup", "How a rescue helicopter takes people aboard - Rope climb:\nit hovers with two ropes, AI swim to them, players use\n'Climb rope'. Instant: placed aboard when it's close."],
    ["MCCMK Commander Console", "Search and rescue"],
    [[0, 1], ["Rope climb", "Instant"], 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_sarClimbSpeed",
    "SLIDER",
    ["Rope climb speed", "Metres a second up a rescue rope (1 = a realistic climb,\n2-3 = more like being winched)."],
    ["MCCMK Commander Console", "Search and rescue"],
    [0.5, 3, 1.5, 1],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_floatAircraft",
    "CHECKBOX",
    ["Floating aircraft", "Large aircraft float on water: watertight while they can\nfly, a slow leak once crippled (they sink). Carrier\naircraft can load and unload a small boat."],
    ["MCCMK Commander Console", "Water"],
    true,
    true
] call CBA_Settings_fnc_init;
//(MK) Floatary: driving a boat straight into a carrier's bay loads it (MCCMK_fnc_boardingInit) - "Load watercraft" stays too
[
    "MCCMK_driveInLoad",
    "CHECKBOX",
    ["Floatary: drive-in loading", "Drive a small boat straight up the ramp of a carrier sitting\non the water - lined up with it, pointing in, moving - and\nit is taken into the bay. Miss, and you hit the helicopter.\n'Load watercraft' from behind it still works as well."],
    ["MCCMK Commander Console", "Water"],
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_scuttleLeak",
    "SLIDER",
    ["Scuttle leak (aircraft)", "How fast a scuttled aircraft takes on water, in litres a\nsecond (the game's water leakiness - 10 is its usual\nstarting value). Time it with debug on: the RPT logs how\nfull it is every 10 s."],
    ["MCCMK Commander Console", "Water"],
    [0.1, 50, 10, 1],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_scuttleTime",
    "SLIDER",
    ["Scuttle time (boats)", "Minutes a scuttled boat takes to flood (a boat floating\nupright ignores the game's leak, so it's flooded a little\nat a time; full and still afloat: it goes down)."],
    ["MCCMK Commander Console", "Water"],
    [1, 30, 5, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_ropeAnim",
    "LIST",
    ["Rope animation", "Harness: Advanced Rappelling (ships with MCC MK) - a rope\nper man, swinging with the rotor wash and the wind;\nplayers hold S to go down (Shift faster), W to climb up;\nAI go by themselves. Also 'Request pickup rope' and\n'Pickup rope: my squad'. Ladder: MCC's own (vanilla pose)."],
    ["MCCMK Commander Console", "Ropes"],
    [[0, 1], ["Harness (Advanced Rappelling)", "Ladder (vanilla)"], 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_anchorsEnabled",
    "CHECKBOX",
    ["Anchors (built in)","Anchoring, mooring, shore and tow lines, tethering and\nwind drift for boats. Takes effect at the next mission\nstart. No effect when the standalone Anchors mod is\nloaded."],
    "MCCMK Anchors",	//(MK) no subcategory: listed first, above all the Anchors sections
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_resCampaign",
    "LIST",
    ["Resources - campaign","While a campaign is running.\nOn: everything costs resources, and completed missions\npay rewards.\nFree: nothing costs anything (shown as the infinity\nsign) - a good way to learn."],
    ["MCCMK Resources", "Modes"],
    [[0,1],["On","Free"],0],
    true,
    {if (isServer) then {[] call MCCMK_fnc_resFreeLoop}}
] call CBA_Settings_fnc_init;

[
    "MCCMK_resSandbox",
    "LIST",
    ["Resources - without a campaign","Mission Generator, Front Line or sandbox play.\nOn: everything costs resources; generated missions pay\nrewards.\nOriginal MCC: everything costs resources, missions pay\nnothing, and the mission maker hands out resources.\nFree: nothing costs anything."],
    ["MCCMK Resources", "Modes"],
    [[0,1,2],["On","Original MCC","Free"],0],
    true,
    {if (isServer) then {[] call MCCMK_fnc_resFreeLoop}}
] call CBA_Settings_fnc_init;

[
    "MCCMK_rewardMultCampaign",
    "LIST",
    ["Reward multiplier - campaign","How much completed campaign missions pay, compared with\nnormal."],
    ["MCCMK Resources", "Rewards"],
    [[0,1,2,3],["x0.5","x1","x2","x3"],1],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_rewardMultSandbox",
    "LIST",
    ["Reward multiplier - without a campaign","How much completed generated missions pay, compared\nwith normal."],
    ["MCCMK Resources", "Rewards"],
    [[0,1,2,3],["x0.5","x1","x2","x3"],1],
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_shipReplaceCost",
    "EDITBOX",
    ["Ships: replace a weapon","Supply, Ammo to replace one destroyed ship weapon."],
    ["MCCMK Commander Console", "Ships"],
    "200,100",
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_podCostFuel",
    "EDITBOX",
    ["Fuel pod cost","Ammo, Supply, Fuel, Meds - including the flight. A fuel\npod refuels vehicles beside it."],
    ["MCCMK Commander Console", "Taru supply pods"],
    "0,0,250,0",
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_podCostRepair",
    "EDITBOX",
    ["Repair pod cost","Ammo, Supply, Fuel, Meds - including the flight. A\nrepair pod repairs vehicles beside it."],
    ["MCCMK Commander Console", "Taru supply pods"],
    "0,200,50,0",
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_podCostAmmo",
    "EDITBOX",
    ["Ammunition pod cost","Ammo, Supply, Fuel, Meds - including the flight. An\nammunition pod rearms vehicles beside it."],
    ["MCCMK Commander Console", "Taru supply pods"],
    "200,0,50,0",
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_podCostMedical",
    "EDITBOX",
    ["Medical pod cost","Ammo, Supply, Fuel, Meds - including the flight. A\nmedical pod is a field medical station."],
    ["MCCMK Commander Console", "Taru supply pods"],
    "0,0,50,75",
    true
] call CBA_Settings_fnc_init;

[
    "MCCMK_podCostLogistics",
    "EDITBOX",
    ["Logistics pod cost","Ammo, Supply, Fuel, Meds - including the flight. A\nlogistics pod is a cargo container."],
    ["MCCMK Commander Console", "Taru supply pods"],
    "0,150,50,0",
    true
] call CBA_Settings_fnc_init;

//(MK) SUPPORT AIRCRAFT (MCCMK_fnc_supportAir): the rescue helicopter (or boat), rope extraction, pickup and Boat pickup
// helicopters, fast-rope helicopters, the airdrop plane and paradrop aircraft - set as each is created
[
    "MCCMK_supportInvuln",
    "CHECKBOX",
    ["Support aircraft: invulnerable", "The rescue helicopter (and rescue boat), rope extraction,\npickup and Boat pickup helicopters, fast-rope helicopters,\nthe airdrop plane and paradrop aircraft: on - they and\ntheir crews can't be damaged. Set as each is created."],
    ["MCCMK Commander Console", "Support aircraft"],
    false,
    true
] call CBA_Settings_fnc_init;
[
    "MCCMK_supportTargeted",
    "CHECKBOX",
    ["Support aircraft: targeted by the enemy", "Off: their crews are captive and the enemy ignores them\n(they can still be damaged unless invulnerable).\nOn: the enemy treats them as normal targets.\nEither way their side is told if one is destroyed.\nSet as each is created."],
    ["MCCMK Commander Console", "Support aircraft"],
    false,
    true
] call CBA_Settings_fnc_init;

//(MK) Pickup for a squad's Taru pod drop (MCCMK_fnc_taruPickup): smoke at the LZ when the Tarus come in (it can cost frames)
[
    "MCCMK_pickupSmoke",
    "CHECKBOX",
    ["Pickup: smoke at the LZ", "With a squad's Pod drop or Winch drop by Pickup, a smoke\nshell at the LZ as the Tarus come in. (The LZ is always\nmarked on the map.) Smoke can cost frames."],
    ["MCCMK Commander Console", "Air support"],
    false,
    true
] call CBA_Settings_fnc_init;
