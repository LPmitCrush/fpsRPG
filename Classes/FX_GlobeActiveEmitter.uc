class FX_GlobeActiveEmitter extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'fpsRPGMesh.Effects.GlobeRings1'
         SpinParticles=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         RevolutionsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(Y=1.000000)
         SpinsPerSecondRange=(Y=(Min=0.250000,Max=0.250000))
         SizeScale(1)=(RelativeTime=0.100000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
         InitialParticlesPerSecond=1000.000000
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=2.000000,Max=2.000000)
     End Object
     Emitters(0)=MeshEmitter'fpsRPG.FX_GlobeActiveEmitter.MeshEmitter0'

     bNoDelete=False
     bOnlyDrawIfAttached=True
     bReplicateInstigator=True
     bOnlyDirtyReplication=True
     RemoteRole=ROLE_DumbProxy
     NetUpdateFrequency=10.000000
     bUseLightingFromBase=True
}
