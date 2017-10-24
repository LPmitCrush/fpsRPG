class AbilityEnhancedReduction extends RPGAbility
	config(fpsRPG) 
	abstract;

var config int RequiredLevel;
var config float LevMultiplier;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool ok;

	for (x = 0; x < Data.Abilities.length && !ok; x++)
		if (Data.Abilities[x] == class'ClassMonsterMaster')
			ok = true;
	if(!ok)
	{
		if(CurrentLevel > 0)
			log("Warning:"@data.Name@"has"@default.class@"Level"@CurrentLevel@"but does not have an associated Class to allow them to purchase it");
		return 0;
	}
	
	if(Data.Level < (default.RequiredLevel + CurrentLevel))
		return 0;

	return Super.Cost(Data, CurrentLevel);
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(bOwnedByInstigator)
		return; //if the instigator is doing the damage, ignore this.
	if(Damage > 0)
		Damage *= (abs((AbilityLevel * default.LevMultiplier)-1));
}

defaultproperties
{
     RequiredLevel=40
     LevMultiplier=0.040000
     AbilityName="Advanced Damage Reduction"
     Description="Increases your cumulative total damage reduction by 4% per level. You must be a Medic / Monster Master to purchase this skill. Does not apply to self damage.|Cost (per level): 5. Max Level: 10. You must be level 40 to purchase the first level of this ability, level 41 to purchase the second level, and so on."
     StartingCost=5
     MaxLevel=10
}
