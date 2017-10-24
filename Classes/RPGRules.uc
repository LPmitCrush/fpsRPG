class RPGRules extends GameRules;

var MutfpsRPG RPGMut;
var int PointsPerLevel;
var float LevelDiffExpGainDiv;
var float MA_AdjustDamageByVehicleScale; // hack for Monster Assault and EXP by damage
var bool bAwardedFirstBlood;

var bool bGaveXP;

function PostBeginPlay()
{
	local GameObjective GO;

	SetTimer(Level.TimeDilation, true);

	//hack to deal with Assault's stupid hardcoded scoring setup
	if (Level.Game.IsA('ASGameInfo'))
		foreach AllActors(class'GameObjective', GO)
			GO.Score = 0;

	Super.PostBeginPlay();
}

function RPGStatsInv GetStatsInvFor(Controller C, optional bool bMustBeOwner)
{
	local Inventory Inv;

	for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
		if ( Inv.IsA('RPGStatsInv') && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
						   || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);

	//fallback - shouldn't happen
	if (C.Pawn != None)
	{
		Inv = C.Pawn.FindInventoryType(class'RPGStatsInv');
		if ( Inv != None && ( !bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn
				      || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver) ) )
			return RPGStatsInv(Inv);
	}

	return None;
}

//checks if the player that owns the specified RPGStatsInv is linked up to anybody and if so shares Amount EXP
//equally between them, otherwise gives it all to the lone player
function ShareExperience(RPGStatsInv InstigatorInv, float Amount)
{
	local LinkGun HeadLG, LG;
	local Controller C;
	local RPGStatsInv StatsInv;
	local array<RPGStatsInv> Links;
	local int i;

	if (InstigatorInv.Instigator == None || InstigatorInv.Instigator.Weapon == None)
	{
		// dead or has no weapon, so can't be linked up
		if (InstigatorInv.Instigator != None)
		{
			InstigatorInv.DataObject.AddExperienceFraction(Amount, RPGMut, InstigatorInv.Instigator.PlayerReplicationInfo);
		}
		else
		{
			InstigatorInv.DataObject.AddExperienceFraction(Amount, RPGMut, Controller(InstigatorInv.Owner).PlayerReplicationInfo);
		}
	}
	else
	{
		HeadLG = LinkGun(InstigatorInv.Instigator.Weapon);
		if (HeadLG == None && InstigatorInv.Instigator.Weapon.IsA('RPGWeapon'))
		{
			HeadLG = LinkGun(RPGWeapon(InstigatorInv.Instigator.Weapon).ModifiedWeapon);
		}
		if (HeadLG == None)
		{
			// Instigator is not using a Link Gun
			InstigatorInv.DataObject.AddExperienceFraction(Amount, RPGMut, InstigatorInv.Instigator.PlayerReplicationInfo);
		}
		else
		{
			//create a list of everyone that should share the EXP
			Links[0] = InstigatorInv;
			for (C = Level.ControllerList; C != None; C = C.NextController)
			{
				if (C.Pawn != None && C.Pawn.Weapon != None)
				{
					LG = LinkGun(C.Pawn.Weapon);
					if (LG == None && RPGWeapon(C.Pawn.Weapon) != None)
					{
						LG = LinkGun(RPGWeapon(C.Pawn.Weapon).ModifiedWeapon);
					}
					if (LG != None && LG.LinkedTo(HeadLG))
					{
						//this player is linked, find the RPGStatsInv
						StatsInv = GetStatsInvFor(C, false);
						if (StatsInv != None)
						{
							Links[Links.length] = StatsInv;
						}
					}
				}
			}

			// share the experience among the linked players
			for (i = 0; i < Links.length; i++)
			{
				Links[i].DataObject.AddExperienceFraction(Amount / Links.length, RPGMut, Links[i].Instigator.PlayerReplicationInfo);
			}
		}
	}
}

