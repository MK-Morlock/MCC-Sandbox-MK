class general
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\general";
	class pre_init
	{
		preInit = 1;
		description = "Pre init mod only";
	};
	#else
	file = "mcc\fnc\general";
	#endif

	class login {};
	class unitCategory {description = "MCC unit category of a class, also for mod vehicleClass names";};
	class combatInfantry {description = "Ground infantry only from a faction soldier list (no pilots, crews, divers, unarmed)";};
	class factionSide {description = "Side number of a faction, also when CfgFactionClasses has no side";};
	class activateAddons {preInit = 1; description = "Pre init addon";};
	class gear	{preInit = 1; description = "Assign gear by roles";};

	class mobileRespawn	{description = "will move the respawn marker to the current position of the unit while the unit is alive, if the unit dead will move the marker to the prvious location.";};
	class buildingPosCount	{description = "return the ammount of indexed positions in a building.";};
	class posOnBuilding	{description = "(MK) is a spawn spot on, in or under a building";};
	class gaiaFireSafe	{description = "(MK) GAIA artillery: is it safe to fire at this spot";};
	class roadsideSpot	{description = "(MK) a clear roadside spot for a vehicle, on the nearest roads to a point";};
	class vehicleCanDriveOut	{description = "(MK) can a vehicle drive from a spot to the nearest road (or the zone centre), by the AI pathfinder";};
	class nextZoneNumber	{description = "(MK) lowest zone number not in use";};
	class secAction	{description = "(MK) fixed named actions that players can request on other machines";};
	class secSenderOK	{description = "(MK) server side: was this remote call sent by the server, an admin, the mission maker, a Zeus or a headless client";};
	class secRemote	{description = "(MK) remote call routed through the server, which checks the sender";};
	class secRelay	{description = "(MK) server side of secRemote: only the mission maker, admins, Zeus and headless clients are relayed";};
	class isWaterStructure	{description = "(MK) is a building a pier, jetty, bridge or other structure over water";};
	class isUtilityVehicle	{description = "(MK) an unarmed, single-seat, non-supply vehicle such as an aircraft tug";};
	class landSpot	{description = "(MK) a land spot for people: no water, rocks, steep ground or buildings close by";};
	class structuresNear	{description = "(MK) is there a building, wall, fence or other structure within a radius";};
	class compositionFootprint	{description = "(MK) radius a composition covers, from its pieces";};
	class contentAllowed	{description = "(MK) does a class pass the Mission Generator content filter for a faction";};
	class contentFilterList	{description = "(MK) a unit list with the Mission Generator content filter applied";};
	class gaiaSentryHold	{description = "(MK) GAIA sentry teams hold their spot instead of re-forming";};
	class findFlatSpot	{description = "(MK) the flattest open spot near a position, inside its zone";};
	class safeSpawnPos	{description = "(MK) a safe spawn spot for a group or vehicle near a position";};
	class clearVehicleSpot	{description = "(MK) a clear spot for a vehicle near a position";};
	class openSpotNear	{description = "(MK) Nearest open ground around a spawn spot that was on a building";};
	class paraOffRoof	{description = "(MK) AI parachutist landed: chute removed, off a roof when nobody is near or watching";};
	class makeUnitsArray	{description = "returns a unit array consist of all the units from the given function and simulation in format [_cfgclass,_vehicleDisplayName].";};
	class countGroup	{description = "Count the number of infantry, vehicles, tank, air, ships in a group.";};
	class edenFactionCombo	{description = "Eden faction drop-down for MCC module attributes";};
	class assetRoleMatch	{description = "Does a class fit an asset role";};
	class factionVehicles	{description = "A faction own vehicles for a role (tank, aa, artillery, air, podCarrier, gunship)";};
	class factionSiblings	{description = "Other factions of the same mod and side";};
	class toggleRespawn	{description = "Console respawn button: switch player respawn off or on";};
	class respawnButton	{description = "Console respawn button text";};
	class respawnRestore	{description = "Bring a spectating player back when respawn is on again";};
	class supportFactionOK	{description = "No support menus for civilian factions";};
	class edenStartLocPreview	{description = "Eden: preview of Start Location modules";};
	class uavCanAim {description = "(MK) Commander console UAV view: can the drone's weapon reach the aim point, by the turret's own traverse / elevation limits (or a fixed weapon's missile lock cone): [ok, details]";};
	class uavPickWeapon {description = "(MK) Commander console UAV view: the drone's first loaded missile or bomb (pilot or gunner, pylons included) as [label, rounds, weapon, ammo, firing unit]";};
	class uavSetHeight {description = "(MK) Commander console UAV view: set a drone's flight height and have it hold its position there, so it climbs or descends";};
	class formationMove {description = "(MK) Player-led squad given a move order: each AI goes to his formation slot around the destination (leader's spot left empty) and falls back in when the leader arrives";};
	class acReticle {description = "(MK) AC-130 console view: draw the gunship sight reticle (cross with ticks and corner brackets) over the video";};
	class consoleApply3D {description = "(MK) Buttons console: swap the static flat button pictures of a window for their 3D versions";};
	class openDebug {description = "(MK) Open Arma's debug console from the MCC Debug panel and say so when the game refuses it";};
	class dialogName {description = "(MK) Name of an MCC window for the chosen console look (Flat or Buttons)";};
	class supportHint {description = "(MK) The 'Air support incoming' hint, with a control reminder for the AC-130 (gun control) and the UAVs (camera control)";};
	class acAmmoType {description = "(MK) AC-130 console view: the selected 40mm ammunition type (HE or AP) as [muzzle, label, rounds left]";};
	class acAmmoRefresh {description = "(MK) AC-130 console view: refresh the 40mm counter and the ammunition button";};
	class acAmmoToggle {description = "(MK) AC-130 console view: switch the 40mm between HE and AP ammunition";};
	class acAmmo {description = "(MK) AC-130 console view: rounds left for a weapon, summed from the gunship's magazines in every turret";};
	class acFire {description = "(MK) AC-130 console view: fire a gun, finding and remembering the fire mode that actually produces a round";};
	class acGun {description = "(MK) AC-130 console view: the crew member and muzzle that fire a given weapon";};
	class acAim {description = "(MK) AC-130 console view aim: gun turret limits, centre, clamp, or world direction from traverse / elevation";};
	class supportNotice {description = "(MK) Support aircraft message (leaving, left, arrived) on the console banner, shown once per aircraft and kind";};
	class consoleBanner {description = "(MK) Message drawn on top of the commander console screen for a few seconds (falls back to a notification when no console is open)";};
	class consoleFKey {description = "(MK) Commander console F2 (UAV) / F3 (AC-130): connect, ask to select on the map, or deploy through the normal CAS call";};
	class consoleFKeyState {description = "(MK) What F2 / F3 will do: [action, target or CAS list index, tooltip]";};
	class consoleFolderClose	{description = "Commander console: slide a side folder back in";};
	class factionClasses	{description = "Public CfgVehicles classes of a faction (engine filter, cached for the session)";};
	class pipFollow	{description = "Smooth follow camera for small video feeds";};
	class perfLog	{description = "Performance diagnostics: mission generation and approaching objectives";};
	class pipCycleView	{description = "Right-click the video feed: next camera view";};
	class PiPOpen	{description = "Do the transmitting feed animation.";};
	class time2String	{description = "convert time to string.";};
	class time	{description = "convert time to hh:mm:ss.";};
	class setVehicleInit	{description = "Sets vehicle init.";};
	class setVehicleName	{description = "Sets vehicle name.";};
	class setTime	{description = "Setstime on all clients.";};
	class setWeather	{description = "Sets weather  on all clients  - skip time by one hour to make the weather change.";};
	class globalSay3D	{description = "Say sound on 3d on all clients.";};
	class globalHint	{description = "Broadcast a meesege on all clients.";};
	class globalExecute	{description = "Global execute a command on selected clients or server.";};
	class groupChat	{description = "Send chat across MP.";};
	class moveToPos		{description = "move an object to a new location.";};
	class pickItem	{description = "Make a vehicle class item pickable and add variable to it.";};
	class broadcast	{description = "Create a virtual camera and broadcast a short PiP video to all clients for 15 seconds.";};
	class paradrop	{description = "Create a HALO or regular parachute jump for the given unit.";};
	class pipOrbit	{description = "Mouse orbit / zoom of the MCC console unit video feed";};
	class paraGuide	{description = "Steer an AI paratrooper to his landing spot";};
	class realParadrop	{description = "Create a HALO or regular parachute jump for the given units with simulation of running out of an airplane.";};
	class realParadropPlayer	{description = "Handle the paradrop from the unit side.";};
	class countGroupHC	{description = "Count the number of infantry, vehicles, tank, air, ships in a group expand.";};
	class manageWp	{description = "Create and control AI WP on map.";};
	class sync	{description = "Sync the player with the server.";};
	class objectMapper	{description = "Takes an array of data about a dynamic object template and creates the objects.";};
	class findRoadsLeadingZone	{description = "Find Road segments leading to an area.";};
	class nearestRoad	{description = "Return a Road segments array near positions";};
	class garrison	{description = "Populate soldiers inside empty houses";};
	class saveToSQM	{description = "Save MCC's placments in SQM file format and copy it to clipboard";};
	class saveToMCC	{description = "prepare the mcc_output variable";};
	class loadFromMCC	{description = "Load the mcc_output variable";};
	class saveToComp	{description = "Save MCC's 3D editor placments in composition format";};
	class replaceString	{description = "Filter a string and removes certain characters ( _filter)";};
	class dirToString	{description = "Get direction integer and return it as a strin North, east exc";};
	class startLocations	{description = "Teleport the player when start location has been found";};
	class spawnGroup	{description = "MCC Custom group spawning";};
	class keyToName		{description = "get idkKey and return string with his name";};
	class makeBriefing	{description = "Server Only - create a Logic based briefing";};
	class handleAddaction	{description = "Handle addactions after respawn - init";};
	class loadGear	{description = "Equip player from a saved gear array (goggles/headgear/uniform/vest/backpack/weapons/items) - used by the DB persistence restore and the respawn-carries-your-gear feature";};
	class log		{description = "Write a tagged MCC line to the RPT (MCC [LEVEL] source | message | t= machine player)";};
	class logSummary	{description = "Dump MCC log counters to the RPT (runs on mission end)";};
	class parseSetting	{description = "Safely compile an MCC CBA EDITBOX setting; falls back to the default and logs the setting name if malformed";};
	class ppEffects	{description = "Create effects to all players";};
	class SetPitchBankYaw	{};
	class openArtillery {};
	class deleteBrush{};
	class crewCount {description = "return empty seats of a specific vehicle with or without FFV (firing From Vehicles)";};
	class addVelocity {description = "adds velocity to object depends on its current velocity";};
	class makeTask {description = "Handles tasks on the server using BI setTask fnc";};
	class halt {description = "halt all function in game";};
};

