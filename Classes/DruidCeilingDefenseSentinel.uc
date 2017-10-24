class DruidCeilingDefenseSentinel extends ASTurret;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

defaultproperties
{
     DefaultWeaponClassName=""
     VehicleNameString="Ceiling Defense Sentinel"
     bCanBeBaseForPawns=False
     Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'
     DrawScale=0.300000
     Skins(0)=Combiner'fpsRPGTex.Turrets.CeilingDefense_C'
     Skins(1)=Combiner'fpsRPGTex.Turrets.CeilingDefense_C'
     AmbientGlow=10
     CollisionRadius=45.000000
     CollisionHeight=60.000000
}
