class ArtifactHealEffectB extends BioSmoke;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0,False);
}

defaultproperties
{
     mSizeRange(0)=80.000000
     mSizeRange(1)=80.000000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=4.000000
}