class ied
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\ied";
	#else
	file = "mcc\fnc\ied";
	#endif

	class IedFakeExplosion	{description = "Create a fake explosion.";};
	class IedDeadlyExplosion	{description = "Create a deadly explosion.";};
	class IedDisablingExplosion	{description = "Create a disabling explosion.";};
	class ACSingle	{description = "Create an armed civilian at the given position.";};
	class trapSingle	{description = "Create an IED at the given position.";};
	class iedHit		{description = "Determine what will happened when an IED got hit.";};
	class ambushSingle	{description = "Create an ambush group.";};
	class createIED		{description = "Create the IED mechanic.";};
	class manageAmbush	{description = "Manage ambush behavior in a group.";};
	class manageAC		{description = "Manage armed civilian behavior.";};
	class SBSingle		{description = "Place suicide bomber.";};
	class manageSB		{description = "Manage SB bomber behavior.";};
	class mineSingle	{description = "Create a mine field.";};
	class iedSync {};
};

class cas
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\cas";
	#else
	file = "mcc\fnc\cas";
	#endif

	class CreateAmmoDrop	{description = "drop an object from a plane and attach paracute to it, thanks to BIS.";};
	class createPlane		{description = "create a flying plane from the given type and return the plane , pilot and group.";};
	class deletePlane		{description = "set a plane to move to a location and delete it once it come closer then 800 meters.";};
	class gunshipClass	{description = "Gunship class for the Gunship button (faction first)";};
	class casAllowedTypes	{description = "CAS attack types an aircraft can fly";};
	class casCanRun {description = "(MK) Can this aircraft's pilot fly this Direct CAS run (0 gun, 1 rockets, 2 gun + rockets, 3 bombs) with his own weapons and pylons";};
	class casGuide {description = "(MK) Steer one real projectile onto a point (ASL) or a target object";};
	class casGuideArm {description = "(MK) Guide every projectile a vehicle fires in the next few seconds onto a target (point with spread, or object); run where the vehicle is local";};
	class casReleaseWait {description = "(MK) Wait until a bomb released now would fall onto the target (ballistic release point)";};
	class casRealFire {description = "(MK) An aircraft fires its own loaded weapon of a kind (bomb, rocket, agm, aam) at targets, each real projectile guided on";};
	class supportTimer {description = "(MK) On-station time limit for a support aircraft: 60 s warning, optional leave when out of ammunition, releases a controlling player, flies it away";};
	class casFillTypes	{description = "Fill the CAS type list for the chosen aircraft";};
	class airDrop		{description = "Handles CAS and airdrop requests on the server";};
	class uavDetect {};
	class cas {description = "Simulate Zeus CAS with moded vehicles";};
};

