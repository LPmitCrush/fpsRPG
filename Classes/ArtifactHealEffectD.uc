Class ArtifactHealEffectD extends xEmitter;

#exec OBJ LOAD FILE=XEffectMat.utx

simulated function PostBeginPlay()
{
	SetTimer(1.0,False);
	Super.PostBeginPlay();
}

simulated function Timer()
{
	mRegen=False;
}

defaultproperties
{
     mSpawningType=ST_Explode
     mStartParticles=0
     mMaxParticles=25
     mLifeRange(0)=0.750000
     mLifeRange(1)=0.750000
     mRegenRange(0)=25.000000
     mRegenRange(1)=25.000000
     mPosDev=(X=256.000000,Y=256.000000,Z=256.000000)
     mSpeedRange(0)=-400.000000
     mSpeedRange(1)=-400.000000
     mPosRelative=True
     mSizeRange(0)=65.000000
     mSizeRange(1)=65.000000
     mGrowthRate=-80.000000
     mAttenKa=0.300000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.750000
     Skins(0)=Texture'XEffectMat.Shock.shock_sparkle'
     Style=STY_Translucent
}
