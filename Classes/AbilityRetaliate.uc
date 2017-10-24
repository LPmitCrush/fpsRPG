class AbilityRetaliate extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.Defense < 50)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (bOwnedByInstigator)
	{
		// do not allow this ability to kill another player
		if (DamageType == class'DamTypeRetaliation' && Damage >= Injured.Health + Injured.GetShieldStrength())
		{
			Damage = Injured.Health + Injured.GetShieldStrength() - 1;
		}
		return;
	}
	if (DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None)
		return;

	Instigator.TakeDamage(int(float(Damage) * (0.05 * AbilityLevel)), Injured, Instigator.Location, vect(0,0,0), class'DamTypeRetaliation');
}

defaultproperties
{
     AbilityName="Retaliation"
     Description="Whenever you are damaged by another player, 5% of the damage per level is also done to the player that hurt you. Your Damage Bonus stat and your opponent's Damage Reduction stat are applied to this extra damage. You can't retaliate to retaliation damage and retaliation damage will not kill the enemy by itself. You must have a Damage Reduction of at least 50 to purchase this ability. (Max Level: 25)"
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=25
}
