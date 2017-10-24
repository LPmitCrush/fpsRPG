class ResurrectionEffect extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=22,G=160,R=241,A=66))
         ColorScale(1)=(RelativeTime=1.000000)
         FadeInEndTime=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         StartSizeRange=(X=(Min=14.000000,Max=14.000000),Y=(Min=200.000000,Max=200.000000),Z=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=4.000000
         Texture=Texture'AW-2004Particles.Energy.AirBlast'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.300000,Max=0.300000)
     End Object
     Emitters(0)=SpriteEmitter'fpsRPG.ResurrectionEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=22,G=160,R=241))
         ColorScale(2)=(RelativeTime=1.000000)
         Opacity=0.250000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=17.000000,Max=17.000000))
         InitialParticlesPerSecond=4.000000
         Texture=Texture'AW-2004Particles.Energy.EclipseCircle'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         InitialDelayRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(1)=SpriteEmitter'fpsRPG.ResurrectionEffect.SpriteEmitter1'

     TimeTillResetRange=(Min=5.000000,Max=5.000000)
     AutoDestroy=True
     bNoDelete=False
     bTrailerSameRotation=True
     bReplicateMovement=False
     Physics=PHYS_Trailer
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
