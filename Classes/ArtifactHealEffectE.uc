Class ArtifactHealEffectE extends xEmitter;

var Rotator EffectRotation;

simulated function PostBeginPlay()
{
	SetRotation(EffectRotation);
	//SetTimer(0.1,true);
	Super.PostBeginPlay();
}

simulated function Timer()
{

}

defaultproperties
{
     EffectRotation=(Pitch=16384)
     mParticleType=PT_Mesh
     mStartParticles=0
     mMaxParticles=1
     mLifeRange(0)=2.000000
     mLifeRange(1)=2.000000
     mRegenRange(0)=20.000000
     mRegenRange(1)=20.000000
     mSpeedRange(0)=100.000000
     mSpeedRange(1)=100.000000
     mSpinRange(0)=100.000000
     mSpinRange(1)=100.000000
     mSizeRange(0)=1.500000
     mSizeRange(1)=1.500000
     mGrowthRate=2.000000
     mColorRange(0)=(G=0,R=0)
     mColorRange(1)=(G=0,R=0)
     mAttenKa=0.300000
     mAttenFunc=ATF_ExpInOut
     mMeshNodes(0)=StaticMesh'E_Pickups.Health.MidHealth'
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     Skins(0)=FinalBlend'PickupSkins.Shaders.FinalHealthGlass'
}
