class EngineerPointsInv extends Inventory
	config(fpsRPG);

//this class is the summoning nexus for all things that can be summoned by Engineers in DruidsRPG

var array<Pawn> SummonedSentinels;
var array<int> SummonedSentinelPoints;
var int TotalSentinelPoints;
var int UsedSentinelPoints;

var array<Pawn> SummonedTurrets;
var array<int> SummonedTurretPoints;
var int TotalTurretPoints;
var int UsedTurretPoints;

var array<Pawn> SummonedVehicles;
var array<int> SummonedVehiclePoints;
var int TotalVehiclePoints;
var int UsedVehiclePoints;

var array<Pawn> SummonedBuildings;
var array<int> SummonedBuildingPoints;
var int TotalBuildingPoints;
var int UsedBuildingPoints;

struct ItemAvailability
{
	Var int Number;
	var int Level;
};
var config Array<ItemAvailability> SentinelAvailability;
var config Array<ItemAvailability> VehicleAvailability;
var config Array<ItemAvailability> TurretAvailability;
var config Array<ItemAvailability> BuildingAvailability;

var localized string NotEnoughPointsMessage;
var localized string UnableToSpawnMessage;
var localized string TooManyToSpawnMessage;
var localized string NotAtLevel;
var localized string TooManyExtra;

var int PlayerLevel;

//client side only
var PlayerController PC;
var Player Player;
var EngineerInteraction Interaction;
var int TimerCount;
var float RecoveryTime;
var float FastBuildPercent;		// the actual percent of the recovery time to use

replication
{
	reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
		TotalSentinelPoints, UsedSentinelPoints, TotalTurretPoints, UsedTurretPoints, 
		TotalVehiclePoints, UsedVehiclePoints, TotalBuildingPoints, UsedBuildingPoints, PlayerLevel;
	reliable if (Role == ROLE_Authority)
		SetClientRecoveryTime, RemoveInteraction, ClientCheckInteraction;
}

function PostBeginPlay()
{
	if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
		setTimer(5, true);
	super.postBeginPlay();

	if (Level.Game != None && !Level.Game.bAllowVehicles)
		Level.Game.bAllowVehicles = true;
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
	if (Level.NetMode == NM_DedicatedServer || Interaction != None) //* || (TotalBuildingPoints+TotalSentinelPoints+TotalTurretPoints+TotalVehiclePoints) < 1)
	{
		disable('Tick');
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && !PC.PlayerReplicationInfo.bIsSpectator)
		{
			Player = PC.Player;
			if(Player != None && (TotalBuildingPoints+TotalSentinelPoints+TotalTurretPoints+TotalVehiclePoints)>0)
			{
				//first, find out if they have the interaction already.
				
				for(x = 0; x < Player.LocalInteractions.length; x++)
				{
					if(EngineerInteraction(Player.LocalInteractions[x]) != None)
					{
						Interaction = EngineerInteraction(Player.LocalInteractions[x]);
						if (Interaction.EInv == None)
							Interaction.EInv = self;
					}
				}
				if(Interaction == None) //they dont have one
					AddInteraction();
			}
			if(Interaction != None)
				disable('Tick');
		}
	}
}


simulated function ClientCheckInteraction()
{
	if (Level.NetMode != NM_DedicatedServer && (TotalBuildingPoints+TotalSentinelPoints+TotalTurretPoints+TotalVehiclePoints) > 0 && Interaction == None)
	{
		enable('Tick');
	}
}

//not done through the interaction master, because that requires a string with a package name.
simulated function AddInteraction()
{
	Interaction = new class'EngineerInteraction';
	if (Interaction != None)
	{
		Player.LocalInteractions.Length = Player.LocalInteractions.Length + 1;
		Player.LocalInteractions[Player.LocalInteractions.Length-1] = Interaction;
		Interaction.ViewportOwner = Player;

		// Initialize the Interaction

		Interaction.Initialize();
		Interaction.Master = Player.InteractionMaster;
		Interaction.EInv = self;
	}
	else
		Log("Could not create EngineerInteraction");

} // AddInteraction

function SetRecoveryTime(int RecoveryPeriod)
{
	RecoveryTime = Level.TimeSeconds + (RecoveryPeriod*FastBuildPercent);
	SetClientRecoveryTime(RecoveryPeriod*FastBuildPercent);
}