class artillery
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\artillery";
	#else
	file = "mcc\fnc\artillery";
	#endif

	class CBU	{description = "drop a bomb that explode to some skeets with paracute the explode to some kind of CBU.";};
	class SADARM	{description = "drop a bomb that explode to some skeets that will search and destroy near by armor.";};
	class artyBomb	{description = "Create artillery strike with sounds on given spot.";};
	class artyFlare	{description = "Create a flare.";};
	class artyDPICM	{description = "Create DPICM artillery barage.";};
	class amb_Art	{description = "Create ambient artillery barage.";};
	class calcSolution	{description = "calculate artillery solution high or low";};
	class artyGetSolution	{description = "Broadcast artillery solution high or low";};
	class consoleFireArtillery	{description = "Broadcast artillery to artillery units";};
	class artillery {};
};

class groupGen
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\groupGen";
	#else
	file = "mcc\fnc\groupGen";
	#endif

	class groupGenRefresh	{description = "Refresh the group gen markers";};
		class spawnLists	{description = "Spawn panel: Branch and Class lists matching Type and Branch";};
	class groupSpawn		{description = "Create a group on the server";};
	class applyPlaceBehaviour	{description = "(MK) 3D editor: Behaviour and Commandable for a placed group";};
	class restore3D		{description = "(MK) 3D editor: rebuild deleted objects for Ctrl+Z";};
	class groupPlace3D		{description = "(MK) 3D editor: spawn a group facing and at the height it was placed, and add it to undo";};
	class groupGenUMRefresh	{description = "Refresh the group gen units lists";};
};

