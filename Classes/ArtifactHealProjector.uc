class ArtifactHealProjector extends Projector;



var Rotator EffectRotation;

simulated event PostBeginPlay()
{
	DetachProjector();
	SetRotation(EffectRotation);
	AttachProjector( FadeInTime );
	
	AbandonProjector(LifeSpan);
}


//360 degrees = 65536
//180 degrees = 32768

defaultproperties
{
     EffectRotation=(Pitch=49152)
     FrameBufferBlendingOp=PB_AlphaBlend
     ProjTexture=TexRotator'fpsRPGTex.HealEffects.Ring1_Rotator'
     FOV=1
     MaxTraceDistance=512
     bClipBSP=True
     bProjectOnUnlit=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     FadeInTime=1.000000
     bStatic=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=4.000000
     DrawScale=4.000000
     bGameRelevant=True
     bNotOnDedServer=True
}