// award EXP based on damage done
function AwardEXPForDamage(Controller InstigatedBy, RPGStatsInv InstigatedStatsInv, Pawn injured, float Damage)
{
	// only do EXP for damage for non-summoned monsters
	// (doing it for others would be too easily exploitable)
	if ( InstigatedBy != injured.Controller && InstigatedStatsInv != None && injured.IsA('Monster')
		&& FriendlyMonsterController(injured.Controller) == None )
	{
		//if the game is MonsterAssault and it's a vehicle hitting a monster, scale damage
		if (Level.Game.IsA('MonsterAssault') && Vehicle(InstigatedBy.Pawn) != None)
		{
			Damage *= MA_AdjustDamageByVehicleScale;
		}
		//cap to how much health monster has left so we don't hand out too much EXP
		Damage = FMin(Damage, injured.Health);
		ShareExperience(InstigatedStatsInv, Damage / injured.HealthMax * Monster(injured).ScoringValue);
	}
}

function ScoreKill(Controller Killer, Controller Killed)
{
	local RPGPlayerDataObject KillerData, KilledData;
	local int x, LevelDifference;
	local Inventory Inv, NextInv;
	local RPGStatsInv StatsInv, KillerStatsInv;
	local vector TossVel, U, V, W;
	local class<Weapon> LastWeapon;
	local int newscore;

	if (Killed == None)
	{
		Super.ScoreKill(Killer, Killed);
		return;
	}

	//make killed pawn drop any artifacts he's got
	if (Killed.Pawn != None)
	{
		Inv = Killed.Pawn.Inventory;
		while (Inv != None)
		{
			NextInv = Inv.Inventory;
			if (RPGArtifact(Inv) != None)
			{
				TossVel = Vector(Killed.Pawn.GetViewRotation());
				TossVel = TossVel * ((Killed.Pawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);
				TossVel += VRand() * (100 + Rand(250));
				Inv.Velocity = TossVel;
				Killed.Pawn.GetAxes(Killed.Pawn.Rotation, U, V, W);
				Inv.DropFrom(Killed.Pawn.Location + 0.8 * Killed.Pawn.CollisionRadius * U - 0.5 * Killed.Pawn.CollisionRadius * V);
			}
			Inv = NextInv;
		}
	}

	Super.ScoreKill(Killer, Killed);

	// if this player is now out of the game, find the lowest level player that remains
	if (Killed.PlayerReplicationInfo != None && Killed.PlayerReplicationInfo.bOutOfLives)
		RPGMut.FindCurrentLowestLevelPlayer();

	if (Killer == None)
		return;

	//EXP for killing monsters and nonplayer AI vehicles/turrets
	//note: most monster EXP is awarded in NetDamage(); this just notifies abilities and awards an extra 1 EXP
	//to make sure the killer got at least 1 total (plus it's an easy way to know who got the final blow)
	if (Monster(Killed.Pawn) != None || TurretController(Killed) != None)
	{
		if(AUDRPGWeapon(Killer.Pawn.Weapon) != None)
			AUDRPGWeapon(Killer.Pawn.Weapon).ScoreKill(Killer,Killed);

		StatsInv = GetStatsInvFor(Killer);
		if (StatsInv != None)
		{
			newscore = Monster(Killed.Pawn).ScoringValue;//(Monster(Killed.Pawn).HealthMax * 0.25)+Monster(Killed.Pawn).ScoringValue;
			KillerData = StatsInv.DataObject;
			for (x = 0; x < KillerData.Abilities.length; x++)
				KillerData.Abilities[x].static.ScoreKill(Killer, Killed, true, KillerData.AbilityLevels[x]);
			if (Killed.IsA('FriendlyMonsterController'))
			{
				// summoned monsters don't do EXP by damage so award full scoring value
				ShareExperience(StatsInv, float(newscore));
			}
			else
			{
				ShareExperience(StatsInv, float(newscore));
				StatsInv.ServerAddMoney(RPGMut.Default.MoneyPerKill);
			}
		}
		return;
	}

	if ( Killer == Killed || !Killed.bIsPlayer || !Killer.bIsPlayer
	     || (Killer.PlayerReplicationInfo != None && Killer.PlayerReplicationInfo.Team != None && Killed.PlayerReplicationInfo != None && Killer.PlayerReplicationInfo.Team == Killed.PlayerReplicationInfo.Team) )
		return;

	// if Killed was spawnkilled, no EXP
	if (Killed.Pawn != None && Level.TimeSeconds - Killed.Pawn.LastStartTime < 5)
	{
		LastWeapon = Killed.GetLastWeapon();
		if ( LastWeapon != None && ( LastWeapon.Name == 'AssaultRifle' || LastWeapon.Name == 'ShieldGun'
					     || LastWeapon == Level.Game.BaseMutator.GetDefaultWeapon() ) )
		{
			return;
		}
	}

	//get data
	KillerStatsInv = GetStatsInvFor(Killer);
	if (KillerStatsInv == None)
	{
		Log("KillerData not found for "$Killer.GetHumanReadableName());
		return;
	}
	KillerData = KillerStatsInv.DataObject;

	StatsInv = GetStatsInvFor(Killed);
	if (StatsInv == None)
	{
		Log("KilledData not found for "$Killed.GetHumanReadableName());
		return;
	}
	KilledData = StatsInv.DataObject;

	for (x = 0; x < KillerData.Abilities.length; x++)
		KillerData.Abilities[x].static.ScoreKill(Killer, Killed, true, KillerData.AbilityLevels[x]);
	for (x = 0; x < KilledData.Abilities.length; x++)
		KilledData.Abilities[x].static.ScoreKill(Killer, Killed, false, KilledData.AbilityLevels[x]);

	LevelDifference = Max(0, KilledData.Level - KillerData.Level);
	if (LevelDifference > 0)
		LevelDifference = int(float(LevelDifference*LevelDifference) / LevelDiffExpGainDiv);
	//cap gained exp to enough to get to Killed's level
	if (KilledData.Level - KillerData.Level > 0 && LevelDifference > (KilledData.Level - KillerData.Level) * KilledData.NeededExp)
		LevelDifference = (KilledData.Level - KillerData.Level) * KilledData.NeededExp;
	ShareExperience(KillerStatsInv, 1.0 + LevelDifference);

	//bonus experience for multikills
	if (UnrealPlayer(Killer) != None && UnrealPlayer(Killer).MultiKillLevel > 0)
		KillerData.Experience += Min(Square(float(UnrealPlayer(Killer).MultiKillLevel)), 100);
	else if (AIController(Killer) != None && Killer.Pawn != None && Killer.Pawn.Inventory != None)
		Killer.Pawn.Inventory.OwnerEvent('RPGScoreKill');	//hack to record multikills for bots (handled by RPGStatsInv)

	//bonus experience for sprees
	if (Killer.Pawn != None && Killer.Pawn.GetSpree() % 5 == 0)
		KillerData.Experience += int(Square(float(Killer.Pawn.GetSpree() / 5 + 1)));

	//bonus experience for ending someone else's spree
	if (Killed.Pawn != None && Killed.Pawn.GetSpree() > 4)
		KillerData.Experience += Killed.Pawn.GetSpree() * 2 / 5;

	//bonus experience for first blood
	if (!bAwardedFirstBlood && TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo) != None && TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo).bFirstBlood)
	{
		KillerData.Experience += 2 * Max(KilledData.Level - KillerData.Level, 1);
		bAwardedFirstBlood = true;
	}

	//level up
	RPGMut.CheckLevelUp(KillerData, Killer.PlayerReplicationInfo);
}

