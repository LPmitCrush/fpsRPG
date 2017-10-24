class DruidLightningSentinel extends ASTurret;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

defaultproperties
{
     TurretBaseClass=Class'fpsRPG.DruidLightningSentinelBase'
     DefaultWeaponClassName=""
     VehicleNameString="Lightning Sentinel"
     bCanBeBaseForPawns=False
     Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
     DrawScale=0.500000
     AmbientGlow=120
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
