class ArtifactGodlynessPickup extends RPGArtifactPickup;

var Emitter Godlyness;
/*
Simulated function PostBeginPlay()
{

	Godlyness = Spawn(class'GodlynessPickupEffect', self);
	Super.PostBeginPlay();

}


simulated function destroyed()
{
	if ( Godlyness != None )
		Godlyness.Kill();
	Super.Destroyed();
}
  */

defaultproperties
{
     InventoryType=Class'fpsRPG.ArtifactGodlyness'
     PickupMessage="You found the Gift of the Gods"
     PickupSound=Sound'PickupSounds.ShieldPack'
     PickupForce="ShieldPack"
     DrawType=DT_StaticMesh
     bAcceptsProjectors=False
     AmbientGlow=255
}
