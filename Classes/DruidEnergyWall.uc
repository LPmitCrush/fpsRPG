class DruidEnergyWall extends ASTurret;

var config int DamagePerHit;
var config float DamageFraction;

var int MaxGap;
var int MinGap;		// minimum gap for the wall, including posts. 
var int Height;

var vector P1Loc, P2Loc;
var DruidEnergyWallPost Post1,Post2;
var() class<Controller> DefaultController;
var() class<DruidEnergyWallPost> DefaultPost;

var float vScaleY;
var int origDamage;
var int TotalDamage;
var int TakenDamage;

replication
{
	reliable if (Role == ROLE_Authority)
		vScaleY;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	if (Role == ROLE_Authority)	
	{
		if (AssignPosts())
			DrawWall();
	}
			
	// now ASVehicle calls SetCollision(true,true) which sets bCollideActors and bBlockActors. We just want to collide actors and block nothing
	SetCollision(true,false,false);
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	// ok lets draw the wall. 
	if (Role < ROLE_Authority)	
		ClientDrawWall();
}

function bool AssignPosts()
{
	local DruidEnergyWallPost P;
	
	ForEach DynamicActors(class'DruidEnergyWallPost',P)
	{
		if ( P.wall == None && vsize(P.Location - Location) < default.MaxGap && P.Owner == Owner)
		{
			// found a post
			if (Post1 == None)
			{
				Post1 = P;
				P1Loc = P.Location;
				P.wall = self;
			}
			else if (Post2 == None)
			{
				Post2 = P;
				P2Loc = P.Location;
				P.wall = self;
				return true;		// got both posts
			}
		}
	}
	return false;
}

function DrawWall()
{
	local float wallgap;
	local vector vScale;

	// need to set the size of the wall here. Relative to initial size (100,50,50 scaled at 0.1)
	vScale.X = 0.02;
	wallgap = VSize(P1Loc - P2Loc) - 20.0;		// gap between posts take off the width of the posts
	vScale.Y = wallgap/50.0;
	if (vScale.Y < 0.1) vScale.Y = 0.1;
	vScaleY = vScale.Y;							// for replication to the client. If use vScale, the values get rounded.
	vScale.Z = Height/25.0;
	SetDrawScale3D( vScale );

}

simulated function ClientDrawWall()
{
	local vector cScale;

	if(Level.NetMode != NM_DedicatedServer)
	{
		cScale.X = 0.1;	// cannot use vScale.X as it gets rounded to zero
		cScale.Y = vScaleY;
		cScale.Z = default.Height/25.0;
		SetDrawScale3D( cScale );
	}	
}

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

simulated function Destroyed()
{
	if ( Post1 != None )
		Post1.Destroy();

	if ( Post2 != None )
		Post2.Destroy();

	super.Destroyed();
}

simulated event touch (Actor Other)
{
	local pawn P;
	local Controller C;
	local Controller PC;
	
	super.touch(Other);
	
	if (Role < ROLE_Authority)
		return;			// dont try to do anything clientside
		
	P = Pawn(Other);
	if (P == None || P.Health <= 0)
		return;		// not pawn so no use hurting, or is already dead
		
	// let's hit them for damage
	if ( Controller == None || DruidEnergyWallController(Controller) == None || DruidEnergyWallController(Controller).PlayerSpawner == None  || DruidEnergyWallController(Controller).PlayerSpawner.Pawn == None)
		return; 
	PC = DruidEnergyWallController(Controller).PlayerSpawner;
	
	if (P == PC.Pawn )
		return;		// is spawner
		
	C = P.Controller;
	if (C == None)
		return;		// not controlled so no use hurting
		
	if (TeamGame(Level.Game) != None && C.SameTeamAs(PC)) 	// on same team
		return;
		
	P.TakeDamage(DamagePerHit, self, P.Location, vect(0,0,0), class'DamTypeEnergyWall');

}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType) 
{
	local int ReducedDamage;

	ReducedDamage = float(Damage)*DamageFraction;	// reduce damage by DamageFraction as it isn't really hitting anything
	
	// taking some damage
	if (ReducedDamage <= 0 && Damage > 0)
		ReducedDamage = 1;
	momentum = vect(0,0,0);		// and we don't really want to move
	
	Super.TakeDamage(ReducedDamage, instigatedBy, hitlocation, momentum, damageType) ;	

}

defaultproperties
{
     DamagePerHit=40
     DamageFraction=0.300000
     MaxGap=500
     MinGap=80
     Height=120
     DefaultController=Class'fpsRPG.DruidEnergyWallController'
     DefaultPost=Class'fpsRPG.DruidEnergyWallPost'
     bNonHumanControl=True
     AutoTurretControllerClass=None
     VehicleNameString="Energy Wall"
     bCanBeBaseForPawns=False
     HealthMax=2000.000000
     Health=2000
     ControllerClass=None
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'fpsRPGMesh.Block.TestBlock'
     bReplicateMovement=False
     DrawScale=0.500000
     Skins(0)=FinalBlend'AW-ShieldShaders.Shaders.RedShieldFinal'
     Skins(1)=FinalBlend'AW-ShieldShaders.Shaders.RedShieldFinal'
     AmbientGlow=10
     bMovable=False
     bBlockActors=False
     bBlockKarma=False
     Mass=1000.000000
}
