class AbilityCounterShove extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.Defense < 50)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float MomentumMod;

	if (bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None)
		return;

	//negative values to reverse direction
	if (AbilityLevel < 5)
		MomentumMod = - (0.25 * AbilityLevel);
	else
		MomentumMod = -1.50;

	Instigator.TakeDamage(0, Injured, Instigator.Location, (Momentum * Injured.Mass) * MomentumMod, class'DamTypeRetaliation');
}

defaultproperties
{
     AbilityName="ÿCounterShove"
     Description="Whenever you are damaged by another player, 25% of the momentum per level (or 150% at level 5) is also done to the player who hurt you. Will not CounterShove a CounterShove. You must have a Damage Reduction of at least 50 to purchase this ability. (Max Level: 5)"
     StartingCost=15
     MaxLevel=5
}
