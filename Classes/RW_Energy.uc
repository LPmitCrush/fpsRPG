class RW_Energy extends AUDRPGWeapon
	HideDropDown
	CacheExempt;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if (Other.Controller != None && Other.Controller.bAdrenalineEnabled)
		return true;

	return false;
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local float AdrenalineBonus;

	if (Pawn(Victim) == None)
		return;

	if (!bIdentified)
		Identify();

	if (Damage > Pawn(Victim).Health)
		AdrenalineBonus = Pawn(Victim).Health;
	else
		AdrenalineBonus = Damage;
	AdrenalineBonus *= 0.02 * Modifier;

	if ( UnrealPlayer(Instigator.Controller) != None && Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax
	     && Instigator.Controller.Adrenaline + AdrenalineBonus >= Instigator.Controller.AdrenalineMax && !Instigator.InCurrentCombo() )
		UnrealPlayer(Instigator.Controller).ClientDelayedAnnouncementNamed('Adrenalin', 15);
	Instigator.Controller.Adrenaline = FMin(Instigator.Controller.Adrenaline + AdrenalineBonus, Instigator.Controller.AdrenalineMax);
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.LightningHit'
     AIRatingBonus=0.020000
     PostfixPos=" of Energy"
     PrefixNeg="Draining "
}