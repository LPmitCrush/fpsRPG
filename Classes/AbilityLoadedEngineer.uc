class AbilityLoadedEngineer extends RPGAbility
	config(fpsRPG)
	abstract;

struct SentinelConfig
{
	Var String FriendlyName;
	var Class<Pawn> Sentinel;
	var int Points;
	var int StartHealth;
	var int NormalHealth;
	var int RecoveryPeriod;
};
var config Array<SentinelConfig> SentinelConfigs;

struct TurretConfig
{
	Var String FriendlyName;
	var Class<Pawn> Turret;
	var int Points;
	var int StartHealth;
	var int NormalHealth;
	var int RecoveryPeriod;
};
var config Array<TurretConfig> TurretConfigs;

struct VehicleConfig
{
	Var String FriendlyName;
	var Class<Pawn> Vehicle;
	var int Points;
	var int StartHealth;
	var int NormalHealth;
	var int RecoveryPeriod;
};
var config Array<VehicleConfig> VehicleConfigs;

struct BuildingConfig
{
	Var String FriendlyName;
	var Class<Pawn> Building;
	var int Points;
	var int StartHealth;
	var int NormalHealth;
	var int RecoveryPeriod;
};
var config Array<BuildingConfig> BuildingConfigs;

var config int PointsPerLevel;
var config Array<string> IncludeVehicleGametypes;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}
	
	if (Data.Level < ((CurrentLevel+1)*6))
		return 0;

	return super.Cost(Data, CurrentLevel);
}

static function SetShieldHealingLevel(Pawn Other, RW_EngineerLink EGun)
{
	local int x;
	local RPGStatsInv StatsInv;

	if (EGun == None || Other == None)
		return;

	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));

	for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
		if (StatsInv.Data.Abilities[x] == class'AbilityShieldHealing')
		{	// code duplicated from AbilityShieldHealing.ModifyPlayer
			EGun.HealingLevel = StatsInv.Data.AbilityLevels[x];
			EGun.ShieldHealingPercent = class'AbilityShieldHealing'.default.ShieldHealingPercent;
		}

	return;
}

