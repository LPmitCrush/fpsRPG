class ArtifactLightningBeam extends RPGArtifact
		config(fpsRPG);

var class<xEmitter> HitEmitterClass;
var config float MaxRange;
var config int DamagePerAdrenaline;
var config int AdrenalineForMiss;
var config bool UseWithUDamage;			//if true and running DD, only use half adrenaline. If false and running DD, pretend only half damage to do to negate DD 
var config int MaxDamageNonInvasion;
var config float TimeBetweenShots;
var float LastUsed;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.8 )
		Activate();
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function Activate()
{
	local Vehicle V;
	local Vector FaceDir;
	local Vector BeamEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local Pawn  HitPawn;
	local Vector StartTrace;
	local xEmitter HitEmitter;
	local int StartHealth;
	local int NewHealth;
	local int HealthTaken;
	local Actor A;
	local int UDamageAdjust;
	local int DamageToDo;

	if ((Instigator != None) && (Instigator.Controller != None))
	{
		if (LastUsed  + TimeBetweenShots > Instigator.Level.TimeSeconds)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
			bActive = false;
			GotoState('');
			return;	// cannot use yet
		}
		if (Instigator.Controller.Adrenaline < AdrenalineForMiss)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 10, None, None, Class);
			bActive = false;
			GotoState('');
			return;	// not enough power to charge
		}

		V = Vehicle(Instigator);
		if (V != None )
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
			bActive = false;
			GotoState('');
			return;	// can't use in a vehicle
		}

		// lets see what we hit then
		FaceDir = Vector(Instigator.Controller.GetViewRotation());
		StartTrace = Instigator.Location + Instigator.EyePosition();
		BeamEndLocation = StartTrace + (FaceDir * MaxRange);

		// See if we hit something.
       		AHit = Trace(HitLocation, HitNormal, BeamEndLocation, StartTrace, true);
		if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
		{
			// missed. Take off the miss adrenaline penalty
			Instigator.Controller.Adrenaline -= AdrenalineForMiss;
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;

			bActive = false;
			GotoState('');
			return;	// didn't hit an enemy
		}

		HitPawn = Pawn(AHit);
		if ( HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
		     && VSize(HitPawn.Location - StartTrace) < MaxRange && HitPawn.Controller.bGodMode == False)
		{
			// got it.
			HitEmitter = spawn(HitEmitterClass,,, (StartTrace + Instigator.Location)/2, rotator(HitLocation - ((StartTrace + Instigator.Location)/2)));
			if (HitEmitter != None)
			{
				HitEmitter.mSpawnVecA = HitPawn.Location;
			}

			A = spawn(class'BlueSparks',,, Instigator.Location);
			if (A != None)
			{
				A.RemoteRole = ROLE_SimulatedProxy;
				A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
			}
			A = spawn(class'BlueSparks',,, HitPawn.Location);
			if (A != None)
			{
				A.RemoteRole = ROLE_SimulatedProxy;
				A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*HitPawn.TransientSoundVolume,,HitPawn.TransientSoundRadius);
			}

			// damage it
			StartHealth = HitPawn.Health;

    		// damage it
	       	DamageToDo = DamagePerAdrenaline * Instigator.Controller.Adrenaline;
            //now limit the damage if it is not an invasion. Otherwise get instagibs which are not fair
            if (!Instigator.Level.Game.IsA('Invasion'))
                DamageToDo = min(DamageToDo,MaxDamageNonInvasion);
                
            // now check if we have a udamage running, and want to limit damage
			If (Instigator.HasUDamage())
			{
				UDamageAdjust = 2;				                	// assume double damage. If it is the triple, and not invasion, then they do more damage but use more adrenaline
    	       If (!UseWithUDamage)
                    DamageToDo = DamageToDo/UDamageAdjust;          // adjust intended damage down so expected damage done after udamage ups it
			}
			else
				UDamageAdjust = 1;
				
			HitPawn.TakeDamage(DamageToDo, Instigator, HitPawn.Location, vect(0,0,0), class'DamTypeLightningBolt');
				
			//first see if we killed it
			if (HitPawn == None || HitPawn.Health <= 0)
				AddArtifactKill(Instigator,class'WeaponBeam');

			// see how much damage we caused, and remove only that much adrenaline
			// If UseWithUDamage set, then only half (or 1/3) of the adrenaline should be taken if UDamage active
			NewHealth = 0;
			if (HitPawn != None)
				NewHealth = HitPawn.Health;
			if (NewHealth < 0)
				NewHealth = 0;
			HealthTaken = StartHealth - NewHealth;
			if (HealthTaken < 0)
				HealthTaken = StartHealth;	// Ghost knocks the health up to 9999

			// now check for double/triple damage, and adjust adrenaline taken accordingly
			if (UseWithUDamage)
				Instigator.Controller.Adrenaline -= HealthTaken / (DamagePerAdrenaline * UDamageAdjust);        // take less adrenaline
			else
				Instigator.Controller.Adrenaline -= HealthTaken / DamagePerAdrenaline;                          // take single damage adrenaline

			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;

			LastUsed = Instigator.Level.TimeSeconds;
		}
	}

}

static function AddArtifactKill(Pawn P,class<Weapon> W)
{
	local int i;
	local TeamPlayerReplicationInfo TPPI;
	local TeamPlayerReplicationInfo.WeaponStats NewWeaponStats;

	// When you kill someone, it calls AddWeaponKill. Unfortunately this checks the damage type is from a weapon.
	// so lightning rod/beam/bolt etc do not get kills logged. So bodge in as weapon kills so show on stats
	if (P == None || W == None)
		return;

  // not sure if I need the next two lines. I don't think so. Assault seems to also give a list of weapon kills
  //      if (!P.Level.Game.IsA('Invasion'))
  //		return;

	TPPI = TeamPlayerReplicationInfo(P.PlayerReplicationInfo);
	if (TPPI == None)
		return;

	for ( i=0; i<TPPI.WeaponStatsArray.Length && i<200; i++ )
	{
		if ( TPPI.WeaponStatsArray[i].WeaponClass == W )
		{
			TPPI.WeaponStatsArray[i].Kills++;
			return;
		}
	}

	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Kills = 1;
	TPPI.WeaponStatsArray[TPPI.WeaponStatsArray.Length] = NewWeaponStats;
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 5000)
		return "Cannot use this artifact again yet";
	else
		return "At least" @ switch @ "adrenaline is required to use this artifact";
}

defaultproperties
{
     HitEmitterClass=Class'fpsRPG.LightningBeamEmitter'
     MaxRange=3000.000000
     DamagePerAdrenaline=7
     AdrenalineForMiss=10
     MaxDamageNonInvasion=100
     TimeBetweenShots=1.000000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fpsRPG.ArtifactLightningBeamPickup'
     IconMaterial=Texture'fpsRPGTex.Icons.LightningBeamIcon'
     ItemName="Lightning Beam"
}
