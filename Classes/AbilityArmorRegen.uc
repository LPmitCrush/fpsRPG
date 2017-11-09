class AbilityArmorRegen extends CostRPGAbility
	abstract;

var int MinLev;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.ShieldMax < 50)
		return 0;
	else
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
     AbilityName="ÿ¹Armor Regeneration"
     Description="Heals 2 armor per second per level. Does not heal past starting armor amount. You must have a Health Bonus stat equal to 25 times the ability level you wish to have before you can purchase it. |Cost (per level): 15,20,25,30,..."
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=10
}
