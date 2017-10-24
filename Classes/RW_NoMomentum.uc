class RW_NoMomentum extends AUDRPGWeapon
	HideDropDown
	CacheExempt;


function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();
	if(damage > 0)
		Momentum = vect(0,0,0);

	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     ModifierOverlay=Shader'UT2004Weapons.Shaders.ShockHitShader'
     PrefixPos="Sturdy "
     PrefixNeg="Sturdy "
}
