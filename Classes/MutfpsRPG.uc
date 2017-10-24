#exec OBJ LOAD FILE=fpsRPGTex.utx
#exec OBJ LOAD FILE=fpsRPGMesh.usx

class MutfpsRPG extends Mutator
	config(fpsRPG);

const RPG_VERSION = 1;

var config int SaveDuringGameInterval; //periodically save during game - to avoid losing data from game crash or server kill
var config int StartingLevel; //starting level - cannot be less than 1
var config int PointsPerLevel; //stat points per levelup
var config array<int> Levels; //Experience needed for each level, NOTE: Levels[x] is exp needed for Level x+1
var config int InfiniteReqEXPOp; //For each level beyond the last in the Levels list, do this operation... (0 == Add, 1 == Multiply)
var config int InfiniteReqEXPValue; //...with this value to the EXP required for next level
var config float LevelDiffExpGainDiv; //divisor to extra experience from defeating someone of higher level (a value of 1 results in level difference squared EXP)
var config int MaxLevelupEffectStacking; //maximum number of levelup effects that can be spawned if player gains multiple levels at once
var config int EXPForWin; //EXP for winning the match (given to each member of team in team games)
var config int BotBonusLevels; //extra levelups bots gain after matches to counter that they're in only a fraction of the matches played (only if bFakeBotLevels is false)
var config int StatCaps[7]; //by popular demand :(
var config array<class<RPGAbility> > Abilities; //List of Abilities available to players
var config array<class<RPGAbility> > RemovedAbilities; //These Abilities failed an AbilityIsAllowed() check so try to re-add them next game
var config float WeaponModifierChance; //chance any given pickup results in a weapon modifier (0 to 1)
var config int MonsterLevel;

//A modifier a weapon might be given
struct WeaponModifier
{
	var class<RPGWeapon> WeaponClass;
	var int Chance; //chance this modifier will be used, relative to all others in use
};

var config array<WeaponModifier> WeaponModifiers;
var int TotalModifierChance; //precalculated total Chance of all WeaponModifiers
var config int Version; // config data version - used to know if the mod has been upgraded and the config needs to be updated
var bool bHasInteraction;
var bool bJustSaved;
//var config bool bExperiencePickups; //replace adrenaline pickups with experience pickups
var config bool bMagicalStartingWeapons; //weapons given at start can have magical properties (same probability as picked up weapons)
var config bool bAutoAdjustInvasionLevel; //auto adjust invasion monsters' level based on lowest level player
var config bool bFakeBotLevels; //if true, bots' data isn't saved and they're simply given a level near that of the players in the game
var config bool bIronmanMode; //if true, only the winner(s) of the match get their data saved
var config bool bNoUnidentified; //no unidentified items
var config bool bReset; //delete all player data on next startup
var config bool bUseOfficialRedirect; //redirect clients to a special official redirect server instead of the server's usual redirect
var config bool bAllowMagicSuperWeaponReplenish; //allow RPGWeapon::FillToInitialAmmo() on superweapons
var config float InvasionAutoAdjustFactor; //affects how dramatically monsters increase in level for each level of the lowest level player
var int BotSpendAmount; //bots that are buying stats spend points in increments of this amount
var config string HighestLevelPlayerName; //Highest level player ever to display in server query for all to see :)
var config int HighestLevelPlayerLevel;
var transient RPGPlayerDataObject CurrentLowestLevelPlayer; //Data of lowest level player currently playing (for auto-adjusting monsters, etc)
var transient array<RPGPlayerDataObject> OldPlayers; //players who were playing and then left the server - used when playing Invasion in Ironman mode
var transient string LastOverrideDownloadIP; //last IP sent to OverrideDownload() to make sure we don't override the REAL redirect for non-fpsRPG files
var config array<name> SuperAmmoClassNames; // names of ammo classes that belong to superweapons (WARNING: subclasses MUST be listed seperately!)
var config array< class<Monster> > ConfigMonsterList; // configurable monster list override for summoning abilities
var array< class<Monster> > MonsterList; //monsters available in the current game; if ConfigMonsterList is empty, automatically filled

var localized string PropsDisplayText[22];
var localized string PropsDescText[22];
var localized string PropsExtras;

// list of markers associated with players using the Vampire ability
// the Vampire ability needs an easy way to find them and this is the best persistent object to place them on
// (in a perfect world, we'd use the Pawn or Controller, but I don't want to subclass them for compatibility reasons)

var array<VampireMarker> VampireMarkers;

//AUD Store Stuff
struct WeaponsInfo
{
	var Class<Weapon> WeaponClass;
	var int WeaponCost;
};

struct ArtifactsInfo
{
	var Class<RPGArtifact> ArtifactClass;
	var int ArtifactCost;
};

struct ModifiersInfo
{
	var Class<RPGArtifact> ArtifactClass;
	var int ModifierCost;
};

var config array<WeaponsInfo> WeaponsList;
var config array<ArtifactsInfo> ArtifactsList;
var config array<ModifiersInfo> ModifiersList;
var config int MoneyPerKill,StartingMoney;

static final function int GetVersion()
{
	return RPG_VERSION;
}

// simple utility to find the mutator in the given game
static final function MutfpsRPG GetRPGMutator(GameInfo G)
{
	local Mutator M;
	local MutfpsRPG RPGMut;

	for (M = G.BaseMutator; M != None && RPGMut == None; M = M.NextMutator)
	{
		RPGMut = MutfpsRPG(M);
	}

	return RPGMut;
}

//returns true if the specified ammo belongs to a weapon that we consider a superweapon
static final function bool IsSuperWeaponAmmo(class<Ammunition> AmmoClass)
{
	local int i;

	if (AmmoClass.default.MaxAmmo < 5)
	{
		return true;
	}
	else
	{
		for (i = 0; i < default.SuperAmmoClassNames.length; i++)
		{
			if (AmmoClass.Name == default.SuperAmmoClassNames[i])
			{
				return true;
			}
		}
	}

	return false;
}