static function EngineerPointsInv GetEngInv(Pawn Other)
{
	local EngineerPointsInv EInv;
	local RPGStatsInv StatsInv;

	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));

	EInv = EngineerPointsInv(Other.FindInventoryType(class'EngineerPointsInv'));
	if (EInv != None && StatsInv != None)
		EInv.PlayerLevel = StatsInv.Data.Level;
	
	// if they haven't got one, its time they had.
	if(EInv == None)
	{
		EInv = Other.spawn(class'EngineerPointsInv', Other,,, rot(0,0,0));
		if(EInv == None)
		{
			return EInv; //get it later I guess?
		}
		EInv.UsedBuildingPoints = 0;
		EInv.UsedSentinelPoints = 0;
		EInv.UsedVehiclePoints = 0;
		EInv.UsedTurretPoints = 0;
		EInv.FastBuildPercent = 1.0;
		if (StatsInv != None)
			EInv.PlayerLevel = StatsInv.Data.Level;
		EInv.giveTo(Other);
	}
	return EInv;
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int i;
	local LoadedInv LoadedInv;
	Local RPGArtifact Artifact;
	Local bool PreciseLevel;
	local Inventory OInv;
	local Weapon NewWeapon;
	local EngineerPointsInv EInv;
	local bool bAddVehicles;
	local bool bGotTrans;
	local EngTransLauncher ETrans;
	local RW_EngineerLink EGun;


	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));
	PreciseLevel = false;

	if(LoadedInv != None)
	{
		if(LoadedInv.type != 'Engineer')
		{
			LoadedInv.Destroy(); 
		}
		else if(LoadedInv.AbilityLevel != AbilityLevel)
		{
			LoadedInv.Destroy();//for when they buy a new level of this skill
			PreciseLevel = true; //only giving items for this level.
		}
		else
		{
			return;
		}
	}

	LoadedInv = Other.spawn(class'LoadedInv');

	if(LoadedInv == None)
		return;

	LoadedInv.type = 'Engineer';
	LoadedInv.AbilityLevel = AbilityLevel;
	LoadedInv.GiveTo(Other);

	EInv = GetEngInv(Other);
	if (EInv != None)
	{
		EInv.TotalBuildingPoints = AbilityLevel*Default.PointsPerLevel;
		EInv.TotalSentinelPoints = AbilityLevel*Default.PointsPerLevel;
		EInv.TotalVehiclePoints = AbilityLevel*Default.PointsPerLevel;
		EInv.TotalTurretPoints = AbilityLevel*Default.PointsPerLevel;
	}

	// see if we need to add vehicles as well
	bAddVehicles = false;
	for(i = 0; i < Default.IncludeVehicleGametypes.length; i++)
	{
		if (caps(Default.IncludeVehicleGametypes[i]) == "ALL"
		 || (Other.Level.Game != None && instr(caps(Other.Level.Game.GameName), caps(Default.IncludeVehicleGametypes[i])) > -1))
			bAddVehicles = true;
	}

	// ok, now lets give them the spawning artifacts
	for(i = 0; i < Default.SentinelConfigs.length; i++)
	{
		if(Default.SentinelConfigs[i].Sentinel != None) //make sure the object is sane.
		{
			if(Default.SentinelConfigs[i].Points <= (AbilityLevel*Default.PointsPerLevel))
			{
				if (PreciseLevel && Default.SentinelConfigs[i].Points <= ((AbilityLevel-1)*Default.PointsPerLevel))
					continue;
				Artifact = Other.spawn(class'DruidSentinelSummon', Other,,, rot(0,0,0));
				if(Artifact == None)
					continue; // wow.
				DruidSentinelSummon(Artifact).Setup(Default.SentinelConfigs[i].FriendlyName, Default.SentinelConfigs[i].Sentinel, Default.SentinelConfigs[i].Points, Default.SentinelConfigs[i].StartHealth, Default.SentinelConfigs[i].NormalHealth, Default.SentinelConfigs[i].RecoveryPeriod);
				Artifact.GiveTo(Other);
			}
		}
	}

	for(i = 0; i < Default.TurretConfigs.length; i++)
	{
		if(Default.TurretConfigs[i].Turret != None) //make sure the object is sane.
		{
			if(Default.TurretConfigs[i].Points <= (AbilityLevel*Default.PointsPerLevel))
			{
				if (PreciseLevel && Default.TurretConfigs[i].Points <= ((AbilityLevel-1)*Default.PointsPerLevel))
					continue;
				Artifact = Other.spawn(class'DruidTurretSummon', Other,,, rot(0,0,0));
				if(Artifact == None)
					continue; // wow.
				DruidTurretSummon(Artifact).Setup(Default.TurretConfigs[i].FriendlyName, Default.TurretConfigs[i].Turret, Default.TurretConfigs[i].Points, Default.TurretConfigs[i].StartHealth, Default.TurretConfigs[i].NormalHealth, Default.TurretConfigs[i].RecoveryPeriod);
				Artifact.GiveTo(Other);
			}
		}
	}

	if (bAddVehicles)
	{
		for(i = 0; i < Default.vehicleConfigs.length; i++)
		{
			if(Default.vehicleConfigs[i].vehicle != None) //make sure the object is sane.
			{
				if(Default.vehicleConfigs[i].Points <= (AbilityLevel*Default.PointsPerLevel))
				{
					if (PreciseLevel && Default.VehicleConfigs[i].Points <= ((AbilityLevel-1)*Default.PointsPerLevel))
						continue;
					Artifact = Other.spawn(class'DruidvehicleSummon', Other,,, rot(0,0,0));
					if(Artifact == None)
						continue; // wow.
					DruidvehicleSummon(Artifact).Setup(Default.vehicleConfigs[i].FriendlyName, Default.vehicleConfigs[i].vehicle, Default.vehicleConfigs[i].Points, Default.vehicleConfigs[i].StartHealth, Default.vehicleConfigs[i].NormalHealth, Default.vehicleConfigs[i].RecoveryPeriod);
					Artifact.GiveTo(Other);
				}
			}
		}
	}

	for(i = 0; i < Default.BuildingConfigs.length; i++)
	{
		if(Default.BuildingConfigs[i].Building != None) //make sure the object is sane.
		{
			if(Default.BuildingConfigs[i].Points <= (AbilityLevel*Default.PointsPerLevel))
			{
				if (PreciseLevel && Default.BuildingConfigs[i].Points <= ((AbilityLevel-1)*Default.PointsPerLevel))
					continue;
				Artifact = Other.spawn(class'DruidBuildingSummon', Other,,, rot(0,0,0));
				if(Artifact == None)
					continue; // wow.
				DruidBuildingSummon(Artifact).Setup(Default.BuildingConfigs[i].FriendlyName, Default.BuildingConfigs[i].Building, Default.BuildingConfigs[i].Points, Default.BuildingConfigs[i].StartHealth, Default.BuildingConfigs[i].NormalHealth, Default.BuildingConfigs[i].RecoveryPeriod);
				Artifact.GiveTo(Other);
			}
		}
	}

	// ok,lets add the kill artifacts
	if(!PreciseLevel)
	{
		Artifact = Other.spawn(class'ArtifactKillAllSentinels', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
		Artifact = Other.spawn(class'ArtifactKillAllTurrets', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
		if (bAddVehicles)
		{
			Artifact = Other.spawn(class'ArtifactKillAllVehicles', Other,,, rot(0,0,0));
			Artifact.GiveTo(Other);
		}
		Artifact = Other.spawn(class'ArtifactKillAllBuildings', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
	}

// I'm guessing that NextItem is here to ensure players don't start with
// no item selected.  So the if should stop weird artifact scrambles.
	if(Other.SelectedItem == None)
		Other.NextItem();

	// lets see if they have a translocator. If not, then perhaps running a gametype that transing isn't a good idea
	// give them a limited translocator that will let them spawn items, but not translocate
	bGotTrans = false;
	for (OInv=Other.Inventory; OInv != None; OInv = OInv.Inventory)
	{
		if(instr(caps(OInv.ItemName), "TRANSLOCATOR") > -1 && ClassIsChildOf(OInv.Class,class'Weapon'))
		{
			bGotTrans=true;
		}
	}
	if (!bGotTrans)
	{
		ETrans = Other.spawn(class'EngTransLauncher', Other,,, rot(0,0,0));
		if (ETrans != None)
			ETrans.GiveTo(Other);
	}

	// Now let's give the EngineerLinkGun
	EGun = None;
	for (OInv=Other.Inventory; OInv != None; OInv = OInv.Inventory)
	{
		if(ClassIsChildOf(OInv.Class,class'RW_EngineerLink'))
		{
			EGun = RW_EngineerLink(OInv);
			break;
		}
	}
	if (EGun != None)
		return; //already got one

	// now add the new one.
	NewWeapon = Other.spawn(class'EngineerLinkGun', Other,,, rot(0,0,0));
	if(NewWeapon == None)
		return;
	while(NewWeapon.isA('RPGWeapon'))
		NewWeapon = RPGWeapon(NewWeapon).ModifiedWeapon;

	EGun = Other.spawn(class'RW_EngineerLink', Other,,, rot(0,0,0));
	if(EGun == None)
		return;

	EGun.Generate(None);
	if(EGun != None)
		SetShieldHealingLevel(Other, EGun);	// set shield healing level
	
	//I'm checking the state of RPG Weapon a bunch because sometimes it becomes none mid method.
	if(EGun != None)
		EGun.SetModifiedWeapon(NewWeapon, true);

	if(EGun != None)
		EGun.GiveTo(Other);

}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	local float KillScore;
	local Controller PlayerSpawner;
	local TeamPlayerReplicationInfo TPPI;
	local class<Vehicle> V;
	local int i;
	local TeamPlayerReplicationInfo.VehicleStats NewVehicleStats;

	// score and stats not generated for sentinels. So add here.
	if (!bOwnedByKiller)
		return;

	if (Killer == None || Killed == None)
		return;

	PlayerSpawner = None;
	if (DruidSentinelController(Killer) != None)
		PlayerSpawner = DruidSentinelController(Killer).PlayerSpawner;
	else if (DruidBaseSentinelController(Killer) != None)
		PlayerSpawner = DruidBaseSentinelController(Killer).PlayerSpawner;
	else if (DruidLightningSentinelController(Killer) != None)
		PlayerSpawner = DruidLightningSentinelController(Killer).PlayerSpawner;
	else if (DruidEnergyWallController(Killer) != None)
		PlayerSpawner = DruidEnergyWallController(Killer).PlayerSpawner;
	else
		return;	// not a sentinel controller

	if (PlayerSpawner == None)
		return;

	// now, don't want to add points to killer, but to owner.
	if (PlayerSpawner.PlayerReplicationInfo == None)
		return;

	// ok, first lets add the stats
	PlayerSpawner.PlayerReplicationInfo.Kills++;
	KillScore = float(Killed.Pawn.GetPropertyText("ScoringValue"));
	if (KillScore < 1.0)
		KillScore = 1.0;
	PlayerSpawner.PlayerReplicationInfo.Score += KillScore;
	PlayerSpawner.PlayerReplicationInfo.Team.Score += KillScore;
	PlayerSpawner.PlayerReplicationInfo.Team.NetUpdateTime = PlayerSpawner.Level.TimeSeconds - 1;
	PlayerSpawner.AwardAdrenaline(KillScore);
	PlayerSpawner.PlayerReplicationInfo.NetUpdateTime = PlayerSpawner.Level.TimeSeconds - 1;
	TPPI = TeamPlayerReplicationInfo(PlayerSpawner.PlayerReplicationInfo);
	if (TPPI != None && Killer.Pawn != None)
	{
		v = class<Vehicle>(Killer.Pawn.Class);
		for (i = 0; i < TPPI.VehicleStatsArray.Length && i<200; i++)
			if (TPPI.VehicleStatsArray[i].VehicleClass == V)
			{
				TPPI.VehicleStatsArray[i].Kills++;
				return;
			}
		NewVehicleStats.VehicleClass = V;
		NewVehicleStats.Kills = 1;
		TPPI.VehicleStatsArray[TPPI.VehicleStatsArray.Length] = NewVehicleStats;
	}

}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	local class<Weapon> NewWeaponClass;

	if (RPGLinkGunPickup(item) != None)
	{
		bAllowPickup = 0;	// not allowed
		return true;
	}
	else if (WeaponPickup(item) != None && WeaponPickup(item).InventoryType != None)
	{
		NewWeaponClass = class<Weapon>(WeaponPickup(item).InventoryType);
		if (NewWeaponClass != None && ClassIsChildOf(NewWeaponClass, class'RPGLinkGun'))
		{
			bAllowPickup = 0;	// not allowed
			return true;
		}
	}
	else if (WeaponLocker(item) != None && WeaponLocker(item).InventoryType != None)
	{
		NewWeaponClass = class<Weapon>(WeaponLocker(item).InventoryType);
		if (NewWeaponClass != None && ClassIsChildOf(NewWeaponClass, class'RPGLinkGun'))
		{
			bAllowPickup = 0;	// not allowed
			return true;
		}
	}
	return false;			// don't know, so let someone else decide
}

defaultproperties
{
     SentinelConfigs(0)=(FriendlyName="Sentinel",Sentinel=Class'fpsRPG.DruidSentinel',Points=3,StartHealth=5,NormalHealth=300,RecoveryPeriod=60)
     VehicleConfigs(0)=(FriendlyName="Scorpion",Vehicle=Class'Onslaught.ONSRV',Points=3,StartHealth=10,NormalHealth=300,RecoveryPeriod=60)
     PointsPerLevel=1
     IncludeVehicleGametypes(0)="Vehicle"
     IncludeVehicleGametypes(1)="Onslaught"
     AbilityName="Loaded Engineer"
     Description="Learn sentinels, turrets, vehicle and buildings to summon. At each level, you can summon better items. You need to have a level six times the ability level you wish to purchase. (Max Level: 15)|You must be an Engineer to purchase this skill.|Cost (per level): 3,4,5,6,7,8,9,10,11,12,13,14,15,16,17"
     StartingCost=3
     CostAddPerLevel=1
     MaxLevel=15
}
