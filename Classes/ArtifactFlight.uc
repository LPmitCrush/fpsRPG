class ArtifactFlight extends RPGArtifact;

var Emitter FlightTrail;
var localized string NotInVehicleMessage;

function BotConsider()
{
	if ( !bActive && Instigator.Controller.RouteGoal.Location.Z - 100 > Instigator.Location.Z
	     && Instigator.Controller.Adrenaline > 5 * VSize(Instigator.Controller.RouteGoal.Location - Instigator.Location) / Instigator.AirSpeed )
		Activate();
	else if ( bActive && Instigator.Controller.RouteGoal.Location.Z - 100 < Instigator.Location.Z && !FastTrace(Instigator.Location + vect(0,0,-200), Instigator.Location))
		Activate();
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
		if (PlayerController(Instigator.Controller) != None)
			Instigator.Controller.GotoState('PlayerFlying');
		else
			Instigator.SetPhysics(PHYS_Flying);
		bActive = true;
		FlightTrail = Instigator.spawn(class'FlightEffect', Instigator);
	}

	function EndState()
	{
		if (Instigator != None && Instigator.Controller != None && Instigator.DrivenVehicle == None)
		{
			Instigator.SetPhysics(PHYS_Falling);
			if (PlayerController(Instigator.Controller) != None)
				Instigator.Controller.GotoState(Instigator.LandMovementState);
		}
		bActive = false;
		if (FlightTrail != None)
			FlightTrail.Kill();
	}
}

defaultproperties
{
     NotInVehicleMessage="Sorry, vehicles can't wear boots."
     CostPerSec=5
     PickupClass=Class'fpsRPG.ArtifactFlightPickup'
     IconMaterial=Texture'fpsRPGTex.Icons.FlightIcon'
     ItemName="Boots of Flight"
}
