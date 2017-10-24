class DruidsRPGKeysMut extends Mutator
	config(fpsRPG);

struct ArtifactKeyConfig
{
	Var String Alias;
	var Class<RPGArtifact> ArtifactClass;
};
var config Array<ArtifactKeyConfig> ArtifactKeyConfigs;

function ModifyPlayer(Pawn Other)
{
	Local GiveItemsInv GIInv;

	super.ModifyPlayer(Other);

	//add the default items to their inventory..
	GIInv= GiveItemsInv(Other.FindInventoryType(class'GiveItemsInv'));
	if(GIInv == None)
	{
		GIInv = Other.Spawn(class'GiveItemsInv', Other);
		GIInv.giveTo(Other);
		GIInv.KeysMut = self;
		GIInv.InitializeKeyArray();
	}
}

defaultproperties
{
     ArtifactKeyConfigs(0)=(Alias="SelectTriple",ArtifactClass=Class'fpsRPG.DruidArtifactTripleDamage')
     ArtifactKeyConfigs(1)=(Alias="SelectGlobe",ArtifactClass=Class'fpsRPG.ArtifactInvulnerability')
     ArtifactKeyConfigs(2)=(Alias="SelectMWM",ArtifactClass=Class'fpsRPG.DruidArtifactMakeMagicWeapon')
     ArtifactKeyConfigs(3)=(Alias="SelectDouble",ArtifactClass=Class'fpsRPG.DruidDoubleModifier')
     ArtifactKeyConfigs(4)=(Alias="SelectMax",ArtifactClass=Class'fpsRPG.DruidMaxModifier')
     ArtifactKeyConfigs(5)=(Alias="SelectPlusOne",ArtifactClass=Class'fpsRPG.DruidPlusOneModifier')
     ArtifactKeyConfigs(6)=(Alias="SelectBolt",ArtifactClass=Class'fpsRPG.ArtifactLightningBolt')
     ArtifactKeyConfigs(7)=(Alias="SelectRepulsion",ArtifactClass=Class'fpsRPG.ArtifactRepulsion')
     ArtifactKeyConfigs(8)=(Alias="SelectFreezeBomb",ArtifactClass=Class'fpsRPG.ArtifactFreezeBomb')
     ArtifactKeyConfigs(9)=(Alias="SelectPoisonBlast",ArtifactClass=Class'fpsRPG.ArtifactPoisonBlast')
     ArtifactKeyConfigs(10)=(Alias="SelectMegaBlast",ArtifactClass=Class'fpsRPG.ArtifactMegaBlast')
     ArtifactKeyConfigs(11)=(Alias="SelectHealingBlast",ArtifactClass=Class'fpsRPG.ArtifactHealingBlast')
     ArtifactKeyConfigs(12)=(Alias="SelectMedic",ArtifactClass=Class'fpsRPG.ArtifactMakeSuperHealer')
     ArtifactKeyConfigs(13)=(Alias="SelectFlight",ArtifactClass=Class'fpsRPG.ArtifactFlight')
     ArtifactKeyConfigs(14)=(Alias="SelectMagnet",ArtifactClass=Class'fpsRPG.DruidArtifactSpider')
     ArtifactKeyConfigs(15)=(Alias="SelectTeleport",ArtifactClass=Class'fpsRPG.ArtifactTeleport')
     ArtifactKeyConfigs(16)=(Alias="SelectBeam",ArtifactClass=Class'fpsRPG.ArtifactLightningBeam')
     ArtifactKeyConfigs(17)=(Alias="SelectRod",ArtifactClass=Class'fpsRPG.DruidArtifactLightningRod')
     ArtifactKeyConfigs(18)=(Alias="SelectSphereInv",ArtifactClass=Class'fpsRPG.ArtifactSphereInvulnerability')
     ArtifactKeyConfigs(19)=(Alias="SelectSphereHeal",ArtifactClass=Class'fpsRPG.ArtifactSphereHealing')
     ArtifactKeyConfigs(20)=(Alias="SelectSphereDamage",ArtifactClass=Class'fpsRPG.ArtifactSphereDamage')
     ArtifactKeyConfigs(21)=(Alias="SelectRemoteDamage",ArtifactClass=Class'fpsRPG.ArtifactRemoteDamage')
     ArtifactKeyConfigs(22)=(Alias="SelectRemoteInv",ArtifactClass=Class'fpsRPG.ArtifactRemoteInvulnerability')
     ArtifactKeyConfigs(23)=(Alias="SelectRemoteMax",ArtifactClass=Class'fpsRPG.ArtifactRemoteMax')
     ArtifactKeyConfigs(24)=(Alias="SelectShieldBlast",ArtifactClass=Class'fpsRPG.ArtifactShieldBlast')
     GroupName="DruidsRPGKeys"
     FriendlyName="ÿfpsRPG Key Bindings"
     Description="Allow users to bind keys for selecting RPG Artifacts"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
