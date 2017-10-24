//This holds and maintains the list of the local player's enemy pawns for use in AwarenessInteraction
//A seperate actor is used to prevent invalid pointer problems since Actor references
//in non-Actors don't get set to None automatically when the Actor is destroyed
// We just made a few changes to Mysterial's ... but they were in the biggest function
class DruidAwarenessEnemyList extends Actor;

var array<Pawn> Enemies;
var PlayerController PlayerOwner;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = Level.GetLocalPlayerController();
	if (PlayerOwner != None)
		SetTimer(2, true);
	else
		Warn("DruidAwarenessEnemyList spawned with no local PlayerController!");
}

simulated function Timer()
{
	local Pawn P, PlayerDriver;
	local bool GoodMonster;
	local FriendlyMonsterEffect FME;

	Enemies.length = 0;

	if (PlayerOwner.Pawn == None || PlayerOwner.Pawn.Health <= 0)
		return;

	if (Vehicle(PlayerOwner.Pawn) != None)
		PlayerDriver = Vehicle(PlayerOwner.Pawn).Driver;

	foreach DynamicActors(class'Pawn', P)
	{
		if (P.IsA('Monster'))
		{
// Assume bad monster.
			GoodMonster = False;
			foreach DynamicActors(class'FriendlyMonsterEffect', FME)
			{
// Skip it, not the one we're looking for.
				if (P != FME.Base)
					continue;
// The one we're looking for, and it's ours.
				else if (FME.MasterPRI == PlayerOwner.PlayerReplicationInfo)
				{
					GoodMonster = True;
					break;
				}
// The one we're looking for, not ours, but on our team.
				else if(FME.MasterPRI.Team != None && FME.MasterPRI.Team == PlayerOwner.PlayerReplicationInfo.Team)
				{
					GoodMonster = True;
					break;
				}
// Gotta be a bad guy.
				else
				{
					break;
				}
			}
// If we haven't found it related to an FME, or the FME says it's not friendly ...
			if (!GoodMonster)
				Enemies[Enemies.length] = P;
		}
		else if (Vehicle(P) != None && Vehicle(P).Driver != None &&
		    Vehicle(P).Driver != PlayerDriver &&
		    (Vehicle(P).GetTeamNum() != PlayerOwner.GetTeamNum() || PlayerOwner.GetTeamNum() == 255))
		{
			Enemies[Enemies.length] = P;
		}
		else if (Vehicle(P) == None && P != PlayerOwner.Pawn && P.DrivenVehicle == None &&
		    (PlayerOwner.GetTeamNum() == 255 || P.GetTeamNum() != PlayerOwner.GetTeamNum()))
		{
			Enemies[Enemies.length] = P;
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
