class AbilityEnhancedDamage extends RPGAbility
	config(fpsRPG) 
	abstract;

var config int RequiredLevel;
var config float LevMultiplier;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.Attack < 250)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator)
		return;
	if(Damage > 0)
		Damage *= (1 + (AbilityLevel * default.LevMultiplier));
}

defaultproperties
{
     RequiredLevel=75
     LevMultiplier=0.015000
     AbilityName="ÿmAdvanced Damage Bonus"
     Description="Increases your cumulative total damage bonus by 1.5% per level. You must be a Weapons Master to purchase this skill.|Cost (per level): 5. Max Level: 10. You must be level 75 to purchase the first level of this ability, level 76 to purchase the second level, and so on."
     StartingCost=5
     MaxLevel=10
}
