class DruidRegen extends AbilityRegen
	config(fpsRPG) 
	abstract;

var config int AdjustableMultiplierPerLevel;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassWeaponsMaster' || Data.Abilities[x] == class'ClassMonsterMaster')
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

defaultproperties
{
     AdjustableMultiplierPerLevel=30
     Description="Heals 1 health per second per level. Does not heal past starting health amount. You must have a Health Bonus stat equal to 30 times the ability level you wish to have before you can purchase it. (Max Level: 5) You must be a Weapons Master or a Monster Master to purchase this skill.|Cost (per level): 15,20,25,30,35"
}
