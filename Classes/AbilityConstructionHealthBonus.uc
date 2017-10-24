class AbilityConstructionHealthBonus extends EngineerAbility
	config(fpsRPG)
	abstract;

var config float HealthBonus;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length; x++)
		if (Data.Abilities[x] == class'ClassEngineer')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	return super.Cost(Data, CurrentLevel);
}

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	Other.HealthMax += Other.HealthMax * (Default.HealthBonus * AbilityLevel);
	Other.Health += Other.Health * (Default.HealthBonus * AbilityLevel);
	Other.SuperHealthMax += Other.SuperHealthMax * (Default.HealthBonus * AbilityLevel);
}

defaultproperties
{
     HealthBonus=0.200000
     AbilityName="Constructions: Health Bonus"
     Description="Gives an additional health bonus to your summoned constructions. Each level adds 20% health to your construction's max health. (Max Level: 10)|You must be an Engineer to purchase this skill.|Cost (per level): 2,4,6,8,10,12,14,16,18,20"
     StartingCost=2
     CostAddPerLevel=2
     MaxLevel=10
}
