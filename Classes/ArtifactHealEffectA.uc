class ArtifactHealEffectA extends xEmitter;

var Rotator EffectRotation;

simulated function PostBeginPlay()
{
	SetTimer(1.0,False);
	Super.PostBeginPlay();
	SetRotation(EffectRotation);
}

simulated function Timer()
{
	mRegen=False;
}

defaultproperties
{
     EffectRotation=(Pitch=16384)
     mParticleType=PT_Line
     mStartParticles=0
     mMaxParticles=150
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.100000
     mRegenRange(0)=150.000000
     mRegenRange(1)=150.000000
     mPosDev=(X=384.000000,Y=384.000000)
     mSpawnVecB=(Z=0.200000)
     mSpeedRange(0)=600.000000
     mSpeedRange(1)=999.000000
     mAirResistance=0.000000
     mSizeRange(0)=20.000000
     mSizeRange(1)=5.000000
     mColorRange(0)=(G=100,R=100)
     mNumTileColumns=4
     mNumTileRows=4
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.500000
     Skins(0)=Texture'XEffects.Skins.TransTrailT'
     Style=STY_Additive
}
