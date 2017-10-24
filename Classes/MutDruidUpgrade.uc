class MutDruidUpgrade extends Mutator
	config(DruidUpgrade);

var config Class<DruidUpgradeInv> Upgrader;

function ModifyPlayer(Pawn Other)
{
	Local DruidUpgradeInv inv;

	if(Other.Controller != None && Other.Controller.isA('PlayerController'))
	{
		Inv = DruidUpgradeInv(Other.FindInventoryType(class'DruidUpgradeInv'));
		if(Inv == None)
		{
			Inv = spawn(Upgrader, Other,,, rot(0,0,0));
			Inv.giveTo(Other);
		}
	}

	super.ModifyPlayer(Other);
}

defaultproperties
{
     Upgrader=Class'fpsRPG.DruidUpgradeInv'
     GroupName="DruidsRPGUpgradeMutator"
     FriendlyName="ÿfps RPG Upgrader"
     Description="fps RPG Upgrade Mutator. Needed to upgrade old RPG Data"
}