function PostBeginPlay()
{
	local RPGRules G;
	local int x;
	local Pickup P;
	local RPGPlayerDataObject DataObject;
	local array<string> PlayerNames;
	local TCPNetDriver NetDriver;
	local string DownloadManagers;

	//update version
	if (Version <= 20)
	{
		if (Version <= 12)
		{
			// if we're using the default EXP table from version 1.2, update it
			if (Levels.length == 29 && Levels[28] == 150 && InfiniteReqEXPOp == 0 && InfiniteReqEXPValue == 0)
			{
				InfiniteReqEXPValue = 5;
			}
			// add Healing magic weapon to the list
			WeaponModifiers.Insert(0, 1);
			WeaponModifiers[0].WeaponClass = class<RPGWeapon>(DynamicLoadObject("fpsRPG.RW_Healing", class'Class'));
			WeaponModifiers[0].Chance = 1;
		}

		class'RPGArtifactManager'.static.UpdateArtifactList();

		Version = RPG_VERSION;
		SaveConfig();
	}

	G = spawn(class'RPGRules');
	G.RPGMut = self;
	G.PointsPerLevel = PointsPerLevel;
	G.LevelDiffExpGainDiv = LevelDiffExpGainDiv;
	//RPGRules needs to be first in the list for compatibility with some other mutators (like UDamage Reward)
	if (Level.Game.GameRulesModifiers != None)
		G.NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = G;

	if (bReset)
	{
		//load em all up, and delete them one by one
		PlayerNames = class'RPGPlayerDataObject'.static.GetPerObjectNames("fpsRPG",, 1000000);
		for (x = 0; x < PlayerNames.length; x++)
		{
			DataObject = new(None, PlayerNames[x]) class'RPGPlayerDataObject';
			DataObject.ClearConfig();
			//bleh, this sucks, what a waste of memory
			//if only ClearConfig() actually cleared the properties of the object instance...
			DataObject = new(None, PlayerNames[x]) class'RPGPlayerDataObject';
		}

		bReset = false;
		SaveConfig();
	}

	for (x = 0; x < WeaponModifiers.length; x++)
		TotalModifierChance += WeaponModifiers[x].Chance;

	spawn(class'RPGArtifactManager');

	if (SaveDuringGameInterval > 0.0 && !bIronmanMode)
		SetTimer(SaveDuringGameInterval, true);

	if (StartingLevel < 1)
	{
		StartingLevel = 1;
		SaveConfig();
	}

	BotSpendAmount = PointsPerLevel * 3;

	//HACK - if another mutator played with the weapon pickups in *BeginPlay() (like Random Weapon Swap does)
	//we won't get CheckRelevance() calls on those pickups, so find any such pickups here and force it
	foreach DynamicActors(class'Pickup', P)
		if (P.bScriptInitialized && !P.bGameRelevant && !CheckRelevance(P))
			P.Destroy();

	//remove any disallowed abilities
	for (x = 0; x < Abilities.length; x++)
	{
		if (Abilities[x] == None)
		{
			Abilities.Remove(x, 1);
			SaveConfig();
			x--;
		}
		else if (!Abilities[x].static.AbilityIsAllowed(Level.Game, self))
		{
			RemovedAbilities[RemovedAbilities.length] = Abilities[x];
			Abilities.Remove(x, 1);
			SaveConfig();
			x--;
		}
	}
	//See if any abilities that weren't allowed last game are allowed this time
	//(so user doesn't have to fix ability list when switching gametypes/mutators a lot)
	for (x = 0; x < RemovedAbilities.length; x++)
		if (RemovedAbilities[x].static.AbilityIsAllowed(Level.Game, self))
		{
			Abilities[Abilities.length] = RemovedAbilities[x];
			RemovedAbilities.Remove(x, 1);
			SaveConfig();
			x--;
		}

	// set up an extra download manager that we'll override later with the official UT2004RPG redirect
	if (Level.NetMode != NM_StandAlone && bUseOfficialRedirect)
	{
		foreach AllObjects(class'TCPNetDriver', NetDriver)
		{
			DownloadManagers = NetDriver.GetPropertyText("DownloadManagers");
			NetDriver.SetPropertyText("DownloadManagers", "(\"IpDrv.HTTPDownload\"," $ Right(DownloadManagers, Len(DownloadManagers) - 1));
		}
	}

	Super.PostBeginPlay();
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int x;
	local FakeMonsterWeapon w;
	local RPGWeaponPickup p;
	local WeaponLocker Locker;
	local RPGWeaponLocker RPGLocker;
	local Controller C;
	local RPGStatsInv StatsInv;
	local Weapon Weap;
	//local ExperiencePickup EXP;

	if (Other == None)
	{
		return true;
	}

	//hack to allow players to pick up above normal ammo from inital ammo pickup;
	//MaxAmmo will be set to a good value later by the player's RPGStatsInv
	if (Ammunition(Other) != None && ShieldAmmo(Other) == None)
		Ammunition(Other).MaxAmmo = 999;

	/*if (AdrenalinePickup(Other) != None && bExperiencePickups)
	{
		EXP = ExperiencePickup(ReplaceWithActor(Other, "fpsRPG.ExperiencePickup"));
		if (EXP != None)
			EXP.RPGMut = self;
		return false;
	}*/

	if (WeaponModifierChance > 0)
	{
		if (Other.IsA('WeaponLocker') && !Other.IsA('RPGWeaponLocker'))
		{
			Locker = WeaponLocker(Other);
			RPGLocker = RPGWeaponLocker(ReplaceWithActor(Other, "fpsRPG.RPGWeaponLocker"));
			if (RPGLocker != None)
			{
				RPGLocker.SetLocation(Locker.Location);
				RPGLocker.RPGMut = self;
				RPGLocker.ReplacedLocker = Locker;
				Locker.GotoState('Disabled');
			}
			for (x = 0; x < Locker.Weapons.length; x++)
				if (Locker.Weapons[x].WeaponClass == class'LinkGun')
					Locker.Weapons[x].WeaponClass = class'RPGLinkGun';
		}

		// don't affect the translocator because it breaks bots
		// don't affect Weapons of Evil's Sentinel Deployer because it doesn't work at all
		if ( Other.IsA('WeaponPickup') && !Other.IsA('TransPickup') && !Other.IsA('RPGWeaponPickup')
			&& !Other.IsA('SentinelDeployerPickup') )
		{
			p = RPGWeaponPickup(ReplaceWithActor(Other, "fpsRPG.RPGWeaponPickup"));
			if (p != None)
			{
				p.RPGMut = self;
				p.FindPickupBase();
				p.GetPropertiesFrom(class<WeaponPickup>(Other.Class));
			}
			return false;
		}

		//various weapon hacks to work around casts of Pawn.Weapon
		if (xWeaponBase(Other) != None)
		{
			if (xWeaponBase(Other).WeaponType == class'LinkGun')
				xWeaponBase(Other).WeaponType = class'RPGLinkGun';
		}
		else
		{
			Weap = Weapon(Other);
			if (Weap != None)
			{
				for (x = 0; x < Weap.NUM_FIRE_MODES; x++)
				{
					if (Weap.FireModeClass[x] == class'ShockProjFire')
						Weap.FireModeClass[x] = class'RPGShockProjFire';
					else if (Weap.FireModeClass[x] == class'PainterFire')
						Weap.FireModeClass[x] = class'RPGPainterFire';
				}
			}
		}
	}
	else if (Other.IsA('Weapon'))
	{
		// need ammo instances for Max Ammo stat to work without magic weapons
		// I hate this but I couldn't think of a better way
		Weapon(Other).bNoAmmoInstances = false;
	}

	//Give monsters a fake weapon
	if (Other.IsA('Monster'))
	{
		Monster(Other).Health = Monster(Other).Health +(AUDInvasion(Level.Game).Gamemode * 1000.00);
        Monster(Other).HealthMax = Monster(Other).Health;
        Monster(Other).DamageScaling = Monster(Other).DamageScaling + (AUDInvasion(level.Game).GameMode * 1000.00);
        Monster(Other).ScoringValue = Monster(Other).ScoringValue + (Monster(Other).Health*0.25);
		if(Monster(Other).FindInventoryType(Class'BossInv') != None)
        {
            Monster(Other).Health = Monster(Other).Health+(Monster(Other).Health * 500.00);  //*gamemode maybe??
            Monster(Other).HealthMax = Monster(Other).Health;
            Monster(Other).DamageScaling = Monster(Other).DamageScaling+(Monster(Other).DamageScaling * 500.00);
        }

		w = spawn(class'FakeMonsterWeapon',Other,,,rot(0,0,0));
		w.GiveTo(Pawn(Other));
	}
	else if (Pawn(Other) != None)
	{
		// evil hack for bad Assault code
		// when Assault does its respawn and teleport stuff (e.g. when finished spacefighter part of AS-Mothership)
		// it spawns a new pawn and destroys the old without calling any of the proper functions
		C = Controller(Other.Owner);
		if (C != None && C.Pawn != None)
		{
			// NOTE - the use of FindInventoryType() here is intentional
			// we don't need to do anything if the old pawn doesn't have possession of an RPGStatsInv
			StatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv != None)
				StatsInv.OwnerDied();
		}
	}

	//force adrenaline on if artifacts enabled
	//FIXME maybe disable all combos?
	if ( Controller(Other) != None && class'RPGArtifactManager'.default.ArtifactDelay > 0 && class'RPGArtifactManager'.default.MaxArtifacts > 0
	     && class'RPGArtifactManager'.default.AvailableArtifacts.length > 0 )
		Controller(Other).bAdrenalineEnabled = true;


	return true;
}

//Replace an actor and then return the new actor
function Actor ReplaceWithActor(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( aClassName == "" )
		return None;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if ( A.IsA('Pickup') )
			Pickup(A).Respawntime = 0.0;
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return A;
	}
	return None;
}

