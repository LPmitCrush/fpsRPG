class RW_Penetrating extends AUDRPGWeapon
	HideDropDown
	CacheExempt;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	local int x;

	for (x = 0; x < NUM_FIRE_MODES; x++)
		if (class<InstantFire>(Weapon.default.FireModeClass[x]) != None)
			return true;

	return false;
}

function SetModifiedWeapon(Weapon w, bool bIdentify)
{
	Super.SetModifiedWeapon(w, bIdentify);

	if (InstantFire(FireMode[0]) != None && InstantFire(FireMode[1]) != None)
		AIRatingBonus *= 1.2;
}

function AdjustTargetDamage(out int Damage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local int i;
	local vector X, Y, Z, StartTrace;

	if (HitLocation == vect(0,0,0))
		return;

	for (i = 0; i < NUM_FIRE_MODES; i++)
		if (InstantFire(FireMode[i]) != None && InstantFire(FireMode[i]).DamageType == DamageType)
		{
			if (!bIdentified)
				Identify();
			//HACK - compensate for shock rifle not firing on crosshair
			if (ShockBeamFire(FireMode[i]) != None && PlayerController(Instigator.Controller) != None)
			{
				StartTrace = Instigator.Location + Instigator.EyePosition();
				GetViewAxes(X,Y,Z);
				StartTrace = StartTrace + X*class'ShockProjFire'.Default.ProjSpawnOffset.X;
				if (!WeaponCentered())
					StartTrace = StartTrace + Hand * Y*class'ShockProjFire'.Default.ProjSpawnOffset.Y + Z*class'ShockProjFire'.Default.ProjSpawnOffset.Z;
				InstantFire(FireMode[i]).DoTrace(HitLocation + Normal(HitLocation - StartTrace) * Victim.CollisionRadius * 2, rotator(HitLocation - StartTrace));
			}
			else
				InstantFire(FireMode[i]).DoTrace(HitLocation + Normal(HitLocation - (Instigator.Location + Instigator.EyePosition())) * Victim.CollisionRadius * 2, rotator(HitLocation - (Instigator.Location + Instigator.EyePosition())));
			return;
		}

    super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.PlayerTrans'
     AIRatingBonus=0.080000
     PrefixPos="Penetrating "
}
