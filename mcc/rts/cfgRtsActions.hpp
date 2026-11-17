class MCC_rts_startElectricity
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\elec1.paa";
	#else
	picture = "mcc\rts\data\elec1.paa";
	#endif

	displayName = "Generator On";
	descriptionShort = "";
	condition = "!(missionNamespace getVariable [format ['MCC_rtsElecOn_%1', playerSide],false])";
	requiredBuildings[] = {{"elecPower",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsStartElectricity";
	resources[] = {{"fuel",50}};
};

class MCC_rts_stopElectricity
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\power.paa";
	#else
	picture = "mcc\rts\data\power.paa";
	#endif

	displayName = "Generator Off";
	descriptionShort = "";
	condition = "(missionNamespace getVariable [format ['MCC_rtsElecOn_%1', playerSide],false])";
	requiredBuildings[] = {{"elecPower",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsStartElectricity";
	resources[] = {};
};

class MCC_rts_scanResourcesBasic
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\hq.paa";
	#else
	picture = "mcc\rts\data\hq.paa";
	#endif

	displayName = "Basic Mission Scan";
	descriptionShort = "Order HQ to look for basic resources missions";
	condition = "!(missionNamespace getVariable [format ['MCC_rtsMissionOn_%1', playerSide],false]);";
	requiredBuildings[] = {{"hq",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsScanResourcesBasic";
	resources[] = {{"time",60}};
};

class MCC_rts_scanResourcesAdvanced
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\satcom.paa";
	#else
	picture = "mcc\rts\data\satcom.paa";
	#endif

	displayName = "Advanced Mission Scan";
	descriptionShort = "Order HQ to look for advanced resources missions";
	condition = "!(missionNamespace getVariable [format ['MCC_rtsMissionOn_%1', playerSide],false]);";
	requiredBuildings[] = {{"hq",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsScanResourcesAdvanced";
	resources[] = {{"time",60}};
};

/*

//Maybe when i'll have time i'll expend it more then it is today

class MCC_rts_scanResourcesBasic
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\hq.paa";
	#else
	picture = "mcc\rts\data\hq.paa";
	#endif

	displayName = "Basic Mission Scan";
	descriptionShort = "Order HQ to look for a basic missions";
	condition = "!(missionNamespace getVariable [format ['MCC_rtsMissionOn_%1', playerSide],false]);";
	requiredBuildings[] = {{"hq",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsBuildUIContainer";
	variables[] = {"cfgRtsBuildings","missionsBasic","cfgRtsMissions"};
	resources[] = {};
};

class MCC_rts_scanResourcesAdvanced
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\satcom.paa";
	#else
	picture = "mcc\rts\data\satcom.paa";
	#endif

	displayName = "Advanced Mission Scan";
	descriptionShort = "Order HQ to look for advanced resources missions";
	condition = "!(missionNamespace getVariable [format ['MCC_rtsMissionOn_%1', playerSide],false]);";
	requiredBuildings[] = {{"hq",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsBuildUIContainer";
	variables[] = {"cfgRtsBuildings","missionsAdvanced","cfgRtsMissions"};
	resources[] = {};
};
*/


class MCC_rts_scanResourcesCancel
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\power.paa";
	#else
	picture = "mcc\rts\data\power.paa";
	#endif

	displayName = "Abort Mission";
	descriptionShort = "Abort the HQ mission and delete all units and crates";
	condition = "(missionNamespace getVariable [format ['MCC_rtsMissionOn_%1', playerSide],false]);";
	requiredBuildings[] = {{"hq",1}};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsScanResourcesCancel";
	dontShowDisabled = 1;	//(MK) only shown while there is a mission to abort
	resources[] = {};
};

class MCC_rts_buyTickets
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\addTickets.paa";
	#else
	picture = "mcc\rts\data\addTickets.paa";
	#endif

	displayName = "Redeem Tickets";
	descriptionShort = "Add 5 tickets";
	condition = "";
	requiredBuildings[] = {{"triage",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsBuyTickets";
	resources[] = {{"med",50}};
};

class MCC_rts_createMeds
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\meds.paa";
	#else
	picture = "mcc\rts\data\meds.paa";
	#endif

	displayName = "Create Meds";
	descriptionShort = "Convert food and fuel into meds";
	condition = "";
	requiredBuildings[] = {{"triage",1}};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsCreateMeds";
	resources[] = {{"food",100},{"fuel",50}};
};

class MCC_rts_ammo2Food
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\ammo2Food.paa";
	#else
	picture = "mcc\rts\data\ammo2Food.paa";
	#endif

	displayName = "Trade Ammo";
	descriptionShort = "Trade ammo with the locals for food";
	condition = "";
	requiredBuildings[] = {{"tradePost",1}};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsTradeforFood";
	resources[] = {{"ammo",200},{"time",5}};
	gain[] = {{"food",50}};
};

class MCC_rts_fuel2Food
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\fuel2Food.paa";
	#else
	picture = "mcc\rts\data\fuel2Food.paa";
	#endif

	displayName = "Trade Fuel";
	descriptionShort = "Trade fuel with the locals for food";
	condition = "";
	requiredBuildings[] = {{"tradePost",1}};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsTradeforFood";
	resources[] = {{"fuel",200},{"time",5}};
	gain[] = {{"food",50}};
};

class MCC_rts_repair2Food
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\repair2Food.paa";
	#else
	picture = "mcc\rts\data\repair2Food.paa";
	#endif

	displayName = "Trade Supplies";
	descriptionShort = "Trade supplies with the locals for food";
	condition = "";
	requiredBuildings[] = {{"tradePost",1}};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsTradeforFood";
	resources[] = {{"repair",200},{"time",5}};
	gain[] = {{"food",50}};
};