function ModifyPlayer(Pawn Other)
{
	local RPGPlayerDataObject data;
	local int x, FakeBotLevelDiff;
	local RPGStatsInv StatsInv;
	local Inventory Inv;
	local array<Weapon> StartingWeapons;
	local class<Weapon> StartingWeaponClass;
	local RPGWeapon MagicWeapon;

	Super.ModifyPlayer(Other);

	if (Other.Controller == None || !Other.Controller.bIsPlayer)
		return;
	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		if (StatsInv.Instigator != None)
			for (x = 0; x < StatsInv.Data.Abilities.length; x++)
				StatsInv.Data.Abilities[x].static.ModifyPawn(StatsInv.Instigator, StatsInv.Data.AbilityLevels[x]);
		return;
	}
	else
	{
		for (Inv = Other.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
			//I fail to understand why I need this check... am I missing something obvious or is this some weird script bug?
			if (Inv.Inventory == None)
			{
				Inv.Inventory = None;
				break;
			}
		}
	}

	if (StatsInv != None)
		data = StatsInv.DataObject;
	else
	{
		data = RPGPlayerDataObject(FindObject("Package." $ Other.PlayerReplicationInfo.PlayerName, class'RPGPlayerDataObject'));
		if (data == None)
			data = new(None, Other.PlayerReplicationInfo.PlayerName) class'RPGPlayerDataObject';
		if (bFakeBotLevels && PlayerController(Other.Controller) == None) //a bot, and fake bot levels is turned on
		{
			// if the bot has data, delete it
			if (data.Level != 0)
			{
				data.ClearConfig();
				data = new(None, Other.PlayerReplicationInfo.PlayerName) class'RPGPlayerDataObject';
			}

			// give the bot a level near the current lowest level
			if (CurrentLowestLevelPlayer != None)
			{
				FakeBotLevelDiff = 3 + Min(25, CurrentLowestLevelPlayer.Level * 0.1);
				data.Level = Max(StartingLevel, CurrentLowestLevelPlayer.Level - FakeBotLevelDiff + Rand(FakeBotLevelDiff * 2));
			}
			else
				data.Level = StartingLevel;

			data.PointsAvailable = PointsPerLevel * data.Level;
			data.AdrenalineMax = 100;
			data.Shieldmax = 150;
			if (Levels.length > data.Level)
				data.NeededExp = Levels[data.Level];
			else if (InfiniteReqEXPValue != 0)
			{
				if (InfiniteReqEXPOp == 0)
					data.NeededExp = Levels[Levels.length - 1] + InfiniteReqEXPValue * (data.Level - (Levels.length - 1));
				else
				{
					data.NeededExp = Levels[Levels.length - 1];
					for (x = Levels.length - 1; x < data.Level; x++)
						data.NeededExp += int(float(data.NeededExp) * float(InfiniteReqEXPValue) * 0.01);
				}
			}
			else
				data.NeededExp = Levels[Levels.length - 1];

			// give some random amount of EXP toward next level so some will gain a level or two during the match
			data.Experience = Rand(data.NeededExp);

			data.OwnerID = "Bot";
		}
		else if (data.Level == 0) //new player
		{
			data.Level = StartingLevel;
			data.PointsAvailable = PointsPerLevel * (StartingLevel - 1);
			data.AdrenalineMax = 100;
			data.Shieldmax = 150;
			if (Levels.length > StartingLevel)
				data.NeededExp = Levels[StartingLevel];
			else if (InfiniteReqEXPValue != 0)
			{
				if (InfiniteReqEXPOp == 0)
					data.NeededExp = Levels[Levels.length - 1] + InfiniteReqEXPValue * (data.Level - (Levels.length - 1));
				else
				{
					data.NeededExp = Levels[Levels.length - 1];
					for (x = Levels.length - 1; x < StartingLevel; x++)
						data.NeededExp += int(float(data.NeededEXP) * float(InfiniteReqEXPValue) * 0.01);
				}
			}
			else
				data.NeededExp = Levels[Levels.length - 1];
			if (PlayerController(Other.Controller) != None)
				data.OwnerID = PlayerController(Other.Controller).GetPlayerIDHash();
			else
				data.OwnerID = "Bot";
		}
		else //returning player
		{
			if ( (PlayerController(Other.Controller) != None && !(PlayerController(Other.Controller).GetPlayerIDHash() ~= data.OwnerID))
			     || (Bot(Other.Controller) != None && data.OwnerID != "Bot") )
			{
				//imposter using somebody else's name
				if (PlayerController(Other.Controller) != None)
					PlayerController(Other.Controller).ReceiveLocalizedMessage(class'RPGNameMessage', 0);
				Level.Game.ChangeName(Other.Controller, Other.PlayerReplicationInfo.PlayerName$"_Imposter", true);
				if (string(data.Name) ~= Other.PlayerReplicationInfo.PlayerName) //initial name change failed
					Level.Game.ChangeName(Other.Controller, string(Rand(65000)), true); //That's gotta suck, having a number for a name
				ModifyPlayer(Other);
				return;
			}
			ValidateData(data);
		}
	}

	if (data.PointsAvailable > 0 && Bot(Other.Controller) != None)
	{
		x = 0;
		do
		{
			BotLevelUp(Bot(Other.Controller), data);
			x++;
		} until (data.PointsAvailable <= 0 || data.BotAbilityGoal != None || x > 10000)
	}

	if ((CurrentLowestLevelPlayer == None || data.Level < CurrentLowestLevelPlayer.Level) && (!bFakeBotLevels || Other.Controller.IsA('PlayerController')))
		CurrentLowestLevelPlayer = data;

	//spawn the stats inventory item
	if (StatsInv == None)
	{
		StatsInv = spawn(class'RPGStatsInv',Other,,,rot(0,0,0));
		if (Other.Controller.Inventory == None)
			Other.Controller.Inventory = StatsInv;
		else
		{
			for (Inv = Other.Controller.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
			{}
			Inv.Inventory = StatsInv;
		}
	}
	StatsInv.DataObject = data;
	data.CreateDataStruct(StatsInv.Data, false);
	StatsInv.RPGMut = self;
	StatsInv.GiveTo(Other);

	if (WeaponModifierChance > 0)
	{
		x = 0;
		for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if (Weapon(Inv) != None && RPGWeapon(Inv) == None)
				StartingWeapons[StartingWeapons.length] = Weapon(Inv);
			x++;
			if (x > 1000)
				break;
		}

		for (x = 0; x < StartingWeapons.length; x++)
		{
			StartingWeaponClass = StartingWeapons[x].Class;
			// don't affect the translocator because it breaks bots
			// don't affect Weapons of Evil's Sentinel Deployer because it doesn't work at all
			if (StartingWeaponClass.Name != 'TransLauncher' && StartingWeaponClass.Name != 'SentinelDeployer')
			{
				StartingWeapons[x].Destroy();
				if (bMagicalStartingWeapons)
					MagicWeapon = spawn(GetRandomWeaponModifier(StartingWeaponClass, Other), Other,,, rot(0,0,0));
				else
					MagicWeapon = spawn(class'RPGWeapon', Other,,, rot(0,0,0));
				MagicWeapon.Generate(None);
				MagicWeapon.SetModifiedWeapon(spawn(StartingWeaponClass,Other,,,rot(0,0,0)), bNoUnidentified);
				MagicWeapon.GiveTo(Other);
			}
		}
		Other.Controller.ClientSwitchToBestWeapon();
	}

	if(xPawn(Other) != None)
		xPawn(Other).ShieldStrengthMax = xPawn(Other).default.ShieldStrengthMax + data.ShieldMax;

	//set pawn's properties
	Other.Health = Other.default.Health + data.HealthBonus;
	Other.HealthMax = Other.default.HealthMax + data.HealthBonus;
	Other.SuperHealthMax = Other.HealthMax + (Other.default.SuperHealthMax - Other.default.HealthMax);
	Other.Controller.AdrenalineMax = data.AdrenalineMax;
	for (x = 0; x < data.Abilities.length; x++)
		data.Abilities[x].static.ModifyPawn(Other, data.AbilityLevels[x]);
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local int DefHealth, i;
	local float DefLinkHealMult, HealthPct;
	local array<RPGArtifact> Artifacts;

	if (V.Controller != None)
	{
		for (Inv = V.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
	}

	if (StatsInv == None)
		StatsInv = RPGStatsInv(P.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		//FIXME maybe give it inventory to remember original values instead so it works with other mods that change vehicle properties?
		if (ASVehicleFactory(V.ParentFactory) != None)
		{
			DefHealth = ASVehicleFactory(V.ParentFactory).VehicleHealth;
			DefLinkHealMult = ASVehicleFactory(V.ParentFactory).VehicleLinkHealMult;
		}
		else
		{
			DefHealth = V.default.Health;
			DefLinkHealMult = V.default.LinkHealMult;
		}
		HealthPct = float(V.Health) / V.HealthMax;
		V.HealthMax = DefHealth + StatsInv.Data.HealthBonus;
		V.Health = HealthPct * V.HealthMax;
		V.LinkHealMult = DefLinkHealMult * (V.HealthMax / DefHealth); //FIXME maybe make faster link healing an ability instead?

		StatsInv.ModifyVehicle(V);
		StatsInv.ClientModifyVehicle(V);
	}
	else
		Warn("Couldn't find RPGStatsInv for "$P.GetHumanReadableName());

	//move all artifacts from driver to vehicle, so player can still use them
	for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
		if (RPGArtifact(Inv) != None)
			Artifacts[Artifacts.length] = RPGArtifact(Inv);

	//hack - temporarily give the pawn its Controller back because RPGArtifact::Activate() needs it
	P.Controller = V.Controller;
	for (i = 0; i < Artifacts.length; i++)
	{
		if (Artifacts[i].bActive)
		{
			//turn it off first
			Artifacts[i].ActivatedTime = -1000000; //force it to allow deactivation
			Artifacts[i].Activate();
		}
		if (Artifacts[i] == P.SelectedItem)
			V.SelectedItem = Artifacts[i];
		P.DeleteInventory(Artifacts[i]);
		Artifacts[i].GiveTo(V);
	}
	P.Controller = None;

	Super.DriverEnteredVehicle(V, P);
}

