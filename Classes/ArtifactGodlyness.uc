class ArtifactGodlyness extends RPGArtifact;



//var Material EffectOverlay;
// remember the Controller we set god mode to
var Controller InstigatorController;
var emitter GodlynessEffect;
var localized string NotInVehicleMessage;

//var FriendlyMonsterEffect Effect;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 100)
		return;

	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
		Activate();
	else if ( !bActive && Instigator.Controller.Enemy != None
		  && Instigator.Health < 70 && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.7 )
		Activate();
}

function PostBeginPlay()
{

	Super.PostBeginPlay();
}


function Activate()
{
	if (Vehicle(Instigator) == None)
		Super.Activate();
	else if (Instigator != None)
		Instigator.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2)
		return Default.NotInVehicleMessage;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

state Activated
{
	function BeginState()
	{
			InstigatorController = Instigator.Controller;
			InstigatorController.bGodMode = true;
                        Instigator.SetCollision(false, false, false);
			Instigator.bCollideWorld = false;
			GodlynessEffect = Instigator.Spawn(class'GodlynessEffect',Instigator);
                        Instigator.AttachToBone(GodlynessEffect, 'Spine');

		if (PlayerController(Instigator.Controller) != None)
			Instigator.Controller.GotoState('PlayerFlying');
		else
			Instigator.SetPhysics(PHYS_Flying);

			bActive = true;
	}

	function EndState()
	{
		if (InstigatorController != None && Instigator != None && Instigator.Controller != None)
		{
			InstigatorController.bGodMode = false;
			InstigatorController = None;
			Instigator.SetCollision(true, true, true);
			Instigator.bCollideWorld = true;
			Instigator.SetPhysics(PHYS_Falling);

		if (PlayerController(Instigator.Controller) != None)
			Instigator.Controller.GotoState(Instigator.LandMovementState);

		if (GodlynessEffect != None)
		   GodlynessEffect.kill();

                bActive = false;
                  }       
        }
}

defaultproperties
{
     NotInVehicleMessage="Umm were sorry, but vehicles can't become godly."
     CostPerSec=33
     MinActivationTime=0.000001
     PickupClass=Class'fpsRPG.ArtifactGodlynessPickup'
     IconMaterial=Texture'fpsRPGTex.Icons.TheStar'
     ItemName="Godlyness"
}
