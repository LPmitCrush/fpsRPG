class DruidArmorRegen extends RPGAbility
	config(fpsRPG) 
	abstract;

var config int AdjustableMultiplierPerLevel;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	if (Data.HealthBonus < default.AdjustableMultiplierPerLevel * (CurrentLevel + 1))
		return 0;
	
	return super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local DruidArmorRegenInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	Inv = Other.FindInventoryType(class'DruidArmorRegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'DruidArmorRegenInv', Other,,,rot(0,0,0));
	R.RegenAmount = AbilityLevel;
	R.GiveTo(Other);
}

defaultproperties
{
     AdjustableMultiplierPerLevel=30
     AbilityName="Armor Regeneration"
     Description="Heals 1 armor per second per level. Does not heal past starting armor amount. You must have a Health Bonus stat equal to 30 times the ability level you wish to have before you can purchase it. (Max Level: 5) You must be an Engineer to purchase this skill.|Cost (per level): 15,20,25,30,35"
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=5
}
