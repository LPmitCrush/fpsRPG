class RW_EnhancedPiercing extends RW_Piercing
	HideDropDown
	CacheExempt
	config(fpsRPG);

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();

	if(damage > 0)
	{
		Damage = Max(Damage, OriginalDamage); //smokes any reduction. This wont affect reduction because of skills though.
		//if I Ever think of coding up a "skill" that does damage reduction, I'll have to do math
		// here to increase the damage up enough that the reduction results in nothing.
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     PrefixNeg="Piercing "
}