function DriverLeftVehicle(Vehicle V, Pawn P)
{
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local array<RPGArtifact> Artifacts;
	local int i;

	if (P.Controller != None)
	{
		for (Inv = P.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
	}

	if (StatsInv == None)
		StatsInv = RPGStatsInv(P.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		// yet another Assault hack (spacefighters)
		if (StatsInv.Instigator == V)
			V.DeleteInventory(StatsInv);

		StatsInv.UnModifyVehicle(V);
		StatsInv.ClientUnModifyVehicle(V);
	}
	else
		Warn("Couldn't find RPGStatsInv for "$P.GetHumanReadableName());

	//move all artifacts from vehicle to driver
	for (Inv = V.Inventory; Inv != None; Inv = Inv.Inventory)
		if (RPGArtifact(Inv) != None)
			Artifacts[Artifacts.length] = RPGArtifact(Inv);

	//hack - temporarily give the vehicle its Controller back because RPGArtifact::Activate() needs it
	V.Controller = P.Controller;
	for (i = 0; i < Artifacts.length; i++)
	{
		if (Artifacts[i].bActive)
		{
			//turn it off first
			Artifacts[i].ActivatedTime = -1000000; //force it to allow deactivation
			Artifacts[i].Activate();
		}
		if (Artifacts[i] == V.SelectedItem)
			P.SelectedItem = Artifacts[i];
		V.DeleteInventory(Artifacts[i]);
		Artifacts[i].GiveTo(P);
	}
	V.Controller = None;

	Super.DriverLeftVehicle(V, P);
}

//Check the player data at the given index for errors (too many/not enough stat points, invalid abilities)
//Converts the data by giving or taking the appropriate number of stat points and refunding points for abilities bought that are no longer allowed
//This allows the server owner to change points per level settings and/or the abilities allowed and have it affect already created players properly
function ValidateData(RPGPlayerDataObject Data)
{
	local int TotalPoints, x, y;
	local bool bAllowedAbility;

	//check stat caps
	if (StatCaps[0] >= 0)
		Data.WeaponSpeed = Min(Data.WeaponSpeed, StatCaps[0]);
	if (StatCaps[1] >= 0)
		Data.HealthBonus = Min(Data.HealthBonus, StatCaps[1]);
	if (StatCaps[2] >= 0)
		Data.ShieldMax = Max(Min(Data.ShieldMax, StatCaps[2]), Min(StatCaps[2], 150));
	else
        Data.ShieldMax = Max(Data.ShieldMax, 150);
	if (StatCaps[3] >= 0)
		Data.AdrenalineMax = Max(Min(Data.AdrenalineMax, StatCaps[3]), Min(StatCaps[3], 100));
	else
		Data.AdrenalineMax = Max(Data.AdrenalineMax, 100); // make sure adrenaline max is above starting value
	if (StatCaps[4] >= 0)
		Data.Attack = Min(Data.Attack, StatCaps[4]);
	if (StatCaps[5] >= 0)
		Data.Defense = Min(Data.Defense, StatCaps[5]);
	if (StatCaps[6] >= 0)
		Data.AmmoMax = Min(Data.AmmoMax, StatCaps[6]);

	TotalPoints += Data.WeaponSpeed + Data.Attack + Data.Defense + Data.AmmoMax;
	TotalPoints += Data.HealthBonus / 2;
	TotalPoints += Data.AdrenalineMax - 100;
	TotalPoints += Data.ShieldMax - 150;
	for (x = 0; x < Data.Abilities.length; x++)
	{
		bAllowedAbility = false;
		for (y = 0; y < Abilities.length; y++)
			if (Data.Abilities[x] == Abilities[y])
			{
				bAllowedAbility = true;
				y = Abilities.length;		//kill loop without break due to UnrealScript bug that causes break to kill both loops
			}
		if (bAllowedAbility)
		{
			for (y = 0; y < Data.AbilityLevels[x]; y++)
				TotalPoints += Data.Abilities[x].static.Cost(Data, y);
		}
		else
		{
			for (y = 0; y < Data.AbilityLevels[x]; y++)
				Data.PointsAvailable += Data.Abilities[x].static.Cost(Data, y);
			Log("Ability"@Data.Abilities[x]@"was in"@Data.Name$"'s data but is not an available ability - removed (stat points refunded)");
			Data.Abilities.Remove(x, 1);
			Data.AbilityLevels.Remove(x, 1);
			x--;
		}
	}
	TotalPoints += Data.PointsAvailable;

	if ( TotalPoints != ((Data.Level - 1) * PointsPerLevel) )
	{
		Data.PointsAvailable += ((Data.Level - 1) * PointsPerLevel) - TotalPoints;
		Log(Data.Name$" had "$TotalPoints$" total stat points at Level "$Data.Level$", should be "$((Data.Level - 1) * PointsPerLevel)$", PointsAvailable changed by "$(((Data.Level - 1) * PointsPerLevel) - TotalPoints)$" to compensate");
	}
}

//Do a bot's levelup
function BotLevelUp(Bot B, RPGPlayerDataObject Data)
{
	local int WSpeedChance, HealthBonusChance, AdrenalineMaxChance, AttackChance, DefenseChance, AmmoMaxChance, AbilityChance;
	local int Chance, TotalAbilityChance;
	local int x, y, Index;
	local bool bHasAbility, bAddAbility;

	if (Data.BotAbilityGoal != None)
	{
		if (Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel) > Data.PointsAvailable)
			return;

		Index = -1;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == Data.BotAbilityGoal)
			{
				Index = x;
				break;
			}
		if (Index == -1)
			Index = Data.Abilities.length;
		Data.PointsAvailable -= Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel);
		Data.Abilities[Index] = Data.BotAbilityGoal;
		Data.AbilityLevels[Index]++;
		Data.BotAbilityGoal = None;
		return;
	}

	//Bots always allocate all their points to one stat - random, but tilted towards the bot's tendencies

	WSpeedChance = 2;
	HealthBonusChance = 2;
	AdrenalineMaxChance = 1;
	AttackChance = 2;
	DefenseChance = 2;
	AmmoMaxChance = 1; //less because bots don't get ammo half the time as it is, so it's not as useful a stat for them
	AbilityChance = 3;

	if (B.Aggressiveness > 0.25)
	{
		WSpeedChance += 3;
		AttackChance += 3;
		AmmoMaxChance += 2;
	}
	if (B.Accuracy < 0)
	{
		WSpeedChance++;
		DefenseChance++;
		AmmoMaxChance += 2;
	}
	if (B.FavoriteWeapon != None && B.FavoriteWeapon.default.FireModeClass[0] != None && B.FavoriteWeapon.default.FireModeClass[0].default.FireRate > 1.25)
		WSpeedChance += 2;
	if (B.Tactics > 0.9)
	{
		HealthBonusChance += 3;
		AdrenalineMaxChance += 3;
		DefenseChance += 3;
	}
	else if (B.Tactics > 0.4)
	{
		HealthBonusChance += 2;
		AdrenalineMaxChance += 2;
		DefenseChance += 2;
	}
	else if (B.Tactics > 0)
	{
		HealthBonusChance++;
		AdrenalineMaxChance++;
		DefenseChance++;
	}
	if (B.StrafingAbility < 0)
	{
		HealthBonusChance++;
		AdrenalineMaxChance++;
		DefenseChance += 2;
	}
	if (B.CombatStyle < 0)
	{
		HealthBonusChance += 2;
		AdrenalineMaxChance += 2;
		DefenseChance += 2;
	}
	else if (B.CombatStyle > 0)
	{
		AttackChance += 2;
		AmmoMaxChance++;
	}
	if (Data.Level < 20)
		AbilityChance--;	//very few abilities to choose from at this low level so reduce chance
	else
	{
		//More likely to buy an ability if don't have that many
		y = 0;
		for (x = 0; x < Data.AbilityLevels.length; x++)
			y += Data.AbilityLevels[x];
		if (y < (Data.Level - 20) / 10)
			AbilityChance++;
	}

	if (Data.AmmoMax >= 50)
		AmmoMaxChance = Max(AmmoMaxChance / 1.5, 1);
	if (Data.AdrenalineMax >= 175)
		AdrenalineMaxChance /= 1.5;  //too much adrenaline and you'll never get to use any combos!

	//disable choosing of stats that are maxxed out
	if (StatCaps[0] >= 0 && Data.WeaponSpeed >= StatCaps[0])
		WSpeedChance = 0;
	if (StatCaps[1] >= 0 && Data.HealthBonus >= StatCaps[1])
		HealthBonusChance = 0;
	if (StatCaps[2] >= 0 && Data.AdrenalineMax >= StatCaps[2])
		AdrenalineMaxChance = 0;
	if (StatCaps[3] >= 0 && Data.Attack >= StatCaps[3])
		AttackChance = 0;
	if (StatCaps[4] >= 0 && Data.Defense >= StatCaps[4])
		DefenseChance = 0;
	if (StatCaps[5] >= 0 && Data.AmmoMax >= StatCaps[5])
		AmmoMaxChance = 0;

	//choose a stat
	Chance = Rand(WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance + DefenseChance + AmmoMaxChance + AbilityChance);
	bAddAbility = false;
	if (Chance < WSpeedChance)
		Data.WeaponSpeed += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance)
		Data.HealthBonus += Min(Data.PointsAvailable, BotSpendAmount) * 2;
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance)
		Data.AdrenalineMax += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance)
		Data.Attack += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance + DefenseChance)
		Data.Defense += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance + DefenseChance + AmmoMaxChance)
		Data.AmmoMax += Min(Data.PointsAvailable, BotSpendAmount);
	else
		bAddAbility = true;
	if (!bAddAbility)
		Data.PointsAvailable -= Min(Data.PointsAvailable, BotSpendAmount);
	else
	{
		TotalAbilityChance = 0;
		for (x = 0; x < Abilities.length; x++)
		{
			bHasAbility = false;
			for (y = 0; y < Data.Abilities.length; y++)
				if (Abilities[x] == Data.Abilities[y])
				{
					bHasAbility = true;
					TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, Data.AbilityLevels[y]);
					y = Data.Abilities.length; //kill loop without break
				}
			if (!bHasAbility)
				TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, 0);
		}
		if (TotalAbilityChance == 0)
			return; //no abilities can be bought
		Chance = Rand(TotalAbilityChance);
		TotalAbilityChance = 0;
		for (x = 0; x < Abilities.length; x++)
		{
			bHasAbility = false;
			for (y = 0; y < Data.Abilities.length; y++)
				if (Abilities[x] == Data.Abilities[y])
				{
					bHasAbility = true;
					TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, Data.AbilityLevels[y]);
					if (Chance < TotalAbilityChance)
					{
						Data.BotAbilityGoal = Abilities[x];
						Data.BotGoalAbilityCurrentLevel = Data.AbilityLevels[y];
						Index = y;
					}
					y = Data.Abilities.length; //kill loop without break
				}
			if (!bHasAbility)
			{
				TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, 0);
				if (Chance < TotalAbilityChance)
				{
					Data.BotAbilityGoal = Abilities[x];
					Data.BotGoalAbilityCurrentLevel = 0;
					Index = Data.Abilities.length;
					Data.AbilityLevels[Index] = 0;
				}
			}
			if (Chance < TotalAbilityChance)
				break; //found chosen ability
		}
		if (Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel) <= Data.PointsAvailable)
		{
			Data.PointsAvailable -= Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel);
			Data.Abilities[Index] = Data.BotAbilityGoal;
			Data.AbilityLevels[Index]++;
			Data.BotAbilityGoal = None;
		}
	}
}