//Give experience for game objectives
function ScoreObjective(PlayerReplicationInfo Scorer, Int Score)
{
	local RPGStatsInv StatsInv;

	if (Score >= 0 && Scorer != None && Scorer.Owner != None)
	{
		StatsInv = GetStatsInvFor(Controller(Scorer.Owner));
		if (StatsInv != None)
		{
			StatsInv.DataObject.Experience += Max(Score, 1);
			RPGMut.CheckLevelUp(StatsInv.DataObject, Scorer);
		}
	}

	Super.ScoreObjective(Scorer, Score);

	// jailbreak execution hack - the victorious team's pawns are destroyed and respawned with no notification
	// so they'd lose their RPGStatsInv without this
	if (Level.Game.IsA('Jailbreak') && Level.Game.IsInState('Executing') && Score == 1 && StatsInv != None)
	{
		StatsInv.OwnerDied();
	}
}

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local RPGPlayerDataObject InjuredData, InstigatedData;
	local RPGStatsInv InjuredStatsInv, InstigatedStatsInv;
	local int x, MonsterLevel;
	local FriendlyMonsterController C;
	local bool bZeroDamage;

	if (injured == None || instigatedBy == None || injured.Controller == None || instigatedBy.Controller == None)
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

	C = FriendlyMonsterController(injured.Controller);
	if (C != None && C.Master != None)
	{
		if (C.Master == instigatedBy.Controller)
			Damage = OriginalDamage;
		else if (C.SameTeamAs(instigatedBy.Controller))
			Damage *= TeamGame(Level.Game).FriendlyFireScale;
	}

	// get instigatedBy's RPGStatsInv here so if we bail early we can still give exp for any damage vs monsters
	InstigatedStatsInv = GetStatsInvFor(instigatedBy.Controller);

	if (DamageType.default.bSuperWeapon || Damage >= 1000)
	{
		//if this is weapon damage and the player doing the damage has an RPGWeapon, let it modify the damage
		if (ClassIsChildOf(DamageType, class'WeaponDamageType') && RPGWeapon(InstigatedBy.Weapon) != None)
			RPGWeapon(InstigatedBy.Weapon).NewAdjustTargetDamage(Damage, OriginalDamage, Injured, HitLocation, Momentum, DamageType);
		AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage);
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}
	else if (Monster(injured) != None && FriendlyMonsterController(injured.Controller) == None && Monster(instigatedBy) != None && FriendlyMonsterController(instigatedBy.Controller) == None)
	{
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}

	if (Damage <= 0)
	{
		Damage = Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		if (Damage < 0)
			return Damage;
		else if (Damage == 0) //for zero damage, still process abilities/magic weapons so effects relying on hits instead of damage still work
			bZeroDamage = true;
	}

	//get data
	if (InstigatedStatsInv != None)
		InstigatedData = InstigatedStatsInv.DataObject;

	InjuredStatsInv = GetStatsInvFor(injured.Controller);
	if (InjuredStatsInv != None)
		InjuredData = InjuredStatsInv.DataObject;

	if (InstigatedData == None || InjuredData == None)
	{
		if (Level.Game.IsA('Invasion'))
		{
			MonsterLevel = (Invasion(Level.Game).WaveNum + 1) * 2;
			if (RPGMut.bAutoAdjustInvasionLevel && RPGMut.CurrentLowestLevelPlayer != None)
				MonsterLevel += Max(0, RPGMut.CurrentLowestLevelPlayer.Level * RPGMut.InvasionAutoAdjustFactor);
		}
		else if (RPGMut.CurrentLowestLevelPlayer != None)
			MonsterLevel = RPGMut.CurrentLowestLevelPlayer.Level;
		else
			MonsterLevel = 1;
		if ( InstigatedData == None && ( (instigatedBy.IsA('Monster') && !instigatedBy.Controller.IsA('FriendlyMonsterController'))
						 || TurretController(instigatedBy.Controller) != None ) )
		{
			InstigatedData = RPGPlayerDataObject(Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
			InstigatedData.Attack = MonsterLevel / 2 * PointsPerLevel;
			InstigatedData.Defense = InstigatedData.Attack;
			InstigatedData.Level = MonsterLevel;
		}
		if ( InjuredData == None && ( (injured.IsA('Monster') && !injured.Controller.IsA('FriendlyMonsterController'))
					      || TurretController(injured.Controller) != None ) )
		{
			InjuredData = RPGPlayerDataObject(Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
			InjuredData.Attack = MonsterLevel / 2 * PointsPerLevel;
			InjuredData.Defense = InjuredData.Attack;
			InjuredData.Level = MonsterLevel;
		}
	}

	if (InstigatedData == None)
	{
		//This should never happen
		Log("InstigatedData not found for "$instigatedBy.GetHumanReadableName());
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}
	if (InjuredData == None)
	{
		//This should never happen
		Log("InjuredData not found for "$injured.GetHumanReadableName());
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}

	//headshot bonus EXP
	if (DamageType.Name == 'DamTypeSniperHeadShot' && InstigatedStatsInv != None && !instigatedBy.Controller.SameTeamAs(injured.Controller))
	{
		InstigatedData.Experience++;
		RPGMut.CheckLevelUp(InstigatedData, InstigatedBy.PlayerReplicationInfo);
	}

	Damage += int((float(Damage) * (1.0 + float(InstigatedData.Attack) * 0.005)) - (float(Damage) * (1.0 + float(InjuredData.Defense) * 0.005)));

	if (Damage < 1 && !bZeroDamage)
		Damage = 1;

	//if this is weapon damage and the player doing the damage has an RPGWeapon, let it modify the damage
	if (ClassIsChildOf(DamageType, class'WeaponDamageType') && RPGWeapon(InstigatedBy.Weapon) != None)
		RPGWeapon(InstigatedBy.Weapon).NewAdjustTargetDamage(Damage, OriginalDamage, Injured, HitLocation, Momentum, DamageType);

	//Allow Abilities to react to damage
	if (InstigatedStatsInv != None)
	{
		for (x = 0; x < InstigatedData.Abilities.length; x++)
			InstigatedData.Abilities[x].static.HandleDamage(Damage, injured, instigatedBy, Momentum, DamageType, true, InstigatedData.AbilityLevels[x]);
	}
	else
		Level.ObjectPool.FreeObject(InstigatedData);
	if (InjuredStatsInv != None)
	{
		for (x = 0; x < InjuredData.Abilities.length; x++)
			InjuredData.Abilities[x].static.HandleDamage(Damage, injured, instigatedBy, Momentum, DamageType, false, InjuredData.AbilityLevels[x]);
	}
	else
		Level.ObjectPool.FreeObject(InjuredData);

	if (bZeroDamage)
	{
		return 0;
	}
	else
	{
		if (InstigatedBy.HasUDamage())
		{
			//UDamage is applied after this function so add it in to get the real amount of damage that will be done
			AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage * 2);
		}
		else
		{
			AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage);
		}
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}
}

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
	local RPGStatsInv StatsInv;
	local int x;

	//increase value of ammo pickups based on Max Ammo stat
	if (Other.Controller != None)
	{
		StatsInv = GetStatsInvFor(Other.Controller);
		if (StatsInv != None)
		{
			if (Ammo(item) != None)
				Ammo(item).AmmoAmount = int(Ammo(item).default.AmmoAmount * (1.0 + float(StatsInv.DataObject.AmmoMax) / 100.f));

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
				if (StatsInv.DataObject.Abilities[x].static.OverridePickupQuery(Other, item, bAllowPickup, StatsInv.DataObject.AbilityLevels[x]))
					return true;
		}
	}

	return Super.OverridePickupQuery(Other, item, bAllowPickup);
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local bool bAlreadyPrevented;
	local int x;
	local RPGStatsInv StatsInv;
	local FriendlyMonsterKillMarker M;
	local TeamPlayerReplicationInfo TPRI;
	local Controller KilledController;

	bAlreadyPrevented = Super.PreventDeath(Killed, Killer, damageType, HitLocation);

	if (Killed.Controller != None)
		KilledController = Killed.Controller;
	else if (Killed.DrivenVehicle != None && Killed.DrivenVehicle.Controller != None)
		KilledController = Killed.DrivenVehicle.Controller;
	if (KilledController != None)
		StatsInv = GetStatsInvFor(KilledController, true);

	if (StatsInv != None)
	{
		//FIXME Pawn should probably still call PreventDeath() in cases like this, but it might be wiser to ignore the value
		if (!KilledController.bPendingDelete && (KilledController.PlayerReplicationInfo == None || !KilledController.PlayerReplicationInfo.bOnlySpectator))
		{
			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
				if (StatsInv.DataObject.Abilities[x].static.PreventDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x], bAlreadyPrevented))
					bAlreadyPrevented = true;
		}

		//tell StatsInv its owner died
		if (!bAlreadyPrevented)
			StatsInv.OwnerDied();
	}

	if (bAlreadyPrevented)
		return true;

	//Hack to give master credit for all his/her monster's kills
	if (FriendlyMonsterController(Killer) != None && FriendlyMonsterController(Killer).Master != None)
	{
		M = spawn(class'FriendlyMonsterKillMarker', Killed);
		M.Killer = FriendlyMonsterController(Killer).Master;
		M.Health = Killed.Health;
		M.DamageType = damageType;
		M.HitLocation = HitLocation;
		//done here because monster will never be told it has killed anybody due to Master getting credit
		Killer.Pawn.PlayVictoryAnimation();
		return true;
	}

	//Hack to give EXP and game stats (but NOT points) for killing someone else's monster
	if (FriendlyMonsterController(Killed.Controller) != None)
	{
		//don't count this monster as part of an Invasion wave
		if (Invasion(Level.Game) != None)
			Invasion(Level.Game).NumMonsters++;

		if (Killer != None && Killer != Killed && Killer.bIsPlayer)
		{
			if (FriendlyMonsterController(Killed.Controller).Master != Killer)
			{
				Level.Game.GameRulesModifiers.ScoreKill(Killer, Killed.Controller);
				TPRI = TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo);
				if (TPRI != None)
				{
					TPRI.Kills++;
					TPRI.AddWeaponKill(damageType);
				}
			}

			M = spawn(class'FriendlyMonsterKillMarker', Killed);
			M.Health = Killed.Health;
			M.DamageType = damageType;
			M.HitLocation = HitLocation;
			Killed.Controller.Destroy();
			return true;
		}
	}
	else if ((damageType.default.bCausedByWorld || damageType.Name == 'DamTypeTeleFrag') && Killed.Health > 0)
	{
		// if this damagetype is an instant kill that bypasses Pawn.TakeDamage() and calls Pawn.Died() directly
		// then we need to award EXP by damage for the rest of the monster's health
		AwardEXPForDamage(Killer, GetStatsInvFor(Killer, true), Killed, Killed.Health);
	}

	// Yet Another Invasion Hack - Invasion doesn't call ScoreKill() on the GameRules if a monster kills something
	// This one's so bad I swear I'm fixing it for a patch
	if (int(Level.EngineVersion) < 3190 && Level.Game.IsA('Invasion') && KilledController != None && MonsterController(Killer) != None)
	{
		if (KilledController.PlayerReplicationInfo != None)
			KilledController.PlayerReplicationInfo.bOutOfLives = true;
		ScoreKill(Killer, KilledController);
	}

	return false;
}

