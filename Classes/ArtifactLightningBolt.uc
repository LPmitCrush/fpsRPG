class ArtifactLightningBolt extends RPGArtifact
		config(fpsRPG);

var class<xEmitter> HitEmitterClass;
var config float TargetRadius;
var config int DamagePerAdrenaline;
var config bool UseWithUDamage;		//if true and running DD, only use half adrenaline. If false and running DD, pretend only half damage to do to negate DD 
var config int MaxDamageNonInvasion;
var config int AdrenalineForMiss;
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
	local Controller C, BestC;
	local xEmitter HitEmitter;
	local int MostHealth;
	local int NewHealth;
	local int HealthTaken;
	local Actor A;
	local int UDamageAdjust;
	local Vehicle V;
	local int DamageToDo;

	if ((Instigator == None) || (Instigator.Controller == None))
	{
		bActive = false;
		GotoState('');
		return;	// really corrupt
	}

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

	C = Level.ControllerList;
	BestC = None;
	MostHealth = 0;
	while (C != None)
	{
		// loop round finding strongest enemy to attack
		if ( C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && FastTrace(C.Pawn.Location, Instigator.Location) && C.bGodMode == False)
		{
			if (C.Pawn.Health > MostHealth)
			{
				MostHealth = C.Pawn.Health;
				BestC = C;
			}
		}
		C = C.NextController;
	}
	if ((MostHealth > 0) && (BestC != None) && (BestC.Pawn != None))
	{
		HitEmitter = spawn(HitEmitterClass,,, Instigator.Location, rotator(BestC.Pawn.Location - Instigator.Location));
		if (HitEmitter != None)
			HitEmitter.mSpawnVecA = BestC.Pawn.Location;

		A = spawn(class'BlueSparks',,, Instigator.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
		}
		A = spawn(class'BlueSparks',,, BestC.Pawn.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*BestC.Pawn.TransientSoundVolume,,BestC.Pawn.TransientSoundRadius);
		}
		
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
				
        BestC.Pawn.TakeDamage(DamageToDo, Instigator, BestC.Pawn.Location, vect(0,0,0), class'DamTypeLightningBolt');
        
		//first see if we killed it
		if (BestC == None || BestC.Pawn == None || BestC.Pawn.Health <= 0 )
			class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponBolt');

		// see how much damage we caused, and remove only that much adrenaline
		NewHealth = 0;
		if (BestC != None && BestC.Pawn != None)
			NewHealth = BestC.Pawn.Health;
		if (NewHealth < 0)
			NewHealth = 0;
		HealthTaken = MostHealth - NewHealth;
		if (HealthTaken < 0)
			HealthTaken = MostHealth;	// Ghost knocks the health up to 9999

		// now check for double/triple damage, and adjust adrenaline taken accordingly
		if (UseWithUDamage)
			Instigator.Controller.Adrenaline -= HealthTaken / (DamagePerAdrenaline * UDamageAdjust);        // take less adrenaline
		else
			Instigator.Controller.Adrenaline -= HealthTaken / DamagePerAdrenaline;                          // take single damage adrenaline

		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		LastUsed = Instigator.Level.TimeSeconds;
	}
	else
	{
    	// missed. Take off the miss adrenaline penalty
		Instigator.Controller.Adrenaline -= AdrenalineForMiss;
		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		LastUsed = Instigator.Level.TimeSeconds;	// tough life isnt it?
	}

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
     HitEmitterClass=Class'fpsRPG.LightningBoltEmitter'
     TargetRadius=2000.000000
     DamagePerAdrenaline=3
     MaxDamageNonInvasion=100
     AdrenalineForMiss=10
     TimeBetweenShots=3.000000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fpsRPG.ArtifactLightningBoltPickup'
     IconMaterial=Texture'fpsRPGTex.Icons.LightningBoltIcon'
     ItemName="Lightning Bolt"
}
