class RW_Piercing extends AUDRPGWeapon
	HideDropDown
	CacheExempt;

var class<DamageType> ModifiedDamageType;

function float GetAIRating()
{
	if (Bot(Instigator.Controller) != None && Bot(Instigator.Controller).Enemy.ShieldStrength > 0)
		return ModifiedWeapon.GetAIRating() + AIRatingBonus;

	return ModifiedWeapon.GetAIRating();
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	//ugly, but it works
	if (Pawn(Victim) != None && Pawn(Victim).ShieldStrength > 0 && DamageType.default.bArmorStops)
	{
		if (!bIdentified)
			Identify();
		DamageType.default.bArmorStops = false;
		ModifiedDamageType = DamageType;
	}
	
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

simulated function WeaponTick(float dt)
{
	if (ModifiedDamageType != None)
	{
		ModifiedDamageType.default.bArmorStops = true;
		ModifiedDamageType = None;
	}

	Super.WeaponTick(dt);
}

defaultproperties
{
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.PlayerTrans'
     AIRatingBonus=0.150000
     PrefixPos="Piercing "
}
