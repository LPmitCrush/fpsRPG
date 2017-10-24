class AbilityArmorRegen extends CostRPGAbility
	abstract;

var int MinLev;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	if(Data.Level < default.MinLev && CurrentLevel == 0)
		return 0;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local ArmorRegenInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	Inv = Other.FindInventoryType(class'ArmorRegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'ArmorRegenInv', Other,,,rot(0,0,0));
	R.RegenAmount = AbilityLevel*2;
	R.GiveTo(Other);
}

defaultproperties
{
     MinLev=35
     MinHealthBonus=25
     HealthBonusStep=25
     AbilityName="ÿArmor Regeneration"
     Description="Heals 2 armor per second per level. Does not heal past starting armor amount. You must have a Health Bonus stat equal to 25 times the ability level you wish to have before you can purchase it. |Cost (per level): 15,20,25,30,..."
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=10
}