class console
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\console";
	#else
	file = "mcc\fnc\console";
	#endif

	class consoleClickGroupIcon	{description = "Define icon behaviot when clicked on the MCC Console";};
	class consoleMapFollow	{description = "Commander console map: follow a moving object until right-click";};
};

class mp
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\mp";
	#else
	file = "mcc\fnc\mp";
	#endif

	class vote	{description = "Start a voting process.";};
	class getActiveSides	{description = "Return an array of the active sides in a role selection game.";};
	class PDAcreatemarker	{description = "Creates markers on mp per side and delete them after a period of time";};
	class construction		{description = "Constract a tactical building on the server side";};
	class construct_base	{description = "Constract a building in base";};
	class addRating			{description = "Adds rating to a specific player";};
	class radioSupport		{description = "Broadcast radio support to all elements not including the broadcaster group";};
	class inidbGet	{};
	class inidbSet 	{};
	class handleDB {};
	class initExtDB3 {description = "Detect and connect to extDB3 for persistent campaign storage; falls back to profileNamespace";};
	class saveServer {description = "Save persistent data about the server to the server";};
	class loadServer {description = "Load persistent data about the server from the server";};
	class savePlayer {description = "Save persistent data about the player to the server";};
	class loadPlayer {description = "Load persistent data about the player from the server";};
	class clearPersistentData {description = "Clear all data from saved files";};
};

class actions
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\actions";
	#else
	file = "mcc\fnc\actions";
	#endif

	class ilsChilds		{description = "Handles ILS childs";};
	class dragObject	{description = "Start a dragging animation must be run local on the dragging unit";};
	class releaseObject	{description = "stop a dragging animation must be run local on the dragging unit";};
	class releasePod	{description = "Release a pod from Taru helicopter";};
	class podTaruReturn	{description = "(MK) Pod drop Taru: waits away 5 minutes, comes back, hooks, winches and docks the pod, then leaves";};
	class taruAI	{description = "(MK) AI Taru pod job: pick up / winch drop / parachute / release a pod at a place";};
	class taruWaypoint	{description = "(MK) A Taru pod job as a waypoint (the console's Taru - ... types)";};
	class podDock	{description = "(MK) Dock a Taru pod from the sling (XENO - Taru Pod Mod)";};
	class podAssault	{description = "(MK) Assault undock: lower the pod on the ropes, unload, dock again (XENO - Taru Pod Mod)";};
	class attachPod		{description = "Attach a pod to Taru helicopter";};
	class vault			{description = "Vault over an obstacle";};
	class cover			{description = "Manage cover mechanics";};
	class coverInit		{preInit = 1; description = "Init Cover System";};
	class weaponSelect	{description = "Change weapons and throw utility";};
	class utilityUse	{description = "use utility";};
	class grenadeThrow	{description = "Throw grenades";};
	class pickKit		{description = "pick up dead unit kit";};
	class canAttachPod	{description = "check if can attach pod";};
	class addILSChildrenACE {description = "Add ILS actions to ACE ui";};
	class spotEnemy {description = "spot an enmey from ACE menu";};
	class callSupport {description = "Call support from ACE menu";};
	class callConstruct {description = "Call construct from ACE menu";};
	class resupply {description = "Resupply ammo from an ammo box";};
	class breakdown {description = "Breakdown MCC crate into supplies";};
	class ACEdropAmmobox {description = "Drop MCC ammbox in ACE";};
};

