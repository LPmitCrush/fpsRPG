class AbilityDefenseSentinelResupply extends EngineerAbility
	config(fpsRPG)
	abstract;

var int MinLev;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;
        local bool foundDefSentEnergy;

	if(Data.Level < default.MinLev && CurrentLevel == 0)
		return 0;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
			ok = true;

        else if (data.abilities[x] == class'AbilityDefenseSentinelEnergy')
		foundDefSentEnergy = true;

	if(!ok || !foundDefSentEnergy)
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
	    DruidDefenseSentinel(Other).ResupplyLevel = AbilityLevel;
}

defaultproperties
{
     MinLev=40
     AbilityName="ÿDefSent Resupply"
     Description="Allows defense sentinels to grant ammo resupply when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     MaxLevel=10
}
