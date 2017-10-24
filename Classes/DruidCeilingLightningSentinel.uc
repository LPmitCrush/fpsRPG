class DruidCeilingLightningSentinel extends ASTurret;
#exec OBJ LOAD FILE=..\Animations\AS_Vehicles_M.ukx

function AddDefaultInventory()
{
	// do nothing. Do not want default weapon adding
}

defaultproperties
{
     DefaultWeaponClassName=""
     VehicleNameString="Ceiling LightSentinel"
     bCanBeBaseForPawns=False
     Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'
     DrawScale=0.300000
     Skins(0)=Combiner'fpsRPGTex.Turrets.CeilingLightning_C'
     Skins(1)=Combiner'fpsRPGTex.Turrets.CeilingLightning_C'
     AmbientGlow=120
     CollisionRadius=45.000000
     CollisionHeight=60.000000
}
