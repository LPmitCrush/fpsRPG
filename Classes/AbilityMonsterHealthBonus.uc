class AbilityMonsterHealthBonus extends MonsterAbility
	config(fpsRPG)
	abstract;

var config float HealthBonus;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
		if (Data.Abilities[x] == class'ClassMonsterMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return super.Cost(Data, CurrentLevel);
}

static simulated function ModifyMonster(Monster Other, int AbilityLevel)
{
	Other.HealthMax += Other.HealthMax * (Default.HealthBonus * AbilityLevel);
	Other.Health += Other.Health * (Default.HealthBonus * AbilityLevel);
}

defaultproperties
{
     HealthBonus=0.100000
     AbilityName="Summons: Health Bonus"
     Description="Gives an additional health bonus to your summoned monsters. Each level adds 10% health to your monster's max health. (Max Level: 10)|You must be a Monster Master to purchase this skill.|Cost (per level): 2,6,10,14,18,22,26,30,34,38"
     StartingCost=2
     CostAddPerLevel=4
     MaxLevel=10
}
