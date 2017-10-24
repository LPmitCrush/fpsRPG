class SphereDamage900r extends Emitter
	placeable;

// for changing the size of the sphere:
// A radius of 900 requires Sizescale set to 200, and StartSizeRange set to 7.
// if you want a radius of 1800, double the StartSizeRange to 14.

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'fpsRPGMesh.Meshes.SphereDamage'
         RenderTwoSided=True
         UseParticleColor=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=10.000000),Y=(Max=10.000000),Z=(Max=10.000000))
         SizeScale(0)=(RelativeSize=200.000000)
         StartSizeRange=(X=(Min=7.000000,Max=7.000000),Y=(Min=7.000000,Max=7.000000),Z=(Min=7.000000,Max=7.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=MeshEmitter'fpsRPG.SphereDamage900r.MeshEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bDirectional=True
}
