class RW_Vampire extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);

var config float VampireAmount;

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();

	if(damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}
	
	if(Pawn(Victim) == None)
		return;

	Class'AbilityVampire'.static.HandleDamage(Damage, Pawn(Victim), Instigator, Momentum, DamageType, true, Float(Modifier) * VampireAmount);

        super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     VampireAmount=0.750000
     ModifierOverlay=Shader'WeaponSkins.ShockLaser.LaserShader'
     AIRatingBonus=0.080000
     PrefixPos="Vampiric "
}
