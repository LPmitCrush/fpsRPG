class AbilityDefenseSentinelEnergy extends EngineerAbility
	config(fpsRPG)
	abstract;

var int MinLev;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;
        local bool foundDefSentHealing;

	if(Data.Level < default.MinLev && CurrentLevel == 0)
		return 0;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
			ok = true;

        else if (Data.Abilities[x] == class'AbilityDefenseSentinelHealing')
		foundDefSentHealing = true;

	if(!ok || !foundDefSentHealing)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (DruidDefenseSentinel(Other) != None)
	    DruidDefenseSentinel(Other).AdrenalineHealingLevel = AbilityLevel;
}

defaultproperties
{
     MinLev=35
     AbilityName="ÿDefSent Energy Bonus"
     Description="Allows defense sentinels to supply adrenaline when they are not busy. Each level adds 1 to each healing shot.|Must have DefSent Healing to unlock this ability|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     MaxLevel=10
}