simulated function SetClientRecoveryTime(int RecoveryPeriod)
{
	// set the recoverytime on the client side for the hud display
	if(Level.NetMode != NM_DedicatedServer)
	{
		RecoveryTime = Level.TimeSeconds + RecoveryPeriod;
	}
}

simulated function int GetRecoveryTime()
{
	 return int(RecoveryTime - Level.TimeSeconds);
}

function Vector GetSpawnHeight(Vector BeaconLocation)
{
	// hack to ensure turrets aren't spawned too high in the air.
	local Vector DownEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	
	DownEndLocation = BeaconLocation + vect(0,0,-300);

	// See if we hit something.
    	AHit = Trace(HitLocation, HitNormal, DownEndLocation, BeaconLocation, true);
	if (AHit == None || !AHit.bWorldGeometry)
		return vect(0,0,0);		// invalid, nothing to spawn on
	else 
		return HitLocation;
}

function Vector FindCeiling(Vector BeaconLocation)
{
	// hack to ensure turrets aren't spawned too high in the air.
	local Vector UpEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	
	UpEndLocation = BeaconLocation + vect(0,0,300);

	// See if we hit something.
    	AHit = Trace(HitLocation, HitNormal, UpEndLocation, BeaconLocation, true);
	if (AHit == None || !AHit.bWorldGeometry)
		return vect(0,0,0);		// invalid, nothing to spawn on
	else 
		return HitLocation;
}

simulated function bool AllowedAnotherSentinel()
{
	local int i;

	for(i=0;i<SentinelAvailability.length;i++)
		if (PlayerLevel >= SentinelAvailability[i].Level && SummonedSentinels.length < SentinelAvailability[i].Number)
			return true;	// required level less than we have, and number greater than the number we have
	return false;
}

simulated function bool AllowedAnotherVehicle()
{
	local int i;

	for(i=0;i<VehicleAvailability.length;i++)
		if (PlayerLevel >= VehicleAvailability[i].Level && SummonedVehicles.length < VehicleAvailability[i].Number)
			return true;	// required level less than we have, and number greater than the number we have
	return false;
}

simulated function bool AllowedAnotherTurret()
{
	local int i;

	for(i=0;i<TurretAvailability.length;i++)
		if (PlayerLevel >= TurretAvailability[i].Level && SummonedTurrets.length < TurretAvailability[i].Number)
			return true;	// required level less than we have, and number greater than the number we have
	return false;
}

simulated function bool AllowedAnotherBuilding()
{
	local int i;

	for(i=0;i<BuildingAvailability.length;i++)
		if (PlayerLevel >= BuildingAvailability[i].Level && SummonedBuildings.length < BuildingAvailability[i].Number)
			return true;	// required level less than we have, and number greater than the number we have
	return false;
}

simulated function bool AllowedMoreBuildings(int numReqd)
{
	local int i;

	for(i=0;i<BuildingAvailability.length;i++)
		if (PlayerLevel >= BuildingAvailability[i].Level && (SummonedBuildings.length+numReqd) <= BuildingAvailability[i].Number)
			return true;	// required level less than we have, and number greater than the number we have
	return false;
}

