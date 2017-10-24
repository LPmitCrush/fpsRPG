class ArtifactSuperMakeMagicWeaponPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'fpsRPG.ArtifactSuperMakeMagicWeapon'
     PickupMessage="You got the Super Magic Weapon Maker!"
     PickupSound=Sound'PickupSounds.ShieldPack'
     PickupForce="ShieldPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XPickups_rc.UDamagePack'
     bAcceptsProjectors=False
     DrawScale=0.075000
     Skins(0)=Shader'XGameShaders.PlayerShaders.PlayerTrans'
     AmbientGlow=255
}
