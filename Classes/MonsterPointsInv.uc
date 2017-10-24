class MonsterPointsInv extends Inventory
	config(fpsRPG);

//this class is the summoning nexus for all monsters in DruidsRPG

var array<Monster> SummonedMonsters;
var array<int> SummonedMonsterPoints;
var int TotalMonsterPoints;
var int UsedMonsterPoints;

var config int MaxMonsters;

var localized string NotEnoughAdrenalineMessage;
var localized string NotEnoughMonsterPointsMessage;
var localized string UnableToSpawnMonsterMessage;
var localized string TooManyMonstersMessage;

//client side only
var PlayerController PC;
var Player Player;
var MonsterMasterInteraction Interaction;

replication
{
	reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
		TotalMonsterPoints, UsedMonsterPoints;
	reliable if (Role == ROLE_Authority)
		RemoveInteraction, ClientCheckInteraction;
}

function PostBeginPlay()
{
	if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
		setTimer(5, true);
	super.postBeginPlay();
}

simulated function PostNetBeginPlay()
{
	if(Level.NetMode != NM_DedicatedServer)
		enable('Tick');
	super.PostNetBeginPlay();
}

simulated function Tick(float deltaTime)
{
	local int x;
	if (Level.NetMode == NM_DedicatedServer || Interaction != None || TotalMonsterPoints < 1)
	{
		disable('Tick');
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && !PC.PlayerReplicationInfo.bIsSpectator)
		{
			Player = PC.Player;
			if(Player != None && TotalMonsterPoints > 0)
			{
				//first, find out if they have the interaction already.
				
				for(x = 0; x < Player.LocalInteractions.length; x++)
				{
					if(MonsterMasterInteraction(Player.LocalInteractions[x]) != None)
					{
						Interaction = MonsterMasterInteraction(Player.LocalInteractions[x]);
						Interaction.MInv = self;
					}
				}
				if(Interaction == None) //they dont have one
					AddInteraction();
			}
			if(Interaction != None || TotalMonsterPoints < 1)
				disable('Tick');
		}else
		{
			disable('Tick');
		}
	}
}

simulated function ClientCheckInteraction()
{
	if (Level.NetMode != NM_DedicatedServer && TotalMonsterPoints > 0 && Interaction == None)
	{
		enable('Tick');
	}
}

//not done through the interaction master, because that requires a string with a package name.
simulated function AddInteraction()
{
	Interaction = new class'MonsterMasterInteraction';

	if (Interaction != None)
	{
		Player.LocalInteractions.Length = Player.LocalInteractions.Length + 1;
		Player.LocalInteractions[Player.LocalInteractions.Length-1] = Interaction;
		Interaction.ViewportOwner = Player;

		// Initialize the Interaction

		Interaction.Initialize();
		Interaction.Master = Player.InteractionMaster;
		Interaction.MInv = self;
	}
	else
		Log("Could not create MonsterMasterInteraction");

} // AddInteraction

function Monster SummonMonster(class<Monster> ChosenMonster, int Adrenaline, int MonsterPoints)
{
	Local Monster m;
	Local Vector SpawnLocation;
	local rotator SpawnRotation;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local int x;
	local FriendlyMonsterController C;
	Local FriendlyMonsterInv FriendlyInv;

	ClientCheckInteraction();

	if(Instigator.Controller.Adrenaline < Adrenaline)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 1, None, None, Class);
		return None;
	}
	if(TotalMonsterPoints - UsedMonsterPoints < MonsterPoints)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(SummonedMonsters.length >= MaxMonsters)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	SpawnLocation = getSpawnLocation(ChosenMonster);
	SpawnRotation = getSpawnRotator(SpawnLocation);

	M = spawn(ChosenMonster,,, SpawnLocation, SpawnRotation);
	if(M == None)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}
	else
	{
		if (M.Controller != None)
			M.Controller.Destroy();

		FriendlyInv = M.spawn(class'FriendlyMonsterInv');

		if(FriendlyInv == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			M.Died(None, class'DamageType', vect(0,0,0)); //whatever.
			//M.Destroy();
			return None;
		}
		FriendlyInv.MasterPRI = Instigator.Controller.PlayerReplicationInfo;
		FriendlyInv.giveTO(M);
		FriendlyInv.MonsterPointsInv = self;

		C = spawn(class'FriendlyMonsterController',,, SpawnLocation, SpawnRotation);
		if(C == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			M.Died(None, class'DamageType', vect(0,0,0)); //whatever.
			FriendlyInv.Destroy();
			M.Destroy();
			return None;
		}
		C.Possess(M); //do not call InitializeSkill before this line.
		C.SetMaster(Instigator.Controller);

		Instigator.Controller.Adrenaline -= Adrenaline;
		UsedMonsterPoints += MonsterPoints;
		SummonedMonsters[SummonedMonsters.length] = M;
		SummonedMonsterPoints[SummonedMonsterPoints.length] = MonsterPoints;

		//allow Instigator's abilities to affect the monster
		for (Inv = Instigator.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
		if (StatsInv == None) //fallback, should never happen
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None) //this should always be the case
		{
			for (x = 0; x < StatsInv.Data.Abilities.length; x++)
			{
				if(ClassIsChildOf(StatsInv.Data.Abilities[x], class'MonsterAbility'))
					class<MonsterAbility>(StatsInv.Data.Abilities[x]).static.ModifyMonster(M, StatsInv.Data.AbilityLevels[x]);
				else
					StatsInv.Data.Abilities[x].static.ModifyPawn(M, StatsInv.Data.AbilityLevels[x]);
			}

			if (C.Inventory == None) //should never be the case.
				C.Inventory = StatsInv;
			else
			{
				for (Inv = C.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
				{}
				Inv.Inventory = StatsInv;
			}
		}
	}

	return M;
}

