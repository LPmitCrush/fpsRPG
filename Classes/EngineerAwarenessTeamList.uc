//This holds and maintains the list of the local player's team pawns for use in EngineerAwarenessInteraction
//A seperate actor is used to prevent invalid pointer problems since Actor references
//in non-Actors don't get set to None automatically when the Actor is destroyed
class EngineerAwarenessTeamList extends Actor;

var array<Pawn> TeamPawns;
var PlayerController PlayerOwner;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = Level.GetLocalPlayerController();
	if (PlayerOwner != None)
		SetTimer(2, true);
	else
		Warn("EngineerAwarenessEnemyList spawned with no local PlayerController!");
}

simulated function Timer()
{
	local Pawn P, PlayerDriver;
	local FriendlyMonsterEffect FME;

	TeamPawns.length = 0;

	if (PlayerOwner.Pawn == None || PlayerOwner.Pawn.Health <= 0)
		return;

	if (Vehicle(PlayerOwner.Pawn) != None)
		PlayerDriver = Vehicle(PlayerOwner.Pawn).Driver;

// Near as I can tell GetTeamNum() returns 255 if there aren't any teams.
	foreach DynamicActors(class'Pawn', P)
	{
		if (P != PlayerOwner.Pawn && P != PlayerDriver  
			&& P.GetTeamNum() == PlayerOwner.GetTeamNum() && PlayerOwner.GetTeamNum() != 255 // engineerawareness no use in none team games
		   	&& Vehicle(P) == None && DruidBlock(P) == None && DruidExplosive(P) == None && RedeemerWarhead(P) == None) 
		{
			TeamPawns[TeamPawns.length] = P;
		}
	}
	foreach DynamicActors(class'FriendlyMonsterEffect',FME)
	{
// First case: covers all friendly monsters in team games; or
// Second case: covers our own monsters in DeathMatch
		if ((FME.MasterPRI.Team != None && FME.MasterPRI.Team == PlayerOwner.PlayerReplicationInfo.Team &&
		   PlayerOwner.GetTeamNum() != 255) || FME.MasterPRI == PlayerOwner.PlayerReplicationInfo)
		{
			TeamPawns[TeamPawns.length] = Pawn(FME.Base);
		}
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