function ASTurret SummonBaseSentinel(class<Pawn> ChosenSentinel, int SentinelPoints, Pawn P, Vector SpawnLocation)
{
	Local ASTurret S;
	local rotator SpawnRotation;

	ClientCheckInteraction();

	if(TotalSentinelPoints - UsedSentinelPoints < SentinelPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(!AllowedAnotherSentinel())
	{
		if (SummonedSentinels.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	SpawnRotation = getSpawnRotator(SpawnLocation);

	S = ASTurret(spawn(ChosenSentinel,,, SpawnLocation, SpawnRotation));
	if(S == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	S.SetTeamNum(P.GetTeamNum());
	if (S.Controller != None)
		S.Controller.Destroy();
	S.bAutoTurret=true;
	S.bNonHumanControl=true;

	UsedSentinelPoints += SentinelPoints;
	SummonedSentinels[SummonedSentinels.length] = S;
	SummonedSentinelPoints[SummonedSentinelPoints.length] = SentinelPoints;

	return S;
}

function DruidEnergyWall SummonEnergyWall(class<DruidEnergyWall> ChosenEWall, int SentinelPoints, Pawn P, vector SpawnLocation, vector P1Loc, vector P2Loc)
{
	Local DruidEnergyWall E;
	local rotator SpawnRotation;
	local DruidEnergyWallPost Post1,Post2;
	//local vector Normalvect, XVect, YVect, ZVect;

	ClientCheckInteraction();

	if(TotalSentinelPoints - UsedSentinelPoints < SentinelPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(!AllowedAnotherSentinel())
	{
		if (SummonedSentinels.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}
	
	// lets create the posts
	Post1 = spawn(ChosenEWall.default.DefaultPost,P,, P1Loc, );
	if (Post1 == None)
	{
		// lets retry a bit further away from the edge
		P1Loc = P1Loc + (10 * Normal(P2Loc - P1Loc));
		Post1 = spawn(ChosenEWall.default.DefaultPost,P,, P1Loc, );
		if (Post1 == None)
		{
			P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			return None;
		}
	}
	Post2 = spawn(ChosenEWall.default.DefaultPost,P,, P2Loc, );
	if (Post2 == None)
	{
		// lets retry a bit further away from the edge
		P2Loc = P2Loc + (10 * Normal(P1Loc - P2Loc));
		Post2 = spawn(ChosenEWall.default.DefaultPost,P,, P2Loc, );
		if (Post2 == None)
		{
			Post1.Destroy();
			P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			return None;
		}
	}

	
	// ok, got 2 posts so spawn the wall between
	SpawnRotation = getSpawnRotator(SpawnLocation);
	SpawnLocation = (P1Loc+P2Loc)/2;
	SpawnLocation.z -= 22;

	E = spawn(ChosenEWall,P,,SpawnLocation,SpawnRotation);	// position halfway between the posts
	if (E == None)
	{	
		Post1.Destroy();
		Post2.Destroy();
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	E.P1Loc = P1Loc;
	E.P2Loc = P2Loc;
	E.SetTeamNum(P.GetTeamNum());
	if (E.Controller != None)
		E.Controller.Destroy();

	UsedSentinelPoints += SentinelPoints;
	SummonedSentinels[SummonedSentinels.length] = E;
	SummonedSentinelPoints[SummonedSentinelPoints.length] = SentinelPoints;

	return E;
}

function Vehicle SummonTurret(class<Pawn> ChosenTurret, int TurretPoints, Pawn P, Vector SpawnLocation)
{
	Local Vehicle T;
	local rotator SpawnRotation;

	ClientCheckInteraction();

	if(TotalTurretPoints - UsedTurretPoints < TurretPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(!AllowedAnotherTurret())
	{
		if (SummonedTurrets.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	SpawnRotation = getSpawnRotator(SpawnLocation);

	T = Vehicle(spawn(ChosenTurret,,, SpawnLocation, SpawnRotation));
	if(T == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	T.SetTeamNum(P.GetTeamNum());
	if (T.Controller != None)
		T.Controller.Destroy();

	UsedTurretPoints += TurretPoints;
	SummonedTurrets[SummonedTurrets.length] = T;
	SummonedTurretPoints[SummonedTurretPoints.length] = TurretPoints;

	return T;
}

function Vehicle SummonVehicle(class<Pawn> ChosenVehicle, int VehiclePoints, Pawn P, Vector SpawnLocation)
{
	Local Vehicle V;
	local rotator SpawnRotation;

	ClientCheckInteraction();

	if(TotalVehiclePoints - UsedVehiclePoints < VehiclePoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(!AllowedAnotherVehicle())
	{
		if (SummonedVehicles.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	SpawnRotation = getSpawnRotator(SpawnLocation);

	V = Vehicle(spawn(ChosenVehicle,,, SpawnLocation, SpawnRotation));
	if(V == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	V.SetTeamNum(P.GetTeamNum());

	if (V.Controller != None)
		V.Controller.Destroy();

	UsedVehiclePoints += VehiclePoints;
	SummonedVehicles[SummonedVehicles.length] = V;
	SummonedVehiclePoints[SummonedVehiclePoints.length] = VehiclePoints;

	return V;
}

function Vehicle SummonBuilding(class<Pawn> ChosenBuilding, int BuildingPoints, Pawn P, Vector SpawnLocation)
{
	Local Vehicle B;
	local rotator SpawnRotation;

	ClientCheckInteraction();

	if(TotalBuildingPoints - UsedBuildingPoints < BuildingPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(!AllowedAnotherBuilding())
	{
		if (SummonedBuildings.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	SpawnRotation = getSpawnRotator(SpawnLocation);

	B = Vehicle(spawn(ChosenBuilding,,, SpawnLocation, SpawnRotation));
	if(B == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	B.SetTeamNum(P.GetTeamNum());
	if (B.Controller != None)
		B.Controller.Destroy();

	UsedBuildingPoints += BuildingPoints;
	SummonedBuildings[SummonedBuildings.length] = B;
	SummonedBuildingPoints[SummonedBuildingPoints.length] = BuildingPoints;
	
	return B;
}

function DruidBlock SummonBlock(class<Pawn> ChosenBuilding, int BuildingPoints, Pawn P, Vector SpawnLocation, rotator SpawnRotation)
{
	Local DruidBlock B;

	ClientCheckInteraction();

	if(TotalBuildingPoints - UsedBuildingPoints < BuildingPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(!AllowedAnotherBuilding())
	{
		if (SummonedBuildings.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	B = DruidBlock(spawn(ChosenBuilding,,, SpawnLocation, SpawnRotation));
	if(B == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	B.SetTeamNum(P.GetTeamNum());
	if (B.Controller != None)
		B.Controller.Destroy();

	UsedBuildingPoints += BuildingPoints;
	SummonedBuildings[SummonedBuildings.length] = B;
	SummonedBuildingPoints[SummonedBuildingPoints.length] = BuildingPoints;
	
	return B;
}

function bool CheckMultiBlock(int BuildingPoints, int numBlocks, Pawn P)
{

	if(TotalBuildingPoints - UsedBuildingPoints < BuildingPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return false;
	}

	if(!AllowedMoreBuildings(numBlocks))
	{
		if (SummonedBuildings.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 6, None, None, Class);
		return false;
	}

	return true;
}

function DruidExplosive SummonExplosive(class<Pawn> ChosenExp, int BuildingPoints, Pawn P, Vector SpawnLocation, rotator SpawnRotation)
{
	Local DruidExplosive Expl;

	ClientCheckInteraction();

	if(TotalBuildingPoints - UsedBuildingPoints < BuildingPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if(!AllowedAnotherBuilding())
	{
		if (SummonedBuildings.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	Expl = DruidExplosive(spawn(ChosenExp,,, SpawnLocation, SpawnRotation));
	if(Expl == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	Expl.SetTeamNum(P.GetTeamNum());
	if (Expl.Controller != None)
		Expl.Controller.Destroy();

	UsedBuildingPoints += BuildingPoints;
	SummonedBuildings[SummonedBuildings.length] = Expl;
	SummonedBuildingPoints[SummonedBuildingPoints.length] = BuildingPoints;
	
	return Expl;
}

//timer checks for dead minions and resets the cooldown period after summoning.
function Timer()
{
	local int i;
	local RPGStatsInv StatsInv;

	for(i = 0; i < SummonedSentinels.length; i++)
	{
		if(SummonedSentinels[i] == None || SummonedSentinels[i].health <= 0)
		{
			UsedSentinelPoints -= SummonedSentinelPoints[i];
			if(UsedSentinelPoints < 0)
			{
				Warn("Sentinel Points less than zero!");
				UsedSentinelPoints = 0; //just an emergency checkertrap in case something interesting happens
			}
			SummonedSentinels.remove(i, 1);
			SummonedSentinelPoints.remove(i, 1);
			i--;
		}
	}
	for(i = 0; i < SummonedTurrets.length; i++)
	{
		if(SummonedTurrets[i] == None || SummonedTurrets[i].health <= 0)
		{
			UsedTurretPoints -= SummonedTurretPoints[i];
			if(UsedTurretPoints < 0)
			{
				Warn("Turret Points less than zero!");
				UsedTurretPoints = 0; //just an emergency checkertrap in case something interesting happens
			}
			SummonedTurrets.remove(i, 1);
			SummonedTurretPoints.remove(i, 1);
			i--;
		}
	}
	for(i = 0; i < SummonedVehicles.length; i++)
	{
		if(SummonedVehicles[i] == None || SummonedVehicles[i].health <= 0)
		{
			UsedVehiclePoints -= SummonedVehiclePoints[i];
			if(UsedVehiclePoints < 0)
			{
				Warn("Vehicle Points less than zero!");
				UsedVehiclePoints = 0; //just an emergency checkertrap in case something interesting happens
			}
			SummonedVehicles.remove(i, 1);
			SummonedVehiclePoints.remove(i, 1);
			i--;
		}
	}
	for(i = 0; i < SummonedBuildings.length; i++)
	{
		if(SummonedBuildings[i] == None || SummonedBuildings[i].health <= 0)
		{
			UsedBuildingPoints -= SummonedBuildingPoints[i];
			if(UsedBuildingPoints < 0)
			{
				Warn("Building Points less than zero!");
				UsedBuildingPoints = 0; //just an emergency checkertrap in case something interesting happens
			}
			SummonedBuildings.remove(i, 1);
			SummonedBuildingPoints.remove(i, 1);
			i--;
		}
	}

	// now also check if player level has changed
	if (Role == ROLE_Authority)
	{
		StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None && StatsInv.Data.Level>PlayerLevel)
			PlayerLevel = StatsInv.Data.Level;
	}
}

function rotator getSpawnRotator(Vector SpawnLocation)
{
	local rotator SpawnRotation;

	SpawnRotation.Yaw = rotator(SpawnLocation - Instigator.Location).Yaw;
	return SpawnRotation;
}

function KillAllSentinels()
{
	local int i;
	
	for(i = 0; i < 100 && SummonedSentinels.length > 0; i++)
		KillFirstSentinel();
}

function KillFirstSentinel()
{
	if(SummonedSentinels.length == 0)
		return; //nothing to kill
	if(SummonedSentinels[0] != None)
	{
		if (Vehicle(SummonedSentinels[0]) != None && Vehicle(SummonedSentinels[0]).Driver != None)
			Vehicle(SummonedSentinels[0]).EjectDriver();
		SummonedSentinels[0].Health = 0;
		SummonedSentinels[0].LifeSpan = 0.1 * SummonedSentinels.length; //so the server will do it in it's own time and not all at once...
	}		
		
	UsedSentinelPoints -= SummonedSentinelPoints[0];
	if(UsedSentinelPoints < 0)
	{
		Warn("Sentinel Points less than zero!");
		UsedTurretPoints = 0; //just an emergency checkertrap in case something interesting happens
	}
	SummonedSentinels.remove(0, 1);
	SummonedSentinelPoints.remove(0, 1);
}

function KillAllTurrets()
{
	local int i;
	
	for(i = 0; i < 100 && SummonedTurrets.length > 0; i++)
		KillFirstTurret();
}

function KillFirstTurret()
{
	if(SummonedTurrets.length == 0)
		return; //nothing to kill
	if(SummonedTurrets[0] != None)
	{
		if (Vehicle(SummonedTurrets[0]) != None && Vehicle(SummonedTurrets[0]).Driver != None)
			Vehicle(SummonedTurrets[0]).EjectDriver();
		SummonedTurrets[0].Health = 0;
		SummonedTurrets[0].LifeSpan = 0.1 * SummonedTurrets.length; //so the server will do it in it's own time and not all at once...
	}		
		
	UsedTurretPoints -= SummonedTurretPoints[0];
	if(UsedTurretPoints < 0)
	{
		Warn("Turret Points less than zero!");
		UsedTurretPoints = 0; //just an emergency checkertrap in case something interesting happens
	}
	SummonedTurrets.remove(0, 1);
	SummonedTurretPoints.remove(0, 1);
}

function KillAllVehicles()
{
	local int i;
	
	for(i = 0; i < 100 && SummonedVehicles.length > 0; i++)
		KillFirstVehicle();
}

function KillFirstVehicle()
{
	if(SummonedVehicles.length == 0)
		return; //nothing to kill
	if(SummonedVehicles[0] != None)
	{
		if (Vehicle(SummonedVehicles[0]) != None && Vehicle(SummonedVehicles[0]).Driver != None)
			Vehicle(SummonedVehicles[0]).EjectDriver();
		SummonedVehicles[0].Health = 0;
		SummonedVehicles[0].LifeSpan = 0.1 * SummonedVehicles.length; //so the server will do it in it's own time and not all at once...
	}		
		
	UsedVehiclePoints -= SummonedVehiclePoints[0];
	if(UsedVehiclePoints < 0)
	{
		Warn("Vehicle Points less than zero!");
		UsedVehiclePoints = 0; //just an emergency checkertrap in case something interesting happens
	}
	SummonedVehicles.remove(0, 1);
	SummonedVehiclePoints.remove(0, 1);
}

function KillAllBuildings()
{
	local int i;
	
	for(i = 0; i < 100 && SummonedBuildings.length > 0; i++)
		KillFirstBuilding();
}

function KillFirstBuilding()
{
	if(SummonedBuildings.length == 0)
		return; //nothing to kill
	if(SummonedBuildings[0] != None)
	{
		if (Vehicle(SummonedBuildings[0]) != None && Vehicle(SummonedBuildings[0]).Driver != None)
			Vehicle(SummonedBuildings[0]).EjectDriver();
		SummonedBuildings[0].Health = 0;
		SummonedBuildings[0].LifeSpan = 0.1 * SummonedBuildings.length; //so the server will do it in it's own time and not all at once...
	}		
		
	UsedBuildingPoints -= SummonedBuildingPoints[0];
	if(UsedBuildingPoints < 0)
	{
		Warn("Building Points less than zero!");
		UsedBuildingPoints = 0; //just an emergency checkertrap in case something interesting happens
	}
	SummonedBuildings.remove(0, 1);
	SummonedBuildingPoints.remove(0, 1);
}

simulated function Destroyed()
{	
	if(Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
	{
		setTimer(0, false);
		KillAllSentinels();
		KillAllTurrets();
		KillAllVehicles();
		KillAllBuildings();
	}
	if(Interaction != None)
	{
		Interaction.EInv = None; //clear the reference.
		RemoveInteraction();
	}
	
	super.Destroyed();
}

simulated function RemoveInteraction()
{
	if(Player != None && Player.InteractionMaster != None && Interaction != None)
		Player.InteractionMaster.RemoveInteraction(Interaction);
	if(Interaction != None)
		Interaction.Einv = None;
	Interaction = None;
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2)
		return Default.NotEnoughPointsMessage;
	if (Switch == 3)
		return Default.UnableToSpawnMessage;
	if (Switch == 4)
		return Default.TooManyToSpawnMessage;
	if (Switch == 5)
		return Default.NotAtLevel;
	if (Switch == 6)
		return Default.TooManyExtra;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

defaultproperties
{
     SentinelAvailability(0)=(Number=1,Level=15)
     SentinelAvailability(1)=(Number=2,Level=70)
     SentinelAvailability(2)=(Number=3,Level=130)
     VehicleAvailability(0)=(Number=1,Level=20)
     VehicleAvailability(1)=(Number=2,Level=40)
     TurretAvailability(0)=(Number=1,Level=30)
     TurretAvailability(1)=(Number=2,Level=50)
     BuildingAvailability(0)=(Number=1,Level=4)
     BuildingAvailability(1)=(Number=2,Level=10)
     BuildingAvailability(2)=(Number=3,Level=15)
     BuildingAvailability(3)=(Number=4,Level=20)
     BuildingAvailability(4)=(Number=5,Level=25)
     BuildingAvailability(5)=(Number=6,Level=30)
     BuildingAvailability(6)=(Number=7,Level=35)
     BuildingAvailability(7)=(Number=8,Level=40)
     BuildingAvailability(8)=(Number=9,Level=45)
     BuildingAvailability(9)=(Number=10,Level=50)
     BuildingAvailability(10)=(Number=11,Level=55)
     BuildingAvailability(11)=(Number=12,Level=60)
     BuildingAvailability(12)=(Number=13,Level=70)
     BuildingAvailability(13)=(Number=14,Level=80)
     BuildingAvailability(14)=(Number=15,Level=90)
     NotEnoughPointsMessage="Insufficent points available to summon this."
     UnableToSpawnMessage="Unable to spawn."
     TooManyToSpawnMessage="You have summoned too many of these. You must kill one before you can summon another one."
     NotAtLevel="You need to be a higher level to spawn one of these"
     TooManyExtra="You cannot spawn this many extra items"
     FastBuildPercent=1.000000
     MessageClass=Class'UnrealGame.StringMessagePlus'
}