function CheckLevelUp(RPGPlayerDataObject data, PlayerReplicationInfo MessagePRI)
{
	local LevelUpEffect Effect;
	local int Count;

	while (data.Experience >= data.NeededExp && Count < 10000)
	{
		Count++;
		data.Level++;
		data.PointsAvailable += PointsPerLevel;
		data.Experience -= data.NeededExp;

		if (Levels.length > data.Level)
			data.NeededExp = Levels[data.Level];
		else if (InfiniteReqEXPValue != 0)
		{
			if (InfiniteReqEXPOp == 0)
				data.NeededExp = Levels[Levels.length - 1] + InfiniteReqEXPValue * (data.Level - (Levels.length - 1));
			else
				data.NeededExp += int(float(data.NeededEXP) * float(InfiniteReqEXPValue) / 100.f);
		}
		else
			data.NeededExp = Levels[Levels.length - 1];

		if (MessagePRI != None)
		{
			if (Count <= MaxLevelupEffectStacking && Controller(MessagePRI.Owner) != None && Controller(MessagePRI.Owner).Pawn != None)
			{
				Effect = Controller(MessagePRI.Owner).Pawn.spawn(class'LevelUpEffect', Controller(MessagePRI.Owner).Pawn);
				Effect.SetDrawScale(Controller(MessagePRI.Owner).Pawn.CollisionRadius / Effect.CollisionRadius);
				Effect.Initialize();
			}
		}

		if (data.Level > HighestLevelPlayerLevel && (!bFakeBotLevels || data.OwnerID != "Bot"))
		{
			HighestLevelPlayerName = string(data.Name);
			HighestLevelPlayerLevel = data.Level;
			SaveConfig();
		}
	}

	if (Count > 0 && MessagePRI != None)
		Level.Game.BroadCastLocalized(self, class'GainLevelMessage', data.Level, MessagePRI);
}

function class<RPGWeapon> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other)
{
	local int x, Chance;

	if (FRand() < WeaponModifierChance)
	{
		Chance = Rand(TotalModifierChance);
		for (x = 0; x < WeaponModifiers.Length; x++)
		{
			Chance -= WeaponModifiers[x].Chance;
			if (Chance < 0 && WeaponModifiers[x].WeaponClass.static.AllowedFor(WeaponType, Other))
				return WeaponModifiers[x].WeaponClass;
		}
	}

	return class'RPGWeapon';
}

function FillMonsterList()
{
	local Object O;
	local class<Monster> MonsterClass;

	if (MonsterList.length == 0)
	{
		if (ConfigMonsterList.length > 0)
		{
			MonsterList = ConfigMonsterList;
		}
		else
		{
			foreach AllObjects(class'Object', O)
			{
				MonsterClass = class<Monster>(O);
				if ( MonsterClass != None && MonsterClass != class'Monster' && MonsterClass.default.Mesh != class'xPawn'.default.Mesh
					&& MonsterClass.default.ScoringValue < 100 )
					MonsterList[MonsterList.length] = MonsterClass;
			}
		}
	}
}

function NotifyLogout(Controller Exiting)
{
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local RPGPlayerDataObject DataObject;

	if (Level.Game.bGameRestarted)
	{
		return;
	}

	for (Inv = Exiting.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			break;
	}

	if (StatsInv == None)
		return;

	DataObject = StatsInv.DataObject;
	StatsInv.Destroy();

	// possibly save data
	if (!bFakeBotLevels || Exiting.IsA('PlayerController'))
	{
		if (bIronmanMode)
		{
			// in Invasion record players that leave so if the team wins they still keep the EXP
			// this isn't done in other team-based gametypes because there's too many other issues
			// (team switchers and such)
			if (Level.Game.IsA('Invasion'))
			{
				OldPlayers[OldPlayers.length] = DataObject;
			}
		}
		else
		{
			DataObject.SaveConfig();
		}
	}

	if (DataObject == CurrentLowestLevelPlayer)
		FindCurrentLowestLevelPlayer();
}

//find who is now the lowest level player
function FindCurrentLowestLevelPlayer()
{
	local Controller C;
	local Inventory Inv;

	CurrentLowestLevelPlayer = None;
	for (C = Level.ControllerList; C != None; C = C.NextController)
		if (C.bIsPlayer && C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOutOfLives && (!bFakeBotLevels || C.IsA('PlayerController')))
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				if ( RPGStatsInv(Inv) != None && ( CurrentLowestLevelPlayer == None
								  || RPGStatsInv(Inv).DataObject.Level < CurrentLowestLevelPlayer.Level ) )
					CurrentLowestLevelPlayer = RPGStatsInv(Inv).DataObject;
}

simulated function Tick(float deltaTime)
{
	local PlayerController PC;
	local Controller C;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local RPGPlayerDataObject NewDataObject;

	// see PreSaveGame() for comments on this
	if (bJustSaved)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			if (C.bIsPlayer)
			{
				for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				{
					StatsInv = RPGStatsInv(Inv);
					if (StatsInv != None)
					{
						NewDataObject = RPGPlayerDataObject(FindObject("Package." $ string(StatsInv.DataObject.Name), class'RPGPlayerDataObject'));
						if (NewDataObject == None)
							NewDataObject = new(None, string(StatsInv.DataObject.Name)) class'RPGPlayerDataObject';
						NewDataObject.CopyDataFrom(StatsInv.DataObject);
						StatsInv.DataObject = NewDataObject;
					}
				}
			}
		}

		FindCurrentLowestLevelPlayer();
		bJustSaved = false;
	}

	if (Level.NetMode == NM_DedicatedServer || bHasInteraction)
	{
		disable('Tick');
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None)
		{
			PC.Player.InteractionMaster.AddInteraction("fpsRPG.RPGInteraction", PC.Player);
			if (GUIController(PC.Player.GUIController) != None)
			{
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_AbilityList');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_ResetButton');
			}
			bHasInteraction = true;
			disable('Tick');
		}
	}
}

