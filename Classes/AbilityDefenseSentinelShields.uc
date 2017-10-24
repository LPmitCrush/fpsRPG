class AbilityDefenseSentinelShields extends EngineerAbility
	config(fpsRPG)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).ShieldHealingLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="ÿDefSent Shield healing"
     Description="Allows defense sentinels to heal shields when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     MaxLevel=10
}