function KillAllMonsters()
{
	local int i;
	
	for(i = 0; i < 1000 && SummonedMonsters.length > 0; i++)
		KillFirstMonster();
}

function KillFirstMonster()
{
	if(SummonedMonsters.length == 0)
		return; //nothing to kill
	if(SummonedMonsters[0] != None)
	{
		SummonedMonsters[0].Health = 0;
		SummonedMonsters[0].LifeSpan = 0.1 * SummonedMonsters.length; //so the server will do it in it's own time and not all at once...
		//SummonedMonsters[0].Died(None, class'DamageType', vect(0,0,0));
	}		
		
	UsedMonsterPoints -= SummonedMonsterPoints[0];
	if(UsedMonsterPoints < 0)
	{
		Warn("Monster Points less than zero!");
		UsedMonsterPoints = 0; //just an emergency checkertrap in case something interesting happens
	}
	SummonedMonsters.remove(0, 1);
	SummonedMonsterPoints.remove(0, 1);
}

//timer checks for dead minions.
function Timer()
{
	local int i;
	for(i = 0; i < SummonedMonsters.length; i++)
	{
		if(SummonedMonsters[i] == None || SummonedMonsters[i].health <= 0)
		{
			UsedMonsterPoints -= SummonedMonsterPoints[i];
			if(UsedMonsterPoints < 0)
			{
				Warn("Monster Points less than zero!");
				UsedMonsterPoints = 0; //just an emergency checkertrap in case something interesting happens
			}
			SummonedMonsters.remove(i, 1);
			SummonedMonsterPoints.remove(i, 1);
			i--;
		}
	}
}

function vector getSpawnLocation(Class<Monster> ChosenMonster)
{
	local float Dist, BestDist;
	local vector SpawnLocation;
	local NavigationPoint N, BestDest;

	BestDist = 50000.f;
	for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		Dist = VSize(N.Location - Instigator.Location);
		if (Dist < BestDist && Dist > ChosenMonster.default.CollisionRadius * 2)
		{
			BestDest = N;
			BestDist = VSize(N.Location - Instigator.Location);
		}
	}

	if (BestDest != None)
		SpawnLocation = BestDest.Location + (ChosenMonster.default.CollisionHeight - BestDest.CollisionHeight) * vect(0,0,1);
	else
		SpawnLocation = Instigator.Location + ChosenMonster.default.CollisionHeight * vect(0,0,1.5); //is this why monsters spawn on heads?

	return SpawnLocation;	
}

function rotator getSpawnRotator(Vector SpawnLocation)
{
	local rotator SpawnRotation;

	SpawnRotation.Yaw = rotator(SpawnLocation - Instigator.Location).Yaw;
	return SpawnRotation;
}

simulated function Destroyed()
{	
	if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
	{
		KillAllMonsters();
		setTimer(0, false);
	}
	if(Interaction != None)
	{
		Interaction.MInv = None; //clear the reference.
		RemoveInteraction();
	}
	
	super.Destroyed();
}

simulated function RemoveInteraction()
{
	if(Player != None && Player.InteractionMaster != None && Interaction != None)
		Player.InteractionMaster.RemoveInteraction(Interaction);
	if(Interaction != None)
		Interaction.Minv = None;
	Interaction = None;
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 1)
		return Default.NotEnoughAdrenalineMessage;
	if (Switch == 2)
		return Default.NotEnoughMonsterPointsMessage;
	if (Switch == 3)
		return Default.UnableToSpawnMonsterMessage;
	if (Switch == 4)
		return Default.TooManyMonstersMessage;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

defaultproperties
{
     MaxMonsters=3
     NotEnoughAdrenalineMessage="You do not have enough adrenaline to summon this monster."
     NotEnoughMonsterPointsMessage="Insufficent monster points available to summon this monster."
     UnableToSpawnMonsterMessage="Unable to spawn monster."
     TooManyMonstersMessage="You have summoned too many monsters. You must kill one before you can summon another one."
     MessageClass=Class'UnrealGame.StringMessagePlus'
}
