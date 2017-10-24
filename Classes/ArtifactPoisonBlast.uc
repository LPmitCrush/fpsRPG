class ArtifactPoisonBlast extends RPGArtifact
		config(fpsRPG);

var config int AdrenalineRequired;
var config int BlastDistance;

var config float ChargeTime;
var config float MaxDrain;
var config float MinDrain;
var config float DrainTime;
var config float DamageRadius;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
		Activate();
	else if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.5 )
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
	local Vector BlastLocation;
	local vector HitLocation;
	local vector HitNormal;
	local PoisonBlastCharger PBC;

	if (Instigator != None)
	{
		if(Instigator.Controller.Adrenaline < AdrenalineRequired)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired, None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}
		
		V = Vehicle(Instigator);
		if (V != None )
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
			bActive = false;
			GotoState('');
			return;	// can't use in a vehicle

		}

		// change the guts of it
		FaceDir = Vector(Instigator.Controller.GetViewRotation());
		BlastLocation = Instigator.Location + (FaceDir * BlastDistance);
		if (!FastTrace(Instigator.Location, BlastLocation ))
		{
			// can't get directly to where we want to be. Spawn explosion where we collide.
       			Trace(HitLocation, HitNormal, BlastLocation, Instigator.Location, true);
			BlastLocation = HitLocation - (30*Normal(FaceDir));
		}

		PBC = Instigator.spawn(class'PoisonBlastCharger', Instigator.Controller,,BlastLocation);
		if(PBC != None)
		{
			PBC.MaxDrain = MaxDrain;
			PBC.MinDrain = MinDrain;
			PBC.DamageRadius = DamageRadius;
			PBC.ChargeTime = ChargeTime;
			PBC.DrainTime = DrainTime;

			Instigator.Controller.Adrenaline -= AdrenalineRequired;
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;
		}

	}
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=150
     BlastDistance=1500
     ChargeTime=2.000000
     MaxDrain=30.000000
     MinDrain=15.000000
     DrainTime=5.000000
     DamageRadius=2200.000000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fpsRPG.ArtifactPoisonBlastPickup'
     IconMaterial=Texture'XEffects.Skins.MuzFlashLink_t'
     ItemName="PoisonBlast"
}
