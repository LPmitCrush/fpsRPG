class ArtifactHealProjectorBase extends Actor;

simulated function PostNetBeginPlay()
{
	spawn(class'ArtifactHealProjectorA',,, Location);
	spawn(class'ArtifactHealProjectorB',,, Location);
	spawn(class'ArtifactHealProjectorC',,, Location);
	destroy();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
}
