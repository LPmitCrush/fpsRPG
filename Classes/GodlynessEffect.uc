class GodlynessEffect extends Emitter;

var bool bKillNow;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		bKillNow;
}

function BeginPlay()
{
	Super.BeginPlay();

	if (Instigator == None)
		Destroy();
	else if (Level.NetMode != NM_DedicatedServer)
		SetOffsets();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.NetMode != NM_DedicatedServer)
	{
		Emitters[0].InitialDelay = FRand();
		Emitters[1].InitialDelay = FRand();
	}
}

simulated function PostNetReceive()
{
	if (bKillNow)
		Kill();
	else if (Instigator != None)
		SetOffsets();
}

simulated function SetOffsets()
{
	Instigator.PlayAnim('Jump_Mid');
	//Emitters[0].StartLocationOffset = Instigator.GetBoneCoords('lfoot').Origin - Instigator.Location;
	//Emitters[1].StartLocationOffset = Instigator.GetBoneCoords('rfoot').Origin - Instigator.Location;
}

simulated function Kill()
{
	Super.Kill();
	bKillNow = true;

	if (Level.NetMode == NM_DedicatedServer)
		SetTimer(3, false);
}

function Timer()
{
	Destroy();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         SpinParticles=True
         UniformSize=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=75.000000))
         Texture=Texture'EpicParticles.Flares.FlashFlare1'
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=SpriteEmitter'fpsRPG.GodlynessEffect.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         SpinParticles=True
         UniformSize=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=150.000000,Max=200.000000))
         Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(1)=SpriteEmitter'fpsRPG.GodlynessEffect.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         BlendBetweenSubdivisions=True
         CoordinateSystem=PTCS_Relative
         MaxParticles=5
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=75.000000))
         Texture=Texture'AW-2004Particles.Energy.ElecPanels'
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         LifetimeRange=(Min=1.000000)
     End Object
     Emitters(2)=SpriteEmitter'fpsRPG.GodlynessEffect.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         FadeIn=True
         UniformSize=True
         FadeOutStartTime=0.800000
         FadeInEndTime=0.100000
         CoordinateSystem=PTCS_Relative
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=128.000000,Max=128.000000)
         StartSizeRange=(X=(Min=8.000000,Max=15.000000))
         Texture=Texture'AW-2004Particles.Weapons.HardSpot'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRadialRange=(Min=-80.000000,Max=-80.000000)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(3)=SpriteEmitter'fpsRPG.GodlynessEffect.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UniformSize=True
         Acceleration=(Z=15.000000)
         FadeOutStartTime=0.800000
         FadeInEndTime=0.200000
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=64.000000,Max=64.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=15.000000,Max=25.000000))
         Texture=Texture'AW-2004Particles.Weapons.PlasmaStar'
         LifetimeRange=(Min=1.000000,Max=1.200000)
     End Object
     Emitters(4)=SpriteEmitter'fpsRPG.GodlynessEffect.SpriteEmitter4'

     Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_Linear
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=8000
         DistanceThreshold=5.000000
         UseCrossedSheets=True
         UseColorScale=True
         FadeOut=True
         ColorMultiplierRange=(X=(Max=0.000000))
         FadeOutStartTime=0.800000
         StartSizeRange=(X=(Min=35.000000,Max=35.000000))
         Texture=Texture'AS_FX_TX.Trails.Trail_Blue'
         LifetimeRange=(Min=1.000000,Max=1.000000)
     End Object
     Emitters(5)=TrailEmitter'fpsRPG.GodlynessEffect.TrailEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bTrailerSameRotation=True
     bReplicateInstigator=True
     bReplicateMovement=False
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bNetNotify=True
}