function Timer()
{
	SaveData();
}

function SaveData()
{
	local Controller C;
	local Inventory Inv;
	local int i;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if ( C.bIsPlayer && (!bFakeBotLevels || C.IsA('PlayerController'))
		     && ( !bIronmanMode || (C.PlayerReplicationInfo != None && C.PlayerReplicationInfo == Level.Game.GameReplicationInfo.Winner)
		          || (C.PlayerReplicationInfo.Team != None && C.PlayerReplicationInfo.Team == Level.Game.GameReplicationInfo.Winner) ) )
		{
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				if (Inv.IsA('RPGStatsInv'))
				{
					RPGStatsInv(Inv).DataObject.SaveConfig();
					break;
				}
		}
	}

	// if playing Invasion in Ironman mode and the team won, let players that left early keep their data as well
	if (bIronmanMode && Level.Game.IsA('Invasion') && Level.Game.GameReplicationInfo.Winner == TeamGame(Level.Game).Teams[0])
	{
		for (i = 0; i < OldPlayers.length; i++)
		{
			OldPlayers[i].SaveConfig();
		}
	}
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	local int i, NumPlayers;
	local float AvgLevel;
	local Controller C;
	local Inventory Inv;

	Super.GetServerDetails(ServerState);

	i = ServerState.ServerInfo.Length;

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "fpsRPG Version";
	ServerState.ServerInfo[i++].Value = ""$(RPG_VERSION / 10)$"."$int(RPG_VERSION % 10);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Starting Level";
	ServerState.ServerInfo[i++].Value = string(StartingLevel);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Stat Points Per Level";
	ServerState.ServerInfo[i++].Value = string(PointsPerLevel);

	//find average level of players currently on server
	if (!Level.Game.bGameRestarted)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			if (C.bIsPlayer && (!bFakeBotLevels || C.IsA('PlayerController')))
			{
				for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
					if (Inv.IsA('RPGStatsInv'))
					{
						AvgLevel += RPGStatsInv(Inv).DataObject.Level;
						NumPlayers++;
					}
			}
		}
		if (NumPlayers > 0)
			AvgLevel = AvgLevel / NumPlayers;

		ServerState.ServerInfo.Length = i+1;
		ServerState.ServerInfo[i].Key = "Current Avg. Level";
		ServerState.ServerInfo[i++].Value = ""$AvgLevel;
	}

	if (HighestLevelPlayerLevel > 0)
	{
		ServerState.ServerInfo.Length = i+1;
		ServerState.ServerInfo[i].Key = "Highest Level Player";
		ServerState.ServerInfo[i++].Value = HighestLevelPlayerName@"("$HighestLevelPlayerLevel$")";
	}

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Magic Weapon Chance";
	ServerState.ServerInfo[i++].Value = string(int(WeaponModifierChance*100))$"%";

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Magical Starting Weapons";
	ServerState.ServerInfo[i++].Value = string(bMagicalStartingWeapons);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Artifacts";
	ServerState.ServerInfo[i++].Value = string(class'RPGArtifactManager'.default.MaxArtifacts > 0 && class'RPGArtifactManager'.default.ArtifactDelay > 0);

	if (Level.Game.IsA('Invasion'))
	{
		ServerState.ServerInfo.Length = i+1;
		ServerState.ServerInfo[i].Key = "Auto Adjust Invasion Monster Level";
		ServerState.ServerInfo[i++].Value = string(bAutoAdjustInvasionLevel);
		if (bAutoAdjustInvasionLevel)
		{
			ServerState.ServerInfo.Length = i+1;
			ServerState.ServerInfo[i].Key = "Monster Adjustment Factor";
			ServerState.ServerInfo[i++].Value = string(InvasionAutoAdjustFactor);
		}
	}

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Ironman Mode";
	ServerState.ServerInfo[i++].Value = string(bIronmanMode);
}

event bool OverrideDownload(string PlayerIP, string PlayerID, string PlayerURL, out string RedirectURL)
{
	//only override the redirect once for each connect
	//since we added an extra HTTPDownload to the DownloadManagers list in PostBeginPlay()
	//this effectively creates an extra redirect for fpsRPG files so servers always have one for
	//the latest fpsRPG version even if their own is outdated
	if (!bUseOfficialRedirect || LastOverrideDownloadIP ~= PlayerIP)
	{
		return Super.OverrideDownload(PlayerIP, PlayerID, PlayerURL, RedirectURL);
	}
	else
	{
		RedirectURL = "http://flameinv.gamingdeluxe.net/";
		LastOverrideDownloadIP = PlayerIP;
		return true;
	}
}

function Mutate(string MutateString, PlayerController Sender)
{
	local GhostInv Inv;
	local Pawn P;

	// "mutate ghostsuicide" suicides while being affected by Ghost (since normal suicide doesn't work then)
	if (MutateString ~= "ghostsuicide")
	{
		P = Pawn(Sender.ViewTarget);
		if (P != None)
		{
			Inv = GhostInv(P.FindInventoryType(class'GhostInv'));
			if (Inv != None)
			{
				Inv.ReviveInstigator();
				P.Suicide();
			}
		}
	}

	Super.Mutate(MutateString, Sender);
}

function RPGStatsInv GetStatsInvFor(Controller C, optional bool bMustBeOwner)
{
	local Inventory Inv;

	for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
		if ( Inv.IsA('RPGStatsInv') && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
						   || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);

	//fallback - shouldn''t happen
	if (C.Pawn != None)
	{
		Inv = C.Pawn.FindInventoryType(class'RPGStatsInv');
		if ( Inv != None && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
				      || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);
	}

	return None;
}

event PreSaveGame()
{
	local Controller C;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local RPGPlayerDataObject NewDataObject;

	//create new RPGPlayerDataObjects with the same data but the Level as their Outer, so that savegames will work
	//(can't always have the objects this way because using the Level as the Outer for a PerObjectConfig
	//object causes it to be saved in LevelName.ini)
	//second hack of mine in UT2004's code that's backfired in two days. Ugh.
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (C.bIsPlayer)
		{
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
			{
				StatsInv = RPGStatsInv(Inv);
				if (StatsInv != None)
				{
					NewDataObject = RPGPlayerDataObject(FindObject(string(xLevel) $ "." $ string(StatsInv.DataObject.Name), class'RPGPlayerDataObject'));
					if (NewDataObject == None)
						NewDataObject = new(xLevel, string(StatsInv.DataObject.Name)) class'RPGPlayerDataObject';
					NewDataObject.CopyDataFrom(StatsInv.DataObject);
					StatsInv.DataObject = NewDataObject;
				}
			}
		}
	}

	Level.GetLocalPlayerController().Player.GUIController.CloseAll(false);

	bJustSaved = true;
	enable('Tick');
}

