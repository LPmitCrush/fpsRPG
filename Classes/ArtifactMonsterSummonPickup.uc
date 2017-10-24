class ArtifactMonsterSummonPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'fpsRPG.ArtifactMonsterSummon'
     PickupMessage="You got the Summoning Charm!"
     PickupSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     PickupForce="TranslocatorModuleRegeneration"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'fpsRPGMesh.Artifacts.MonsterCoin'
     DrawScale=0.250000
     AmbientGlow=128
}
