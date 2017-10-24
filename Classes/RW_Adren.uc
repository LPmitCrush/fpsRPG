class RW_Adren extends OneDropRPGWeapon
	HideDropDown
	CacheExempt;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
  	if ( ClassIsChildOf(Weapon, class'MiniGun') || ClassIsChildOf(Weapon, class'FlakCannon'))
		return true;
}

function bool HasActiveArtifact(Pawn Other)
{
	local Inventory Inv;

	for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv.IsA('RPGArtifact') && RPGArtifact(Inv).bActive)
		{
			return true;
		}
	}

	return false;
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;

	if ( ClassIsChildOf(DamageType, class'DamTypeMinigunBullet') || ClassIsChildOf(DamageType, class'DamTypeFlakChunk') && !HasActiveArtifact(Instigator) )
         {

		P = Pawn(Victim);
		if (P != None && ( P == Instigator || (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None) )  && !HasActiveArtifact(P))
		{
                	if(Instigator != None && Instigator.PlayerReplicationInfo != None && P != None && PlayerController(P.Controller) != None && (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None) )
			P.Controller.AwardAdrenaline(Modifier);
			P.SetOverlayMaterial(ModifierOverlay, 1.0, false);
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'AdrenConditionMessage', 0, Instigator.PlayerReplicationInfo);
			Damage = 0;
			Momentum = vect(0,0,0);
		}

	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     ModifierOverlay=TexPanner'XEffectMat.Combos.RedBoltPanner'
     MaxModifier=50
     AIRatingBonus=0.020000
     PrefixPos="Infinity Adrenal "
}