class evac
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\evac";
	#else
	file = "mcc\fnc\evac";
	#endif

	class evacDelete {description = "Delete the given vehicle or it's driver";};
	class evacFillFactions {description = "(MK) Evac panel: fill the Faction list (factions that have evac vehicles), defaulting to the player's faction";};
	class evacFillClass {description = "(MK) Evac panel: fill the Class list straight from the chosen faction and type";};
	class evacConsoleRefresh {description = "(MK) Commander Console: rebuild the evac list from the side's live evac list, keeping the selection on the same vehicle";};
	class evacSide {description = "(MK) Side an evac made in the MCC console belongs to: the console's side if a player is on it, otherwise the mission maker's own side";};
	class evacPanelRefresh {description = "(MK) Rebuild the Evac panel's evac list from the side's live evac list, keeping the selection on the same vehicle";};
	class evacMove {description = "Move a vehicle to selected WP";};
	class evacSpawn {description = "Spawn a vehicle with crew and gunners, mark it as an evac vehicle";};
	class repairEvac {description = "Repair evac helicopter";};
	class setEvac {description = "Sets an empty ot AI vehicle into an ecav for a specific side";};
	class evacGunners {description = "(MK) AI already in an evac's gun seats join its gunners group so they engage";};
	class fastRopeLocal {description = "handles fast rope on clients";};
};

class uiTheme
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\ui";
	#else
	file = "mcc\fnc\ui";
	#endif

	class hintBrief	{description = "Hint that clears itself after a few seconds";};
	class consoleCampaignTiles	{description = "Hide the campaign tiles on the console map while it is open";};
	class comboRemember	{description = "Console panels: drop-down lists open on the last choice";};
	class consoleTheme	{description = "Console colour (squares under the transparency sliders)";};
	class feedVision	{description = "View mode of every MCC video feed (saved per feed)";};
	class umFeedToggle	{description = "MCC console unit video feed On / Off button";};
	class umToolboxHighlight	{description = "Rounded box under the chosen Units / Groups and video view entries";};
	class choiceBar	{description = "Small one-line three-button choice window";};
	class umAutoSelect	{description = "Select a group / units just spawned in the MCC console unit list";};
	class haloFormation	{description = "HALO formation free fall (after ROS_HaloFormation)"; file = "\mcc_sandbox_mod\mcc\fnc\general\fn_haloFormation.sqf";};
	class haloFormationPlayer	{description = "(MK) HALO formation round a player and his AI (ROS_HaloFormation)"; file = "\mcc_sandbox_mod\mcc\fnc\general\fn_haloFormationPlayer.sqf";};
	class haloPlaneExit	{description = "HALO aircraft flies off the nearest map edge at its drop height and is deleted"; file = "\mcc_sandbox_mod\mcc\fnc\general\fn_haloPlaneExit.sqf";};
	class dropLight	{description = "(MK) Jump light in a drop aircraft: red / green (ROS Group HALO)"; file = "\mcc_sandbox_mod\mcc\fnc\general\fn_dropLight.sqf";};
	class umModeSwitch	{description = "Units / Groups switch: the selection follows";};
	class umSelectionFromList	{description = "MCC_selectedUnits from what is highlighted in the unit list";};
	class consoleModeButtons	{description = "Commander console mode buttons: show the one in use";};
	class consoleAlpha	{description = "Transparency slider of the MCC console";};
	class consoleMapLayers	{description = "MK: map layers button of the MCC console (terrain / contours only)";};
	class consoleFilter	{description = "MK: MCC console filter toggles (All, Players, West, East, Ind, Civ)";};
	class consoleAmbientLook	{description = "MK: MCC console Ambient Warzone toggle look";};
	class zoneList	{description = "MK: MCC console Zone drop-down - zones on the map, rows carry the zone number";};
	class deleteZone	{description = "MK: MCC console Delete Zone button";};
	class applyTheme	{description = "MCC look (VBS4 style) for an MCC window";};
};

class dynamicDialog
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\dynamicDialog";
	#else
	file = "mcc\fnc\dynamicDialog";
	#endif

	class initDynamicDialog {description = "init the dynamic dialog";};
	class messageBox	{description = "MCC-styled question box (replaces BIS_fnc_guiMessage)";};
};