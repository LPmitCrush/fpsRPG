class DruidAdrenalineSurge extends AbilityAdrenalineSurge
	config(fpsRPG) 
	abstract;

var config int AdjustableStartingDamage, AdjustableStartingAdrenaline;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local bool ok;
	local int x;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassAdrenalineMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}

	if (Data.AdrenalineMax < default.AdjustableStartingAdrenaline || Data.Attack < default.AdjustableStartingDamage)
		return 0;

	return super.Cost(Data, CurrentLevel);
}

defaultproperties
{
     AdjustableStartingDamage=50
     AdjustableStartingAdrenaline=150
     Description="For each level of this ability, you gain 50% more adrenaline from all kill related adrenaline bonuses. You must have a Damage Bonus of at least 50 and an Adrenaline Max stat at least 150 to purchase this ability. (Max Level: 2) You must be an Adrenaline Master to purchase this skill.|Cost (per level): 2,8"
     StartingCost=2
     CostAddPerLevel=6
}