function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType)
{
	local int x;
	local RPGStatsInv StatsInv;

	if (Killed.Controller != None)
	{
		StatsInv = GetStatsInvFor(Killed.Controller, true);
		if (StatsInv != None)
			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
				if (StatsInv.DataObject.Abilities[x].static.PreventSever(Killed, boneName, Damage, DamageType, StatsInv.DataObject.AbilityLevels[x]))
					return true;
	}

	return Super.PreventSever(Killed, boneName, Damage, DamageType);
}

function Timer()
{
	local Controller C;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local int x;

	if((AUDInvasion(Level.Game).WaveNum+1) % 10 == 0)
	{
		if(!bGaveXP)
		{
			for (C = Level.ControllerList; C != None; C = C.NextController)
			if (C != None)
			{
				StatsInv = GetStatsInvFor(C);
				if (StatsInv != None)
				{
					StatsInv.DataObject.Experience += 50000;;
					RPGMut.CheckLevelUp(StatsInv.DataObject, C.PlayerReplicationInfo);
				}
			}
		bGaveXP=true;
		}
	}
	else
	bGaveXP=false;

	if (Level.Game.bGameEnded)
	{
		if (TeamInfo(Level.Game.GameReplicationInfo.Winner) != None)
		{
			for (C = Level.ControllerList; C != None; C = C.NextController)
				if (C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.Team == Level.Game.GameReplicationInfo.Winner)
				{
					StatsInv = GetStatsInvFor(C);
					if (StatsInv != None)
					{
						StatsInv.DataObject.Experience += RPGMut.EXPForWin;
						RPGMut.CheckLevelUp(StatsInv.DataObject, C.PlayerReplicationInfo);
					}
				}
			Log(Level.Game.GameReplicationInfo.Winner.GetHumanReadableName()@"won the match, awarded"@RPGMut.EXPForWin@"EXP");
		}
		else if ( PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner) != None
			  && Controller(PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner).Owner) != None )
		{
			StatsInv = GetStatsInvFor(Controller(PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner).Owner));
			if (StatsInv != None)
			{
				StatsInv.DataObject.Experience += RPGMut.EXPForWin;
				RPGMut.CheckLevelUp(StatsInv.DataObject, PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner));
				Log(PlayerReplicationInfo(Level.Game.GameReplicationInfo.Winner).PlayerName@"won the match, awarded "$RPGMut.EXPForWin$" EXP");
			}
		}

		if (!RPGMut.bFakeBotLevels && RPGMut.BotBonusLevels > 0)
		{
			//If Fake Bot Levels is off, bots get a configurable amount of bonus levels after the game
			//to counter that they're in only a fraction of the total games played on the machine
			for (C = Level.ControllerList; C != None; C = C.NextController)
				if (Bot(C) != None)
				{
					StatsInv = GetStatsInvFor(C);
					if (StatsInv != None)
					{
						for (x = 0; x < RPGMut.BotBonusLevels; x++)
						{
							StatsInv.DataObject.Experience += StatsInv.DataObject.NeededExp;
							RPGMut.CheckLevelUp(StatsInv.DataObject, None);
						}
						RPGMut.BotLevelUp(Bot(C), StatsInv.DataObject);
					}
				}
		}

		SetTimer(0, false);
	}
	else if (Level.Game.ResetCountDown == 2)
	{
		//unattach all RPGStatsInv from any pawns because the game is resetting and all pawns are about to be destroyed
		//this is done here to insure it happens right before the game actually resets anything
		for (C = Level.ControllerList; C != None; C = C.NextController)
			if (C.bIsPlayer)
				for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
					if (Inv.IsA('RPGStatsInv') && Inv.Owner != C && Inv.Owner != None)
					{
						Log("Resetting StatsInv: "$Inv);
						RPGStatsInv(Inv).OwnerDied();
						break;
					}
	}
}