class MCC_rts_destroyLogic
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\destroy.paa";
	#else
	picture = "mcc\rts\data\destroy.paa";
	#endif

	displayName = "Destroy Facility";
	descriptionShort = "Destroy the current selected facility";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsDestroyLogic";
	resources[] = {};
};

class MCC_rts_rtsFortUIContainer
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\rook.paa";
	#else
	picture = "mcc\rts\data\rook.paa";
	#endif

	displayName = "Fortifications";
	descriptionShort = "Build Fortifications";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsBuildUIContainer";
	variables[] = {"cfgRtsBuildings","fortifications","cfgRtsActions"};
	resources[] = {};
};

class MCC_rts_rtsUnitsUIContainer
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\addTickets.paa";
	#else
	picture = "mcc\rts\data\addTickets.paa";
	#endif

	displayName = "Units";
	descriptionShort = "Recruit Units";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsBuildUIContainer";
	variables[] = {"cfgRtsBuildings","groups","cfgMCCRtsGroups"};
	resources[] = {};
};

class MCC_rts_rtsBuildUIContainer
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\hammer.paa";
	#else
	picture = "mcc\rts\data\hammer.paa";
	#endif

	displayName = "Build";
	descriptionShort = "Build Menu";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsBuildUIContainer";
	variables[] = {"cfgRtsBuildings","buildings","cfgRtsBuildings"};
	resources[] = {};
};

class MCC_rts_rtsBuildUIContainerBack
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\back.paa";
	#else
	picture = "mcc\rts\data\back.paa";
	#endif

	displayName = "Exit";
	descriptionShort = "Exit Build Menu";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsBuildUIContainerBack";
	resources[] = {};
};
//(MK) Helipads menu on the HQ (its helipads[] list), opened like the Fortifications menu
class MCC_rts_rtsHelipadUIContainer
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\helipad.paa";
	#else
	picture = "mcc\rts\data\helipad.paa";
	#endif

	displayName = "Helipads";
	descriptionShort = "Build a helipad: square, circle, civil or rescue (lit or not), or an invisible landing spot";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsBuildUIContainer";
	variables[] = {"cfgRtsBuildings","helipads","cfgRtsActions"};
	resources[] = {};
};

class MCC_rts_rtsFortUIContainerBack
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\back.paa";
	#else
	picture = "mcc\rts\data\back.paa";
	#endif

	displayName = "Exit";
	descriptionShort = "Exit Fortifications Menu";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsBuildUIContainerBack";
	resources[] = {};
};

class MCC_rts_rtsbuyVehicle
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\buyVehicle.paa";
	#else
	picture = "mcc\rts\data\buyVehicle.paa";
	#endif

	displayName = "Buy Vehicles";
	descriptionShort = "Buy Vehicles";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsbuyVehicle";
	resources[] = {};
};

