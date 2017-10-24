class RW_Infinity extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fpsRPG);


static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if ( Weapon.default.FireModeClass[0] != None && Weapon.default.FireModeClass[0].default.AmmoClass != None
	          && class'MutfpsRPG'.static.IsSuperWeaponAmmo(Weapon.default.FireModeClass[0].default.AmmoClass) )
		return false;

	return true;
}

simulated function bool StartFire(int Mode)
{
	if (!bIdentified && Role == ROLE_Authority)
		Identify();

	return Super.StartFire(Mode);
}

function bool ConsumeAmmo(int Mode, float Load, bool bAmountNeededIsMax)
{
	if (!bIdentified)
		Identify();

	return true;
}

simulated function WeaponTick(float dt)
{
	MaxOutAmmo();

	Super.WeaponTick(dt);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();
	if(damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 +DamageBonus * Modifier;
	}
}

defaultproperties
{
     ModifierOverlay=Shader'XGameShaders.BRShaders.BombIconRS'
     AIRatingBonus=0.050000
     PostfixPos=" of Infinity"
     PostfixNeg=" of Infinity"
}
