//Regeneration ability
class AbilityRegen extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.HealthBonus < 30 * (CurrentLevel + 1))
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local RegenInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	//remove old one, if it exists
	//might happen if player levels up this ability while still alive
	Inv = Other.FindInventoryType(class'RegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'RegenInv', Other,,,rot(0,0,0));
	R.RegenAmount = AbilityLevel;
	R.GiveTo(Other);
}

defaultproperties
{
     AbilityName="Regeneration"
     Description="Heals 1 health per second per level. Does not heal past starting health amount. You must have a Health Bonus stat equal to 30 times the ability level you wish to have before you can purchase it. (Max Level: 10)"
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=10
}
