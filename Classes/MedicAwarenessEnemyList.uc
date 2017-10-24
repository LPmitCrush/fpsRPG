//This holds and maintains the list of the local player's enemy pawns for use in MedicAwarenessInteraction
//A seperate actor is used to prevent invalid pointer problems since Actor references
//in non-Actors don't get set to None automatically when the Actor is destroyed
class MedicAwarenessEnemyList extends Actor;

var array<Pawn> Enemies;
var PlayerController PlayerOwner;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = Level.GetLocalPlayerController();
	if (PlayerOwner != None)
		SetTimer(2, true);
	else
		Warn("MedicAwarenessEnemyList spawned with no local PlayerController!");
}

simulated function Timer()
{
	local Pawn P, PlayerDriver;
	local FriendlyMonsterEffect FME;

	Enemies.length = 0;

	if (PlayerOwner.Pawn == None || PlayerOwner.Pawn.Health <= 0)
		return;

	if (Vehicle(PlayerOwner.Pawn) != None)
		PlayerDriver = Vehicle(PlayerOwner.Pawn).Driver;

// Near as I can tell GetTeamNum() returns 255 if there aren't any teams.
	foreach DynamicActors(class'Pawn', P)
	{
		if (((P != PlayerOwner.Pawn && P.GetTeamNum() == PlayerOwner.GetTeamNum() &&
		   PlayerOwner.GetTeamNum() != 255) || P.Instigator == PlayerOwner.Pawn) &&
		   Vehicle(P) == None && DruidBlock(P) == None && DruidExplosive(P) == None && DruidEnergyWall(P) == None && RedeemerWarhead(P) == None) 
			Enemies[Enemies.length] = P;
	}
	foreach DynamicActors(class'FriendlyMonsterEffect',FME)
	{
// First case: covers all friendly monsters in team games; or
// Second case: covers our own monsters in DeathMatch
		if ((FME.MasterPRI.Team != None &&
		   FME.MasterPRI.Team == PlayerOwner.PlayerReplicationInfo.Team &&
		   PlayerOwner.GetTeamNum() != 255)
		   || FME.MasterPRI == PlayerOwner.PlayerReplicationInfo)
			Enemies[Enemies.length] = Pawn(FME.Base);
	}
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     bGameRelevant=True
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
