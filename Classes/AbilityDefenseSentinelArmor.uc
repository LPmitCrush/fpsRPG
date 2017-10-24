class AbilityDefenseSentinelArmor extends EngineerAbility
	config(fpsRPG)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).ArmorHealingLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="ÿDefSent Armor healing"
     Description="Allows defense sentinels to heal armor when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     MaxLevel=10
}