event PostLoadSavedGame()
{
	// interactions are not saved in savegames so we have to recreate it
	bHasInteraction = false;
	enable('Tick');
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("fpsRPG", "SaveDuringGameInterval", default.PropsDisplayText[i++], 1, 10, "Text", "3;0:999");
	PlayInfo.AddSetting("fpsRPG", "StartingLevel", default.PropsDisplayText[i++], 1, 10, "Text", "2;1:99");
	PlayInfo.AddSetting("fpsRPG", "PointsPerLevel", default.PropsDisplayText[i++], 5, 10, "Text", "2;1:99");
	PlayInfo.AddSetting("fpsRPG", "LevelDiffExpGainDiv", default.PropsDisplayText[i++], 1, 10, "Text", "5;0.001:100.0",,, true);
	PlayInfo.AddSetting("fpsRPG", "EXPForWin", default.PropsDisplayText[i++], 10, 10, "Text", "3;0:99999");
	PlayInfo.AddSetting("fpsRPG", "bFakeBotLevels", default.PropsDisplayText[i++], 4, 10, "Check");
	PlayInfo.AddSetting("fpsRPG", "bReset", default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("fpsRPG", "WeaponModifierChance", default.PropsDisplayText[i++], 50, 10, "Text", "4;0.0:1.0");
	PlayInfo.AddSetting("fpsRPG", "bMagicalStartingWeapons", default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("fpsRPG", "bNoUnidentified", default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("fpsRPG", "bAutoAdjustInvasionLevel", default.PropsDisplayText[i++], 1, 10, "Check");
	PlayInfo.AddSetting("fpsRPG", "InvasionAutoAdjustFactor", default.PropsDisplayText[i++], 1, 10, "Text", "4;0.01:3.0");
	PlayInfo.AddSetting("fpsRPG", "MaxLevelupEffectStacking", default.PropsDisplayText[i++], 1, 10, "Text", "2;1:10",,, true);
	PlayInfo.AddSetting("fpsRPG", "StatCaps", default.PropsDisplayText[i++], 1, 14, "Text",,,, true);
	PlayInfo.AddSetting("fpsRPG", "InfiniteReqEXPOp", default.PropsDisplayText[i++], 1, 12, "Select", default.PropsExtras,,, true);
	PlayInfo.AddSetting("fpsRPG", "InfiniteReqEXPValue", default.PropsDisplayText[i++], 1, 13, "Text", "3;0:999",,, true);
	PlayInfo.AddSetting("fpsRPG", "Levels", default.PropsDisplayText[i++], 1, 11, "Text",,,, true);
	//FIXME perhaps make Abilities menu a "Select" option, using .int or .ucl to find all available abilities?
	PlayInfo.AddSetting("fpsRPG", "Abilities", default.PropsDisplayText[i++], 1, 15, "Text",,,, true);
	PlayInfo.AddSetting("fpsRPG", "bIronmanMode", default.PropsDisplayText[i++], 4, 10, "Check",,,, true);
	PlayInfo.AddSetting("fpsRPG", "bUseOfficialRedirect", default.PropsDisplayText[i++], 4, 10, "Check",,, true, true);
	PlayInfo.AddSetting("fpsRPG", "BotBonusLevels", default.PropsDisplayText[i++], 4, 10, "Text", "2;0:99",,, true);
	PlayInfo.AddSetting("fpsRPG", "MonsterLevel", default.PropsDisplayText[i++], 1, 10, "Text", "5;1:1000");

	class'RPGArtifactManager'.static.FillPlayInfo(PlayInfo);
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "SaveDuringGameInterval":	return default.PropsDescText[0];
		case "StartingLevel":		return default.PropsDescText[1];
		case "PointsPerLevel":		return default.PropsDescText[2];
		case "LevelDiffExpGainDiv":	return default.PropsDescText[3];
		case "EXPForWin":		return default.PropsDescText[4];
		case "bFakeBotLevels":		return default.PropsDescText[5];
		case "bReset":			return default.PropsDescText[6];
		case "WeaponModifierChance":	return default.PropsDescText[7];
		case "bMagicalStartingWeapons":	return default.PropsDescText[8];
		case "bNoUnidentified":		return default.PropsDescText[9];
		case "bAutoAdjustInvasionLevel":return default.PropsDescText[10];
		case "InvasionAutoAdjustFactor":return default.PropsDescText[11];
		case "MaxLevelupEffectStacking":return default.PropsDescText[12];
		case "StatCaps":		return default.PropsDescText[13];
		case "InfiniteReqEXPOp":	return default.PropsDescText[14];
		case "InfiniteReqEXPValue":	return default.PropsDescText[15];
		case "Levels":			return default.PropsDescText[16];
		case "Abilities":		return default.PropsDescText[17];
		case "bIronmanMode":		return default.PropsDescText[18];
		case "bUseOfficialRedirect":	return default.PropsDescText[19];
		case "BotBonusLevels":		return default.PropsDescText[20];
		case "MonsterLevel":		return default.PropsDescText[21];
	}
}

defaultproperties
{
     SaveDuringGameInterval=5
     StartingLevel=35
     PointsPerLevel=10
     Levels(1)=15
     Levels(2)=20
     Levels(3)=25
     Levels(4)=30
     Levels(5)=35
     Levels(6)=40
     Levels(7)=45
     Levels(8)=50
     Levels(9)=55
     Levels(10)=60
     Levels(11)=65
     Levels(12)=70
     Levels(13)=75
     Levels(14)=80
     Levels(15)=85
     Levels(16)=90
     Levels(17)=95
     Levels(18)=100
     Levels(19)=105
     Levels(20)=110
     Levels(21)=115
     Levels(22)=120
     Levels(23)=125
     Levels(24)=130
     Levels(25)=135
     Levels(26)=140
     Levels(27)=145
     Levels(28)=150
     InfiniteReqEXPValue=127
     LevelDiffExpGainDiv=2.000000
     MaxLevelupEffectStacking=5
     EXPForWin=50000
     BotBonusLevels=0
     StatCaps(0)=200
     StatCaps(1)=2000
     StatCaps(2)=500
     StatCaps(3)=1500
     StatCaps(4)=1750
     StatCaps(5)=2000
     StatCaps(6)=440
     MoneyPerKill=2
     StartingMoney=0
     Abilities(0)=Class'fpsRPG.AbilityRegen'
     Abilities(1)=Class'fpsRPG.AbilityAdrenalineRegen'
     Abilities(2)=Class'fpsRPG.AbilityAmmoRegen'
     Abilities(3)=Class'fpsRPG.AbilityCounterShove'
     Abilities(4)=Class'fpsRPG.AbilityJumpZ'
     Abilities(5)=Class'fpsRPG.AbilityReduceFallDamage'
     Abilities(6)=Class'fpsRPG.AbilityRetaliate'
     Abilities(7)=Class'fpsRPG.AbilitySpeed'
     Abilities(8)=Class'fpsRPG.AbilityShieldStrength'
     Abilities(9)=Class'fpsRPG.AbilityNoWeaponDrop'
     Abilities(10)=Class'fpsRPG.AbilityVampire'
     Abilities(11)=Class'fpsRPG.AbilityHoarding'
     Abilities(12)=Class'fpsRPG.AbilityReduceSelfDamage'
     Abilities(13)=Class'fpsRPG.AbilitySmartHealing'
     Abilities(14)=Class'fpsRPG.AbilityAirControl'
     Abilities(15)=Class'fpsRPG.AbilityGhost'
     Abilities(16)=Class'fpsRPG.DruidUltima'
     Abilities(17)=Class'fpsRPG.AbilityAdrenalineSurge'
     Abilities(18)=Class'fpsRPG.AbilityFastWeaponSwitch'
     Abilities(19)=Class'fpsRPG.AbilityAwareness'
     Abilities(20)=Class'fpsRPG.AbilityMonsterSummon'
     WeaponModifierChance=0.000000
     MonsterLevel=5
     WeaponModifiers(0)=(WeaponClass=Class'fpsRPG.RW_Vampire',Chance=1)
     WeaponModifiers(1)=(WeaponClass=Class'fpsRPG.RW_Vorpal',Chance=1)
     WeaponModifiers(2)=(WeaponClass=Class'fpsRPG.RW_EnhancedInfinity',Chance=1)
     WeaponModifiers(3)=(WeaponClass=Class'fpsRPG.RW_Freeze',Chance=1)
     WeaponModifiers(4)=(WeaponClass=Class'fpsRPG.RW_Healer',Chance=2)
     WeaponModifiers(5)=(WeaponClass=Class'fpsRPG.RW_Knockback',Chance=1)
     WeaponModifiers(6)=(WeaponClass=Class'fpsRPG.RW_Speedy',Chance=1)
     WeaponModifiers(7)=(WeaponClass=Class'fpsRPG.RW_NullEntropy',Chance=1)
     WeaponModifiers(8)=(WeaponClass=Class'fpsRPG.RW_EnhancedForce',Chance=2)
     WeaponModifiers(9)=(WeaponClass=Class'fpsRPG.RW_EnhancedPenetrating',Chance=2)
     WeaponModifiers(10)=(WeaponClass=Class'fpsRPG.RW_EnhancedDamage',Chance=4)
     WeaponModifiers(11)=(WeaponClass=Class'fpsRPG.RW_EnhancedNoMomentum',Chance=3)
     WeaponModifiers(12)=(WeaponClass=Class'fpsRPG.RW_EnhancedEnergy',Chance=2)
     WeaponModifiers(13)=(WeaponClass=Class'fpsRPG.RW_EnhancedLuck',Chance=3)
     WeaponModifiers(14)=(WeaponClass=Class'fpsRPG.RW_EnhancedPiercing',Chance=2)
     WeaponModifiers(15)=(WeaponClass=Class'fpsRPG.RW_Rage',Chance=1)
     WeaponModifiers(16)=(WeaponClass=Class'fpsRPG.RW_Reflection',Chance=1)
     WeaponModifiers(17)=(WeaponClass=Class'fpsRPG.RW_Experience',Chance=2)
     WeaponModifiers(18)=(WeaponClass=Class'fpsRPG.RW_Adren',Chance=2)
     WeaponsList(0)=(WeaponClass=Class'xWeapons.TransLauncher',WeaponCost=5)
     WeaponsList(1)=(WeaponClass=Class'xWeapons.LinkGun',WeaponCost=5)

     ArtifactsList(0)=(ArtifactClass=Class'fpsRPG.ArtifactFlight',ArtifactCost=5)
     ArtifactsList(1)=(ArtifactClass=Class'fpsRPG.ArtifactLightningBeam',ArtifactCost=5)
     ArtifactsList(2)=(ArtifactClass=Class'fpsRPG.ArtifactLightningBolt',ArtifactCost=5)
     ArtifactsList(3)=(ArtifactClass=Class'fpsRPG.ArtifactLightningRodB',ArtifactCost=5)
     ArtifactsList(4)=(ArtifactClass=Class'fpsRPG.Artifact_GlobeInvulnerability',ArtifactCost=5)
     ArtifactsList(5)=(ArtifactClass=Class'fpsRPG.ArtifactFreezeBomb',ArtifactCost=5)
     ArtifactsList(6)=(ArtifactClass=Class'fpsRPG.ArtifactHealingBlast',ArtifactCost=5)
     ArtifactsList(7)=(ArtifactClass=Class'fpsRPG.ArtifactPoisonBlast',ArtifactCost=5)
     ArtifactsList(8)=(ArtifactClass=Class'fpsRPG.ArtifactMegaBlast',ArtifactCost=5)
     ArtifactsList(9)=(ArtifactClass=Class'fpsRPG.ArtifactRepulsion',ArtifactCost=5)
     ArtifactsList(10)=(ArtifactClass=Class'fpsRPG.ArtifactResurrection',ArtifactCost=5)
     ArtifactsList(11)=(ArtifactClass=Class'fpsRPG.ArtifactShieldBlast',ArtifactCost=5)
     ArtifactsList(12)=(ArtifactClass=Class'fpsRPG.ArtifactSphereDamage',ArtifactCost=5)
     ArtifactsList(13)=(ArtifactClass=Class'fpsRPG.ArtifactSphereHealing',ArtifactCost=5)
     ArtifactsList(14)=(ArtifactClass=Class'fpsRPG.ArtifactSphereInvulnerability',ArtifactCost=5)
     ArtifactsList(15)=(ArtifactClass=Class'fpsRPG.ArtifactSpider',ArtifactCost=5)
     ArtifactsList(16)=(ArtifactClass=Class'fpsRPG.ArtifactTeleport',ArtifactCost=5)
     ArtifactsList(17)=(ArtifactClass=Class'fpsRPG.ArtifactTripleDamageB',ArtifactCost=5)
     
     ModifiersList(0)=(ArtifactClass=Class'fpsRPG.ArtifactMakeAdren',ModifierCost=5)
     ModifiersList(1)=(ArtifactClass=Class'fpsRPG.ArtifactMakeDamage',ModifierCost=5)
     ModifiersList(2)=(ArtifactClass=Class'fpsRPG.ArtifactMakeEnergy',ModifierCost=5)
     ModifiersList(3)=(ArtifactClass=Class'fpsRPG.ArtifactMakeForce',ModifierCost=5)
     ModifiersList(4)=(ArtifactClass=Class'fpsRPG.ArtifactMakeFreeze',ModifierCost=5)
     ModifiersList(5)=(ArtifactClass=Class'fpsRPG.ArtifactMakeInfinity',ModifierCost=5)
     ModifiersList(6)=(ArtifactClass=Class'fpsRPG.ArtifactMakeKnockback',ModifierCost=5)
     ModifiersList(7)=(ArtifactClass=Class'fpsRPG.ArtifactMakeLuck',ModifierCost=5)
     ModifiersList(8)=(ArtifactClass=Class'fpsRPG.ArtifactMakePenetrating',ModifierCost=5)
     ModifiersList(9)=(ArtifactClass=Class'fpsRPG.ArtifactMakePetrification',ModifierCost=5)
     ModifiersList(10)=(ArtifactClass=Class'fpsRPG.ArtifactMakeExperience',ModifierCost=5)
     ModifiersList(11)=(ArtifactClass=Class'fpsRPG.ArtifactMakePiercing',ModifierCost=5)
     ModifiersList(12)=(ArtifactClass=Class'fpsRPG.ArtifactMakePoison',ModifierCost=5)
     ModifiersList(13)=(ArtifactClass=Class'fpsRPG.ArtifactMakeSpeedy',ModifierCost=5)
     ModifiersList(14)=(ArtifactClass=Class'fpsRPG.ArtifactMakeSturdy',ModifierCost=5)
     ModifiersList(15)=(ArtifactClass=Class'fpsRPG.ArtifactMakeVampire',ModifierCost=5)
     ModifiersList(16)=(ArtifactClass=Class'fpsRPG.ArtifactMakeVorpal',ModifierCost=5)
     
     Version=1
     bMagicalStartingWeapons=False
     bAutoAdjustInvasionLevel=True
     bFakeBotLevels=False
     bUseOfficialRedirect=True
     InvasionAutoAdjustFactor=0.100000
     SuperAmmoClassNames(0)="RedeemerAmmo"
     SuperAmmoClassNames(1)="BallAmmo"
     SuperAmmoClassNames(2)="SCannonAmmo"
     PropsDisplayText(0)="Autosave Interval (seconds)"
     PropsDisplayText(1)="Starting Level"
     PropsDisplayText(2)="Stat Points per Level"
     PropsDisplayText(3)="Divisor to EXP from Level Diff"
     PropsDisplayText(4)="EXP for Winning"
     PropsDisplayText(5)="Fake Bot Levels"
     PropsDisplayText(6)="Reset Player Data Next Game"
     PropsDisplayText(7)="Magic Weapon Chance"
     PropsDisplayText(8)="Magical Starting Weapons"
     PropsDisplayText(9)="No Unidentified Items"
     PropsDisplayText(10)="Auto Adjust Invasion Monster Level"
     PropsDisplayText(11)="Monster Adjustment Factor"
     PropsDisplayText(12)="Max Levelup Effects at Once"
     PropsDisplayText(13)="Stat Caps"
     PropsDisplayText(14)="Infinite Required EXP Operation"
     PropsDisplayText(15)="Infinite Required EXP Value"
     PropsDisplayText(16)="EXP Required for Each Level"
     PropsDisplayText(17)="Allowed Abilities"
     PropsDisplayText(18)="Ironman Mode"
     PropsDisplayText(19)="Use Official Redirect Server"
     PropsDisplayText(20)="Extra Bot Levelups After Match"
     PropsDisplayText(21)="Monsters Starting Level"
     PropsDescText(0)="During the game, all data will be saved every this many seconds."
     PropsDescText(1)="New players start at this Level."
     PropsDescText(2)="The number of stat points earned from a levelup."
     PropsDescText(3)="Lower values = more exp when killing someone of higher level."
     PropsDescText(4)="The EXP gained for winning a match."
     PropsDescText(5)="If checked, bots' data is not saved and instead they are simply given a level near that of the human player(s)."
     PropsDescText(6)="If checked, player data will be reset before the next match begins."
     PropsDescText(7)="Chance of any given weapon having magical properties."
     PropsDescText(8)="If checked, weapons given to players when they spawn can have magical properties."
     PropsDescText(9)="If checked, magical weapons will always be identified."
     PropsDescText(10)="If checked, Invasion monsters' level will be adjusted based on the lowest level player."
     PropsDescText(11)="Invasion monsters will be adjusted based on this fraction of the weakest player's level."
     PropsDescText(12)="The maximum number of levelup particle effects that can be spawned on a character at once."
     PropsDescText(13)="Limit on how high stats can go. Values less than 0 mean no limit. The stats are: 1: Weapon Speed 2: Health Bonus 3: Max Adrenaline 4: Damage Bonus 5: Damage Reduction 6: Max Ammo Bonus"
     PropsDescText(14)="Allows you to make the EXP required for the next level always increase, no matter how high a level you get. This option controls how it increases."
     PropsDescText(15)="Allows you to make the EXP required for the next level always increase, no matter how high a level you get. This option is the value for the previous option's operation."
     PropsDescText(16)="Change the EXP required for each level. Levels after the last in your list will use the last value in the list."
     PropsDescText(17)="Change the list of abilities players can choose from."
     PropsDescText(18)="If checked, only the winning player or team's data is saved - the losers lose the experience they gained that match."
     PropsDescText(19)="If checked, the server will redirect clients to a special official redirect server for fpsRPG files (all other files will continue to use the normal redirect server, if any)"
     PropsDescText(20)="If Fake Bot Levels is off, bots gain this many extra levels after a match because individual bots don't play often."
     PropsDescText(21)="Monsters start at this level"
     PropsExtras="0;Add Specified Value;1;Add Specified Percent"
     bAddToServerPackages=True
     GroupName="RPG"
     FriendlyName="ÿFails Per Second RPG"
     Description="UT2004RPG Hardly Modified for the Fails Per Second Invasion Server"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
