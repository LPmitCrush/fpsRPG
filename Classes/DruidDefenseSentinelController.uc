class DruidDefenseSentinelController extends Controller
	config(fpsRPG);

var Controller PlayerSpawner;
var class<xEmitter> HitEmitterClass;
var RPGStatsInv StatsInv;
var MutfpsRPG RPGMut;

var config float TimeBetweenShots;
var config float TargetRadius;
var config float XPPerHit;      // the amount of xp the summoner gets per projectile taken out

simulated event PostBeginPlay()
{
	local Mutator m;

	super.PostBeginPlay();

	if (Level.Game != None)
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutfpsRPG(m) != None)
			{
				RPGMut = MutfpsRPG(M);
				break;
			}
}

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
	if (PlayerSpawner.PlayerReplicationInfo != None && PlayerSpawner.PlayerReplicationInfo.Team != None )
	{
		if (PlayerReplicationInfo == None)
			PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
		PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s Sentinel";
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = true;
		PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
		PlayerReplicationInfo.RemoteRole = ROLE_None;

		// adjust the fire rate according to weapon speed
		StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None)
			TimeBetweenShots = (default.TimeBetweenShots * 100)/(100 + StatsInv.Data.WeaponSpeed);
	}
	SetTimer(TimeBetweenShots, true);
}

function Timer()
{
	// lets target some enemies
	local Projectile P;
	local xEmitter HitEmitter;
	local Projectile ClosestP;
	local Projectile BestGuidedP;
	local Projectile BestP;
	local int ClosestPdist;
	local int BestGuidedPdist;
	local Mutator m;


	if (PlayerSpawner == None || PlayerSpawner.Pawn == None || Pawn == None || Pawn.Health <= 0)
		return;		// going to die soon.

	// look for projectiles in range
	ClosestP = None;
	BestGuidedP = None;
	ClosestPdist = TargetRadius+1;
	BestGuidedPdist = TargetRadius+1;
	ForEach DynamicActors(class'Projectile',P)
	{
		if (P != None && FastTrace(P.Location, Pawn.Location) && (P.InstigatorController == None ||
			(P.InstigatorController != None && 
				((TeamGame(Level.Game) != None && !P.InstigatorController.SameTeamAs(PlayerSpawner))	// not same team
				 || (TeamGame(Level.Game) == None && P.InstigatorController != PlayerSpawner)))))	// or just not me
		{
			// we prefer to target a server guided projectile, so it can be destroyed client side as well
			// otherwise just go for the closest
			if ( BestGuidedPdist > VSize(Pawn.Location - P.Location) && P.bNetTemporary == false && !P.bDeleteMe)
			{
				BestGuidedP = P;
				BestGuidedPdist = VSize(Pawn.Location - P.Location);
			}
			if ( ClosestPdist > VSize(Pawn.Location - P.Location) && !P.bDeleteMe)
			{
				ClosestP = P;
				ClosestPdist = VSize(Pawn.Location - P.Location);
			}
		}
	}
	if (BestGuidedP != None)
		BestP = BestGuidedP;
	else
		BestP = ClosestP;
	if (BestP == None)
		return;

	HitEmitter = spawn(HitEmitterClass,,, Pawn.Location, rotator(BestP.Location - Pawn.Location));
	if (HitEmitter != None)
		HitEmitter.mSpawnVecA = BestP.Location;

	if (BestP != None && !BestP.bDeleteMe)
	{
		BestP.NetUpdateTime = Level.TimeSeconds - 1;
		BestP.bHidden = true;
		if (BestP.Physics != PHYS_None)	// to stop attacking an exploding redeemer
		{
		    // destroy it
			BestP.Explode(BestP.Location,vect(0,0,0));
			
			// ok, lets see if the initiator gets any xp
       		if (StatsInv == None && PlayerSpawner != None && PlayerSpawner.Pawn != None)
	            StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));
        	// quick check to make sure we got the RPGMut set
        	if (RPGMut == None && Level.Game != None)
        	{
        		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
        			if (MutfpsRPG(m) != None)
        			{
        				RPGMut = MutfpsRPG(M);
        				break;
        			}
        	}
			if ((XPPerHit > 0) && (StatsInv != None) && (StatsInv.DataObject != None) && (RPGMut != None) && (PlayerSpawner != None) && (PlayerSpawner.Pawn != None))
			{
				StatsInv.DataObject.AddExperienceFraction(XPPerHit, RPGMut, PlayerSpawner.Pawn.PlayerReplicationInfo);
			}

		}
	}

}

function Destroyed()
{
	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.Destroy();

	Super.Destroyed();
}

defaultproperties
{
     HitEmitterClass=Class'fpsRPG.DefenseBoltEmitter'
     TimeBetweenShots=0.600000
     TargetRadius=600.000000
     XPPerHit=0.066000
}
