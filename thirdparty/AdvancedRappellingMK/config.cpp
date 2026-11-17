// Advanced Rappelling MK - a corrected version of Advanced Rappelling by Seth Duda ([SA] Duda), MIT licence (see the
// licence file). Changes from the original are marked (MK) in functions\fn_advancedRappellingInit.sqf; in this config:
// - requiredAddons: after all of Arma's data (A3_Data_F_Sams_Loadorder). The original only asks for A3_Modules_F, so it
// can be read BEFORE Arma's animations: its reference to the standing, weapon-raised stance then makes an empty
// placeholder of it, and AI can't raise their weapons.
// - Arma's own seat poses (cargo_marksman, cargo_base, cargo_base_idle, cargo_basepistol, cargo_base_idle_pistol) are
// not redefined: the rope poses derive their own classes (ARMK_...) from them.
//  - its own class names (ARMK_...), so it can sit beside the original; remote-execution entries for restricted servers.
class CfgPatches
{
	class ARMK_AdvancedRappelling
	{
		name = "Advanced Rappelling MK";
		author = "Seth Duda ([SA] Duda); MK corrections: Morlock";
		units[] = {};
		weapons[] = {};
		requiredVersion = 1;
		requiredAddons[] = {"A3_Data_F_Sams_Loadorder", "A3_Modules_F"};
	};
};
class CfgRemoteExec
{
	class Functions
	{
		class ARMK_Client_Rappel_From_Heli {allowedTargets = 0;};
		class ARMK_Rappel_From_Heli {allowedTargets = 2;};
		class ARMK_Rappel_All_Cargo {allowedTargets = 0;};
		class ARMK_Hint {allowedTargets = 0;};
		class ARMK_Heli_Doors {allowedTargets = 0;};
		class ARMK_Hide_Object_Global {allowedTargets = 2;};
		class ARMK_Enable_Rappelling_Animation {allowedTargets = 2;};
		class ARMK_Enable_Rappelling_Animation_Client {allowedTargets = 0;};
		class ARMK_Play_Rappelling_Sounds_Global {allowedTargets = 2;};
		class ARMK_Play_Rappelling_Sounds {allowedTargets = 0;};
	};
};
class CfgNetworkMessages
{
	class ARMKRemoteExecClient
	{
		module = "ARMK";
		parameters[] = {"ARRAY", "STRING", "OBJECT", "BOOL"};
	};
	class ARMKRemoteExecServer
	{
		module = "ARMK";
		parameters[] = {"ARRAY", "STRING", "BOOL"};
	};
};
class CfgFunctions
{
	class ARMK
	{
		class AdvancedRappelling
		{
			file = "\ARMK_AdvancedRappelling\functions";
			class advancedRappellingInit
			{
				postInit = 1;
			};
		};
	};
};
class CfgSounds
{
	class ARMK_Rappel_Loop
	{
		name = "ARMK_Rappel_Loop";
		sound[] = {"\ARMK_AdvancedRappelling\sounds\AR_Rappel_Loop.ogg", 10, 1};
		titles[] = {0, ""};
	};
	class ARMK_Rappel_Start
	{
		name = "ARMK_Rappel_Start";
		sound[] = {"\ARMK_AdvancedRappelling\sounds\AR_Rappel_Start.ogg", 10, 1};
		titles[] = {0, ""};
	};
	class ARMK_Rappel_End
	{
		name = "ARMK_Rappel_End";
		sound[] = {"\ARMK_AdvancedRappelling\sounds\AR_Rappel_End.ogg", 10, 1};
		titles[] = {0, ""};
	};
};
class CfgMovesBasic
{
	class DefaultDie;
	class ManActions
	{
		ARMK_01 = "ARMK_01_Idle";
	};
	class Actions
	{
		class RifleStandActions;
		class ARMK_BaseActions: RifleStandActions
		{
			AdjustF = "";
			AdjustB = "";
			AdjustL = "";
			AdjustR = "";
			AdjustLF = "";
			AdjustLB = "";
			AdjustRB = "";
			AdjustRF = "";
			agonyStart = "";
			agonyStop = "";
			medicStop = "";
			medicStart = "";
			medicStartUp = "";
			medicStartRightSide = "";
			GestureAgonyCargo = "";
			grabCarry = "";
			grabCarried = "";
			grabDrag = "";
			grabDragged = "";
			carriedStill = "";
			released = "";
			releasedBad = "";
			Stop = "";
			StopRelaxed = "";
			TurnL = "";
			TurnR = "";
			TurnLRelaxed = "";
			TurnRRelaxed = "";
			ReloadMagazine = "";
			ReloadMGun = "";
			ReloadRPG = "ReloadRPG";
			ReloadMortar = "";
			WalkF = "";
			WalkLF = "";
			WalkRF = "";
			WalkL = "";
			WalkR = "";
			WalkLB = "";
			WalkRB = "";
			WalkB = "";
			PlayerWalkF = "";
			PlayerWalkLF = "";
			PlayerWalkRF = "";
			PlayerWalkL = "";
			PlayerWalkR = "";
			PlayerWalkLB = "";
			PlayerWalkRB = "";
			PlayerWalkB = "";
			SlowF = "";
			SlowLF = "";
			SlowRF = "";
			SlowL = "";
			SlowR = "";
			SlowLB = "";
			SlowRB = "";
			SlowB = "";
			PlayerSlowF = "";
			PlayerSlowLF = "";
			PlayerSlowRF = "";
			PlayerSlowL = "";
			PlayerSlowR = "";
			PlayerSlowLB = "";
			PlayerSlowRB = "";
			PlayerSlowB = "";
			FastF = "";
			FastLF = "";
			FastRF = "";
			FastL = "";
			FastR = "";
			FastLB = "";
			FastRB = "";
			FastB = "";
			TactF = "";
			TactLF = "";
			TactRF = "";
			TactL = "";
			TactR = "";
			TactLB = "";
			TactRB = "";
			TactB = "";
			PlayerTactF = "";
			PlayerTactLF = "";
			PlayerTactRF = "";
			PlayerTactL = "";
			PlayerTactR = "";
			PlayerTactLB = "";
			PlayerTactRB = "";
			PlayerTactB = "";
			EvasiveLeft = "";
			EvasiveRight = "";
			startSwim = "";
			surfaceSwim = "";
			bottomSwim = "";
			StopSwim = "";
			startDive = "";
			SurfaceDive = "";
			BottomDive = "";
			StopDive = "";
			Down = "";
			Up = "";
			PlayerStand = "";
			PlayerCrouch = "";
			PlayerProne = "";
			Lying = "";
			Stand = "";
			Combat = "";
			Crouch = "";
			CanNotMove = "";
			Civil = "";
			CivilLying = "";
			FireNotPossible = "";
			WeaponOn = "";
			WeaponOff = "";
			Default = "";
			JumpOff = "";
			StrokeFist = "";
			StrokeGun = "";
			SitDown = "";
			Salute = "";
			saluteOff = "";
			GetOver = "";
			Diary = "";
			Surrender = "";
			Gear = "";
			BinocOn = "";
			BinocOff = "";
			PutDown = "";
			PutDownEnd = "";
			Medic = "";
			MedicOther = "";
			Treated = "";
			LadderOnDown = "";
			LadderOnUp = "";
			LadderOff = "";
			LadderOffTop = "";
			LadderOffBottom = "";
			PrimaryWeapon = "";
			SecondaryWeapon = "";
			Binoculars = "";
			StartFreefall = "";
			FDStart = "";
			useFastMove = 0;
			stance = "ManStanceUndefined";
		};
		class ARMK_01_Actions: ARMK_BaseActions
		{
			upDegree = "ManPosCombat";
			stop = "ARMK_01_Aim";
			stopRelaxed = "ARMK_01_Aim";
			default = "ARMK_01_Aim";
			Stand = "ARMK_01_Idle";
			HandGunOn = "ARMK_01_Aim_Pistol";
			PrimaryWeapon = "ARMK_01_Aim";
			SecondaryWeapon = "";
			Binoculars = "";
			die = "ARMK_01_Die";
			Unconscious = "ARMK_01_Die";
			civil = "";
		};
		class ARMK_01_DeadActions: ARMK_BaseActions
		{
			stop = "ARMK_01_Die";
			default = "ARMK_01_Die";
			die = "ARMK_01_Die";
			Unconscious = "ARMK_01_Die";
		};
		class ARMK_01_IdleActions: ARMK_01_Actions
		{
			upDegree = "ManPosStand";
			stop = "ARMK_01_Idle";
			stopRelaxed = "ARMK_01_Idle";
			default = "ARMK_01_Idle";
			Combat = "ARMK_01_Aim";
			fireNotPossible = "ARMK_01_Aim";
			PlayerStand = "ARMK_01_Aim";
		};
		class ARMK_01_PistolActions: ARMK_01_Actions
		{
			upDegree = "ManPosHandGunStand";
			stop = "ARMK_01_Aim_Pistol";
			stopRelaxed = "ARMK_01_Aim_Pistol";
			default = "ARMK_01_Aim_Pistol";
			throwGrenade[] = {"GestureThrowGrenadePistol", "Gesture"};
			Stand = "ARMK_01_Idle_Pistol";
			die = "ARMK_01_Die_Pistol";
			Unconscious = "ARMK_01_Die_Pistol";
		};
		class ARMK_01_IdlePistolActions: ARMK_01_Actions
		{
			upDegree = "ManPosHandGunStand";
			stop = "ARMK_01_Idle_Pistol";
			stopRelaxed = "ARMK_01_Idle_Pistol";
			default = "ARMK_01_Idle_Pistol";
			Combat = "ARMK_01_Aim_Pistol";
			fireNotPossible = "ARMK_01_Aim_Pistol";
			PlayerStand = "ARMK_01_Aim_Pistol";
			die = "ARMK_01_Die_Pistol";
			Unconscious = "ARMK_01_Die_Pistol";
		};
	};
};
class CfgMovesMaleSdr: CfgMovesBasic
{
	class States
	{
		class Crew;
		class AmovPercMstpSrasWrflDnon;
		class AmovPercMstpSrasWpstDnon;
		class AmovPercMstpSoptWbinDnon;
		class AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon;
		class AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon_end;
		class AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon;
		class AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon_end;
		// (MK) Arma's own seat poses - referred to, never redefined (the original re-declared them and emptied their
		// variants, changing them for every seat in the game)
		class cargo_base;
		class cargo_base_idle;
		class cargo_basepistol;
		class cargo_base_idle_pistol;
		class ARMK_cargo_base: cargo_base
		{
			variantsPlayer[] = {};
			variantsAI[] = {};
			enableMissile = 0;
			enableBinocular = 0;
		};
		class ARMK_cargo_base_Rope: ARMK_cargo_base
		{
			ignoreMinPlayTime[] = {"Unconscious"};
			leaning = "AR_aimingDefault_Rope";
		};
		class ARMK_cargo_base_idle: cargo_base_idle
		{
			weaponLowered = 1;
			enableOptics = 0;
			disableWeapons = 1;
			disableWeaponsLong = 1;
			variantsPlayer[] = {};
			variantsAI[] = {};
			enableMissile = 0;
			enableBinocular = 0;
		};
		class ARMK_cargo_basepistol: cargo_basepistol
		{
			variantsPlayer[] = {};
			variantsAI[] = {};
			enableMissile = 0;
			enableBinocular = 0;
		};
		class ARMK_cargo_base_idle_pistol: cargo_base_idle_pistol
		{
			weaponLowered = 1;
			enableOptics = 0;
			disableWeapons = 1;
			disableWeaponsLong = 1;
			variantsPlayer[] = {};
			variantsAI[] = {};
			enableMissile = 0;
			enableBinocular = 0;
		};
		class ARMK_01_Aim: ARMK_cargo_base_Rope
		{
			actions = "ARMK_01_Actions";
			leftHandIKCurve[] = {1};
			minPlayTime = 0.1;
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aim.rtm";
			speed = 100000;
			ConnectTo[] = {};
			InterpolateTo[] = {"ARMK_01_Idle", 0.1, "ARMK_01_Aim_ToPistol", 0.1, "ARMK_01_Die", 0.1};
			variantsAI[] = {"ARMK_01_Aim_Idling", 1};
			variantsPlayer[] = {"ARMK_01_Aim_Idling", 1};
		};
		class ARMK_01_Aim_No_Actions: ARMK_01_Aim
		{
			actions = "NoActions";
			variantsPlayer[] = {};
			variantsAI[] = {};
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};
		class ARMK_01_Aim_Idling: ARMK_01_Aim
		{
			variantsPlayer[] = {};
			headBobStrength = 0;
			soundEnabled = 1;
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aim1.rtm";
			speed = -8;
			ConnectTo[] = {"ARMK_01_Aim", 0.1};
		};
		class ARMK_01_Idle: ARMK_cargo_base_idle
		{
			actions = "ARMK_01_IdleActions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_idle.rtm";
			speed = 100000;
			minPlayTime = 0.1;
			aiming = "aimingDefault";
			leftHandIKCurve[] = {0};
			InterpolateTo[] = {"ARMK_01_Aim", 0.1, "ARMK_01_Aim_ToPistol", 0.1, "ARMK_01_Die", 0.1};
			variantsAI[] = {"ARMK_01_Idle_Idling", 1};
			variantsPlayer[] = {"ARMK_01_Idle_Idling", 1};
		};
		class ARMK_01_Idle_No_Actions: ARMK_01_Idle
		{
			actions = "NoActions";
			variantsPlayer[] = {};
			variantsAI[] = {};
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};
		class ARMK_01_Idle_Idling: ARMK_01_Idle
		{
			variantsPlayer[] = {};
			headBobStrength = 0;
			soundEnabled = 1;
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_idle1.rtm";
			speed = -10;
			ConnectTo[] = {"ARMK_01_Idle", 0.1};
		};
		class ARMK_01_Aim_Pistol: ARMK_cargo_basepistol
		{
			actions = "ARMK_01_PistolActions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aimpistol.rtm";
			aiming = "aimingRifleSlingDefault";
			aimingBody = "aimingUpRifleSlingDefault";
			speed = 100000;
			variantsAI[] = {"ARMK_01_Aim_Pistol_Idling", 1};
			variantsPlayer[] = {"ARMK_01_Aim_Pistol_Idling", 1};
			ConnectTo[] = {};
			InterpolateTo[] = {"ARMK_01_Aim_FromPistol", 0.1, "ARMK_01_Idle_Pistol", 0.2, "ARMK_01_Die_Pistol", 0.5};
		};
		class ARMK_01_Aim_Pistol_No_Actions: ARMK_01_Aim_Pistol
		{
			actions = "NoActions";
			variantsPlayer[] = {};
			variantsAI[] = {};
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};
		class ARMK_01_Aim_Pistol_Idling: ARMK_01_Aim_Pistol
		{
			variantsPlayer[] = {};
			headBobStrength = 0;
			soundEnabled = 1;
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aimpistol1.rtm";
			speed = -8;
			ConnectTo[] = {"ARMK_01_Aim_Pistol", 0.1};
		};
		class ARMK_01_Idle_Pistol: ARMK_cargo_base_idle_pistol
		{
			actions = "ARMK_01_IdlePistolActions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_idlepistol.rtm";
			speed = 100000;
			aiming = "aimingRifleSlingDefault";
			aimingBody = "aimingUpRifleSlingDefault";
			InterpolateTo[] = {"ARMK_01_Aim_Pistol", 0.1, "ARMK_01_Aim_FromPistol", 0.1, "ARMK_01_Die_Pistol", 0.1};
			variantsAI[] = {"ARMK_01_Idle_Pistol_Idling", 1};
			variantsPlayer[] = {"ARMK_01_Idle_Pistol_Idling", 1};
		};
		class ARMK_01_Idle_Pistol_No_Actions: ARMK_01_Idle_Pistol
		{
			actions = "NoActions";
			variantsPlayer[] = {};
			variantsAI[] = {};
			ConnectTo[] = {};
			InterpolateTo[] = {};
		};
		class ARMK_01_Idle_Pistol_Idling: ARMK_01_Idle
		{
			variantsPlayer[] = {};
			headBobStrength = 0;
			soundEnabled = 1;
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_idlepistol1.rtm";
			speed = -10;
			ConnectTo[] = {"ARMK_01_Idle_Pistol", 0.1};
		};
		class ARMK_01_Aim_ToPistol: AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon
		{
			actions = "ARMK_01_PistolActions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aimtopistol.rtm";
			speed = 2;
			ConnectTo[] = {"ARMK_01_Aim_ToPistol_End", 0.1};
			InterpolateTo[] = {};
		};
		class ARMK_01_Aim_ToPistol_End: AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon_end
		{
			actions = "ARMK_01_PistolActions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aimtopistol_end.rtm";
			speed = 1.875;
			ConnectTo[] = {"ARMK_01_Aim_Pistol", 0.1};
			InterpolateTo[] = {};
		};
		class ARMK_01_Aim_FromPistol: AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon
		{
			actions = "ARMK_01_PistolActions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aimFrompistol.rtm";
			speed = 2.307692;
			ConnectTo[] = {"ARMK_01_Aim_FromPistol_End", 0.1};
			InterpolateTo[] = {};
		};
		class ARMK_01_Aim_FromPistol_End: AmovPpneMstpSrasWpstDnon_AmovPpneMstpSrasWrflDnon_end
		{
			actions = "ARMK_01_Actions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_aimfrompistol_end.rtm";
			aiming = "aimingDefault";
			aimingBody = "aimingUpDefault";
			speed = 2;
			leftHandIKCurve[] = {0, 0, 0.5, 1};
			ConnectTo[] = {"ARMK_01_Aim", 0.1};
			InterpolateTo[] = {};
		};
		class ARMK_01_Die: DefaultDie
		{
			actions = "ARMK_01_DeadActions";
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_die.rtm";
			speed = 1;
			looped = "false";
			terminal = 1;
			ragdoll = 1;
			ConnectTo[] = {"Unconscious", 0.1};
			InterpolateTo[] = {};
		};
		class ARMK_01_Die_Pistol: ARMK_01_Die
		{
			file = "\ARMK_AdvancedRappelling\anims\Rup_RopeFX_01_die.rtm";
			actions = "ARMK_01_DeadActions";
			showHandGun = 1;
		};
	};
	class BlendAnims;
};