function Tick(float DeltaTime)
{
	local Object MonsterConfig;

	//hack for Monster Assault - get the vehicle vs monster damage scaling for EXP by damage calculation
	//is it bad that I'm so good at evil hacks like this...?
	if (Level.Game.IsA('MonsterAssault'))
	{
		MonsterConfig = FindObject( "Package." $ Repl(Left(string(Level), InStr(string(Level), ".")), " ", Chr(27)),
						class(DynamicLoadObject(Level.Game.Class.Outer $ ".MAMonsterSetting", class'Class')) );
		if (MonsterConfig == None)
		{
			//failsafe, just incase it gets changed for savegame compatibility
			MonsterConfig = FindObject( string(xLevel) $ "." $ Repl(Left(string(Level), InStr(string(Level), ".")), " ", Chr(27)),
							class(DynamicLoadObject(Level.Game.Class.Outer $ ".MAMonsterSetting", class'Class')) );
		}
		if (MonsterConfig != None)
		{
			MA_AdjustDamageByVehicleScale = float(MonsterConfig.GetPropertyText("AdjustDamageByVehicleScale"));
		}
		else
		{
			Warn("Could not find MonsterConfig for MonsterAssault game!");
		}
	}

	Disable('Tick');
}

function bool HandleRestartGame()
{
	local Controller C;
	local Inventory Inv;

	RPGMut.SaveData();

	//null all RPGPlayerDataObject references so everything gets properly garbage collected
	for (C = Level.ControllerList; C != None; C = C.NextController)
		if (C.bIsPlayer)
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				if (Inv.IsA('RPGStatsInv'))
				{
					RPGStatsInv(Inv).DataObject = None;
					Inv.Disable('Tick');
				}
	RPGMut.CurrentLowestLevelPlayer = None;
	RPGMut.OldPlayers.Length = 0;
	RPGMut.SetTimer(0, false);

	return Super.HandleRestartGame();
}

defaultproperties
{
     MA_AdjustDamageByVehicleScale=1.000000
}
