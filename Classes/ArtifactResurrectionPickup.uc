class ArtifactResurrectionPickup extends RPGArtifactPickup;

var Emitter Rez;

Simulated function PostBeginPlay()
{

	Rez = spawn(class'ResurrectionEffect', self);

	Super.PostBeginPlay();

}


simulated function destroyed()
{
	if ( rez != None )
		rez.Destroy();
	Super.Destroyed();
}

defaultproperties
{
     InventoryType=Class'fpsRPG.ArtifactResurrection'
     PickupMessage="You got the Resurrection Artifact!"
     PickupSound=Sound'PickupSounds.ShieldPack'
     PickupForce="ShieldPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'fpsRPGMesh.res.res'
     DrawScale=0.800000
}