class MCC_rts_addArtilleryAmmo
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\RTS_buttonArtillery.paa";
	#else
	picture = "mcc\rts\data\RTS_buttonArtillery.paa";
	#endif

	displayName = "Buy Artillery Shells";
	descriptionShort = "Buy 10 Artillery Shells - Use the commander console to call artillery";
	condition = "";
	requiredBuildings[] = {};
	needelectricity = 1;
	actionFNC = "MCC_fnc_rtsaddArtilleryAmmo";
	resources[] = {{"ammo",50}};
};

class MCC_rts_buyShip
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\boat.paa";
	#else
	picture = "mcc\rts\data\boat.paa";
	#endif
	displayName = "Buy Ship";
	descriptionShort = "Buy a destroyer, aircraft carrier, submarine or LHD, and choose where it arrives";
	condition = "true";
	requiredBuildings[] = {{"hq",2},{"storage",2}};
	needelectricity = 0;
	actionFNC = "MCCMK_fnc_shipBuyMenu";
	resources[] = {};
};

//(MK) Buy Boat (on the Naval Workshop): click a spot on the water, then the vehicle shop for boats - the side's resources
class MCC_rts_buyBoat
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\boatBuy.paa";
	#else
	picture = "mcc\rts\data\boatBuy.paa";
	#endif
	displayName = "Buy Boat";
	descriptionShort = "Buy a boat with the side's resources, and choose where on the water it's delivered";
	condition = "true";
	requiredBuildings[] = {{"hq",2},{"storage",2}};
	needelectricity = 0;
	actionFNC = "MCCMK_fnc_boatBuyMenu";
	resources[] = {};
};

//(MK) Clear wrecks (on the HQ): every wreck within 300 m of the HQ removed, free
class MCC_rts_clearWrecks
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\clearWrecks.paa";
	#else
	picture = "mcc\rts\data\clearWrecks.paa";
	#endif
	displayName = "Clear wrecks";
	descriptionShort = "Remove every wreck within 300 m of the HQ (salvage enemy vehicles by hand for resources)";
	condition = "true";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCCMK_fnc_rtsClearWrecks";
	resources[] = {};
};

//(MK) Clear bodies (on the HQ, beside Clear wrecks): every body within 300 m of the HQ removed with the weapons beside
// it - not players' own (the body cleanup takes those later, so their kit can be recovered)
class MCC_rts_clearBodies
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\clearBodies.paa";
	#else
	picture = "mcc\rts\data\clearBodies.paa";
	#endif
	displayName = "Clear bodies";
	descriptionShort = "Remove every body within 300 m of the HQ, with the weapons beside it (not players' own)";
	condition = "true";
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "MCCMK_fnc_rtsClearBodies";
	resources[] = {};
};

//(MK) an empty slot in a building's buttons (hidden, but it takes its place - to group buttons)
class MCC_rts_spacer
{
	picture = "";
	displayName = "";
	descriptionShort = "";
	condition = "false";
	dontShowDisabled = 1;
	requiredBuildings[] = {};
	needelectricity = 0;
	actionFNC = "";
	resources[] = {};
};

//(MK) Taru pods placed in the base (the Aerial Workshop): costs as calling the pod by airdrop, less the Taru's fuel
class MCC_rts_taruPods
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\taruPod.paa";
	#else
	picture = "mcc\rts\data\taruPod.paa";
	#endif
	displayName = "Taru pods";
	descriptionShort = "Place a Taru pod in the base: medical, repair, ammunition, fuel, logistics, bench or transport";
	condition = "true";
	requiredBuildings[] = {{"hq",3}};
	needelectricity = 0;
	actionFNC = "MCCMK_fnc_rtsPodMenu";
	resources[] = {};
};

class MCC_rts_evacHelicopterBuy
{
	#ifdef MCCMODE
	picture = "\mcc_sandbox_mod\mcc\rts\data\RTS_evacHelicopter.paa";
	#else
	picture = "mcc\rts\data\RTS_evacHelicopter.paa";
	#endif

	displayName = "Buy Evac Helicopter";
	descriptionShort = "Respawn downed evac helicopter";
	condition = "count (missionNamespace getVariable [format ['MCC_campaignEvac_%1', playerSide],[]]) > 0;";
	requiredBuildings[] = {{"hq",1}};
	needelectricity = 0;
	actionFNC = "MCC_fnc_rtsEvacHelicopterBuy";
	resources[] = {{"repair",200},{"time",10}};
};

#include "forts\forts.hpp"
