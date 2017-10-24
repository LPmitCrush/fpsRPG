Class ArtifactHealEffectC extends xEmitter;

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
     mMaxParticles=150
     mLifeRange(0)=0.300000
     mLifeRange(1)=0.150000
     mRegenRange(0)=100.000000
     mRegenRange(1)=100.000000
     mPosDev=(X=3.000000,Y=3.000000,Z=3.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mMassRange(0)=-1.000000
     mMassRange(1)=-2.000000
     mSizeRange(0)=15.000000
     mSizeRange(1)=20.000000
     mGrowthRate=-16.000000
     mAttenKa=0.500000
     mNumTileColumns=2
     mNumTileRows=2
     LightType=LT_Flicker
     LightHue=170
     LightSaturation=127
     LightBrightness=224.000000
     LightRadius=4.000000
     bDynamicLight=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=1.500000
     Skins(0)=Texture'XEffects.LightningChargeT'
     Style=STY_Translucent
}
